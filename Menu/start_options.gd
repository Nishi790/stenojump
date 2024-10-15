extends Control

signal start_game_pressed
signal game_canceled

enum {STARTSPEED, TARGETSPEED, STEPSIZE}

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
@export var cancel_button: Button

var level_data: RunnerSave


func _ready() -> void:
	level_data = RunnerSave.new()

	level_sequence_selector.item_selected.connect(change_level_sequence)
	start_speed_selector.value_changed.connect(select_speed)
	speed_builder_button.toggled.connect(set_build_speed)
	target_speed_selector.value_changed.connect(set_target_speed)
	speed_step_selector.value_changed.connect(set_speed_step)
	voice_output_toggle.toggled.connect(set_tts)
	start_button.pressed.connect(start_game)
	file_selector_dialogue.file_selected.connect(set_starting_level)


	@warning_ignore("narrowing_conversion")
	level_data.current_speed = start_speed_selector.value
	@warning_ignore("narrowing_conversion")
	level_data.starting_speed = start_speed_selector.value
	cancel_button.pressed.connect(cancel_new_game)


func process_text(text: String) -> bool:
	var split_text:  PackedStringArray = text.split(" ")
	while split_text.size() > 0:
		var target: String = split_text[0]
		split_text.remove_at(0)
		match target:
			"sequence":
				if split_text.size() == 0:
					return false
				var specifier: String = split_text[0]
				split_text.remove_at(0)
				if not match_sequence(specifier):
					return false
			"start":
				if start_button.disabled == false:
					start_game()
					return true
			"cancel":
				cancel_new_game()
			"speed":
				if split_text.size() == 0:
					return false
				var specifier: String = split_text[0]
				split_text.remove_at(0)
				if not match_speed(specifier, STARTSPEED):
					return false
			"build":
				if split_text.size() == 0:
					speed_builder_button.button_pressed = !speed_builder_button.button_pressed
					return true
				var specifier: String = split_text[0]
				split_text.remove_at(0)
				match specifier:
					"on":
						speed_builder_button.button_pressed = true
					"off":
						speed_builder_button.button_pressed = false
					"speed":
						speed_builder_button.button_pressed = !speed_builder_button.button_pressed
			"target":
				if split_text.size() == 0:
					return false
				var specifier: String = split_text[0]
				split_text.remove_at(0)
				if not match_speed(specifier, TARGETSPEED):
					return false
			"step":
				if split_text.size() == 0:
					return false
				var specifier: String = split_text[0]
				split_text.remove_at(0)
				if not match_speed(specifier, STEPSIZE):
					return false
			"tts", "speech":
				voice_output_toggle.button_pressed = !voice_output_toggle.button_pressed
			_:
				return false

	return true


func match_sequence(sequence_name: String) -> bool:
	match sequence_name:
		"lapwing", "lap":
			change_level_sequence(0)
			return true
		"plover":
			change_level_sequence(1)
			return true
		"custom":
			change_level_sequence(2)
			return true
		_:
			var  num_options: int = level_sequence_selector.item_count
			var start_index: int = 2
			while start_index < num_options:
				if level_sequence_selector.get_item_text(start_index) == sequence_name:
					change_level_sequence(start_index)
					return true
				start_index += 1
	return false


func match_speed(speed: String, selector: int) -> bool:
	var speed_value: float = speed.to_float()
	if speed_value > 0:
		if selector == STARTSPEED:
			select_speed(speed_value)
			start_speed_selector.value = speed_value
			return true
		elif selector == TARGETSPEED:
			set_target_speed(speed_value)
			target_speed_selector.value = speed_value
			return true
		elif selector == STEPSIZE:
			set_speed_step(speed_value)
			speed_step_selector.value = speed_value
			return true
		else: return false
	else: return false


func change_level_sequence(sequence: int) -> void:
	level_sequence_selector.select(level_sequence_selector.get_item_index(sequence))
	match sequence:
		0:
			level_data.level_sequence = RunnerSave.LevelSequence.LAPWING
		1:
			level_data.level_sequence = RunnerSave.LevelSequence.LEARN_PLOVER
		2:
			level_data.level_sequence = RunnerSave.LevelSequence.OTHER
			file_selector_dialogue.set_visible(true)
			file_selector_dialogue.grab_focus()
		_:
			printerr("invalid level selection")
			return

	start_button.disabled = false


func select_speed(speed: float) -> void:
	level_data.starting_speed = int(speed)
	PlayerConfig.current_wpm = int(speed)


func set_build_speed(build_speed: bool) -> void:
	PlayerConfig.speed_building_mode = build_speed
	@warning_ignore("narrowing_conversion")
	PlayerConfig.target_wpm = target_speed_selector.value
	@warning_ignore("narrowing_conversion")
	PlayerConfig.step_size = speed_step_selector.value
	if build_speed:
		target_speed_container.set_visible(true)
		speed_step_container.set_visible(true)
	else:
		target_speed_container.set_visible(false)
		speed_step_container.set_visible(false)


func set_target_speed(speed: float) -> void:
	PlayerConfig.target_wpm = int(speed)


func set_speed_step(step: float) -> void:
	PlayerConfig.step_size = int(step)


func set_tts(enabled: bool) -> void:
	PlayerConfig.voice_output_enabled = enabled


#Only called for custom level starts - otherwise uses the predefined start levels
func set_starting_level(path: String) -> void:
	PlayerConfig.custom_start_level = path
	PlayerConfig.start_level_sequence(PlayerConfig.LevelSequence.OTHER)


func start_game() -> void:
	PlayerConfig.set_sequence_data()
	start_game_pressed.emit()


func cancel_new_game() -> void:
	game_canceled.emit()
	queue_free()
