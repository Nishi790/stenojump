extends Node

@export var player: SelfNavCharacter
@export var UI: StoryUI
@export var camera: Camera2D
@export var level: LessonLevelMap

var hints_visible: bool = false

func _ready() -> void:
	camera.player = player
	camera.follow_player = true
	print("Level map holder position is ", level.global_position)
	camera.update_limits(level.tile_map_holder.base_map_layer, level.tile_map_holder.scale)

	level.player = player
	level.word_used.connect(UI.clear_line)
	level.initiate_words()
	level.quest_started.connect(start_quest)
	level.quest_completed.connect(finish_quest)
	level.dialogue_started.connect(start_dialogue)

	set_hints_visible(false)

	UI.input_received.connect(level.propagate_entry)



func set_hints_visible(value: bool) -> void:
	for point: Waypoint in level.waypoints:
		point.hints_active = value


func start_quest(quest_data: BaseQuest) -> void:
	print("Starting quest %s" % quest_data.name)
	UI.display_quest(quest_data)


func finish_quest(quest_name: String) -> void:
	UI.finish_quest(quest_name)


func start_dialogue(key: String, dialogue: DialogueResource) -> void:
	print("dialogue start requested with key %s" % key)
	UI.start_dialogue(key, dialogue, [self])
