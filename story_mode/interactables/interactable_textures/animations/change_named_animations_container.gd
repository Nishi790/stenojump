class_name ChangeNamedAnimationsContainer
extends ChangeDefaultAnimationContainer


@export var changed_anims: Dictionary

func _before_post_animation_hook() -> void:
	change_animations.emit(changed_anims)
