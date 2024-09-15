class_name LessonLevelMap
extends Node2D


@export var waypoints: Array [Marker2D]
@export var interactables: Array[BaseInteractable]

var waypoint_astar_grid: AStar2D
var astar_nav_grid: AStar2D

@export var tile_map_holder: Node2D
@export var tile_map_base: TileMapLayer
@export var tile_map_obstacles: TileMapLayer

@export var player: SelfNavCharacter


func _ready() -> void:
	#Initialize AStar grid
	astar_nav_grid = AStar2D.new()
	var index: int = 0
	var tile_size_x: Vector2i = Vector2i(tile_map_base.tile_set.tile_size.x * tile_map_holder.scale.x, 0)
	var tile_size_y: Vector2i = Vector2i(0, tile_map_base.tile_set.tile_size.y * tile_map_holder.scale.y)
	var top_point: Vector2i
	var bottom_point: Vector2i
	var left_point: Vector2i
	var right_point: Vector2i

	#Cycle through all floor tiles
	for tile_coords in tile_map_base.get_used_cells():
		var tile_data: TileData = tile_map_base.get_cell_tile_data(tile_coords)
		if tile_data.get_custom_data("navigable"):

			#Skip this tile if there is something non-navigable in the obstacle layer
			var obstacle_check_data: TileData = tile_map_obstacles.get_cell_tile_data(tile_coords)
			if obstacle_check_data != null and obstacle_check_data.get_custom_data("navigable") == false:
				continue

			#Add nav point and check for adjacent points (within 1 tile, all cardinal directions) and conncet them
			var tile_world_coords: Vector2i = tile_map_base.map_to_local(tile_coords) * tile_map_holder.scale
			astar_nav_grid.add_point(index, tile_world_coords)
			top_point = tile_world_coords + tile_size_y
			bottom_point = tile_world_coords - tile_size_y
			left_point = tile_world_coords - tile_size_x
			right_point = tile_world_coords + tile_size_x
			var surrounding_points: Array[Vector2i] = [top_point, bottom_point, left_point, right_point]
			for coord in surrounding_points:
				var point_ID: int = astar_nav_grid.get_closest_point(coord)
				if astar_nav_grid.get_point_position(point_ID) as Vector2i == coord:
					astar_nav_grid.connect_points(point_ID, index)
			index += 1

	#player.nav_astar = astar_nav_grid
	#For testing: draw grid
	queue_redraw()

	#Set up interactables
	for inter in interactables:
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


func switch_point_connection(points: Vector2i) -> void:
	if astar_nav_grid.are_points_connected(points.x, points.y):
		astar_nav_grid.disconnect_points(points.x, points.y)
	else:
		astar_nav_grid.connect_points(points.x, points.y)
	queue_redraw()


func _draw() -> void:
	if Engine.is_editor_hint():
		for point_id in astar_nav_grid.get_point_ids():
			var point: Vector2i = astar_nav_grid.get_point_position(point_id)
			draw_circle(point, 3, Color.GREEN)
			var connected_points: PackedInt64Array = astar_nav_grid.get_point_connections(point_id)
			for id in connected_points:
				var connection_position: Vector2 = astar_nav_grid.get_point_position(id)
				draw_line(point, connection_position, Color.WHITE)
