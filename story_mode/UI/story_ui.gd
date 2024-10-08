class_name StoryUI
extends Control

signal input_received(text: String)

@export var player_input: LineEdit
@export var dialog_balloon: CanvasLayer
@export var quest_display: QuestPanel
@export var stroke_display: MarginContainer
@export var stroke_label: RichTextLabel
@export var meow_action: ActionDisplay
@export var hiss_action: ActionDisplay
@export var item_action: ActionDisplay

var all_actions: Array[ActionDisplay]

func _ready() -> void:
	all_actions = [meow_action, hiss_action, item_action]
	player_input.text_changed.connect(send_new_text)
	player_input.grab_focus()

	dialog_balloon.hide()
	DialogueManager.dialogue_ended.connect(end_dialogue)


func show_actions(action_number: int) -> void:
	match action_number:
		1:
			hiss_action.hide()
			item_action.hide()
		2:
			hiss_action.hide()
		_:
			pass
	initialize_actions()


func initialize_actions():
	for action: ActionDisplay in all_actions:
		if action.visible:
			input_received.connect(action.check_target_match)
			action.action_taken.connect(clear_line)
			action.word_requested.emit()


func send_new_text(text: String)-> void:
	input_received.emit(text)


func clear_line(_args = null) -> void:
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
