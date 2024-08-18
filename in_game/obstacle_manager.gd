class_name ObstacleManager
extends Node2D

signal new_word_needed
signal words_returned (int)
signal score_changed (int)
signal obstacle_queue_emptied
signal new_target_word (String)

@export var basic_obstacle: PackedScene
@export var new_word_timer: Timer

var new_word_interval: float = 2
var words_per_obstacle: int = 1
var current_obstacle_queue: Array[Obstacle] = []
var obstacle_start_location: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var screen_limit: Vector2 = get_viewport_rect().size
	obstacle_start_location = screen_limit + Vector2(30, -200)

	new_word_timer.timeout.connect(request_word)
	new_word_timer.wait_time = new_word_interval
	new_word_timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func request_word():
	new_word_needed.emit(words_per_obstacle)


func provide_target_word():
	if not current_obstacle_queue.is_empty():
		var target_obstacle = current_obstacle_queue.front()
		return target_obstacle.target_word
	else: return ""


func add_word(new_words: Array[Dictionary]):
	#Create Obstacle
	var new_obstacle: Obstacle = basic_obstacle.instantiate()
	new_obstacle.position = obstacle_start_location
	add_child(new_obstacle)
	new_obstacle.add_to_group("obstacles")
	current_obstacle_queue.push_back(new_obstacle)

	#Get obstacle data
	var target_words: PackedStringArray = []
	var point_value: int
	var hints: PackedStringArray = []
	for word in new_words:
		target_words.append(word["word"])
		point_value += word["score"]
		hints.append(word["hint"])
	var separator: String = " "
	var final_target: String = separator.join(target_words)
	var final_hint: String = separator.join(hints)

	#Set obstacle data
	new_obstacle.set_target_word(final_target)
	new_obstacle.score = point_value
	new_obstacle.hint = final_hint

	#notify game of the current target if this is the only target on screen
	if current_obstacle_queue.size() == 1:
		new_target_word.emit(new_obstacle.target_word)


func word_cleared():
	var obstacle: Obstacle = current_obstacle_queue.pop_front()

	#TODO design and implement scoring system
	score_changed.emit(obstacle.score)

	if current_obstacle_queue.size() == 0:
		obstacle_queue_emptied.emit()


func reset_words():
	new_word_timer.stop()
	var score_reduction: int = 0
	for obst in get_tree().get_nodes_in_group("obstacles"):
		if current_obstacle_queue.find(obst) == -1:
			score_reduction -= obst.score
		obst.queue_free()
	current_obstacle_queue.clear()
	score_changed.emit(score_reduction)
	return


func resume_obstacle_generation():
	request_word()
	new_word_timer.start(new_word_interval)


func game_over():
	for obstacle in current_obstacle_queue:
		obstacle.stopped = true
	new_word_timer.stop()


func level_complete():
	new_word_timer.stop()


func set_speed(wpm: int):
	var wpm_ratio: float = float(wpm)/30
	words_per_obstacle = ceili(wpm_ratio)
	var obstacles_per_min: float = wpm/words_per_obstacle
	new_word_interval = 60/obstacles_per_min
