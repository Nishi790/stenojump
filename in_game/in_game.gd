extends Node2D

signal score_changed (new_score: int)
signal words_left_changed (remainig_words: int)
signal target_speed_changed (target_speed: int)
signal wpm_updated (wpm: float)

@export var obstacle_manager: ObstacleManager
@export var player: Player
@export var input_box: LineEdit
@export var hud: HUD
@export var background: BackgroundManager

var word_queue: Array
var next_word_index: int = 0
var new_word_interval: float = 3 #seconds until next word
var current_text: String
var target_word: String
var level_time: float = 0
var characters_entered_correctly: int = 0
var wpm: float = 0:
	set(new_wpm):
		wpm = new_wpm
		wpm_updated.emit(wpm)
var level_timer_active: bool = false

var score: int = 0:
	set(new_score):
		score = new_score
		score_changed.emit(score)
var words_left: int:
	set(number_of_words):
		words_left = number_of_words
		words_left_changed.emit(words_left)
var max_words_per_obstacle: int = 1
var obstacles_remaining: int
var level_complete: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Set up obstacle manager
	obstacle_manager.new_word_needed.connect(send_new_word)
	obstacle_manager.words_returned.connect(return_words_to_queue)
	obstacle_manager.score_changed.connect(adjust_score)
	obstacle_manager.obstacle_queue_emptied.connect(on_obstacle_queue_empty)
	obstacle_manager.new_target_word.connect(set_target_word)
	target_speed_changed.connect(obstacle_manager.set_speed)
	obstacle_manager.words_per_obstacle_changed.connect(set_words_per_obstacle)

	#Connect player signals
	player.reset_word.connect(reset_word)
	player.game_over.connect(game_over)
	player.lives_changed.connect(hud.lives_counter.update_lives_counter)
	hud.lives_counter.update_lives_counter(player.lives)
	obstacle_manager.new_target_word.connect(player.start_run)
	obstacle_manager.obstacle_queue_emptied.connect(player.end_level)

	#Connect HUD Signals
	score_changed.connect(hud.score_counter.update_score_text)
	words_left_changed.connect(hud.word_counter.update_word_count)
	input_box.text_changed.connect(update_text)
	input_box.text_submitted.connect(go_to_next_level)
	wpm_updated.connect(hud.wpm_changed)

	#load selected level
	load_level_data(PlayerConfig.current_level_path)
	if PlayerConfig.current_wpm == 0:
		PlayerConfig.current_wpm = PlayerConfig.starting_wpm
	target_speed_changed.emit(PlayerConfig.current_wpm)

	input_box.grab_focus()


func _process(delta):
	if level_timer_active == true:
		level_time += delta
		var normal_words: float = characters_entered_correctly/5
		var minutes: float = level_time/60
		wpm = normal_words/minutes


func send_new_word(number: int):
	if word_queue.size() == next_word_index:
		return
	else:
		var words_to_send: Array[Dictionary] = []
		for index in number:
			if word_queue.size() != next_word_index:
				words_to_send.append(word_queue[next_word_index])
				next_word_index += 1
		obstacle_manager.add_word(words_to_send)


func reset_word(collider: Object):
#Pause Word Generation
	input_box.editable = false
	background.pause_parallax()
	level_timer_active = false

#Display reset message
	hud.life_lost_reset()
	score = score - 1 #TODO scale death score penalty
	print_debug("Failed word was ", collider.target_word)

#Remove all onscreen words
	obstacle_manager.reset_words()

	#Display countdown
	await hud.display_countdown()

	#Resume game
	input_box.clear()
	resume_game()


func return_words_to_queue(number_of_words: int, number_of_obstacles: int):
	next_word_index -= number_of_words
	words_left = word_queue.size() - next_word_index
	obstacles_remaining += number_of_obstacles


func adjust_score(amount: int):
	score += amount


func on_obstacle_queue_empty():
	if word_queue.size() == next_word_index:
		end_level()


func set_target_word(target: String):
	target_word = target


func game_over():
	level_timer_active = false
	hud.game_over()
	background.pause_parallax()
	obstacle_manager.game_over()


func end_level():
	level_timer_active = false
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
		if level_timer_active == false:
			level_timer_active = true
		player.jump()
		characters_entered_correctly += target_word.length()
		input_box.clear()
		obstacle_manager.word_cleared()
		target_word = obstacle_manager.provide_target_word()
		obstacles_remaining = obstacles_remaining - 1
		if obstacles_remaining > 0:
			words_left -= max_words_per_obstacle
		else: words_left = 0


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


func load_level_data(level_path: String = ""):
	if level_path != "":
			LevelLoader.load_level(level_path)
	word_queue = LevelLoader.level_targets.duplicate()
	if LevelLoader.level_order == LevelLoader.LevelOrder.RANDOM:
		word_queue.shuffle()
	word_queue = word_queue.slice(0, LevelLoader.default_level_size)
	next_word_index = 0


func resume_game():
	input_box.editable = true
	if background.background_stopped:
		background.resume_parallax()
	obstacle_manager.resume_obstacle_generation()


func set_words_per_obstacle(number: int):
	max_words_per_obstacle = number
	obstacles_remaining = ceili(float(word_queue.size())/max_words_per_obstacle)
