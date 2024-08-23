extends Control

signal start_game_pressed
signal quit_game_pressed

@export var start_menu: PackedScene
@export var options_menu: PackedScene
@export var resume_game_button: Button
@export var new_game_button: Button
@export var options_button: Button
@export var quit_game_button: Button


func _ready() -> void:
	resume_game_button.pressed.connect(resume_game)
	new_game_button.pressed.connect(new_game)
	options_button.pressed.connect(open_options)
	quit_game_button.pressed.connect(quit_game)
	if PlayerConfig.has_saved_level():
		resume_game_button.show()
	else: resume_game_button.hide()


func resume_game() -> void:
	if PlayerConfig.load_settings() == OK:
		start_game_pressed.emit()


func new_game() -> void:
	var menu: Control = start_menu.instantiate()
	menu.start_game_pressed.connect(start_game)
	add_child(menu)


func open_options() -> void:
	pass


func start_game() -> void:
	start_game_pressed.emit()


func quit_game() -> void:
	quit_game_pressed.emit()
