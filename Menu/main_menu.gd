extends Control

signal story_started(load_path)
signal quit_game_pressed
signal level_creator_selected
signal arcade_mode_selected

@export var options_menu: PackedScene
@export var credits_scene: PackedScene

@export var story_mode_button: Button
@export var arcade_mode_button: Button
@export var options_button: Button
@export var quit_game_button: Button
@export var level_creator_button: Button
@export var credits_button: Button

@export var story_menu: PanelContainer
@export var new_story_button: Button
@export var load_story_button: Button
@export var cancel_story_button: Button

@export var player_input: MarginContainer
var input_processor: Node = self


func _ready() -> void:
	PlayerConfig.load_universal_settings()
	story_mode_button.pressed.connect(func open_panel() -> void:
		story_menu.show()
		new_story_button.grab_focus())
	arcade_mode_button.pressed.connect(func arcade(): arcade_mode_selected.emit())
	options_button.pressed.connect(open_options)
	quit_game_button.pressed.connect(quit_game)
	level_creator_button.pressed.connect(launch_level_creator)
	credits_button.pressed.connect(open_credits)

	new_story_button.pressed.connect(start_story)
	cancel_story_button.pressed.connect(func close_panel()-> void:
		story_menu.hide()
		story_mode_button.grab_focus())

	player_input.new_processed_text.connect(parse_player_input)
	story_mode_button.grab_focus()
	grab_text_processing()


func start_story(load_path: String = "") -> void:
	story_started.emit(load_path)


func open_options() -> void:
	var options: Control = options_menu.instantiate()
	options.returned_to_menu.connect(grab_text_processing)
	options.new_neighbors.connect(player_input.provide_options_focus_neighbor)
	options.side_focus = player_input.text_control
	add_child(options)
	input_processor = options


func open_credits() -> void:
	var credits: Control = credits_scene.instantiate()
	credits.main_menu_pressed.connect(grab_text_processing)
	add_child(credits)
	input_processor = credits


func quit_game() -> void:
	PlayerConfig.save_universal_settings()
	quit_game_pressed.emit()


func launch_level_creator() -> void:
	level_creator_selected.emit()


func parse_player_input(text: String) -> void:
	if input_processor == self:
		match text:
			"new", "new game", "story":
				start_story()
			"arcade", "arcade mode":
				arcade_mode_selected.emit()
			"option", "options":
				open_options()
			"quit", "quit game":
				quit_game()
			"create", "create level":
				launch_level_creator()
			_:
				player_input.unknown_command(text)
	else:
		var processed: bool = input_processor.process_text(text)
		if processed == false:
			player_input.unknown_command(text)


func grab_text_processing() -> void:
	player_input.set_menu_focus_neighbors()
	input_processor = self
