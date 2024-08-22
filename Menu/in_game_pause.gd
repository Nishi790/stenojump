extends Control

signal menu_selected
signal resume_game_selected
signal options_selected

@export var resume_button: Button
@export var options_button: Button
@export var menu_button: Button
@export var text_entry: LineEdit

func _ready() -> void:
	process_mode = ProcessMode.PROCESS_MODE_WHEN_PAUSED
	resume_button.pressed.connect(resume_game)
	options_button.pressed.connect(open_options)
	menu_button.pressed.connect(go_to_menu)
	text_entry.grab_focus()
	text_entry.text_submitted.connect(parse_text)


func resume_game():
	queue_free()
	resume_game_selected.emit()


func open_options():
	options_selected.emit()


func go_to_menu():
	menu_selected.emit()
	queue_free()
	get_tree().paused = false


func parse_text(text: String):
	var text_submitted = text.strip_edges()
	text_submitted = text_submitted.to_lower()
	match text_submitted:
		"main menu":
			go_to_menu()
		"options":
			open_options()
		"resume":
			resume_game()
