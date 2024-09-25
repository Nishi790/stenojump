extends Node2D

signal score_changed (new_score: int)
signal words_left_changed (remaining_words: int)
signal target_speed_changed (target_speed: int)
signal wpm_updated (wpm: float)
signal main_menu_requested

@export var obstacle_manager: ObstacleManager
@export var player: Player
@export var hud: HUD
@export var background: BackgroundManager
@export var obstacle_detector: Area2D

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

#Total Score across levels
var score: int = 0:
	set(new_score):
		score = new_score
		score_changed.emit(score)

#Score in this level - lost if quit mid-level
var level_score: int = 0

var words_left: int:
	set(number_of_words):
		words_left = number_of_words
		if words_left < 0:
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
	@warning_ignore("unsafe_call_argument")
	player.lives_changed.connect(Callable(hud.lives_counter.update_lives_counter))
	hud.lives_counter.update_lives_counter(player.lives)
	obstacle_detector.start_running.connect(player.start_run)

	#Connect HUD Signals
	input_box = hud.input_box
	@warning_ignore("unsafe_call_argument")
	score_changed.connect(hud.score_counter.update_score_text)
	@warning_ignore("unsafe_call_argument")
	words_left_changed.connect(hud.word_counter.update_word_count)
	input_box.text_changed.connect(update_text)
	input_box.text_submitted.connect(enter_pressed)
	wpm_updated.connect(hud.wpm_changed)
	hud.resume_game_requested.connect(resume_game)
	hud.main_menu_requested.connect(quit_game)

	#load selected level
	load_level_data(PlayerConfig.current_level_path)
	target_speed_changed.emit(PlayerConfig.current_wpm)
	score = PlayerConfig.current_score

	change_move_speed(Player.State.WALKING)

	input_box.grab_focus()


func _process(delta: float) -> void:
	if level_timer_active == true:
		level_time += delta
		var normal_words: float = characters_entered_correctly/5.0
		var minutes: float = level_time/60.0
		wpm = normal_words/minutes


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
	score = score - 1
	level_score = level_score - 1 #TODO scale death score penalty


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
	level_score += amount
	score += amount


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
	PlayerConfig.run_lost()


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
	PlayerConfig.current_score = score
	level_score = 0
	await get_tree().create_timer(2).timeout
	player.end_level()
	PlayerConfig.set_high_score(PlayerConfig.current_level_path, word_queue.size())
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
	obstacles_remaining = obstacles_remaining - 1
	if obstacles_remaining > 0:
		words_left -= max_words_per_obstacle
	else: words_left = 0


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
				PlayerConfig.starting_wpm += speed_increase
				if PlayerConfig.target_wpm:
					PlayerConfig.target_wpm += speed_increase
				PlayerConfig.current_wpm = PlayerConfig.starting_wpm
				target_speed_changed.emit(PlayerConfig.current_wpm)
				load_level_data(PlayerConfig.start_level_sequence(PlayerConfig.level_sequence))
				await hud.start_next_level()
				await hud.display_countdown()
				level_complete = false
				resume_game()
			else:
				main_menu_requested.emit()

		var command_entered: String = text.strip_edges()
		command_entered = command_entered.to_lower()
		match command_entered:
			"quit":
				LevelLoader.save_next_level()
				PlayerConfig.save_game()
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
	elif run_ended:
		main_menu_requested.emit()


##Requests level data from the LevelLoader singleton and uses the data to set up the level
##Needs error handling for invalid level paths/level files
func load_level_data(level_path: String = "") -> void:
	if level_path != "":
			LevelLoader.load_level(level_path)

	word_queue = LevelLoader.active_level.level_targets.duplicate()

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


##Increases level strokes per minute by step amount
func increase_speed() -> void:
	var current_speed: int = PlayerConfig.current_wpm
	current_speed = current_speed + PlayerConfig.step_size
	if current_speed > PlayerConfig.target_wpm:
		current_speed = PlayerConfig.target_wpm
	PlayerConfig.current_wpm = current_speed


##Called whenever the player needs to start a level or resume from a pause
func resume_game() -> void:
	input_box.grab_focus()
	player.resume_movement()
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
func quit_game() -> void:
	player.save_data()
	PlayerConfig.save_game()
	main_menu_requested.emit()
