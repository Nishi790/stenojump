extends CharacterBody2D

signal grounded
signal collision (KinematicCollision2D)

const SPEED = 300.0
const JUMP_VELOCITY = -600.0

var on_floor: bool = false

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()
	if get_last_slide_collision()!= null:
		collision.emit(get_last_slide_collision())
	if not on_floor:
		if is_on_floor():
			grounded.emit()
			on_floor = true


func jump():
	if is_on_floor():
		on_floor = false
		velocity.y = JUMP_VELOCITY
	return
