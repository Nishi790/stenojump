@tool
class_name BaseInteractable
extends Waypoint

var ready_to_interact: bool = false
var interactor: SelfNavCharacter = null

@export var animation: AnimatedSprite2D
@export var animation_offset: Vector2:
	set(new_offset):
		animation_offset = new_offset
		if animation:
			animation.offset = animation_offset
@export var collision_shape: Shape2D:
	set(shape):
		collision_shape = shape
		if get_node_or_null("CollisionShape2D") != null:
			$CollisionShape2D.shape = null
			$CollisionShape2D.shape = shape
@export var interaction_anim_name: String = ""
@export var interact_end_pos: Vector2 = Vector2.ZERO:
	set(new_pos):
		interact_end_pos = new_pos
		if Engine.is_editor_hint():
			queue_redraw()
@export var at_height: bool = false
@export var animation_frames: SpriteFrames:
	set(new_frames):
		animation_frames = new_frames
		if animation:
			animation.sprite_frames = animation_frames
			animation.play("idle")
@export var interact_events: Array[String]

func _ready() -> void:
	super()
	animation.animation_finished.connect(return_to_idle)


func _draw() -> void:
	super()
	if Engine.is_editor_hint():
		draw_circle(interact_end_pos, 2, Color.YELLOW)


##Virtual function implemented by all interactables to complete the interaction (play animations, call 'complete interaction'
##Complete interaction is for actions by the interactable that should only be completed once the player animation is finished
func _interact() -> void:
	var global_target_pos: Vector2 = to_global(interact_end_pos)
	interactor.interact(interaction_anim_name, global_target_pos)
	interactor.animations.animation_finished.connect(complete_interact, CONNECT_ONE_SHOT)
	set_ready_to_interact(false)


func complete_interact() -> void:
	if animation_frames.has_animation("interact"):
		animation.play("interact")
	else:
		return_to_idle()
	for event_name in interact_events:
		tried_event.emit(event_name, true)


func return_to_idle() -> void:
	if animation_frames.has_animation("idle_after_interact"):
		animation.play("idle_after_interact")
	else:
		animation.play("idle")


#To connect to signal for interactables that have a different state after interact only until Socks leaves
func reset_idle() -> void:
	animation.play("idle")


func initiate_words(area: Area2D)  -> void:
	super(area)
	if area.get_parent() is SelfNavCharacter:
		var character: SelfNavCharacter = area.get_parent()
		interactor = character
		set_ready_to_interact(true)


func set_ready_to_interact(value: bool) -> void:
	ready_to_interact = value
	if target_data.is_empty() and ready_to_interact:
		request_target_word.emit()
	if value:
		target_label.add_theme_color_override("default_color",Color.YELLOW)
	else: target_label.remove_theme_color_override("default_color")


func hide_words(area: Area2D) -> void:
	super(area)
	set_ready_to_interact(false)


##Respond to word entry
func word_entered() -> void:
	clear_target()
	if ready_to_interact:
		_interact()
	else:
		move_destination_selected.emit(self)
