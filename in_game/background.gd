class_name BackgroundManager
extends Node2D

var base_autoscroll_speeds: Array[Vector2] = [Vector2(-20, 0), Vector2(-50, 0), Vector2(-80, 0), Vector2(-150, 0), Vector2(-200, 0)]
var speed_scale: float = 1.0
var speed_multiplier: float

@export var parallax_layer_textures: Dictionary
var current_theme: RunnerGame.RunnerThemes

func _ready() -> void:
	set_parallax_textures(RunnerGame.RunnerThemes.STREET_DIRTY)


func set_parallax_textures(theme: RunnerGame.RunnerThemes, transition: bool = false) -> void:
	if not transition:
		current_theme = theme
		if parallax_layer_textures.has(current_theme):
			var theme_dict: Dictionary = parallax_layer_textures[current_theme]
			var theme_keys: Array = theme_dict.keys()
			var number_of_layers: int = get_child_count()
			for index: int in number_of_layers:
				var sprite: Sprite2D = get_child(index).get_child(0)
				if theme_keys.has(index):
					sprite.texture = theme_dict[index]
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
