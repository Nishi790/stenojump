extends Control

signal start_game_pressed
signal quit_game_pressed
signal level_creator_selected

@export var start_menu: PackedScene
@export var options_menu: PackedScene
@export var resume_game_button: Button
@export var new_game_button: Button
@export var options_button: Button
@export var quit_game_button: Button
@export var level_creator_button: Button
@export var player_input: MarginContainer
var input_processor: Node = self


func _ready() -> void:
	PlayerConfig.load_universal_settings()
	resume_game_button.pressed.connect(resume_game)
	new_game_button.pressed.connect(new_game)
	options_button.pressed.connect(open_options)
	quit_game_button.pressed.connect(quit_game)
	level_creator_button.pressed.connect(launch_level_creator)
	if PlayerConfig.has_saved_level():
		resume_game_button.show()
	else: resume_game_button.hide()

	player_input.new_processed_text.connect(parse_player_input)
	new_game_button.grab_focus()
	grab_text_processing()


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		print(get_viewport().gui_get_focus_owner())


func resume_game() -> void:
	if PlayerConfig.load_game() == OK:
		start_game_pressed.emit()


func new_game() -> void:
	var menu: Control = start_menu.instantiate()
	menu.start_game_pressed.connect(start_game)
	menu.game_canceled.connect(grab_text_processing)
	add_child(menu)
	input_processor = menu


func open_options() -> void:
	var options: Control = options_menu.instantiate()
	options.returned_to_menu.connect(grab_text_processing)
	options.new_neighbors.connect(player_input.provide_options_focus_neighbor)
	options.side_focus = player_input.text_control
	add_child(options)
	input_processor = options


func start_game() -> void:
	start_game_pressed.emit()


func quit_game() -> void:
	PlayerConfig.save_universal_settings()
	quit_game_pressed.emit()


func launch_level_creator() -> void:
	level_creator_selected.emit()


func parse_player_input(text: String) -> void:
	if input_processor == self:
		match text:
			"resume", "resume game":
				resume_game()
			"new", "new game":
				new_game()
			"option", "options":
				open_options()
			"quit", "quit game":
				quit_game()
			_:
				player_input.unknown_command(text)
	else:
		var processed: bool = input_processor.process_text(text)
		if processed == false:
			player_input.unknown_command(text)


func grab_text_processing() -> void:
	player_input.set_menu_focus_neighbors()
	input_processor = self
