extends PanelContainer

signal level_selected(path: String)

@export var level_folder: String

@export var starting_speed_select: SpinBox
@export var speed_step_select: SpinBox
@export var level_grid: GridContainer


func _ready() -> void:
	level_grid.level_selected.connect(new_level_selected)


func set_folder() -> void:
	level_grid.sequence_folder = level_folder


func new_level_selected(path: String) -> void:
	level_selected.emit(path)


func send_speed_settings() -> void:
	PlayerConfig.starting_wpm = int(starting_speed_select.value)
	PlayerConfig.current_wpm = int(starting_speed_select.value)
	PlayerConfig.step_size = int(speed_step_select.value)
	PlayerConfig.speed_building_mode = true
