extends BaseSelfNavCharacter


func _ready() -> void:
	pass


func wake_up(target_pos: Vector2) -> void:
	animations.play("sleep")
	get_tree().create_timer(animations.current_animation_length).timeout
	animations.play("idle_down")
	await get_tree().create_timer(0.2).timeout
	var move_tween: Tween = create_tween()
	direction = target_pos - position
	direction_changed = true
	navigating = true
	var duration: float = direction.length()/speed
	move_tween.tween_property(self, "position", target_pos, duration)
	await move_tween.finished
	navigating = false
	select_animation()


func get_dressed(target_pos: Vector2) -> void:
	nav_to_coords(target_pos)
	#has_situational_idle = true
	#situational_idle = "dressing"


func nav_to_coords(target_pos: Vector2) -> bool:
	has_situational_idle = false
	super(target_pos)
	return true
