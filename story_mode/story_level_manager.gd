extends Node

@export var player: SelfNavCharacter
@export var UI: Control
@export var camera: Camera2D
@export var level: LessonLevelMap

func _ready() -> void:
	camera.player = player
	camera.follow_player = true
	camera.update_limits(level.tile_map_base)

	level.player = player
	level.initiate_words()
