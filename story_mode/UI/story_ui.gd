class_name StoryUI
extends Control

signal input_received(text: String)

@export var player_input: LineEdit
@export var dialog_balloon: CanvasLayer
@export var quest_display: QuestPanel


func _ready() -> void:
	player_input.text_changed.connect(send_new_text)
	player_input.grab_focus()

	dialog_balloon.hide()
	DialogueManager.dialogue_ended.connect(end_dialogue)


func send_new_text(text: String)-> void:
	input_received.emit(text)


func clear_line() -> void:
	player_input.clear()


func display_quest(quest_data: BaseQuest) -> void:
	quest_display.add_quest_entry(quest_data)


func finish_quest(quest_name: String) -> void:
	quest_display.finish_quest(quest_name)



func start_dialogue(key: String, dialogue: DialogueResource, nodes: Array[Node]) -> void:
	dialog_balloon.show()
	dialog_balloon.start(dialogue, key, nodes)


func end_dialogue(resource: DialogueResource) -> void:
	dialog_balloon.hide()
	player_input.grab_focus()
