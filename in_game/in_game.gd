extends Node2D

signal score_changed (int)
signal words_left_changed (int)

@export var obstacle_manager: ObstacleManager
@export var player: Player
@export var input_box: LineEdit
@export var hud: HUD
@export var background: BackgroundManager

var selected_level: String = "res://in_game/level_data/lapwing_1.json"
var word_queue: Array
var next_word_index: int = 0
var new_word_interval: float = 3 #seconds until next word
var current_text: String
var target_word: String

var score: int = 0:
	set(new_score):
		score = new_score
		score_changed.emit(score)
var words_left: int:
	set(number_of_words):
		words_left = number_of_words
		words_left_changed.emit(words_left)
var level_complete: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Set up obstacle manager
	obstacle_manager.new_word_needed.connect(send_new_word)
	obstacle_manager.words_returned.connect(return_words_to_queue)
	obstacle_manager.score_changed.connect(adjust_score)
	obstacle_manager.obstacle_queue_emptied.connect(on_obstacle_queue_empty)
	obstacle_manager.new_target_word.connect(set_target_word)

	#Connect player signals
	player.reset_word.connect(reset_word)
	player.game_over.connect(game_over)
	player.lives_changed.connect(hud.lives_counter.update_lives_counter)
	hud.lives_counter.update_lives_counter(player.lives)

	#Connect HUD Signals
	score_changed.connect(hud.score_counter.update_score_text)
	words_left_changed.connect(hud.word_counter.update_word_count)
	input_box.text_changed.connect(update_text)
	input_box.text_submitted.connect(go_to_next_level)

	#load level 1
	LevelLoader.load_level(selected_level)
	load_level_data()

	input_box.grab_focus()


func send_new_word():
	if word_queue.size() == next_word_index:
		return
	else:
		obstacle_manager.add_word(word_queue[next_word_index])
		next_word_index += 1


func reset_word(collider: Object):
#Pause Word Generation
	input_box.editable = false
	background.pause_parallax()

#Display reset message
	hud.life_lost_reset()
	score = score - 1 #TODO scale death score penalty

	#identify number of words to reset
	var failed_word = collider.target_word
	print_debug("Failed word was ", failed_word)
	var reset_number = get_tree().get_node_count_in_group("obstacles")
	next_word_index = next_word_index - reset_number
	words_left = word_queue.size() - next_word_index

#Remove all onscreen words
	obstacle_manager.reset_words()

	#Display countdown
	await hud.display_countdown()

	#Resume game
	input_box.clear()
	resume_game()


func return_words_to_queue(number_of_words: int):
	next_word_index -= number_of_words


func adjust_score(amount: int):
	score += amount


func on_obstacle_queue_empty():
	if word_queue.size() == next_word_index:
		end_level()


func set_target_word(target: String):
	target_word = target


func game_over():
	hud.game_over()
	background.pause_parallax()
	obstacle_manager.game_over()


func end_level():
	level_complete = true
	obstacle_manager.level_complete()
	await get_tree().create_timer(2).timeout
	hud.level_complete()


func update_text(new_text: String):
	if level_complete:
		return
	current_text = new_text.strip_edges()
	current_text.to_lower()
	if current_text == target_word:
		player.jump()
		input_box.clear()
		obstacle_manager.word_cleared()
		target_word = obstacle_manager.provide_target_word()
		words_left = words_left - 1


func go_to_next_level(_text: String):
	if level_complete:
		input_box.editable = false
		print("Go to next level detected")
		LevelLoader.load_next_level()
		load_level_data()
		await hud.start_next_level()
		await hud.display_countdown()
		input_box.clear()
		level_complete = false
		resume_game()


func load_level_data():
	word_queue = LevelLoader.level_targets.duplicate()
	if LevelLoader.level_order == LevelLoader.LevelOrder.RANDOM:
		word_queue.shuffle()
	word_queue = word_queue.slice(0, LevelLoader.default_level_size)
	words_left = word_queue.size()
	next_word_index = 0


func resume_game():
	input_box.editable = true
	if background.background_stopped:
		background.resume_parallax()
	obstacle_manager.resume_obstacle_generation()
