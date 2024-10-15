class_name RunnerSave
extends Resource

enum LevelSequence {LEARN_PLOVER, LAPWING, OTHER}

signal next_level(new_level_needed: bool)
signal speed_updated

var lapwing_level_1: String = "lapwing_1.json"
var learn_plover_level_1: String = ""

@export var level_sequence: LevelSequence
@export var custom_start_level: String
@export var current_level_path: String
@export var last_checkpoint_path: String

@export var current_speed: int:
	set(new_speed):
		current_speed = new_speed
		speed_updated.emit()
@export var current_score: int = 0
@export var current_lives: int = 3

@export var speed_building_mode: bool
@export var starting_speed: int
@export var target_speed: int
@export var step_size: int = 5


func _init(save_data: Dictionary = {}):
	level_sequence = save_data["LevelSequence"] if save_data.has("LevelSequence") else LevelSequence.LAPWING
	custom_start_level = save_data["CustomStartLevel"] if save_data.has("CustomStartLevel") else ""
	if save_data.has("LastCheckpoint"):
		last_checkpoint_path = save_data["LastCheckpoint"]
	else:
		match level_sequence:
			LevelSequence.LAPWING:
				last_checkpoint_path = lapwing_level_1
			LevelSequence.OTHER:
				last_checkpoint_path = custom_start_level
	if level_sequence == LevelSequence.OTHER and custom_start_level == "":
		custom_start_level = last_checkpoint_path
	current_level_path = save_data["CurrentLevel"] if save_data.has("CurrentLevel") else last_checkpoint_path

	current_speed = save_data["CurrentSpeed"] if save_data.has("CurrentSpeed") else starting_speed
	current_score = save_data["CurrentScore"] if save_data.has("CurrentScore") else 0
	current_lives = save_data["CurrentLives"] if save_data.has("CurrentLives") else 3

	speed_building_mode = save_data["SpeedBuildMode"] if save_data.has("SpeedBuildMode") else false
	if speed_building_mode:
		starting_speed = save_data["StartingSpeed"] if save_data.has("StartingSpeed") else 20
		target_speed = save_data["TargetSpeed"] if save_data.has("TargetSpeed") else starting_speed
		step_size = save_data["StepSize"] if save_data.has("StepSize") else 5


func serialize_data(current_level_complete: bool = false) -> Dictionary:
	var save_dict: Dictionary = {}
	save_dict["LevelSequence"] = level_sequence
	save_dict["CustomStartLevel"] = custom_start_level
	if current_level_complete:
		save_dict["CurrentLevel"] = LevelLoader.active_level.next_level_path
	else: save_dict["CurrentLevel"] = current_level_path
	save_dict["LastCheckpoint"] = last_checkpoint_path

	save_dict["CurrentLives"] = current_lives
	save_dict["CurrentScore"] = current_score
	save_dict["CurrentSpeed"] = current_speed

	save_dict["SpeedBuildMode"] = speed_building_mode
	save_dict["StartingSpeed"] = starting_speed
	save_dict["TargetSpeed"] = target_speed
	save_dict["StepSize"] = step_size

	return save_dict


func increase_target_speed(increase_amount: int) -> void:
	if speed_building_mode:
		target_speed += increase_amount
		starting_speed += increase_amount
	else: current_speed += increase_amount


func step_speed() -> void:
	if at_target_speed():
		if starting_speed:
			current_speed = starting_speed
		next_level.emit(true)
	else:
		current_speed += step_size
		if current_speed >= target_speed:
			current_speed = target_speed
		next_level.emit(false)



func at_target_speed() -> bool:
	if not speed_building_mode:
		return true
	elif speed_building_mode and current_speed == target_speed:
		return true
	else:
		return false


func update_level_paths() -> void:
	current_level_path = LevelLoader.get_level_path()
	if PlayerConfig.checkpoints_enabled:
		if PlayerConfig.checkpoint_all or LevelLoader.get_checkpoint():
			last_checkpoint_path = LevelLoader.get_checkpoint_path()


func start_level_sequence() -> bool:
	match level_sequence:
		LevelSequence.LAPWING:
			current_level_path = lapwing_level_1
			last_checkpoint_path = current_level_path
		LevelSequence.LEARN_PLOVER:
			current_level_path = learn_plover_level_1
			last_checkpoint_path = current_level_path
		LevelSequence.OTHER:
			current_level_path = custom_start_level
			last_checkpoint_path = current_level_path
		_:
			return false

	LevelLoader.load_level(current_level_path)
	return true
