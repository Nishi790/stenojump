extends Camera2D

@export var player: SelfNavCharacter

var follow_player: bool = false

func _process(delta: float) -> void:
	if follow_player:
		position = player.position


func update_limits(map: TileMapLayer) -> void:
	var map_area: Rect2 = map.get_used_rect()
	limit_top = map_area.position.x
	limit_bottom = map_area.position.x + map_area.size.x
	limit_left = map_area.position.y
	limit_right = limit_left + map_area.size.y
	print("left lim %s, right lim %s, top lim %s, bottom lim %s"  %  [limit_left, limit_right, limit_top, limit_bottom])
