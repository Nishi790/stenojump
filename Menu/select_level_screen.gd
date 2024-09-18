extends HBoxContainer

signal start_level(path: String)

@export var lapwing_tab: PanelContainer
@export var level_preview: PanelContainer

@export var starting_speed_select: SpinBox
@export var speed_step_select: SpinBox
@export var level_grid: GridContainer


func _ready() -> void:
	level_grid.level_selected.connect(preview_level)
	level_preview.start_pressed.connect(level_started)


func level_started(path: String) -> void:
	PlayerConfig.target_wpm = 200
	PlayerConfig.starting_wpm = starting_speed_select.value
	PlayerConfig.current_wpm = starting_speed_select.value
	PlayerConfig.step_size = speed_step_select.value
	start_level.emit(path)


func preview_level(path: String) -> void:
	level_preview.set_preview(path)
