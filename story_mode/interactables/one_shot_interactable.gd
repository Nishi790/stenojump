@tool
class_name OneShotInteractable
extends BaseInteractable

var has_interacted = false


func _interact() -> void:
	super()
	has_interacted = true


func set_ready_to_interact(value: bool) -> void:
	if not has_interacted:
		super(value)
	else:
		super(false)
