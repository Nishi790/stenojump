extends Control

signal return_to_main
signal start_runner(level_data: RunnerSave, mode: RunnerGame.RunnerMode)

@export var steno_jump_resume: Button
@export var steno_jump_new_game: Button
@export var steno_jump_speed_build: Button

@export var steno_jump_level_select_screen: PackedScene
@export var steno_jump_start_menu: PackedScene


@export var return_to_menu_button: Button

func _ready() -> void:

	if PlayerConfig.has_saved_level():
		steno_jump_resume.show()
		steno_jump_resume.grab_focus()
	else:
		steno_jump_resume.hide()
		steno_jump_new_game.grab_focus()
	steno_jump_resume.pressed.connect(resume_steno_jump)
	steno_jump_new_game.pressed.connect(start_steno_jump)
	steno_jump_speed_build.pressed.connect(open_speed_build_selector)

	return_to_menu_button.pressed.connect(return_to_menu)


func resume_steno_jump() -> void:
	if PlayerConfig.load_game() == OK:
		start_runner_game(RunnerSave.new(PlayerConfig.arcade_sequence_save_dictionary))


func start_steno_jump() -> void:
	var menu: Control = steno_jump_start_menu.instantiate()
	menu.start_game_pressed.connect(start_runner_game.bind(RunnerGame.RunnerMode.PROGRESSION))
	menu.game_canceled.connect(return_focus.bind(steno_jump_new_game))
	add_child(menu)


func open_speed_build_selector() -> void:
	if PlayerConfig.level_records.is_empty():
		PlayerConfig.load_game()
	var level_select: Control = steno_jump_level_select_screen.instantiate()
	level_select.start_level.connect(start_runner_game.bind(RunnerGame.RunnerMode.SPEEDBUILD))
	level_select.cancel_select.connect(return_focus.bind(steno_jump_speed_build))
	add_child(level_select)


func start_runner_game(data: RunnerSave, mode: RunnerGame.RunnerMode = RunnerGame.RunnerMode.PROGRESSION) -> void:
	start_runner.emit(data, mode)


func return_focus(node: Control) -> void:
	node.grab_focus()


func return_to_menu() -> void:
	return_to_main.emit()
