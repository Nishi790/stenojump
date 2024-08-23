class_name BackgroundManager
extends Node2D

@export var ground_sprite: Parallax2D

var background_stopped: bool = false
var base_autoscroll_speeds: Array[Vector2] = [Vector2(-10, 0), Vector2(-30, 0), Vector2(-50, 0), Vector2(-100, 0), Vector2(-200, 0)]
var speed_scale: int = 1
var ground_autoscroll_rate: Vector2


func _ready() -> void:
	pass


func pause_parallax() -> void:
	background_stopped = true
	for layer in get_children():
		var layer_position: Vector2 = layer.position
		layer.set_autoscroll(Vector2.ZERO)
		layer.position = layer_position


func resume_parallax() -> void:
	background_stopped = false
	var index: int = 0
	for layer in get_children():
		#Save current position (equivalent to offset), setting autoscroll resets position
		var layer_position: Vector2 = layer.position
		layer.set_autoscroll(base_autoscroll_speeds[index] * speed_scale)
		layer.scroll_offset = layer_position
		index += 1
