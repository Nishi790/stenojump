extends Node2D

signal score_changed (new_score: int)
signal words_left_changed (remainig_words: int)
signal target_speed_changed (target_speed: int)
signal wpm_updated (wpm: float)
signal main_menu_requested

@export var obstacle_manager: ObstacleManager
@export var player: Player
@export var hud: HUD
@export var background: BackgroundManager

var input_box: LineEdit

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
		if level_time > 0.5:
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
var game_paused: bool = false

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
	obstacle_manager.obstacle_queue_emptied.connect(player.end_level)
	$ObstacleDetector.start_running.connect(player.start_run)

	#Connect HUD Signals
	input_box = hud.input_box
	score_changed.connect(hud.score_counter.update_score_text)
	words_left_changed.connect(hud.word_counter.update_word_count)
	input_box.text_changed.connect(update_text)
	input_box.text_submitted.connect(enter_pressed)
	wpm_updated.connect(hud.wpm_changed)
	hud.resume_game_requested.connect(resume_game)
	hud.main_menu_requested.connect(quit_game)

	#load selected level
	load_level_data(PlayerConfig.current_level_path)
	target_speed_changed.emit(PlayerConfig.current_wpm)

	input_box.grab_focus()


func _process(delta: float) -> void:
	if level_timer_active == true:
		level_time += delta
		var normal_words: float = characters_entered_correctly/5.0
		var minutes: float = level_time/60.0
		wpm = normal_words/minutes


func send_new_word(number: int) -> void:
	if word_queue.size() == next_word_index:
		return
	else:
		var words_to_send: Array[Dictionary] = []
		for index in number:
			if word_queue.size() != next_word_index:
				words_to_send.append(word_queue[next_word_index])
				next_word_index += 1
		obstacle_manager.add_word(words_to_send)


func reset_word(collider: Object) -> void:
#Pause Word Generation
	pause_game()

#Display reset message
	hud.life_lost_reset()
	score = score - 1 #TODO scale death score penalty
	print_debug("Failed word was ", collider.target_word)

#Remove all onscreen words
	obstacle_manager.reset_words()

	#Display countdown
	var countdown_complete: bool = await hud.display_countdown()

	#Do not resume if the countdown was aborted b/c game is paused
	if countdown_complete:
		#Resume game
		resume_game()


func return_words_to_queue(number_of_words: int, number_of_obstacles: int) -> void:
	next_word_index -= number_of_words
	words_left = word_queue.size() - next_word_index
	obstacles_remaining += number_of_obstacles


func adjust_score(amount: int) -> void:
	score += amount


func on_obstacle_queue_empty() -> void:
	if word_queue.size() == next_word_index:
		end_level()


func set_target_word(target: String) -> void:
	target_word = target


func game_over() -> void:
	level_timer_active = false
	hud.game_over()
	background.pause_parallax()
	obstacle_manager.game_over()


func end_level() -> void:
	level_timer_active = false
	level_time = 0
	characters_entered_correctly = 0
	level_complete = true
	obstacle_manager.level_complete()
	await get_tree().create_timer(2).timeout
	hud.level_complete()


func update_text(new_text: String) -> void:
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


func enter_pressed(text: String) -> void:
	if level_complete:
		var command_entered: String = text.strip_edges()
		command_entered = command_entered.to_lower()
		match command_entered:
			"quit":
				LevelLoader.save_next_level()
				PlayerConfig.save_settings()
				main_menu_requested.emit()
			_:
				if PlayerConfig.speed_building_mode == true:
					if not PlayerConfig.at_target_speed():
						increase_speed()
					else:
						PlayerConfig.current_wpm = PlayerConfig.starting_wpm
						LevelLoader.load_next_level()
					target_speed_changed.emit(PlayerConfig.current_wpm)
				else: LevelLoader.load_next_level()
				load_level_data()
				await hud.start_next_level()
				await hud.display_countdown()
				level_complete = false
				resume_game()


func load_level_data(level_path: String = "") -> void:
	if level_path != "":
			LevelLoader.load_level(level_path)
	word_queue = LevelLoader.level_targets.duplicate()
	if LevelLoader.level_order == LevelLoader.LevelOrder.RANDOM:
		word_queue.shuffle()
	word_queue = word_queue.slice(0, LevelLoader.default_level_size)
	next_word_index = 0


func increase_speed() -> void:
	var current_speed: int = PlayerConfig.current_wpm
	current_speed = current_speed + PlayerConfig.step_size
	if current_speed > PlayerConfig.target_wpm:
		current_speed = PlayerConfig.target_wpm
	PlayerConfig.current_wpm = current_speed


func resume_game() -> void:
	input_box.grab_focus()
	if background.background_stopped:
		background.resume_parallax()
	obstacle_manager.resume_obstacles()
	player.start_walk()


func set_words_per_obstacle(number: int) -> void:
	max_words_per_obstacle = number
	obstacles_remaining = ceili(float(word_queue.size())/max_words_per_obstacle)


func pause_game(menu_open: bool = false) -> void:
	level_timer_active = false
	obstacle_manager.pause_obstacles()
	background.pause_parallax()
	player.change_states(Player.State.IDLING)
	if menu_open:
		hud.open_pause_menu()


func quit_game() -> void:
	PlayerConfig.save_settings()
	main_menu_requested.emit()
