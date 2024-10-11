extends GutTest

var maps: TileMapHolder
var layers: Array[TileMapLayer]
var waypoint: Waypoint


func before_all() -> void:
	var floor_layer: TileMapLayer = autoqfree(TileMapLayer.new())
	layers.append(floor_layer)
	var tileset: TileSet = load("res://story_mode/story_levels/Tilesets/placeholder_interior_walls_floors.tres")
	floor_layer.tile_set = tileset

	var max_rows: int = 3
	var max_cols: int = 3
	var row_index: int = 0
	var column_index: int = 0
	while row_index <= max_rows:
		while column_index <= max_cols:
			floor_layer.set_cell(Vector2i(row_index, column_index), 0, Vector2i(11, 7))
			column_index += 1
		column_index = 0
		row_index += 1

	var obstacle_layer: TileMapLayer = autoqfree(TileMapLayer.new())
	layers.append(obstacle_layer)
	obstacle_layer.tile_set = tileset
	obstacle_layer.set_cell(Vector2i(2,2), 0, Vector2i(6,10))
	maps = partial_double(TileMapHolder).new()
	maps.base_map_layer = floor_layer
	for layer: TileMapLayer in layers:
		maps.add_child(layer)
	add_child_autoqfree(maps)


func test_astar_gen() -> void:
	maps.create_astar_grid()
	var tile_center: Vector2i = maps.base_map_layer.map_to_local(Vector2i(2, 2))
	var point_at_obstacle: int = maps.astar_grid.get_closest_point(tile_center, true)
	assert_true(maps.astar_grid.is_point_disabled(point_at_obstacle), "non-navigable tiles should disable astar points under them")
	var clear_point: int = maps.astar_grid.get_closest_point(maps.base_map_layer.map_to_local(Vector2i(1, 1)))
	assert_false(maps.astar_grid.is_point_disabled(clear_point), "navigable tiles should have active astar points")


func test_set_astar_point() -> void:
	var level: LessonLevelMap = autoqfree(LessonLevelMap.new())
	level.astar_nav_grid = maps.astar_grid
	level.tile_map_holder = maps
	level.level_word_list = load("res://story_mode/story_levels/level_words/level_1_story_data.tres")

	var waypoint: Waypoint = double(Waypoint).new()
	add_child(waypoint)
	waypoint.position = Vector2(17, 8)
	level.set_up_waypoint(waypoint)
	assert_eq(waypoint.astar_point, 4)

	waypoint.queue_free()
	waypoint = double(Waypoint).new()
	add_child(waypoint)
	waypoint.position = Vector2(24, 8)
	level.set_up_waypoint(waypoint)
	assert_eq(waypoint.astar_point, 4)

	waypoint.queue_free()
	waypoint = double(Waypoint).new()
	add_child(waypoint)
	waypoint.position = Vector2(35, 8)
	level.set_up_waypoint(waypoint)
	assert_ne(waypoint.astar_point, 4, "Should now be closer to the next point over")
	assert_eq(waypoint.astar_point, 8)

	waypoint.queue_free()
	waypoint = double(Waypoint).new()
	add_child(waypoint)
	waypoint.position = Vector2(8, 17)
	level.set_up_waypoint(waypoint)
	assert_eq(waypoint.astar_point, 1)
