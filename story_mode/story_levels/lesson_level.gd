class_name LessonLevelMap
extends Node2D

signal word_used
signal quest_started(quest_data: BaseQuest)
signal quest_completed(quest_name: String)
signal dialogue_started(dialogue_key: String, dialogue: DialogueResource)

@export var waypoints: Array [Waypoint]

var waypoint_astar_grid: AStar2D
var astar_nav_grid: AStar2D
var event_funcs: Dictionary #Should be given keys/values in inherited class
@export var generic_dialog: DialogueResource

@export var tile_map_holder: Node2D
@export var level_word_list: StoryLevelData:
	set(new_data):
		level_word_list = new_data
		if new_data == null:
			return
		level_word_list.quest_started.connect(start_new_quest)
		level_word_list.quest_finished.connect(complete_quest)
		level_word_list.dialog_started.connect(start_dialog)
		level_word_list.event_triggered.connect(call_event)

@export var player: Socks:
	set(new_player):
		player = new_player
		player.nav_astar = astar_nav_grid

@export var available_actions: int = 3

var current_player_point: Waypoint


func _ready() -> void:
	#Initialize AStar grid
	astar_nav_grid = tile_map_holder.astar_grid
	queue_redraw()

	#Set up interactables
	waypoint_astar_grid = AStar2D.new()
	print(waypoints)
	for way_index in waypoints.size():
		var inter: Waypoint = waypoints[way_index]

		inter.request_target_word.connect(provide_target.bind(inter))
		inter.move_destination_selected.connect(set_player_destination)
		inter.tried_event.connect(level_word_list.update_event)
		inter.tried_action.connect(level_word_list.update_action_event)
		inter.became_current_point.connect(set_current_player_point)
		if inter is BaseInteractable:
			if not inter.enable_requirement.is_empty():
				level_word_list.event_triggered.connect(inter.enable_interact)
			inter.failed_interact.connect(start_dialog)
			var tex_rect: Rect2 = inter.get_tex_rect()
			tile_map_holder.disable_points(tex_rect)

		if inter is ConnectionInteractable:
			var area_shape: CollisionShape2D = inter.get_child(0)
			var area_rect: Rect2 = area_shape.get_shape().get_rect()
			var area_pos: Vector2 = inter.global_position
			var right_index: int = astar_nav_grid.get_closest_point(area_pos + Vector2(area_rect.size.x/2, 0))
			var left_index: int = astar_nav_grid.get_closest_point(area_pos - Vector2(area_rect.size.x/2, 0))
			var door_points: Vector2i = Vector2i(right_index, left_index)
			inter.connected_by_door = door_points
			if not inter.door_open:
				switch_point_connection(door_points)
			inter.change_connection.connect(switch_point_connection)

		waypoint_astar_grid.add_point(way_index, inter.global_position)
		for connection in inter.connected_points:
			var point_ID: int = waypoint_astar_grid.get_closest_point(connection.global_position)
			if waypoint_astar_grid.get_point_position(point_ID) == connection.global_position:
				waypoint_astar_grid.connect_points(point_ID, way_index)

	await get_tree().process_frame
	level_word_list.start_level()
	_load_event_funcs()


func _load_event_funcs() -> void:
	pass


func switch_point_connection(points: Vector2i) -> void:
	if astar_nav_grid.are_points_connected(points.x, points.y):
		astar_nav_grid.disconnect_points(points.x, points.y)
	else:
		astar_nav_grid.connect_points(points.x, points.y)


func provide_target(requester: Waypoint) -> void:
	var next_word: Dictionary = level_word_list.get_next_word()
	requester.set_target(next_word)


func provide_action_target(requester: ActionDisplay) -> void:
	var next_word: Dictionary = level_word_list.get_next_word()
	requester.set_target_word(next_word)


func initiate_words() -> void:
	var current_pos: Vector2 = player.global_position
	var closest_point: int = waypoint_astar_grid.get_closest_point(current_pos)
	var closest_obj: Waypoint = waypoints[closest_point]
	closest_obj.initiate_words(player.interaction_area)


func set_current_player_point(point: Waypoint) -> void:
	current_player_point = point


## Send text through available waypoints to look for match
func propagate_entry(text: String)-> void:
	for way in waypoints:
		var match_found: bool = way.check_target_match(text)
		if match_found:
			word_used.emit()
			break


func propagate_action(action: Socks.GeneralActions) -> void:
	print("Trying action %s on %s" % [Socks.GeneralActions.find_key(action), current_player_point.target_word])
	current_player_point.try_action_event(action)


func set_player_destination(point: Waypoint) -> void:
	var navigation_success: bool = player.nav_to_interest_point(point.global_position)
	if not navigation_success and point is ConnectionInteractable:
		var door_collider: Shape2D = point.shape_owner_get_shape(0, 0)
		var door_collider_rect: Rect2 = door_collider.get_rect()
		var door_collider_left_side: Vector2 = point.to_global(door_collider_rect.position) +  Vector2(0, door_collider_rect.size.y/2)
		var door_collider_right_side: Vector2 = door_collider_left_side + Vector2(door_collider_rect.size.x, 0)
		navigation_success = player.nav_to_interest_point(door_collider_left_side)
		if not navigation_success:
			navigation_success = player.nav_to_interest_point(door_collider_right_side)

	if not navigation_success:
		start_dialog("failed_navigation", generic_dialog)
		current_player_point.initiate_words(player.interaction_area)



func start_new_quest(quest_data: BaseQuest) -> void:
	quest_started.emit(quest_data)


func complete_quest(quest_name: String) -> void:
	quest_completed.emit(quest_name)


func start_dialog(dialogue_key: String, dialogue: DialogueResource = level_word_list.dialogue_resource) -> void:
	print("Level received dialog: %s"  % dialogue_key)
	dialogue_started.emit(dialogue_key, dialogue)


func _draw() -> void:
	if OS.is_debug_build():
		for point_id in astar_nav_grid.get_point_ids():
			var point: Vector2i = astar_nav_grid.get_point_position(point_id)
			if astar_nav_grid.is_point_disabled(point_id):
				draw_circle(point, 3, Color.RED)
			else:
				draw_circle(point, 3, Color.GREEN)
			var connected_points: PackedInt64Array = astar_nav_grid.get_point_connections(point_id)
			for id in connected_points:
				var connection_position: Vector2 = astar_nav_grid.get_point_position(id)
				if astar_nav_grid.is_point_disabled(id):
					draw_line(point, connection_position, Color.RED)
				else:
					draw_line(point, connection_position, Color.WHITE)


func call_event(event_name: String, args: Array = []) -> void:
	if event_name.begins_with("dialog"):
		var dialog_name: String = event_name.lstrip("dialog_")
		start_dialog(dialog_name, level_word_list.dialogue_resource)
	else:
		var event_callable: Callable = event_funcs[event_name]
		event_callable.call(args)
