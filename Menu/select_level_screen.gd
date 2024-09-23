extends PanelContainer

signal start_level(path: String)
signal cancel_select

@export var sequence_panel_scene: PackedScene
@export var menu_button: Button
@export var level_preview: PanelContainer
@export var tab_cont: TabContainer


func _ready() -> void:
	level_preview.start_pressed.connect(level_started)
	menu_button.pressed.connect(return_to_menu)
	create_tabs()


func create_tabs() -> void:
	var directories: DirAccess = DirAccess.open(LevelLoader.default_level_path_root)
	var dir_list: PackedStringArray = directories.get_directories()
	for dir in dir_list:
		var new_tab: PanelContainer = sequence_panel_scene.instantiate()
		new_tab.level_folder = LevelLoader.default_level_path_root.path_join(dir)
		new_tab.set_folder()
		new_tab.name = dir
		tab_cont.add_child(new_tab)
		new_tab.level_selected.connect(preview_level)


func level_started(path: String) -> void:
	PlayerConfig.target_wpm = 200
	tab_cont.get_current_tab_control().send_speed_settings()
	start_level.emit(path)


func preview_level(path: String) -> void:
	level_preview.set_preview(path)


func return_to_menu() -> void:
	cancel_select.emit()
	queue_free()
