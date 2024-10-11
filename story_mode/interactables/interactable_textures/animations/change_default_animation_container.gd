class_name ChangeDefaultAnimationContainer
extends AnimationContainer


@export var new_default: AnimationContainer

func _after_pre_animation_hook() -> void:
	default_changed.emit(new_default)
