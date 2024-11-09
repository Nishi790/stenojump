class_name ObstacleManager
extends Node2D

signal new_word_needed
signal words_returned (words_returned: int, obstacles_reset: int)
signal score_changed (score_change_amount: int)
signal obstacle_queue_emptied
signal new_target_word (target: String)
signal words_per_obstacle_changed (number_of_words: int)

@export var basic_obstacle: PackedScene
@export var crawl_obstacle: PackedScene
@export var extended_obstacle: PackedScene
@export var new_word_timer: Timer

var obstacle_types: Array[PackedScene]
var new_obstacle: Obstacle
var upcoming_obstacle: Obstacle

var obstacle_group_name: StringName = &"obstacles"

var level_new_word_interval: float = 2:
	set(interval):
		level_new_word_interval = interval
		if level_new_word_interval * (1/speed_modifier) * stroke_ratio != 0:
			new_word_interval = level_new_word_interval * (1/speed_modifier) * stroke_ratio
var new_word_interval: float = 2 :
	set(interval):
		assert(interval > 0, "invalid timer interval")
		new_word_interval = interval
		new_word_timer.wait_time = new_word_interval
var speed_modifier: float = 1.0:
	set(mod):
		if mod == 0.0:
			new_word_timer.set_paused(true)
		else:
			new_word_timer.set_paused(false)
			speed_modifier = mod
			var new_interval: float = level_new_word_interval * (1/speed_modifier) * stroke_ratio
			if new_interval != 0:
				new_word_interval = new_interval

var words_per_obstacle: int = 1
var current_obstacle_queue: Array[Obstacle] = []
var next_obstacle: Obstacle:
	get():
		if current_obstacle_queue.size() > 0:
			return current_obstacle_queue[0]
		return null
var upcoming_word: Array[Dictionary]
var stroke_ratio: float = 1:
	set(new_ratio):
		stroke_ratio = new_ratio
		var new_interval: float = level_new_word_interval * (1/speed_modifier) * stroke_ratio
		if new_interval != 0:
			new_word_interval = new_interval
			new_word_timer.start()
var obstacle_start_location: Vector2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var screen_limit: Vector2 = get_viewport_rect().size
	obstacle_start_location = Vector2(screen_limit.x + 150,  979)
	obstacle_types = [basic_obstacle, crawl_obstacle, extended_obstacle]

	new_word_timer.timeout.connect(request_word)
	new_word_timer.start()


func set_obstacle_theme(new_theme: RunnerGame.RunnerThemes) -> void:
	pass


func request_word() -> void:
	var words_on_current_obstacle: int = 1

	if new_obstacle != null:
		upcoming_obstacle = new_obstacle

	if upcoming_obstacle != null and upcoming_obstacle is ExtendableObstacle:
		words_on_current_obstacle = upcoming_obstacle.number_of_word_slots

	if upcoming_obstacle is ExtendableObstacle:
		assert(words_on_current_obstacle != 1)

	if new_obstacle == null and upcoming_obstacle == null: #This must be the first obstacle in the run, make it a single word
		new_obstacle = basic_obstacle.instantiate()
	else:
		new_obstacle = obstacle_types.pick_random().instantiate()

	new_obstacle.position = obstacle_start_location
	new_obstacle.speed_modifier = speed_modifier
	add_child(new_obstacle)
	new_obstacle.stopped = true
	new_obstacle.add_to_group(obstacle_group_name)

	var number_of_slots: int = 1

	if new_obstacle is ExtendableObstacle:
		number_of_slots = new_obstacle.check_fit(level_new_word_interval)
		new_word_needed.emit(number_of_slots * words_per_obstacle)
	else:
		new_word_needed.emit(words_per_obstacle)

	var total_strokes: int = 0
	var word_array: Array[Dictionary] = []

	var upcoming_obstacle_stroke_ratio: float = 0

	if upcoming_obstacle is ExtendableObstacle:
		var strokes_on_upcoming_obstacle: int = 0
		for word: Dictionary in upcoming_obstacle.target_data_array:
			strokes_on_upcoming_obstacle += word["score"]
		if upcoming_obstacle.score != 0:
			strokes_on_upcoming_obstacle += upcoming_obstacle.score
		upcoming_obstacle_stroke_ratio = float(strokes_on_upcoming_obstacle)/float(words_on_current_obstacle)

	word_array = upcoming_word
	var word_array_size_modifier: int = 0
	if new_obstacle is ExtendableObstacle:
		word_array_size_modifier = ceili(float(word_array.size())/float(new_obstacle.number_of_word_slots))
	#Calculate number of strokes of next word based on the score, and uses as multiplier on timer

	if word_array_size_modifier > 0:
		word_array = upcoming_word.slice(0, word_array_size_modifier)

	for word in word_array:
		total_strokes += word["score"]
	stroke_ratio = float(total_strokes)/float(words_per_obstacle) + upcoming_obstacle_stroke_ratio




func provide_target_word() -> String:
	if next_obstacle:
		return next_obstacle.target_word
	else: return ""


func add_word(new_words: Array[Dictionary]) -> void:
	if new_words.is_empty():
		level_complete()

	if upcoming_word == null or upcoming_word.is_empty():
		upcoming_word = new_words

		if upcoming_word.is_empty():
			return
		else:
			upcoming_obstacle = basic_obstacle.instantiate()
			upcoming_obstacle.position = obstacle_start_location
			upcoming_obstacle.speed_modifier = speed_modifier
			add_child(upcoming_obstacle)
			upcoming_obstacle.stopped = true
			upcoming_obstacle.add_to_group(obstacle_group_name)
			new_word_needed.emit(words_per_obstacle)
			return

	#Create Obstacle
	upcoming_obstacle.stopped = false
	current_obstacle_queue.push_back(upcoming_obstacle)

	upcoming_obstacle.parse_targets(upcoming_word)
	upcoming_word = new_words

	if PlayerConfig.target_visibility != PlayerConfig.TargetVisibility.ALL:
		upcoming_obstacle.hide_target(true)

	#notify game of the current target if this is the only target on screen
	if current_obstacle_queue.size() == 1:
		new_target_word.emit(upcoming_obstacle.target_word)
		if PlayerConfig.target_visibility == PlayerConfig.TargetVisibility.NEXT:
			upcoming_obstacle.hide_target(false)
		if PlayerConfig.voice_output_enabled == true:
			upcoming_obstacle.speak_words()



func word_cleared() -> void:
	if current_obstacle_queue[0] is ExtendableObstacle and not current_obstacle_queue[0].target_data_array.is_empty():
		var obstacle: ExtendableObstacle = current_obstacle_queue[0]
		score_changed.emit(obstacle.score)
		obstacle.update_targets()
	else:
		var obstacle: Obstacle = current_obstacle_queue.pop_front()

	#TODO design and implement scoring system
		if obstacle:
			score_changed.emit(obstacle.score)

		if current_obstacle_queue.size() == 0:
			obstacle.tree_exited.connect(end_level, ConnectFlags.CONNECT_ONE_SHOT)

	if PlayerConfig.target_visibility == PlayerConfig.TargetVisibility.NEXT:
		current_obstacle_queue[0].hide_target(false)

	if PlayerConfig.voice_output_enabled:
		if current_obstacle_queue.size() > 0:
			current_obstacle_queue[0].speak_words()


func reset_words(collider: Object) -> void:
	new_word_timer.stop()
	var score_reduction: int = 0
	var words_to_reset: int = upcoming_word.size()
	var colliding_obst_found : bool = false
	var obst_returned: int = current_obstacle_queue.size()
	for obst in current_obstacle_queue:
		words_to_reset += obst.number_of_targets
		if obst == collider:
			score_reduction -= obst.score
			colliding_obst_found = true
	if not colliding_obst_found:
		for obst in get_tree().get_nodes_in_group(obstacle_group_name):
			if obst == collider:
				score_reduction -= obst.score
				obst_returned += 1
				words_to_reset += obst.number_of_targets
				break
	get_tree().call_group(obstacle_group_name, "queue_free")
	current_obstacle_queue.clear()
	score_changed.emit(score_reduction)
	words_returned.emit(words_to_reset, obst_returned)
	upcoming_word.clear()
	upcoming_obstacle = null
	new_obstacle = null
	return


#Adjust the speed multiplier when character speed changes
func modify_speed(multiplier: float) -> void:
	speed_modifier = multiplier
	for obstacle in get_tree().get_nodes_in_group(obstacle_group_name):
		obstacle.speed_modifier = multiplier


func pause_obstacles() -> void:
	for obstacle in current_obstacle_queue:
		obstacle.stopped = true
	new_word_timer.set_paused(true)


#Restart obstacle movement and request a new word if required
func resume_obstacles() -> void:
	for obstacle in current_obstacle_queue:
		obstacle.stopped = false
	if current_obstacle_queue.size() == 0:
		request_word()
	else:
		new_target_word.emit(current_obstacle_queue[0].target_word)
	new_word_timer.set_paused(false)
	if new_word_timer.is_stopped():
		new_word_timer.start(new_word_interval)


#Stops timer and kills all obstacles
func game_over() -> void:
	get_tree().call_group(obstacle_group_name, "queue_free")
	current_obstacle_queue.clear()
	new_word_timer.stop()


func end_level() -> void:
	obstacle_queue_emptied.emit()


func level_complete() -> void:
	new_word_timer.stop()


#Determine speed of obstacle generation and number of words per obstacle
func set_speed(wpm: int) -> void:
	var wpm_ratio: float = float(wpm)/50
	words_per_obstacle = ceili(wpm_ratio)
	@warning_ignore("integer_division")
	var obstacles_per_min: float = wpm/words_per_obstacle
	level_new_word_interval = 60.0/obstacles_per_min
	words_per_obstacle_changed.emit(words_per_obstacle)


#Trigger visible target on an obstacle when it gets into range
func show_target(target: PhysicsBody2D) -> void:
	if target is Obstacle and PlayerConfig.target_visibility == PlayerConfig.TargetVisibility.IN_RANGE:
		target.hide_target(false)
