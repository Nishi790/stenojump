class_name Obstacle
extends CharacterBody2D

const direction = Vector2(-1, 0)

enum ObstacleType {JUMP, CRAWL}

@export var word_label: Label
@export var target_container: Container
@export var type: ObstacleType = ObstacleType.JUMP
@export var sprite: Sprite2D

@export var textures: Array[ObstacleSpriteData]

var chosen_texture: ObstacleSpriteData

var target_word: String
var score: int
var hint: String
var number_of_targets: int
var speed: float = 200.0
var speed_modifier: float = 1.0
var stopped: bool = false

func _ready() -> void:
	target_container.set_theme(PlayerConfig.get_theme())
	set_textures()



func set_textures() -> void:
	chosen_texture = textures.pick_random()
	sprite.texture = chosen_texture.texture
	sprite.scale = chosen_texture.req_scale
	sprite.position = chosen_texture.req_offset


func set_target_word(target: String) -> void:
	target_word = target
	word_label.set_text(target_word)


func _physics_process(delta: float) -> void:
	if not stopped:
		velocity = direction * speed * speed_modifier
		move_and_slide()
	if position.x <= -10:
		queue_free()


func reset_word() -> void:
	position.x = get_viewport_rect().size.x


func hide_target(target_hidden: bool) -> void:
	target_container.visible = !target_hidden


func speak_words() -> void:
	PlayerConfig.speak_tts(target_word)
