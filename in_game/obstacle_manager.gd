class_name ObstacleManager
extends Node2D

signal words_left_updated(words_left: int)
signal score_changed (score_change_amount: int)
signal obstacle_queue_emptied
signal new_target_word (target: String)

@export var basic_obstacle: PackedScene
@export var crawl_obstacle: PackedScene
@export var extended_obstacle: PackedScene

var current_theme: LevelTheme
var obstacle_types: Array[PackedScene]

var obstacle_group_name: StringName = &"obstacles"

var words_per_obstacle: int = 1
var current_obstacle_queue: Array[Obstacle] = []
var next_obstacle: Obstacle:
	get():
		if current_obstacle_queue.size() > 0:
			return current_obstacle_queue[0]
		return null

var obstacle_start_location: Vector2
var obstacle_spacing: float

var obstacle_size: int = 1
var speed_modifier: float = 1.0

var stop_adding_words: bool = false

var delaying_obstacle: bool = false
var delayed_obstacle: Obstacle = null
var delay_distance: float

var word_list: Array[Dictionary] #Receive from the game
var word_list_index: int = 0




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var screen_limit: Vector2 = get_viewport_rect().size
	obstacle_start_location = Vector2(screen_limit.x + 150,  979)
	obstacle_types = [basic_obstacle, crawl_obstacle, extended_obstacle]



func _physics_process(_delta: float) -> void:
	if stop_adding_words:
		return

	var distance_to_last_obstacle: float = obstacle_start_location.x - current_obstacle_queue[-1].position.x

	if delaying_obstacle:
		distance_to_last_obstacle = delay_distance

	if distance_to_last_obstacle >= obstacle_spacing * obstacle_size:
		var offset: float = distance_to_last_obstacle - (obstacle_spacing * obstacle_size)
		if delaying_obstacle:
			release_obstacle(delayed_obstacle)
			delayed_obstacle = null
			delay_distance = 0
		else:
			request_next_obstacle(offset)


func request_next_obstacle(distance_offset: float = 0) -> void:
	var queued_obstacle: Obstacle = select_obstacle_type()
	add_child(queued_obstacle)

	var targets_needed: int = 1
	if queued_obstacle is ExtendableObstacle:
		queued_obstacle.check_fit(obstacle_spacing)
		targets_needed = queued_obstacle.number_of_word_slots

	var target_array: Array[Dictionary] = get_targets(targets_needed)
	if target_array.size() == 0:
		stop_adding_targets()
		queued_obstacle.queue_free()
		return
	else:
		queued_obstacle.parse_targets(target_array)

		queued_obstacle.speed_modifier = speed_modifier
		queued_obstacle.position = obstacle_start_location - Vector2(distance_offset, 0)
		queued_obstacle.add_to_group(obstacle_group_name)


	var total_strokes_for_targets: int = queued_obstacle.get_total_score()
	var stroke_ratio: float = float(total_strokes_for_targets)/target_array.size()

	obstacle_size = targets_needed

	if stroke_ratio > 1:
		delay_obstacle_release(queued_obstacle)
		queued_obstacle.stopped = true
		return
	else:
		release_obstacle(queued_obstacle)



func delay_obstacle_release(queued_obstacle: Obstacle) -> void:
	delayed_obstacle = queued_obstacle
	delaying_obstacle = true
	delay_distance = float(queued_obstacle.score)/queued_obstacle.get_current_number_of_targets() * obstacle_spacing


func release_obstacle(queued_obstacle: Obstacle, distance_offset: float = 0) -> void:
	current_obstacle_queue.push_back(queued_obstacle)
	queued_obstacle.adjust_position(distance_offset)
	queued_obstacle.stopped = false

	if PlayerConfig.target_visibility != PlayerConfig.TargetVisibility.ALL:
		queued_obstacle.hide_target(true)

	#notify game of the current target if this is the only target on screen
	if current_obstacle_queue.size() == 1:
		new_target_word.emit(queued_obstacle.target_word)
		if PlayerConfig.target_visibility == PlayerConfig.TargetVisibility.NEXT:
			queued_obstacle.hide_target(false)
		if PlayerConfig.voice_output_enabled == true:
			queued_obstacle.speak_words()


func select_obstacle_type() -> Obstacle:
	var obstacle_roll: float = randf()
	var obst_odds: float = current_theme.obstacle_frequency[0]
	var created_obstacle: Obstacle
	if obstacle_roll <= obst_odds:
		created_obstacle = obstacle_types[2].instantiate()
		created_obstacle.textures.assign(current_theme.extendable_obstacles)
	else:
		obst_odds = obst_odds + current_theme.obstacle_frequency[1]
		if obstacle_roll <= obst_odds:
			created_obstacle = obstacle_types[0].instantiate()
			created_obstacle.textures = current_theme.jump_obstacles
		else:
			created_obstacle = obstacle_types[1].instantiate()
			created_obstacle.textures = current_theme.crawl_obstacles
	return created_obstacle


func get_targets(number_of_targets: int) -> Array[Dictionary]:
	var target_array: Array[Dictionary] = []
	for target_number: int in number_of_targets * words_per_obstacle:
		if word_list.size() > word_list_index:
			target_array.append(word_list[word_list_index])
			word_list_index += 1
		else:
			break
	words_left_updated.emit(word_list.size() - word_list_index)
	return target_array


func stop_adding_targets() -> void:
	stop_adding_words = true


func set_obstacle_theme(new_theme: LevelTheme) -> void:
	current_theme = new_theme


func provide_target_word() -> String:
	if next_obstacle:
		return next_obstacle.target_word
	else: return ""


func word_cleared() -> void:
	if current_obstacle_queue[0] is ExtendableObstacle and not current_obstacle_queue[0].target_data_array.is_empty():
		var obstacle: ExtendableObstacle = current_obstacle_queue[0]
		score_changed.emit(obstacle.score)
		obstacle.update_targets()
		new_target_word.emit(obstacle.target_word)
	else:
		var obstacle: Obstacle = current_obstacle_queue.pop_front()

		if obstacle:
			score_changed.emit(obstacle.score)

		if current_obstacle_queue.size() == 0:
			obstacle.tree_exited.connect(end_level, ConnectFlags.CONNECT_ONE_SHOT)

		else:
			new_target_word.emit(current_obstacle_queue[0].target_word)

	if PlayerConfig.target_visibility == PlayerConfig.TargetVisibility.NEXT:
		current_obstacle_queue[0].hide_target(false)

	if PlayerConfig.voice_output_enabled:
		if current_obstacle_queue.size() > 0:
			current_obstacle_queue[0].speak_words()


func reset_words(collider: Object) -> void:
	stop_adding_words = true
	var score_reduction: int = 0
	var words_to_reset: int = 0
	var colliding_obst_found : bool = false

	for obst in current_obstacle_queue:
		if obst is ExtendableObstacle:
			for target: Dictionary in obst.target_data_array:
				words_to_reset += target["number_of_targets"]
		words_to_reset += obst.get_current_number_of_targets()
		if obst == collider:
			colliding_obst_found = true
	if not colliding_obst_found:
		for obst in get_tree().get_nodes_in_group(obstacle_group_name):
			if obst == collider:
				score_reduction -= obst.score
				words_to_reset += obst.get_total_number_of_targets()
				break

	get_tree().call_group(obstacle_group_name, "queue_free")
	current_obstacle_queue.clear()
	score_changed.emit(score_reduction)

	word_list_index -= words_to_reset
	words_left_updated.emit(word_list.size() - word_list_index)



#Adjust the speed multiplier when character speed changes
func modify_speed(multiplier: float) -> void:
	speed_modifier = multiplier
	for obstacle in get_tree().get_nodes_in_group(obstacle_group_name):
		obstacle.speed_modifier = multiplier


func pause_obstacles() -> void:
	for obstacle in current_obstacle_queue:
		obstacle.stopped = true
	stop_adding_words = true


#Restart obstacle movement and request a new word if required
func resume_obstacles() -> void:
	for obstacle in current_obstacle_queue:
		obstacle.stopped = false
	if current_obstacle_queue.size() == 0:
		request_next_obstacle()
	stop_adding_words = false


#Stops timer and kills all obstacles
func game_over() -> void:
	stop_adding_words = true
	get_tree().call_group(obstacle_group_name, "queue_free")
	current_obstacle_queue.clear()


func end_level() -> void:
	stop_adding_words = true
	obstacle_queue_emptied.emit()


#Determine speed of obstacle generation and number of words per obstacle
func set_speed(strokes_per_min: int) -> void:
	var spm_ratio: float = float(strokes_per_min)/50
	words_per_obstacle = ceili(spm_ratio)
	@warning_ignore("integer_division")
	var obstacles_per_min: float = strokes_per_min/words_per_obstacle
	var next_obstacle_interval: float = 60.0/obstacles_per_min
	obstacle_spacing = next_obstacle_interval * 200.0


func set_target_list(new_list: Array[Dictionary]) -> void:
	word_list = new_list
	word_list_index = 0


#Trigger visible target on an obstacle when it gets into range
func show_target(target: PhysicsBody2D) -> void:
	if target is Obstacle and PlayerConfig.target_visibility == PlayerConfig.TargetVisibility.IN_RANGE:
		target.hide_target(false)
