class_name StoryLevelSelector
extends Control

enum LevelType {STORY, RUNNER}

signal runner_started(level_name: String)
signal story_started(level_name: String)

@export var level_buttons: Array[LevelSelectButton]
@export var unlocked_levels: Array[int]
@export var current_curves: Array[Line2D]



func _ready() -> void:
	for index in unlocked_levels:
		if level_buttons[index].disabled:
			level_buttons[index - 1].unlock_next_level()
	for button in level_buttons:
		if button.disabled:
			button.hide()
		button.level_selected.connect(start_level)
		button.add_curve.connect(add_curve)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		level_buttons[0].unlock_next_level()


func start_level(level_name: String, level_type: LevelType) -> void:
	if level_type == LevelType.RUNNER:
		runner_started.emit(level_name)
	else:
		story_started.emit(level_name)


func add_curve(curve: Line2D) -> void:
	add_child(curve)
	current_curves.append(curve)


func retrieve_next_level(current_level_name: String) -> String:
	var array_index: int = 0
	while array_index < level_buttons.size():
		if level_buttons[array_index].level_name == current_level_name:
			break
		array_index += 1
	return level_buttons[array_index + 1].level_name
