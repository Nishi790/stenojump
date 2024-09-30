@tool
class_name ToggleInteractable
extends BaseInteractable

@export var toggle_value: bool


func _interact() -> void:
	super()


func complete_interact() -> void:
	toggle_value = not toggle_value
	if not select_interact_anim():
		set_ready_to_interact(true)
	for event in interact_events:
		tried_event.emit(event, toggle_value)


func select_interact_anim() -> bool:
	if toggle_value == true:
		if animation_frames.has_animation("interact"):
			animation.play("interact")
			return true
		else:
			return false
	elif toggle_value == false:
		if animation_frames.has_animation("reverse_interact"):
			animation.play("reverse_interact")
			return true
		elif animation_frames.has_animation("interact"):
			animation.play("interact")
			return true
	return false


func return_to_idle()-> void:
	if toggle_value:
		if animation_frames.has_animation("idle_after_interact"):
			animation.play("idle_after_interact")
		else:
			animation.play("idle")
	else:
		animation.play("idle")

	if ready_to_interact == false:
		set_ready_to_interact(true)
