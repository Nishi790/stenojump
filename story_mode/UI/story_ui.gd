class_name StoryUI
extends Control

signal input_received(text: String)

@export var player_input: LineEdit
@export var dialog_balloon: CanvasLayer
@export var quest_display: PanelContainer

@export var level_data: Resource

func _ready() -> void:
	player_input.text_changed.connect(send_new_text)
	player_input.grab_focus()

	dialog_balloon.hide()
	quest_display.hide()


func send_new_text(text: String)-> void:
	input_received.emit(text)


func clear_line() -> void:
	player_input.clear()
