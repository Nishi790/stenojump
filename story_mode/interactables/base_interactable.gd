@tool
class_name BaseInteractable
extends Waypoint

var ready_to_interact: bool = false
var interactor: SelfNavCharacter = null

@export var animation: AnimatedSprite2D
@export var animation_offset: Vector2:
	set(new_offset):
		print("animation offset changed on %s" % name)
		animation_offset = new_offset
		if animation:
			print("Setting animation offset")
			animation.offset = animation_offset
@export var interaction_anim_name: String = ""
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


##Virtual function implemented by all interactables to complete the interaction (play animations, call 'complete interaction'
##Complete interaction is for actions by the interactable that should only be completed once the player animation is finished
func _interact() -> void:
	interactor.interact(interaction_anim_name)
	interactor.animations.animation_finished.connect(complete_interact, CONNECT_ONE_SHOT)
	set_ready_to_interact(false)


func complete_interact() -> void:
	if animation_frames.has_animation("interact"):
		animation.play("interact")
	else:
		return_to_idle()
	for event_name in interact_events:
		tried_event.emit(event_name, true)
	print("Interacted with %s" % self.name)


func return_to_idle() -> void:
	if animation_frames.has_animation("idle_after_interact"):
		animation.play("idle_after_interact")
	else:
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
