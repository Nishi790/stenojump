extends Camera2D

@export var player: Socks

var follow_player: bool = false

func _process(_delta: float) -> void:
	if follow_player:
		global_position = player.global_position


func update_limits(map: TileMapLayer, map_scale: Vector2) -> void:
	var map_area: Rect2 = map.get_used_rect()
	var map_position: Vector2 = map.to_global(map_area.position)

	var real_map_height: int = map_area.size.y * map.tile_set.tile_size.y * map_scale.y
	var real_map_width: int = map_area.size.x * map.tile_set.tile_size.x * map_scale.x
	var pixel_map_pos_x: int = map_position.x * map.tile_set.tile_size.x
	var pixel_map_pos_y: int = map_position.y * map.tile_set.tile_size.y

	if pixel_map_pos_y < 0:
		limit_top = 0
	else:
		limit_top = pixel_map_pos_y
	limit_bottom = pixel_map_pos_y + real_map_height
	limit_left = pixel_map_pos_x
	limit_right = pixel_map_pos_x + real_map_width
	print("left lim %s, right lim %s, top lim %s, bottom lim %s"  %  [limit_left, limit_right, limit_top, limit_bottom])
