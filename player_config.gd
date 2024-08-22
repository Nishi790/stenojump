extends Node

enum LevelSequence {LEARN_PLOVER, LAPWING, OTHER}
enum WordOrder {DEFAULT, RANDOM, ORDERED}

@export var lapwing_level_1: String = "res://level_data/lapwing_1.json"
@export var learn_plover_level_1: String

var min_level_length: int = 0
var max_level_length: int = 0
var preferred_word_order: WordOrder = WordOrder.DEFAULT

var level_sequence: LevelSequence
var current_level_path: String
var starting_wpm: int
var speed_building_mode: bool
var target_wpm: int
var step_size: int

var voice_output_enabled: bool
var voice_all_ui: bool
var preferred_voice: String
var preferred_voice_rate: float = 1
var preferred_voice_pitch: float = 1
var preferred_voice_volume: int = 50

var current_wpm: int

var config_path: String = "user://settings.cfg"
var config_voice_settings: String = "TextToSpeech"
var config_level_settings: String = "LevelSettings"
var config_speed_build_settings: String = "SpeedBuildSettings"


func start_level_sequence(sequence: LevelSequence):
	match sequence:
		LevelSequence.LAPWING:
			current_level_path = lapwing_level_1
		LevelSequence.LEARN_PLOVER:
			current_level_path = learn_plover_level_1
		LevelSequence.OTHER:
			current_level_path = ""


func save_settings():
	var config = ConfigFile.new()
	config.set_value(config_level_settings, "LevelSequence", level_sequence)
	config.set_value(config_level_settings, "CurrentLevel", current_level_path)
	config.set_value(config_level_settings, "CurrentWPM", current_wpm)

	config.set_value(config_speed_build_settings, "SpeedBuildMode", speed_building_mode)
	config.set_value(config_speed_build_settings, "StartingWPM", starting_wpm)
	config.set_value(config_speed_build_settings, "TargetWPM", target_wpm)
	config.set_value(config_speed_build_settings, "StepSize", step_size)

	config.set_value(config_voice_settings, "Enabled", voice_output_enabled)
	config.set_value(config_voice_settings, "AllUIVoiced", voice_all_ui)
	config.set_value(config_voice_settings, "Voice", preferred_voice)
	config.set_value(config_voice_settings, "Rate", preferred_voice_rate)
	config.set_value(config_voice_settings, "Pitch", preferred_voice_pitch)
	config.set_value(config_voice_settings, "Volume", preferred_voice_volume)

	var err = config.save(config_path)
	if err != OK:
		printerr("Save Failed")


func load_settings():
	var config = ConfigFile.new()
	var err = config.load(config_path)
	if err != OK:
		printerr("Settings load failed, loading default settings")
		return

	level_sequence = config.get_value(config_level_settings, "LevelSequence", null)
	current_level_path = config.get_value(config_level_settings, "CurrentLevel", "")
	current_wpm = config.get_value(config_level_settings, "CurrentWPM", 0)

	if current_level_path == "" and level_sequence != null:
		current_level_path = start_level_sequence(level_sequence)

	speed_building_mode = config.get_value(config_speed_build_settings, "SpeedBuildMode", false)
	starting_wpm = config.get_value(config_speed_build_settings, "StartingWPM", 0)
	target_wpm = config.get_value(config_speed_build_settings, "TargetWPM", 0)
	step_size = config.get_value(config_speed_build_settings, "StepSize", 0)

	voice_output_enabled = config.get_value(config_voice_settings, "Enabled")
	voice_all_ui = config.get_value(config_voice_settings, "AllUIVoiced")
	preferred_voice = config.get_value(config_voice_settings, "Voice")
	preferred_voice_rate = config.get_value(config_voice_settings, "Rate")
	preferred_voice_pitch = config.get_value(config_voice_settings, "Pitch")
	preferred_voice_volume = config.get_value(config_voice_settings, "Volume")
