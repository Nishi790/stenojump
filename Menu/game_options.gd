extends Control

signal returned_to_menu
signal new_neighbors(neighbors: Array[Node])

@export var gameplay_tab: PanelContainer
@export var graphics_tab: PanelContainer
@export var sound_tab: PanelContainer
@export var tabs: TabContainer

var side_focus: LineEdit

func _ready() -> void:
	gameplay_tab.menu_pressed.connect(exit_options)
	graphics_tab.menu_pressed.connect(exit_options)
	sound_tab.menu_pressed.connect(exit_options)

	for index in tabs.get_tab_count():
		var tab_control: Control = tabs.get_tab_control(index)
		var tab_bar: TabBar = tabs.get_tab_bar()
		tab_control.menu_button.focus_next = tab_bar.get_path()

	tabs.tab_changed.connect(send_focus_neighbors)
	send_focus_neighbors(0)


func process_text(text: String) -> bool:
	var processed: bool = tabs.get_current_tab_control().process_text(text)
	return processed


func exit_options() -> void:
	returned_to_menu.emit()
	PlayerConfig.save_universal_settings()
	queue_free()


func send_focus_neighbors(tab: int) -> void:
	var neighbor_array: Array[Control] = []
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
			neighbor_array.append(sound_tab.menu_button)
			neighbor_array.append(sound_tab.menu_button)
			neighbor_array.append(sound_tab.menu_button)
			neighbor_array.append(sound_tab.menu_button)
			neighbor_array.append(sound_tab.menu_button)
			neighbor_array.append(sound_tab.menu_button)
	assign_side_focus(tab)
	new_neighbors.emit(neighbor_array)


func assign_side_focus(tab: int) -> void:
	var target_tab: Control = tabs.get_tab_control(tab)
	if side_focus != null:
		var path: NodePath = side_focus.get_path()
		for child in target_tab.get_children(true):
			if child is Control and child.focus_mode != FOCUS_NONE:
				child.focus_neighbor_left = path
				child.focus_neighbos_right = path
	target_tab.initiate_focus()
