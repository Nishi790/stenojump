class_name RunnerGame
extends Node2D

enum RunnerThemes {HOUSE_CLEAN, STREET_DIRTY, HOUSE_MESSY, PARK, STREET_SUBURB}
enum RunnerMode {PROGRESSION, STORY, SPEEDBUILD}

signal words_left_changed (remaining_words: int)
signal target_speed_changed (target_speed: int)
signal wpm_updated (wpm: float)
signal main_menu_requested

@export var obstacle_manager: ObstacleManager
@export var player: Player
@export var hud: HUD
@export var background: BackgroundManager
@export var obstacle_detector: Area2D

var game_mode: RunnerMode
var level_theme: RunnerThemes
var save_data: RunnerSave

var speed_updated: bool

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

var words_left: int:
	set(number_of_words):
		words_left = number_of_words
		if words_left <= 0:
			words_left = 0
		words_left_changed.emit(words_left)
var max_words_per_obstacle: int = 1
var obstacles_remaining: int
var level_complete: bool = false
var game_paused: bool = false
var run_ended: bool = false
var word_failed: bool = false

var on_last_level: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	LevelLoader.last_level.connect(final_level_started)

	#Set up obstacle manager
	obstacle_manager.new_word_needed.connect(send_new_word)
	obstacle_manager.words_returned.connect(return_words_to_queue)
	obstacle_manager.score_changed.connect(adjust_score)
	obstacle_manager.obstacle_queue_emptied.connect(on_obstacle_queue_empty)
	obstacle_manager.new_target_word.connect(set_target_word)
	target_speed_changed.connect(obstacle_manager.set_speed)
	obstacle_manager.words_per_obstacle_changed.connect(set_words_per_obstacle)
	obstacle_detector.body_entered.connect(obstacle_manager.show_target)


	#Connect player signals
	player.reset_word.connect(reset_word)
	player.game_over.connect(game_over)
	player.player_movement_changed.connect(change_move_speed)
	player.obstacle_in_range.connect(clear_word)
	obstacle_detector.start_running.connect(player.start_run)

	#Connect HUD Signals
	input_box = hud.input_box
	@warning_ignore("unsafe_call_argument")
	words_left_changed.connect(hud.word_counter.update_word_count)
	input_box.text_changed.connect(update_text)
	input_box.text_submitted.connect(enter_pressed)
	wpm_updated.connect(hud.wpm_changed)
	hud.resume_game_requested.connect(resume_game)
	hud.main_menu_requested.connect(quit_game)

	change_move_speed(Player.State.WALKING)
	input_box.grab_focus()


func start_level(data: RunnerSave, mode: RunnerMode) -> void:
	game_mode = mode
	save_data = data
	save_data.next_level.connect(start_next_level)
	save_data.speed_updated.connect(update_speed_flag)
	speed_updated = true
	player.data = save_data
	hud.data = save_data

	load_level_data(save_data.current_level_path)
	set_level_theme(RunnerThemes.HOUSE_CLEAN)
	resume_game()



func _process(delta: float) -> void:
	if level_timer_active == true:
		level_time += delta
		var normal_words: float = characters_entered_correctly/5.0
		var minutes: float = level_time/60.0
		wpm = normal_words/minutes


func set_level_theme(new_theme: RunnerThemes, transition: bool = false)-> void:
	background.set_parallax_textures(new_theme, transition)
	obstacle_manager.set_obstacle_theme(new_theme)
	level_theme = new_theme


##Dynamically adjusts obstacle and scroll speed when player is walking instead of running (i.e. level start)
func change_move_speed(move_type: Player.State) -> void:
	var speed_modifier: float = 1.0
	match move_type:
		Player.State.WALKING:
			speed_modifier = 0.8
		Player.State.RUNNING:
			speed_modifier = 1.0
		Player.State.IDLING:
			speed_modifier = 0
	background.run_parallax(speed_modifier)
	obstacle_manager.modify_speed(speed_modifier)


##Sends target word(s)' information to the obstacle manager when requerted to generate new obstacles
func send_new_word(number: int) -> void:
	if word_queue.size() == next_word_index:
		obstacle_manager.add_word([])
	else:
		var words_to_send: Array[Dictionary] = []
		for index in number:
			if word_queue.size() != next_word_index:
				words_to_send.append(word_queue[next_word_index])
				next_word_index += 1
		obstacle_manager.add_word(words_to_send)
		obstacles_remaining -= 1


##Called on failure of an obstacle to reset section
##adjust score, and trigger relevant UI
func reset_word(collider: Object) -> void:
	#Remove all onscreen words
	obstacle_manager.reset_words(collider)
	if level_complete:
		level_complete = false

	#Pause Word Generation
	word_failed = true
	pause_game()

	#display hint
	if collider is Obstacle:
		hud.display_hint(collider.target_word, collider.hint, input_box.text)

	# adjust score
	hud.life_lost_reset()
	save_data.level_score -= 1  #TODO scale death score penalty


func resume_from_missed_word() -> void:
	#Display countdown
	var countdown_complete: bool = await hud.display_countdown()

	#Do not resume if the countdown was aborted b/c game is paused
	if countdown_complete:
		#Resume game
		resume_game()


##Used to reset an obstacle on failure
##Returns a specified number of words and the corresponding number of obstacles to the queue
##Completed by subtracting from indices
func return_words_to_queue(number_of_words: int, number_of_obstacles: int) -> void:
	next_word_index -= number_of_words
	words_left = word_queue.size() - next_word_index
	obstacles_remaining += number_of_obstacles


func adjust_score(amount: int) -> void:
	save_data.level_score += amount


func update_speed_flag() -> void:
	speed_updated = true


##Responds to Obstacle Manager signalling empty queue and prompts 'end level'
func on_obstacle_queue_empty() -> void:
	if word_queue.size() == next_word_index and not run_ended:
		end_level()


##Sets the current target word for text comparison
func set_target_word(target: String) -> void:
	target_word = target


##Called when all lives are lost, triggers reset of current level in save file to last checkpoint level
func game_over() -> void:
	target_word = ""
	level_timer_active = false
	run_ended = true
	if level_complete: level_complete = false
	hud.game_over()
	obstacle_manager.game_over()
	save_data.reset_progress()
	PlayerConfig.save_runner(game_mode, save_data.serialize_data())


##Called when a level is loaded without a following level path (defacto last level)
func final_level_started() -> void:
	on_last_level = true


##Called when a player successfully completes a level.
##Handles reset of required elements, triggering of HUD
func end_level() -> void:
	level_timer_active = false
	level_time = 0
	characters_entered_correctly = 0
	level_complete = true
	save_data.update_saved_score()
	await get_tree().create_timer(2).timeout
	player.end_level()
	PlayerConfig.set_high_score(save_data, word_queue.size())
	if on_last_level:
		hud.game_won()
	else:
		hud.level_complete()


##Called to parse text changes in player input box whenever text changes
##begins level timer on first word match and provides data for wpm counter
func update_text(new_text: String) -> void:
	if level_complete:
		return
	elif new_text == "":
		return
	current_text = new_text.strip_edges()
	current_text.to_lower()
	if word_failed: return
	if current_text == target_word:
		if level_timer_active == false:
			level_timer_active = true
		var obstacle_type: Obstacle.ObstacleType
		if obstacle_manager.next_obstacle != null:
			obstacle_type = obstacle_manager.next_obstacle.type
			player.avoid_obstacle(obstacle_type)

		characters_entered_correctly += target_word.length()
		input_box.clear()


##Called if the player avoids an obstacle in range
##Allows multiple attempts at a word if too early
func clear_word() -> void:
	obstacle_manager.word_cleared()
	target_word = obstacle_manager.provide_target_word()
	words_left -= max_words_per_obstacle



##Called when enter is pressed in player input box, used to move to next level/return to menu
##and for between level commands. like quit
func enter_pressed(text: String) -> void:
	if word_failed:
		word_failed = false
		resume_from_missed_word()
	elif level_complete:
		if on_last_level:
			if text.strip_edges().is_valid_int():
				var speed_increase: int = text.to_int()
				save_data.increase_target_speed(speed_increase)
				save_data.start_level_sequence()
				initiate_level()
				return
			else:
				main_menu_requested.emit()
				return

		var command_entered: String = text.strip_edges()
		command_entered = command_entered.to_lower()
		match command_entered:
			"quit":
				var serialized_data: Dictionary
				if save_data.at_target_speed():
					LevelLoader.save_next_level()
					quit_game(true)
				else:
					quit_game(false)

			_:
				save_data.step_speed()

	elif run_ended:
		main_menu_requested.emit()


func start_next_level(new_level: bool) -> void:
	if new_level:
		LevelLoader.load_next_level()
		save_data.update_level_paths()
	initiate_level()


func initiate_level() -> void:
	load_level_data()
	await hud.start_next_level()
	await hud.display_countdown()
	level_complete = false
	resume_game()


##Requests level data from the LevelLoader singleton and uses the data to set up the level
##Needs error handling for invalid level paths/level files
func load_level_data(level_path: String = "") -> void:
	if level_path != "":
		LevelLoader.load_level(level_path)

	word_queue = LevelLoader.get_wordlist()

#Error out if no words are in the level data
	if word_queue.is_empty():
		printerr("Invalid Level Data. Level contains no target words.")
		main_menu_requested.emit()

	#Set correct level size
	var level_size: int = LevelLoader.active_level.default_level_size
	if PlayerConfig.use_custom_size == true:
		if level_size < PlayerConfig.min_level_length:
			level_size = PlayerConfig.min_level_length
		elif level_size > PlayerConfig.max_level_length:
			level_size = PlayerConfig.max_level_length

	while word_queue.size() < level_size:
		word_queue.append_array(word_queue)

	#shuffle words if needed
	match PlayerConfig.preferred_word_order:
		PlayerConfig.WordOrder.RANDOM:
			word_queue.shuffle()
		PlayerConfig.WordOrder.ORDERED:
			pass
		PlayerConfig.WordOrder.DEFAULT:
			if LevelLoader.active_level.level_order == LevelLoader.LevelOrder.RANDOM:
				word_queue.shuffle()

	word_queue = word_queue.slice(0, level_size)
	next_word_index = 0
	words_left = word_queue.size()
	obstacles_remaining = ceili(words_left/max_words_per_obstacle)


##Called whenever the player needs to start a level or resume from a pause
func resume_game() -> void:
	input_box.grab_focus()
	player.resume_movement()
	if speed_updated:
		speed_updated = false
		obstacle_manager.set_speed(save_data.current_speed)
	obstacle_manager.resume_obstacles()



##Sets words per obstacle to determine number of targets to send obstacle manager when requested
func set_words_per_obstacle(number: int) -> void:
	max_words_per_obstacle = number
	obstacles_remaining = ceili(float(word_queue.size())/max_words_per_obstacle)


##Handles pausing main game for all cases (actual pause menu and resetting obstacles)
func pause_game(menu_open: bool = false) -> void:
	level_timer_active = false
	obstacle_manager.pause_obstacles()
	if menu_open:
		hud.open_pause_menu()
	else:
		player.change_states(Player.State.DIE)


##Saves data before quitting, first sending player class data to the PlayerConfig
##Then saves run related data to file before requesting return to menu
func quit_game(at_next_level: bool = false) -> void:
	var serialized_data: Dictionary = save_data.serialize_data(at_next_level)
	PlayerConfig.save_runner(game_mode, serialized_data)
	main_menu_requested.emit()
