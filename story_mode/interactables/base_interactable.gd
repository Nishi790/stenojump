@tool
class_name BaseInteractable
extends Waypoint

var ready_to_interact: bool = false
var interactor: SelfNavCharacter = null

@export var interaction_anim_name: String = ""


func _ready() -> void:
	super()


func _draw() -> void:
	super()


##Virtual function implemented by all interactables to complete the interaction (play animations, call 'complete interaction'
##Complete interaction is for actions by the interactable that should only be completed once the player animation is finished
func _interact() -> void:
	interactor.interact(interaction_anim_name)
	interactor.animations.animation_finished.connect(complete_interact, CONNECT_ONE_SHOT)
	set_ready_to_interact(false)


func complete_interact() -> void:
	print("Interacted with %s" % self.name)


func initiate_words(area: Area2D)  -> void:
	super(area)
	if area.get_parent() is SelfNavCharacter:
		var character: SelfNavCharacter = area.get_parent()
		interactor = character
		set_ready_to_interact(true)
		if target_data.is_empty():
			request_target_word.emit()


func set_ready_to_interact(value: bool) -> void:
	ready_to_interact = value
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
