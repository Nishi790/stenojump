@tool
class_name ToggleInteractable
extends BaseInteractable

@export var toggle_value: bool


func _interact() -> void:
	super()


func complete_interact(_animation_name: StringName) -> void:
	toggle_value = not toggle_value
	for event in interact_events:
		tried_event.emit(event, toggle_value)
	await animation_controller.play_animation("interact")
	set_ready_to_interact(true)

#
#func select_interact_anim() -> bool:
	#if toggle_value == true:
		#if animation_frames.has_animation("interact"):
			#sprite.play("interact")
			#return true
		#else:
			#return false
	#elif toggle_value == false:
		#if animation_frames.has_animation("reverse_interact"):
			#sprite.play("reverse_interact")
			#return true
		#elif animation_frames.has_animation("interact"):
			#sprite.play("interact")
			#return true
	#return false
#
#
#func return_to_idle()-> void:
	#if toggle_value:
		#if animation_frames.has_animation("idle_after_interact"):
			#sprite.play("idle_after_interact")
		#else:
			#sprite.play("idle")
	#else:
		#sprite.play("idle")
#
	#if ready_to_interact == false:
		#set_ready_to_interact(true)
