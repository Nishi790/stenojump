extends BaseSelfNavCharacter

@export var interest_points: Dictionary


func _ready() -> void:
	pass


func wake_up(target_pos: Vector2) -> void:
	animations.play("sleep")
	await animations.animation_looped
	animations.play("idle_down")
	await animations.frame_changed
	var move_tween: Tween = create_tween()
	direction = target_pos - position
	direction_changed = true
	navigating = true
	var duration: float = direction.length()/speed
	move_tween.tween_property(self, "position", target_pos, duration)
	await move_tween.finished
	navigating = false
	select_animation()


func get_dressed() -> void:
	var target_pos: Vector2 = interest_points["dresser"]
	nav_to_interest_point(target_pos)
	has_situational_idle = true
	situational_idle = "dressing"


func nav_to_interest_point(target_pos: Vector2) -> void:
	super(target_pos)
	has_situational_idle = false
