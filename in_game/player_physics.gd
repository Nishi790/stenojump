extends CharacterBody2D

signal grounded
signal collision (collision: KinematicCollision2D)
signal state_changed (new_state: int, time_of_flight: int)

enum Colliders {RUN, JUMP, CRAWL}

@export var run_coll_shape: CollisionShape2D
@export var jump_coll_shape: CollisionShape2D
@export var crawl_coll_shape: CollisionShape2D

var time_of_flight: float
var ground_height: float
var take_off_height: float
const JUMP_VELOCITY = -500.0

var on_floor: bool = false
var remaining_flight_time: float = 0


func _ready() -> void:
	change_colliders(Colliders.RUN)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()
	if get_last_slide_collision()!= null:
		collision.emit(get_last_slide_collision())
		#this is a hacky way to determine basic ground height
		#will break if the ground level ever changes during a level
		if ground_height == null:
			ground_height = position.y
	if not on_floor:
		if is_on_floor():
			grounded.emit()
			on_floor = true
			change_colliders(Colliders.RUN)


func jump():
	on_floor = false
	velocity.y = JUMP_VELOCITY
	take_off_height = position.y
	var flight_height_change: float = ground_height - take_off_height
	var half_grav = get_gravity().y * 0.5
	var quadratic_root = sqrt(velocity.y ** 2 - 4 * half_grav * flight_height_change)
	var flight_time_1 = (-velocity.y + quadratic_root)/get_gravity().y
	var flight_time_2 = (-velocity.y - quadratic_root)/get_gravity().y
	time_of_flight = maxf(flight_time_1, flight_time_2)
	state_changed.emit(1, time_of_flight)
	change_colliders(Colliders.JUMP)


func change_colliders(activating_collider: Colliders):
	match activating_collider:
		Colliders.RUN:
			jump_coll_shape.set_deferred("disabled", true)
			run_coll_shape.set_deferred("disabled", false)
			crawl_coll_shape.set_deferred("disabled", true)
		Colliders.CRAWL:
			jump_coll_shape.set_deferred("disabled", true)
			run_coll_shape.set_deferred("disabled", true)
			crawl_coll_shape.set_deferred("disabled", false)
		Colliders.JUMP:
			jump_coll_shape.set_deferred("disabled", false)
			run_coll_shape.set_deferred("disabled", true)
			crawl_coll_shape.set_deferred("disabled", true)
