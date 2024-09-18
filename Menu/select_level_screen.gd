extends HBoxContainer

signal start_level(path: String)

@export var lapwing_tab: PanelContainer
@export var level_preview: PanelContainer

@export var starting_speed_select: SpinBox
@export var speed_step_select: SpinBox
@export var level_grid: GridContainer


func level_started(path: String) -> void:
	start_level.emit(path)


func preview_level(path: String) -> void:
	level_preview.set_preview(path)
	level_preview.enable_start()
