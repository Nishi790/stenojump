class_name StoryLevelManager
extends Node

signal level_complete

@export var player: Socks
@export var UI: StoryUI
@export var camera: Camera2D
@export var level_holder: Node2D
@export var level: LessonLevelMap

var hints_visible: bool = false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("skip_dialogue"):
		UI.skip_dialogue()
	if event.is_action_pressed("confirm") and UI.dialog_balloon.visible == false:
		set_hints_visible(!hints_visible)


func _ready() -> void:
	camera.player = player
	camera.follow_player = true


	if level:
		set_level(level)



func set_level(new_level: LessonLevelMap) -> void:
	if level:
		level.queue_free()

	level_holder.add_child(new_level)
	level_holder.move_child(new_level, 0)

	level = new_level
	level.player = player
	level.word_used.connect(UI.clear_line)
	level.initiate_words()
	level.quest_started.connect(start_quest)
	level.quest_completed.connect(finish_quest)
	level.dialogue_started.connect(start_dialogue)
	level.level_complete.connect(func end_level(): level_complete.emit())

	camera.update_limits(level.tile_map_holder.base_map_layer, level.tile_map_holder.scale)
	set_hints_visible(false)

	for action: ActionDisplay in UI.all_actions:
		action.word_requested.connect(level.provide_action_target.bind(action))
		action.action_taken.connect(level.propagate_action)

	UI.input_received.connect(level.propagate_entry)
	UI.show_actions(level.available_actions)


func set_hints_visible(value: bool) -> void:
	hints_visible = value
	for point: Waypoint in level.waypoints:
		point.hints_active = value
	UI.set_hints_visible(value)


func start_quest(quest_data: BaseQuest) -> void:
	UI.display_quest(quest_data)


func finish_quest(quest_name: String) -> void:
	UI.finish_quest(quest_name)


func start_dialogue(key: String, dialogue: DialogueResource) -> void:
	print("dialogue start requested with key %s" % key)
	UI.start_dialogue(key, dialogue, [self])
