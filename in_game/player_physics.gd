class_name PlayerPhysics
extends CharacterBody2D

signal collision (collision: KinematicCollision2D)
signal state_changed (new_state: int, time_of_flight: int)
signal stand_up_triggered

enum Colliders {RUN, JUMP, CRAWL}

@export var run_coll_shape: CollisionShape2D
@export var jump_coll_shape: CollisionShape2D
@export var crawl_coll_shape: CollisionShape2D

const X_RETURN_VEL = 200.0
const JUMP_VELOCITY = -500.0

var time_of_flight: float
var ground_height: float
var take_off_height: float


var on_floor: bool = false
var remaining_flight_time: float = 0
var active_collider: Colliders
var target_x_pos: float


func _ready() -> void:
	change_colliders(Colliders.RUN)
	target_x_pos = position.x


func _physics_process(delta: float) -> void:
	#Reset horizontal movement
	velocity.x = 0

	#Add gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	if position.x != target_x_pos:
		var x_dist: float = target_x_pos - position.x
		var x_vel: float = x_dist/delta
		if absf(x_vel) > X_RETURN_VEL:
			velocity.x = sign(x_vel) * X_RETURN_VEL
		else:
			velocity.x = x_vel
	move_and_slide()
	if get_last_slide_collision() != null:
		collision.emit(get_last_slide_collision())
		#this is a hacky way to determine basic ground height
		#will break if the ground level ever changes during a level
		if ground_height == null:
			ground_height = position.y


func jump() -> void:
	on_floor = false
	velocity.y = JUMP_VELOCITY
	take_off_height = position.y
	var flight_height_change: float = ground_height - take_off_height
	var half_grav: float = get_gravity().y * 0.5
	var quadratic_root: float = sqrt(velocity.y ** 2 - 4 * half_grav * flight_height_change)
	var flight_time_1: float = (-velocity.y + quadratic_root)/get_gravity().y
	var flight_time_2: float = (-velocity.y - quadratic_root)/get_gravity().y
	time_of_flight = maxf(flight_time_1, flight_time_2)
	state_changed.emit(1, time_of_flight)
	change_colliders(Colliders.JUMP)


func stop_jump()-> void:
	velocity.y = 0
	set_deferred("position", Vector2.ZERO)
	change_colliders(Colliders.RUN)


func stand_up() -> void:
	stand_up_triggered.emit()


func change_colliders(activating_collider: Colliders) -> void:
	match activating_collider:
		Colliders.RUN:
			active_collider = Colliders.RUN
			jump_coll_shape.set_deferred("disabled", true)
			run_coll_shape.set_deferred("disabled", false)
			crawl_coll_shape.set_deferred("disabled", true)
		Colliders.CRAWL:
			active_collider = Colliders.CRAWL
			jump_coll_shape.set_deferred("disabled", true)
			run_coll_shape.set_deferred("disabled", true)
			crawl_coll_shape.set_deferred("disabled", false)
		Colliders.JUMP:
			active_collider = Colliders.JUMP
			jump_coll_shape.set_deferred("disabled", false)
			run_coll_shape.set_deferred("disabled", true)
			crawl_coll_shape.set_deferred("disabled", true)


func disable_obstacle_collision(disable: bool) -> void:
	if disable:
		call_deferred("set_collision_layer_value", 3, false)
	else:
		call_deferred("set_collision_layer_value", 3, true)
