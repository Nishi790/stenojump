extends Control

signal returned_to_menu
signal new_neighbors(neighbors: Array[Node])

@export var gameplay_tab: PanelContainer
@export var graphics_tab: PanelContainer
@export var sound_tab: PanelContainer
@export var tabs: TabContainer


func _ready() -> void:
	gameplay_tab.menu_pressed.connect(exit_options)
	graphics_tab.menu_pressed.connect(exit_options)
	#sound_tab.menu_pressed.connect(exit_options)

	tabs.tab_changed.connect(send_focus_neighbors)


func exit_options() -> void:
	returned_to_menu.emit()
	PlayerConfig.save_universal_settings()
	queue_free()


func send_focus_neighbors(tab: int) -> void:
	var neighbor_array: Array[Node] = []
	match tab:
		0:
			#Create Array of focus neighbors in order left, top, right, bottom, next, previous
			neighbor_array.append(gameplay_tab.level_size_toggle)
			neighbor_array.append(gameplay_tab.level_size_toggle)
			neighbor_array.append(gameplay_tab.level_size_toggle)
			neighbor_array.append(gameplay_tab.menu_button)
			neighbor_array.append(gameplay_tab.level_size_toggle)
			neighbor_array.append(gameplay_tab.menu_button)
		1:
			neighbor_array.append(graphics_tab.target_vis_picker)
			neighbor_array.append(graphics_tab.target_vis_picker)
			neighbor_array.append(graphics_tab.target_vis_picker)
			neighbor_array.append(graphics_tab.menu_button)
			neighbor_array.append(graphics_tab.target_vis_picker)
			neighbor_array.append(graphics_tab.menu_button)
		2:
			pass
	new_neighbors.emit()
