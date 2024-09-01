extends LineEdit

enum MenuState {MAIN, OPTIONS, NEW}

@export var main_menu_focus_neighbors: Array[Control]
var start_game_focus_neigbours: Array[Control]
var options_focus_neighbors: Array[Control]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _input(event: InputEvent) -> void:
	if has_focus():
		if event.is_action_pressed("ui_focus_next"):
			accept_event()
			get_node(focus_next).grab_focus()
		elif event.is_action_pressed("ui_focus_prev"):
			accept_event()
			get_node(focus_previous).grab_focus()
		elif event.is_action_pressed("ui_up"):
			accept_event()
			get_node(focus_neighbor_top).grab_focus()
		elif event.is_action_pressed("ui_down"):
			accept_event()
			get_node(focus_neighbor_bottom).grab_focus()
		elif event.is_action_pressed("ui_left"):
			accept_event()
			get_node(focus_neighbor_top).grab_focus()
		elif event.is_action_pressed("ui_right"):
			accept_event()
			get_node(focus_neighbor_right).grab_focus()


func reset_focus_neighbors(menu_arrangement: MenuState) -> void:
	var new_neighbors: Array[Control]
	match menu_arrangement:
		MenuState.MAIN:
			new_neighbors = main_menu_focus_neighbors
		MenuState.OPTIONS:
			new_neighbors = options_focus_neighbors
		MenuState.NEW:
			new_neighbors = start_game_focus_neigbours

	focus_neighbor_left = get_path_to(new_neighbors[0])
	focus_neighbor_top = get_path_to(new_neighbors[1])
	focus_neighbor_right = get_path_to(new_neighbors[2])
	focus_neighbor_bottom = get_path_to(new_neighbors[3])
	focus_next = get_path_to(new_neighbors[4])
	focus_previous = get_path_to(new_neighbors[5])
