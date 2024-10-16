class_name StoryLevelSelector
extends Control

enum LevelType {STORY, RUNNER}

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


func start_level(path: String) -> void:
	if


func add_curve(curve: Line2D) -> void:
	add_child(curve)
	current_curves.append(curve)
