class_name BackgroundManager
extends Node2D

@export var ground_sprite: Parallax2D

var obstacles_stopped: bool = false
var background_stopped: bool = false
var base_autoscroll_speeds: Array[Vector2] = [Vector2(-10, 0), Vector2(-30, 0), Vector2(-50, 0), Vector2(-100, 0), Vector2(-200, 0)]
var speed_scale: int = 1
var ground_autoscroll_rate: Vector2

func _ready():
	pass


func pause_obstacles ():
	obstacles_stopped = true
	ground_autoscroll_rate = ground_sprite.get_autoscroll()
	ground_sprite.set_autoscroll(Vector2.ZERO)


func resume_obstacles ():
	obstacles_stopped = false
	ground_sprite.set_autoscroll(ground_autoscroll_rate)


func pause_parallax():
	background_stopped = true
	obstacles_stopped = true
	for layer in get_children():
		layer.set_autoscroll(Vector2.ZERO)


func resume_parallax():
	background_stopped = false
	obstacles_stopped = false
	var index: int = 0
	for layer in get_children():
		layer.set_autoscroll(base_autoscroll_speeds[index] * speed_scale)
		index += 1
