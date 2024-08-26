extends Node

signal lives_updated

enum LevelSequence {LEARN_PLOVER, LAPWING, OTHER}
enum WordOrder {DEFAULT, RANDOM, ORDERED}
enum TargetVisibility {ALL, NEXT, IN_RANGE, NONE}

@export var lapwing_level_1: String = "res://level_data/lapwing_1.json"
@export var learn_plover_level_1: String

var use_custom_size: bool = false
var min_level_length: int = 0
var max_level_length: int = 0
var preferred_word_order: WordOrder = WordOrder.DEFAULT

var target_visibility: TargetVisibility = TargetVisibility.ALL
var use_custom_target_theme: bool = false
var target_style: Theme = load("res://textures/target_theme.tres")
var custom_target_style: Theme

var level_sequence: LevelSequence
var current_level_path: String
var starting_wpm: int
var speed_building_mode: bool
var target_wpm: int
var step_size: int = 5

var voice_output_enabled: bool
var voice_all_ui: bool
var preferred_voice: String
var preferred_voice_rate: float = 1
var preferred_voice_pitch: float = 1
var preferred_voice_volume: int = 50

var current_wpm: int
var current_score: int = 0
var current_lives: int = 3

var config_path: String = "user://settings.cfg"
var game_save_path: String = "user://quick_save.cfg"
var config_voice_settings: String = "TextToSpeech"
var config_level_settings: String = "LevelSettings"
var config_speed_build_settings: String = "SpeedBuildSettings"
var config_graphics_settings: String = "GraphicsSettings"
var config_gameplay_settings: String = "GameplaySettings"
var config_sound_settings: String = "SoundSettings"


func start_level_sequence(sequence: LevelSequence) -> void:
	match sequence:
		LevelSequence.LAPWING:
			current_level_path = lapwing_level_1
		LevelSequence.LEARN_PLOVER:
			current_level_path = learn_plover_level_1
		LevelSequence.OTHER:
			current_level_path = ""


func save_game(file_name: String = "") -> void:
	var config: ConfigFile = ConfigFile.new()
	var err: Error
	var save_path: String = game_save_path
	if file_name != "":
		save_path = "user://%s.cfg" %file_name

	err = config.load(save_path)

	if err != OK:
		printerr("Creating New Save File")

	config.set_value(config_level_settings, "LevelSequence", level_sequence)
	config.set_value(config_level_settings, "CurrentLevel", current_level_path)
	config.set_value(config_level_settings, "CurrentWPM", current_wpm)
	config.set_value(config_level_settings, "CurrentScore", current_score)
	config.set_value(config_level_settings, "CurrentLives", current_lives)

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


	err = config.save(save_path)
	if err != OK:
		printerr("Save Failed")


func has_saved_level() -> bool:
	var config: ConfigFile = ConfigFile.new()
	var err: Error = config.load(game_save_path)
	if err != OK:
		printerr("Save game not detected")
		return false
	var saved_level: String = config.get_value(config_level_settings, "CurrentLevel", null)
	if saved_level == null:
		return false
	else: return true


func save_universal_settings() -> Error:
	var config: ConfigFile = ConfigFile.new()
	var err: Error = config.load(config_path)
	if err != OK:
		printerr("Settings load failed, creating new settings file")

	config.set_value(config_graphics_settings, "TargetVisibility", target_visibility)
	config.set_value(config_graphics_settings, "CustomTargets", use_custom_target_theme)
	config.set_value(config_graphics_settings, "CustomTargetTheme", custom_target_style)

	config.set_value(config_gameplay_settings, "CustomLevelSize", use_custom_size)
	config.set_value(config_gameplay_settings, "MinLevelSize", min_level_length)
	config.set_value(config_gameplay_settings, "MaxLevelSize", max_level_length)
	config.set_value(config_gameplay_settings, "LevelOrder", preferred_word_order)

	err = config.save(config_path)
	if err != OK:
		printerr("Settings save failed")
	return err


func load_universal_settings() -> Error:
	var config: ConfigFile = ConfigFile.new()
	var err: Error = config.load(config_path)
	if err != OK:
		printerr("Settings load failed, loading default settings")
		return err

	target_visibility = config.get_value(config_graphics_settings, "TargetVisibility")
	use_custom_target_theme = config.get_value(config_graphics_settings, "CustomTargets")
	custom_target_style = config.get_value(config_graphics_settings, "CustomTargetTheme")

	use_custom_size = config.get_value(config_gameplay_settings, "CustomLevelSize")
	min_level_length = config.get_value(config_gameplay_settings, "MinLevelSize")
	max_level_length = config.get_value(config_gameplay_settings, "MaxLevelSize")
	preferred_word_order = config.get_value(config_gameplay_settings, "LevelOrder")

	return err


func load_game(file_name: String = "") -> Error:
	var config: ConfigFile = ConfigFile.new()
	var path: String = game_save_path
	if file_name != "":
		path = "user://%s.cfg" % file_name

	var err: Error = config.load(path)
	if err != OK:
		printerr("Couldn't load saved game, start a new one")
		return err

	level_sequence = config.get_value(config_level_settings, "LevelSequence", null)
	current_level_path = config.get_value(config_level_settings, "CurrentLevel", "")
	current_wpm = config.get_value(config_level_settings, "CurrentWPM", 0)
	current_score = config.get_value(config_level_settings, "CurrentScore")
	current_lives = config.get_value(config_level_settings, "CurrentLives")
	lives_updated.emit()

	if current_level_path == "" and level_sequence != null:
		start_level_sequence(level_sequence)

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

	return err


func at_target_speed() -> bool:
	if current_wpm == target_wpm:
		return true
	else: return false
