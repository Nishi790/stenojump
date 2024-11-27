class_name BackgroundManager
extends Node2D

var base_autoscroll_speeds: Array[Vector2] = [Vector2(-20, 0), Vector2(-50, 0), Vector2(-80, 0), Vector2(-150, 0), Vector2(-200, 0)]
var speed_scale: float = 1.0
var speed_multiplier: float

var current_theme: LevelTheme

#func _ready() -> void:
#	set_parallax_textures(current_theme)


func set_parallax_textures(theme: LevelTheme) -> void:
	current_theme = theme
	var parallax_textures: Dictionary = current_theme.parallax_layers
	var number_of_layers: int = get_child_count()
	for index: int in number_of_layers:
		var sprite: Sprite2D = get_child(index).get_child(0)
		if parallax_textures.has(index):
			sprite.texture = parallax_textures[index]
		else:
			sprite.texture = null



func run_parallax(multiplier: float = 1.0) -> void:
	speed_scale = multiplier
	var index: int = 0
	for layer in get_children():
		#Save current position (equivalent to offset), setting autoscroll resets position
		var layer_position: Vector2 = layer.position
		if index < 2 and multiplier == 0.0:
			layer.set_autoscroll(base_autoscroll_speeds[index] * 0.4)
		else:
			layer.set_autoscroll(base_autoscroll_speeds[index] * speed_scale)
		layer.scroll_offset = layer_position
		index += 1
