extends Control

signal returned_to_menu

@export var gameplay_tab: PanelContainer
@export var graphics_tab: PanelContainer
@export var sound_tab: PanelContainer


func _ready() -> void:
	gameplay_tab.menu_pressed.connect(exit_options)
	graphics_tab.menu_pressed.connect(exit_options)
	#sound_tab.menu_pressed.connect(exit_options)


func exit_options() -> void:
	returned_to_menu.emit()
	PlayerConfig.save_universal_settings()
	queue_free()
