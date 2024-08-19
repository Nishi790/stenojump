extends Control

signal menu_selected
signal resume_game_selected
signal options_selected

@export var resume_button: Button
@export var options_button: Button
@export var menu_button: Button

func _ready() -> void:
	resume_button.pressed.connect(resume_game)
	options_button.pressed.connect(open_options)
	menu_button.pressed.connect(go_to_menu)


func resume_game():
	queue_free()
	resume_game_selected.emit()



func open_options():
	options_selected.emit()


func go_to_menu():
	menu_selected.emit()
	self.queue_free()
