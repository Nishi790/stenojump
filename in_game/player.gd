class_name Player
extends Node2D

signal game_over
signal reset_word (collider: Object)
signal lives_changed (current_lives: int)
signal player_movement_changed (movement_type: State)
signal obstacle_in_range

enum State {WALKING, STARTING_JUMP, SOARING, ENDING_JUMP, RUNNING, CRAWLING, IDLING, DIE}

@export var sprite: AnimatedSprite2D
@export var physics_body: CharacterBody2D
@export var audio_player: AudioStreamPlayer2D
@export var range_area: Area2D
@export var jump_ray: RayCast2D

var data: RunnerSave

var speed: float
var lives: int = PlayerConfig.max_lives

var physics_position: Vector2
var in_air: bool = false
var movement_state: State = State.WALKING
var landing_timer: float = 0
var straight_to_landing: bool = false
var move_queue: Array[int] = []

var crawl_queued: bool = false
var jump_queued: bool = false
var dist_remaining: float = -999
var obst_speed: int


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	physics_body.collision.connect(on_collision)
	physics_body.state_changed.connect(change_states)
	physics_body.stand_up_triggered.connect(stand_up)
	sprite.animation_finished.connect(link_animation)
	var gravity_magnitude : int = ProjectSettings.get_setting("physics/2d/default_gravity")
	var ray_length: float = absf((200.0 * physics_body.JUMP_VELOCITY)/gravity_magnitude)
	jump_ray.target_position.x = ray_length

	start_walk()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	physics_position=physics_body.position
	sprite.set_position(physics_position)
	if landing_timer > 0:
		landing_timer -= delta
		if landing_timer < 0:
			landing_timer = 0
		if is_equal_approx(landing_timer, 0) or landing_timer < 0:
			change_states(State.ENDING_JUMP)
	match movement_state:
		State.WALKING:
			sprite.play("walk")
		State.RUNNING:
			sprite.play("run")
		State.SOARING:
			sprite.play("jump_glide")
		State.CRAWLING:
			sprite.play("crawl")
		State.STARTING_JUMP:
			sprite.play("jump_up")
		State.ENDING_JUMP:
			sprite.play("jump_down")
		State.IDLING:
			if sprite.animation != "idle":
				sprite.play("sit_down")
		State.DIE:
			sprite.play("die")


#Handle delayed jump for autojump
func _physics_process(delta: float) -> void:
	if jump_queued:
		if dist_remaining == -999 and jump_ray.is_colliding():
			var colliding_obstacle: Object = jump_ray.get_collider()
			var shape_id: int = jump_ray.get_collider_shape()
			var owner_id: int = colliding_obstacle.shape_find_owner(shape_id)
			var shape: Shape2D = colliding_obstacle.shape_owner_get_shape(owner_id, shape_id)
			if shape is RectangleShape2D:
				var inside_ray_amount: float = jump_ray.target_position.x - to_local(jump_ray.get_collision_point()).x
				dist_remaining = shape.get_size().x/2 - inside_ray_amount
			elif shape is CircleShape2D:
				var inside_ray_amount: float = jump_ray.target_position.x - to_local(jump_ray.get_collision_point()).x
				dist_remaining = shape.radius - inside_ray_amount
			obst_speed = colliding_obstacle.speed

		dist_remaining -= obst_speed * delta
		if dist_remaining != -999 and dist_remaining <= 0:
			jump()
			jump_queued = false
			dist_remaining = -999
			obst_speed = 0


##Called when player collides to cue death/game over if required
func on_collision(collision: KinematicCollision2D) -> void:
	if collision.get_collider().name=="Ground" or collision.get_collider().name == "Ceiling":
		return
	else:
		if data.current_lives > 0:
			data.current_lives -= 1
			reset_word.emit(collision.get_collider())
		else:
			game_over.emit()
			change_states(State.DIE)


##Called when a word is correctly entered, cues correct avoidance
##Adds actions to queue if currently unable to take an action
func avoid_obstacle(type: Obstacle.ObstacleType, new_action: bool = true) -> void:
	if movement_state == State.DIE:
		return

	#If currently crawyling, queue the action for when out of crawl zone
	elif movement_state == State.CRAWLING and new_action:
		move_queue.append(type)
		return

	match type:
		Obstacle.ObstacleType.JUMP:
			if check_jump_range():
				if PlayerConfig.autojump:
					jump_queued = true
				else:
					jump()
			else:
				jump()
		Obstacle.ObstacleType.CRAWL:
			crawl()
			obstacle_in_range.emit()


func check_jump_range() -> bool:
	##Check that the obstacle is in range
	var bodies_in_range: Array = range_area.get_overlapping_bodies()
	for body: Node2D in bodies_in_range:
		if body.is_in_group("obstacles"):
			obstacle_in_range.emit()
			return true
	return false


func jump() -> void:
	physics_body.jump()


func crawl() -> void:
	change_states(State.CRAWLING)


func link_animation() -> void:
	match sprite.animation:
		"jump_up":
			if straight_to_landing:
				change_states(State.ENDING_JUMP)
				straight_to_landing = false
			else:
				change_states(State.SOARING)
		"jump_down":
			change_states(State.RUNNING)
		"sit_down":
			sprite.play("idle")
		"die":
			change_states(State.IDLING)


func change_states(new_state: State, time_of_flight: float = -1) -> void:
	var old_state: State = movement_state
	if old_state == State.DIE and new_state != State.IDLING:
		return
	movement_state = new_state
	match new_state:
		State.WALKING, State.IDLING:
			if old_state == State.DIE:
				physics_body.disable_obstacle_collision(false)
			if physics_body.active_collider != 0:
				physics_body.change_colliders(0)
			player_movement_changed.emit(new_state)
		State.RUNNING:
			if physics_body.active_collider != 0:
				physics_body.change_colliders(0)
			if old_state == State.WALKING or old_state == State.IDLING:
				player_movement_changed.emit(new_state)
			if old_state == State.ENDING_JUMP:
				play_sfx("land")
				if crawl_queued:
					change_states(State.CRAWLING)
		State.STARTING_JUMP, State.ENDING_JUMP:
			if physics_body.active_collider != 1:
				physics_body.change_colliders(1)
			if time_of_flight > 0:
				calculate_jump_time(time_of_flight)
		State.CRAWLING:
			if old_state == State.ENDING_JUMP or old_state == State.SOARING or old_state == State.STARTING_JUMP:
				crawl_queued = true
				movement_state = old_state
			else:
				crawl_queued = false
				if physics_body.active_collider != 2:
					physics_body.change_colliders(2)
		State.DIE:
			if old_state == State.STARTING_JUMP or old_state == State.SOARING:
				physics_body.stop_jump()
			if physics_body.active_collider != 0:
				physics_body.change_colliders(0)
				physics_body.disable_obstacle_collision(true)
			player_movement_changed.emit(State.IDLING)



func calculate_jump_time(time_of_flight: float) -> void:
	var sprite_frames: SpriteFrames = sprite.sprite_frames
	var landing_anim_length: int = sprite_frames.get_frame_count("jump_down")
	var landing_anim_speed: float = sprite_frames.get_animation_speed("jump_down")
	var seconds_per_frame: float = 1/landing_anim_speed
	var time_needed_to_land: float = seconds_per_frame * landing_anim_length
	landing_timer = time_of_flight - time_needed_to_land
	if landing_timer < 0:
		straight_to_landing = true
		landing_timer = 0
	else: straight_to_landing = false


func start_run() -> void:
	if movement_state == State.WALKING or movement_state == State.IDLING:
		change_states(State.RUNNING)


func resume_movement() -> void:
	if movement_state == State.IDLING:
		start_walk()


func start_walk() -> void:
	change_states(State.WALKING)


func stand_up() -> void:
	if move_queue.is_empty():
		change_states(State.RUNNING)
	else:
		avoid_obstacle(move_queue.pop_front(), false)


func end_level() -> void:
	if movement_state == State.CRAWLING:
		await player_movement_changed
	data.current_lives = PlayerConfig.max_lives
	change_states(State.WALKING)


func play_sfx(effect: String) -> void:
	match effect:
		"land":
			audio_player.play()
