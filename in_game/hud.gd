class_name HUD
extends Control

@export var ingame_message: Label
@export var lives_counter: Label
@export var score_counter: Label
@export var word_counter: Label


func _ready():
	ingame_message.hide()


func life_lost_reset():
	ingame_message.set_text("Oops, let's try again")
	ingame_message.show()


func display_countdown():
	await get_tree().create_timer(1).timeout
	ingame_message.set_text("3")
	await get_tree().create_timer(1).timeout
	ingame_message.set_text("2")
	await get_tree().create_timer(1).timeout
	ingame_message.set_text("1")
	await get_tree().create_timer(1).timeout
	ingame_message.hide()
	return


func level_complete():
	ingame_message.set_text("Level Complete! \n Press Enter (R-R) to proceed")
	ingame_message.show()


func start_next_level():
	ingame_message.set_text("Next level starting in:")
	await get_tree().create_timer(2).timeout


func game_over():
	ingame_message.set_text("Game Over")
	ingame_message.show()
