extends Control

signal start_game_pressed

@export var level_sequence_selector: OptionButton
@export var start_speed_selector: SpinBox
@export var speed_builder_button: CheckBox
@export var target_speed_container: Container
@export var speed_step_container: Container
@export var target_speed_selector: SpinBox
@export var speed_step_selector: SpinBox
@export var voice_output_toggle: CheckBox
@export var start_button: Button
@export var file_selector_dialogue: FileDialog


func _ready() -> void:
	level_sequence_selector.item_selected.connect(change_level_sequence)
	start_speed_selector.value_changed.connect(select_speed)
	speed_builder_button.toggled.connect(set_build_speed)
	target_speed_selector.value_changed.connect(set_target_speed)
	speed_step_selector.value_changed.connect(set_speed_step)
	voice_output_toggle.toggled.connect(set_tts)
	start_button.pressed.connect(start_game)
	file_selector_dialogue.file_selected.connect(set_starting_level)
	PlayerConfig.current_wpm = start_speed_selector.value
	PlayerConfig.starting_wpm = start_speed_selector.value


func change_level_sequence(sequence: int):
	match sequence:
		0:
			PlayerConfig.level_sequence = PlayerConfig.LevelSequence.LAPWING
		1:
			PlayerConfig.level_sequence = PlayerConfig.LevelSequence.LEARN_PLOVER
		_:
			PlayerConfig.level_sequence = PlayerConfig.LevelSequence.OTHER
			file_selector_dialogue.set_visible(true)
			file_selector_dialogue.grab_focus()
	PlayerConfig.start_level_sequence(PlayerConfig.level_sequence)
	start_button.disabled = false


func select_speed(speed: float):
	PlayerConfig.starting_wpm = int(speed)
	PlayerConfig.current_wpm = int(speed)


func set_build_speed(build_speed: bool):
	PlayerConfig.speed_building_mode = build_speed
	PlayerConfig.target_wpm = target_speed_selector.value
	PlayerConfig.step_size = speed_step_selector.value
	if build_speed:
		target_speed_container.set_visible(true)
		speed_step_container.set_visible(true)
	else:
		target_speed_container.set_visible(false)
		speed_step_container.set_visible(false)


func set_target_speed(speed: float):
	PlayerConfig.target_wpm = int(speed)


func set_speed_step(step: float):
	PlayerConfig.step_size = int(step)


func set_tts(enabled: bool):
	PlayerConfig.voice_output_enabled = enabled


func set_starting_level(path: String):
	PlayerConfig.current_level_path = path


func start_game():
	print_debug("First level path: ", PlayerConfig.current_level_path)
	print_debug("Speed building mode is ", PlayerConfig.speed_building_mode)
	start_game_pressed.emit()
