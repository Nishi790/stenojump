class_name Player
extends Node2D

signal game_over
signal reset_word (Object)
signal lives_changed (int)

enum State {WALKING, STARTING_JUMP, SOARING, ENDING_JUMP, RUNNING, CRAWLING, IDLING}

@export var sprite: AnimatedSprite2D
@export var physics_body: CharacterBody2D

var speed: float
var lives: int = 3

var physics_position: Vector2
var in_air: bool = false
var movement_state: State = State.WALKING :
	set(state):
		movement_state = state
var landing_timer: float = 0
var straight_to_landing: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	physics_body.collision.connect(on_collision)
	physics_body.state_changed.connect(change_states)
	sprite.animation_finished.connect(link_animation)
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
	#control animations here


func on_collision(collision: KinematicCollision2D):
	if collision.get_collider().name=="Ground" or collision.get_collider().name == "Ceiling":
		return
	else:
		if lives>0:
			lives=lives-1
			reset_word.emit(collision.get_collider())
			lives_changed.emit(lives)
		else:
			game_over.emit()
			change_states(State.IDLING)


func jump():
	physics_body.jump()


func link_animation():
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


func change_states(new_state: State, time_of_flight: float = -1):
	movement_state = new_state
	match new_state:
		State.WALKING, State.RUNNING, State.IDLING:
			if physics_body.active_collider != 0:
				physics_body.change_colliders(0)
		State.STARTING_JUMP, State.ENDING_JUMP:
			if physics_body.active_collider != 1:
				physics_body.change_colliders(1)
		State.CRAWLING:
			if physics_body.active_collider != 2:
				physics_body.change_colliders(2)
	if time_of_flight > 0:
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


func start_run():
	if movement_state == State.WALKING or movement_state == State.IDLING:
		change_states(State.RUNNING)


func start_walk():
	change_states(State.WALKING)


func end_level():
	await get_tree().create_timer(1).timeout
	change_states(State.WALKING)
