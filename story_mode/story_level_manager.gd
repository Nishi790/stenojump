class_name StoryLevelManager
extends Node

@export var player: Socks
@export var UI: StoryUI
@export var camera: Camera2D
@export var level: LessonLevelMap

var hints_visible: bool = false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("skip_dialogue"):
		UI.skip_dialogue()


func _ready() -> void:
	camera.player = player
	camera.follow_player = true
	camera.update_limits(level.tile_map_holder.base_map_layer, level.tile_map_holder.scale)

	level.player = player
	level.word_used.connect(UI.clear_line)
	level.initiate_words()
	level.quest_started.connect(start_quest)
	level.quest_completed.connect(finish_quest)
	level.dialogue_started.connect(start_dialogue)

	set_hints_visible(false)

	UI.input_received.connect(level.propagate_entry)
	for action: ActionDisplay in UI.all_actions:
		action.word_requested.connect(level.provide_action_target.bind(action))
		action.action_taken.connect(level.propagate_action)
	UI.show_actions(level.available_actions)


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
