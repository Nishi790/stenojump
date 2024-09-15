extends Node

@export var player: SelfNavCharacter
@export var UI: StoryUI
@export var camera: Camera2D
@export var level: LessonLevelMap

var hints_visible: bool = false

func _ready() -> void:
	camera.player = player
	camera.follow_player = true
	camera.update_limits(level.tile_map_base, level.tile_map_holder.scale)

	level.player = player
	level.word_used.connect(UI.clear_line)
	level.initiate_words()

	UI.input_received.connect(level.propagate_entry)



func set_hints_visible(value: bool) -> void:
	for point: Waypoint in level.waypoints:
		point.hints_active = value
