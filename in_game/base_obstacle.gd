class_name Obstacle
extends CharacterBody2D

const direction = Vector2(-1, 0)

@export var word_label: Label

var target_word: String
var score: int
var hint: String
var number_of_targets: int
var speed: float = 200.0
var stopped: bool = false

func set_target_word(target: String) -> void:
	target_word = target
	word_label.set_text(target_word)


func _physics_process(delta: float) -> void:
	if not stopped:
		velocity = direction * speed + (Vector2(0, 5000) * delta)
		move_and_slide()
	if position.x <= -10:
		queue_free()


func reset_word() -> void:
	position.x = get_viewport_rect().size.x
