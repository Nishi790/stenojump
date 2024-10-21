class_name StoryRunner
extends Node2D

signal next_level_requested
signal main_menu_requested

var runner_level: PackedScene = load("res://in_game/runner_game.tscn")
var runner: RunnerGame
var runner_save: RunnerSave


func _init(level_key: String = "lapwing_1.json", speed_required: int = 20) -> void:
	runner_save = RunnerSave.new(create_runner_save_data(level_key, speed_required))



func _ready() -> void:
	runner = runner_level.instantiate()
	runner.next_story_level.connect(next_level)
	runner.main_menu_requested.connect(go_to_menu)
	add_child(runner)
	runner.start_level(runner_save, RunnerGame.RunnerMode.STORY)


func create_runner_save_data(level_key: String, target_speed: int) -> Dictionary:
	var data: Dictionary = {}
	data["SpeedBuildingMode"] = true
	data["StartingSpeed"] = target_speed - 10
	data["CurrentSpeed"] = target_speed - 10
	data["StepSize"] = 5
	data["TargetSpeed"] = target_speed
	data["CurrentLevel"] = level_key
	data["LastCheckpoint"] = level_key
	return data


func next_level() -> void:
	queue_free()
	next_level_requested.emit()


func go_to_menu() -> void:
	queue_free()
	main_menu_requested.emit()
