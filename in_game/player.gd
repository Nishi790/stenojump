class_name Player
extends Node2D

signal game_over
signal reset_word (Object)
signal lives_changed (int)

@export var sprite: AnimatedSprite2D
@export var physics_body: CharacterBody2D

var speed: float
var lives: int = 3

var physics_position: Vector2
var in_air: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	physics_body.grounded.connect(land)
	physics_body.collision.connect(on_collision)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	physics_position=physics_body.position
	sprite.set_position(physics_position)
	#control animations here


func on_collision(collision: KinematicCollision2D):
	if collision.get_collider().name=="Ground":
		return
	else:
		print_debug("Collided with obstacle")
		if lives>0:
			lives=lives-1
			reset_word.emit(collision.get_collider())
			lives_changed.emit(lives)
		else:
			game_over.emit()


func jump():
	physics_body.jump()
	in_air=true


func land():
	in_air = false
