@tool
class_name BaseInteractable
extends Waypoint

signal failed_interact(dialogue_key: String)

var ready_to_interact: bool = false
var interactor: BaseSelfNavCharacter = null

@export var interaction_enabled: bool = true
@export var enable_requirement: String #Should be a specific event name
@export var fail_dialogue_key: String

@export var at_height: bool = false
@export var interact_events: Array[String]

@export_group("Animation")
@export var animation_controller: Animator
@export var audio_player: AudioStreamPlayer2D
@export var sprite: AnimatedSprite2D:
	set(new_sprite):
		sprite = new_sprite
		if animation_controller:
			animation_controller.sprite = sprite

@export var animation_offset: Vector2:
	set(new_offset):
		if not is_node_ready():
			await ready
		animation_offset = new_offset
		set_animation_offset()

@export var animation_frames: SpriteFrames:
	set(new_frames):
		animation_frames = new_frames
		if sprite:
			sprite.sprite_frames = animation_frames

@export var default_animation: AnimationContainer:
	set(default):
		default_animation = default
		if animation_controller:
			animation_controller.default_animation = default_animation
@export var animation_list: Dictionary: #string anim_name: AnimationContainer
	set(list):
		animation_list = list
		if animation_controller:
			animation_controller.animations = animation_list


@export var interaction_anim_name: String = ""
@export var interact_end_pos: Vector2 = Vector2.ZERO:
	set(new_pos):
		interact_end_pos = new_pos
		if Engine.is_editor_hint():
			queue_redraw()

@export_group("Collisions")
@export var collision_shape: Shape2D:
	set(shape):
		collision_shape = shape
		if get_node_or_null("CollisionShape2D") != null:
			$CollisionShape2D.shape = null
			$CollisionShape2D.shape = shape
@export var collision_position: Vector2:
	set(pos):
		collision_position = pos
		if get_node_or_null("CollisionShape2D") != null:
			$CollisionShape2D.position = pos


func _ready() -> void:
	super()
	animation_controller.audio_player = audio_player
	animation_controller.set_up()


func set_animation_offset() -> void:
	if sprite:
		sprite.offset = animation_offset


func _draw() -> void:
	super()
	if Engine.is_editor_hint():
		if interact_end_pos:
			draw_circle(interact_end_pos, 6, Color.YELLOW)
		var tex_rect: Rect2 = get_tex_rect()
		var local_rect: Rect2 = Rect2(to_local(tex_rect.position), tex_rect.size)
		draw_rect(local_rect, Color.BLUE, false, 4)


##Virtual function implemented by all interactables to complete the interaction (play animations, call 'complete interaction'
##Complete interaction is for actions by the interactable that should only be completed once the player animation is finished
func _interact() -> void:
	var global_target_pos: Vector2 = to_global(interact_end_pos)
	interactor.interact(interaction_anim_name, global_position.x + animation_offset.x, global_target_pos)
	interactor.animations.animation_finished.connect(complete_interact, CONNECT_ONE_SHOT)
	set_ready_to_interact(false)


func complete_interact(_animation_name: StringName) -> void:
	animation_controller.play_animation("interact")
	await animation_controller.post_animation_hook
	for event_name in interact_events:
		tried_event.emit(event_name, true)


func npc_interact(npc: BaseSelfNavCharacter) -> void:
	var old_interactor: BaseSelfNavCharacter = interactor
	interactor = npc
	_interact()
	await animation_controller.animation_changed
	interactor = old_interactor


#To connect to signal for interactables that have a different state after interact only until Socks leaves
func reset_idle() -> void:
	animation_controller.play_animation("idle")


func initiate_words(area: Area2D)  -> void:
	super(area)
	if area.get_parent() is Socks:
		var character: Socks = area.get_parent()
		interactor = character
		set_ready_to_interact(true)


func set_ready_to_interact(value: bool) -> void:
	ready_to_interact = value
	if target_data.is_empty() and ready_to_interact:
		request_target_word.emit()
	if value:
		target_label.add_theme_color_override("default_color", PlayerConfig.interact_font_color)
	else: target_label.remove_theme_color_override("default_color")


func hide_words(area: Area2D) -> void:
	super(area)
	set_ready_to_interact(false)
	animation_controller.play_default_animation()


##Respond to word entry
func word_entered() -> void:
	clear_target()
	if ready_to_interact and interaction_enabled:
		_interact()
	elif ready_to_interact:
		failed_interact.emit(fail_dialogue_key)
	else:
		move_destination_selected.emit(self)


#Return a rect containing the animation texture
func get_tex_rect() -> Rect2:
	var texture: Texture2D = animation_frames.get_frame_texture(sprite.animation, sprite.frame)
	var rect_size: Vector2 = texture.get_size() * sprite.scale
	var tex_pos: Vector2 = (sprite.position + sprite.offset) * sprite.scale - rect_size/2
	tex_pos = to_global(tex_pos)
	return Rect2(tex_pos, rect_size)


func enable_interact(event_name: String, _args: Array = []) -> void:
	if enable_requirement == event_name:
		interaction_enabled = not interaction_enabled
