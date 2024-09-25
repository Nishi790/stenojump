class_name StoryUI
extends Control

signal input_received(text: String)

@export var player_input: LineEdit
@export var dialog_balloon: CanvasLayer
@export var quest_display: QuestPanel
@export var stroke_display: MarginContainer
@export var stroke_label: RichTextLabel

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
	nodes.append(self)
	dialog_balloon.show()
	dialog_balloon.start(dialogue, key, nodes)


func end_dialogue(_resource: DialogueResource) -> void:
	dialog_balloon.hide()
	player_input.grab_focus()


##Shows a stroke in the center of the screen - for use as part of learning dialogues
func display_stroke(text: String) -> void:
	stroke_display.show()
	stroke_label.clear()
	stroke_label.push_paragraph(HORIZONTAL_ALIGNMENT_CENTER)
	stroke_label.append_text(text)


func hide_stroke() -> void:
	stroke_display.hide()
