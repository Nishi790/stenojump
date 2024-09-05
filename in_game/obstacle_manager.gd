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
@export var new_word_timer: Timer

var obstacle_types: Array[PackedScene]

var level_new_word_interval: float = 2:
	set(interval):
		level_new_word_interval = interval
		new_word_interval = level_new_word_interval * (1/speed_modifier) * stroke_ratio
var new_word_interval: float = 2 :
	set(interval):
		new_word_interval = interval
		new_word_timer.wait_time = new_word_interval
var speed_modifier: float = 1.0:
	set(mod):
		if mod == 0.0:
			new_word_timer.set_paused(true)
		else:
			new_word_timer.set_paused(false)
			speed_modifier = mod
			new_word_interval = level_new_word_interval * (1/speed_modifier) * stroke_ratio

var words_per_obstacle: int = 1
var current_obstacle_queue: Array[Obstacle] = []
var next_obstacle: Obstacle:
	get():
		if current_obstacle_queue.size() > 0:
			return current_obstacle_queue[0]
		else: return null
var upcoming_word: Array[Dictionary]
var stroke_ratio: float = 1:
	set(new_ratio):
		stroke_ratio = new_ratio
		new_word_interval = level_new_word_interval * (1/speed_modifier) * stroke_ratio
		new_word_timer.start()
var obstacle_start_location: Vector2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var screen_limit: Vector2 = get_viewport_rect().size
	obstacle_start_location = Vector2(screen_limit.x + 30,  979)
	obstacle_types = [basic_obstacle, crawl_obstacle]

	new_word_timer.timeout.connect(request_word)
	new_word_timer.start()


func request_word() -> void:
	new_word_needed.emit(words_per_obstacle)
	var total_strokes: int = 0
	for word in upcoming_word:
		total_strokes += word["score"]
	stroke_ratio = total_strokes/words_per_obstacle



func provide_target_word() -> String:
	if next_obstacle:
		return next_obstacle.target_word
	else: return ""


func add_word(new_words: Array[Dictionary]) -> void:
	if upcoming_word == null or upcoming_word.is_empty():
		upcoming_word = new_words
		new_word_needed.emit(words_per_obstacle)
		return
	#Create Obstacle
	var obs_scene: PackedScene = obstacle_types.pick_random()
	var new_obstacle: Obstacle = obs_scene.instantiate()
	new_obstacle.position = obstacle_start_location
	new_obstacle.speed_modifier = speed_modifier
	add_child(new_obstacle)
	new_obstacle.add_to_group("obstacles")
	current_obstacle_queue.push_back(new_obstacle)

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
	new_obstacle.set_target_word(final_target)
	new_obstacle.score = point_value
	new_obstacle.hint = final_hint
	new_obstacle.number_of_targets = upcoming_word.size()
	upcoming_word = new_words
	if PlayerConfig.target_visibility != PlayerConfig.TargetVisibility.ALL:
		new_obstacle.hide_target(true)

	#notify game of the current target if this is the only target on screen
	if current_obstacle_queue.size() == 1:
		new_target_word.emit(new_obstacle.target_word)
		if PlayerConfig.target_visibility == PlayerConfig.TargetVisibility.NEXT:
			new_obstacle.hide_target(false)
		if PlayerConfig.voice_output_enabled == true:
			new_obstacle.speak_words()


func word_cleared() -> void:
	var obstacle: Obstacle = current_obstacle_queue.pop_front()

	#TODO design and implement scoring system
	if obstacle:
		score_changed.emit(obstacle.score)

	if current_obstacle_queue.size() == 0:
		obstacle_queue_emptied.emit()

	if PlayerConfig.target_visibility == PlayerConfig.TargetVisibility.NEXT:
		current_obstacle_queue[0].hide_target(false)

	if PlayerConfig.voice_output_enabled:
		if current_obstacle_queue.size() > 0:
			current_obstacle_queue[0].speak_words()


func reset_words() -> void:
	new_word_timer.stop()
	var score_reduction: int = 0
	var words_to_reset: int = 0
	var obst_returned: int = get_tree().get_node_count_in_group("obstacles")
	for obst in get_tree().get_nodes_in_group("obstacles"):
		if current_obstacle_queue.find(obst) == -1:
			score_reduction -= obst.score
		words_to_reset += obst.number_of_targets
		obst.queue_free()
	current_obstacle_queue.clear()
	score_changed.emit(score_reduction)
	words_returned.emit(words_to_reset, obst_returned)
	return


func pause_obstacles() -> void:
	for obstacle in current_obstacle_queue:
		obstacle.stopped = true
	new_word_timer.set_paused(true)


func modify_speed(multiplier: float) -> void:
	speed_modifier = multiplier
	for obstacle in current_obstacle_queue:
		obstacle.speed_modifier = multiplier


func resume_obstacles() -> void:
	for obstacle in current_obstacle_queue:
		obstacle.stopped = false
	if current_obstacle_queue.size() == 0:
		request_word()
	else:
		new_target_word.emit(current_obstacle_queue[0].target_word)
	new_word_timer.set_paused(false)
	if new_word_timer.is_stopped():
		new_word_timer.start()


func game_over() -> void:
	get_tree().call_group("obstacles", "queue_free")
	current_obstacle_queue.clear()
	new_word_timer.stop()


func level_complete() -> void:
	new_word_timer.stop()


func set_speed(wpm: int) -> void:
	var wpm_ratio: float = float(wpm)/50
	words_per_obstacle = ceili(wpm_ratio)
	@warning_ignore("integer_division")
	var obstacles_per_min: int = wpm/words_per_obstacle
	level_new_word_interval = 60.0/float(obstacles_per_min)
	words_per_obstacle_changed.emit(words_per_obstacle)


func show_target(target: PhysicsBody2D) -> void:
	if target is Obstacle and PlayerConfig.target_visibility == PlayerConfig.TargetVisibility.IN_RANGE:
		target.hide_target(false)
