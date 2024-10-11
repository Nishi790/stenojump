@tool
class_name TileMapHolder
extends Node2D

var astar_grid: AStar2D
@export var base_map_layer: TileMapLayer


func _ready() -> void:
	for child in get_children():
		if child is TileMapLayer:
			child.changed.connect(on_tile_map_changed)
	create_astar_grid()

	queue_redraw()


func create_astar_grid() -> void:
	astar_grid = AStar2D.new()
	var index: int = 0

	for child in get_children():
		if child is TileMapLayer:
			var tile_size_x: Vector2i = Vector2i(child.tile_set.tile_size.x, 0)
			var tile_size_y: Vector2i = Vector2i(0, child.tile_set.tile_size.y)
			for tile_coords: Vector2i in child.get_used_cells():
				var tile_data: TileData = child.get_cell_tile_data(tile_coords)
				var tile_world_coords: Vector2i = to_global(child.map_to_local(tile_coords))
				var closest_astar_point: int = astar_grid.get_closest_point(tile_world_coords)

				if child == base_map_layer:
					if tile_data.get_custom_data("navigable"):
						index = create_and_connect_point(tile_world_coords, tile_size_y, tile_size_x, index)
				#Check if this point already exists, if so, just adjust whether or not it's enabled
				elif astar_grid.get_point_position(closest_astar_point) as Vector2i == tile_world_coords:
					var navigable: bool = tile_data.get_custom_data("navigable")
					if not navigable:
						astar_grid.set_point_disabled(closest_astar_point)



func create_and_connect_point(tile_world_coords: Vector2i, tile_size_y: Vector2i, tile_size_x: Vector2i, index: int) -> int:
	astar_grid.add_point(index, tile_world_coords)
	var top_point: Vector2i = tile_world_coords + tile_size_y * Vector2i(scale)
	var bottom_point: Vector2i = tile_world_coords - tile_size_y * Vector2i(scale)
	var left_point: Vector2i = tile_world_coords - tile_size_x * Vector2i(scale)
	var right_point: Vector2i = tile_world_coords + tile_size_x * Vector2i(scale)
	var surrounding_points: Array[Vector2i] = [top_point, bottom_point, left_point, right_point]
	for coord: Vector2i in surrounding_points:
		var point_ID: int = astar_grid.get_closest_point(coord)
		if astar_grid.get_point_position(point_ID) as Vector2i == coord:
			astar_grid.connect_points(point_ID, index)
	return index + 1


#Utility for removing all points under a specoific rect
func disable_points(rect: Rect2) -> void:
	print(rect)
	for point in astar_grid.get_point_ids():
		var point_pos: Vector2 = astar_grid.get_point_position(point)
		if rect.has_point(point_pos):
			astar_grid.set_point_disabled(point)


func _draw() -> void:
	if Engine.is_editor_hint():
		for point_id in astar_grid.get_point_ids():
			if astar_grid.is_point_disabled(point_id):
				var point_pos: Vector2 = to_local(astar_grid.get_point_position(point_id))
				draw_circle(point_pos, 3, Color.RED)
				var connected_points: PackedInt64Array = astar_grid.get_point_connections(point_id)
				for id in connected_points:
					var connection_position: Vector2 = to_local(astar_grid.get_point_position(id))
					draw_dashed_line(point_pos, connection_position, Color.RED, 1, 1)
			else:
				var point_pos: Vector2 = to_local(astar_grid.get_point_position(point_id))
				draw_circle(point_pos, 3, Color.GREEN)
				var connected_points: PackedInt64Array = astar_grid.get_point_connections(point_id)
				for id in connected_points:
					var connection_position: Vector2 = to_local(astar_grid.get_point_position(id))
					if astar_grid.is_point_disabled(id):
						draw_dashed_line(point_pos, connection_position, Color.RED, 1, 1)
					else:
						draw_line(point_pos, connection_position, Color.WHITE, 1)


func on_tile_map_changed() -> void:
	if Engine.is_editor_hint():
		call_deferred("create_astar_grid")
		call_deferred("queue_redraw")
