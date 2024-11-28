class_name Obstacle
extends CharacterBody2D

const direction = Vector2(-1, 0)

enum ObstacleType {JUMP, CRAWL}

@export var word_label: Label
@export var target_container: Container
@export var type: ObstacleType = ObstacleType.JUMP
@export var sprite: Sprite2D
@export var collision_shape: CollisionShape2D
@export var visible_on_screen: VisibleOnScreenNotifier2D

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
	visible_on_screen.screen_exited.connect(queue_free)
	target_container.set_theme(PlayerConfig.get_theme())
	chosen_texture = textures.pick_random()
	set_textures()


##Set up appropriate visual and collisions for randomly selected texture
func set_textures() -> void:

	sprite.texture = chosen_texture.texture
	sprite.scale = chosen_texture.req_scale
	sprite.position = chosen_texture.req_offset

	collision_shape.shape = chosen_texture.collider
	collision_shape.position = chosen_texture.collidor_pos


func parse_targets(upcoming_word: Array[Dictionary]) -> void:
	#Get obstacle data
	var target_words: PackedStringArray = []
	var point_value: int = 0
	var hints: PackedStringArray = []
	for word in upcoming_word:
		@warning_ignore("unsafe_call_argument")
		target_words.append(word["word"])
		point_value += word["score"]
		@warning_ignore("unsafe_call_argument")
		hints.append(word["hint"])
	var separator: String = " "
	var final_target: String = separator.join(target_words)
	var final_hint: String = separator.join(hints)

	#Set obstacle data
	set_target_word(final_target)
	score = point_value
	hint = final_hint
	number_of_targets = upcoming_word.size()



##Set and display target word on label
func set_target_word(target: String) -> void:
	target_word = target
	word_label.set_text(target_word)


##Move obstacle
func _physics_process(_delta: float) -> void:
	if not stopped:
		velocity = direction * speed * speed_modifier
		move_and_slide()


##Adjust the starting position of an obstacle based on how late it is relative to the expected start time
func adjust_position(time_offset: float) -> void:
	var distance_to_adjust: Vector2 = direction * speed * speed_modifier * time_offset
	position = distance_to_adjust + position


##Set visibility of the target word
func hide_target(target_hidden: bool) -> void:
	target_container.visible = !target_hidden


func get_total_score() -> int:
	return score


func get_total_number_of_targets() -> int:
	return number_of_targets


func get_current_number_of_targets() -> int:
	return number_of_targets


##Speak word with TTS
func speak_words() -> void:
	PlayerConfig.speak_tts(target_word)
