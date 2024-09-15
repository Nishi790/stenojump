extends Camera2D

@export var player: SelfNavCharacter

var follow_player: bool = false

func _process(delta: float) -> void:
	if follow_player:
		global_position = player.global_position


func update_limits(map: TileMapLayer, map_scale: Vector2) -> void:
	var map_area: Rect2 = map.get_used_rect()
	var map_tile_size: Vector2 = map.tile_set.tile_size
	limit_top = map_area.position.y * map_tile_size.y * map_scale.y
	limit_bottom = (map_area.position.y + map_area.size.y) * map_tile_size.y * map_scale.y
	limit_left = map_area.position.x * map_tile_size.x * map_scale.x
	limit_right = (limit_left + map_area.size.x) * map_tile_size.x * map_scale.x
	print("left lim %s, right lim %s, top lim %s, bottom lim %s"  %  [limit_left, limit_right, limit_top, limit_bottom])
