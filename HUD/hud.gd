class_name HUD
extends Control

signal resume_game_requested
signal main_menu_requested
signal game_options_requested

@export var ingame_message: RichTextLabel
@export var lives_counter: Label
@export var score_counter: Label
@export var word_counter: Label
@export var wpm_counter: Label
@export var message_container: Container
@export var input_box: LineEdit
@export var pause_menu_scene: PackedScene

var hint_string: String = "[center]You wrote [b]%s[/b].\n
The word %s is stroked [b]%s[/b]. \n
Press Enter (R-R) to continue.[/center] "

var paused: bool = false

func _ready() -> void:
	message_container.hide()


func life_lost_reset() -> void:
	input_box.editable = false
	input_box.clear()


func display_countdown() -> bool:
	ingame_message.set_text("[center]3[/center]")
	await get_tree().create_timer(1).timeout
	if paused == true:
		return false
	ingame_message.set_text("[center]2[/center]")
	await get_tree().create_timer(1).timeout
	if paused == true:
		return false
	ingame_message.set_text("[center]1[/center]")
	await get_tree().create_timer(1).timeout
	if paused == true:
		return false
	message_container.hide()
	get_tree().paused = false
	input_box.editable = true
	return true


func display_hint(target_text: String, hint_text: String, error_text: String) -> void:
	message_container.show()
	ingame_message.set_text(hint_string % [error_text, target_text, hint_text])


func level_complete() -> void:
	ingame_message.set_text("[center]Level Complete! \n Press Enter (R-R) to proceed[/center]")
	message_container.show()


func start_next_level() -> void:
	input_box.clear()
	input_box.editable = false
	ingame_message.set_text("Next level starting in:")
	await get_tree().create_timer(1).timeout


func game_over() -> void:
	ingame_message.set_text("[center]Game Over \n Press Enter (%s) to return to menu.[/center]" % "R-R")
	message_container.show()


func wpm_changed(wpm: float) -> void:
	wpm_counter.update_wpm(wpm)


func open_pause_menu() -> void:
	paused = true
	var pause: Control = pause_menu_scene.instantiate()
	pause.menu_selected.connect(return_to_menu)
	pause.resume_game_selected.connect(resume_game)
	pause.options_selected.connect(open_game_options)
	add_child(pause)
	get_tree().paused = true

#emitted when something requests return to main menu - no connected
#functionality yet
func return_to_menu() -> void:
	main_menu_requested.emit()

#emitted to request ongoing play to resume
func resume_game() -> void:
	paused = false
	message_container.visible = true
	display_countdown()
	input_box.editable = true
	input_box.grab_focus()
	resume_game_requested.emit()


func open_game_options() -> void:
	#TODO decide how to handle opening game options while in game
	#Probably child of hud - give hud the packed scene? Or child of game controller...
	game_options_requested.emit()
