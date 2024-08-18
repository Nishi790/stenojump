extends Control

signal start_game_pressed

@export var start_menu: PackedScene
@export var options_menu: PackedScene
@export var resume_game_menu: PackedScene
@export var resume_game_button: Button
@export var new_game_button: Button
@export var options_button: Button


func _ready():
	resume_game_button.pressed.connect(resume_game)
	new_game_button.pressed.connect(new_game)
	options_button.pressed.connect(open_options)


func resume_game():
	pass


func new_game():
	var menu = start_menu.instantiate()
	menu.start_game_pressed.connect(start_game)
	add_child(menu)


func open_options():
	pass


func start_game():
	start_game_pressed.emit()
