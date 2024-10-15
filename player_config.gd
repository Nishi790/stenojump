extends Node

signal lives_updated

enum WordOrder {DEFAULT, RANDOM, ORDERED}
enum TargetVisibility {ALL, NEXT, IN_RANGE, NONE}

@export var lapwing_level_1: String = "lapwing_1.json"
@export var learn_plover_level_1: String

var max_lives: int = 3
var use_custom_size: bool = false
var min_level_length: int = 0
var max_level_length: int = 0
var preferred_word_order: WordOrder = WordOrder.DEFAULT
var checkpoints_enabled: bool = true
var checkpoint_all: bool = false
var autojump: bool = false

var target_visibility: TargetVisibility = TargetVisibility.ALL
var use_custom_target_theme: bool = false
var target_style: Theme = load("res://textures/target_theme.tres")
var custom_target_style: Theme

var interact_font_color: String = Color.YELLOW.to_html()

var arcade_sequence_save_dictionary: Dictionary
var story_save_dictionary: Dictionary


## Path:[speed, accuracy]
var level_records: Dictionary = {}

var voice_output_enabled: bool
var voice_all_ui: bool
var preferred_voice: String
var preferred_voice_rate: float = 1
var preferred_voice_pitch: float = 1
var preferred_voice_volume: int = 50

var config_path: String = "user://settings.cfg"
var game_save_path: String = "user://quick_save.cfg"
var runner_config: String = "RunnerSaveData"
var config_voice_settings: String = "TextToSpeech"
var config_level_settings: String = "LevelSettings"
var config_arcade_data: String = "ArcadeScores"
var config_speed_build_settings: String = "SpeedBuildSettings"
var config_graphics_settings: String = "GraphicsSettings"
var config_gameplay_settings: String = "GameplaySettings"
var config_sound_settings: String = "SoundSettings"


func _ready() -> void:
	var voices: PackedStringArray = DisplayServer.tts_get_voices_for_language("en")
	preferred_voice = voices[0]


func save_game(file_name: String = "") -> void:
	var config: ConfigFile = ConfigFile.new()
	var err: Error
	var save_path: String = game_save_path
	if file_name != "":
		save_path = "user://%s.cfg" %file_name

	err = config.load(save_path)

	if err != OK:
		printerr("Creating New Save File")

	config.set_value(runner_config, "ArcadeProgression", arcade_sequence_save_dictionary)
	config.set_value(runner_config, "StoryProgression", story_save_dictionary)

	config.set_value(config_arcade_data, "ArcadeScores", level_records)

	config.set_value(config_voice_settings, "Enabled", voice_output_enabled)

	err = config.save(save_path)
	if err != OK:
		printerr("Save Failed")


func has_saved_level() -> bool:
	var config: ConfigFile = ConfigFile.new()
	var err: Error = config.load(game_save_path)
	if err != OK:
		return false
	var saved_level: Dictionary = config.get_value(runner_config, "ArcadeProgression", {})
	if saved_level.is_empty():
		if config.get_value(config_level_settings, "CurrentLevel", "") != "":
			return true
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
	config.set_value(config_gameplay_settings, "MaxLives", max_lives)
	config.set_value(config_gameplay_settings, "CheckpointsEnabled", checkpoints_enabled)
	config.set_value(config_gameplay_settings, "CheckpointAll", checkpoint_all)
	config.set_value(config_gameplay_settings, "Autojump", autojump)

	config.set_value(config_voice_settings, "AllUIVoiced", voice_all_ui)
	config.set_value(config_voice_settings, "Voice", preferred_voice)
	config.set_value(config_voice_settings, "Rate", preferred_voice_rate)
	config.set_value(config_voice_settings, "Pitch", preferred_voice_pitch)
	config.set_value(config_voice_settings, "Volume", preferred_voice_volume)

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

	target_visibility = config.get_value(config_graphics_settings, "TargetVisibility", TargetVisibility.ALL)
	use_custom_target_theme = config.get_value(config_graphics_settings, "CustomTargets", false)
	custom_target_style = config.get_value(config_graphics_settings, "CustomTargetTheme", null)

	use_custom_size = config.get_value(config_gameplay_settings, "CustomLevelSize", false)
	min_level_length = config.get_value(config_gameplay_settings, "MinLevelSize", 0)
	max_level_length = config.get_value(config_gameplay_settings, "MaxLevelSize", 0)
	preferred_word_order = config.get_value(config_gameplay_settings, "LevelOrder", WordOrder.DEFAULT)
	max_lives = config.get_value(config_gameplay_settings, "MaxLives", 3)
	checkpoints_enabled = config.get_value(config_gameplay_settings, "CheckpointsEnabled", true)
	checkpoint_all = config.get_value(config_gameplay_settings, "CheckpointAll", false)
	autojump = config.get_value(config_gameplay_settings, "Autojump", false)

	voice_all_ui = config.get_value(config_voice_settings, "AllUIVoiced", false)
	var saved_voice: String = config.get_value(config_voice_settings, "Voice", "")
	if not saved_voice.is_empty():
		preferred_voice = saved_voice
	preferred_voice_rate = config.get_value(config_voice_settings, "Rate", 1)
	preferred_voice_pitch = config.get_value(config_voice_settings, "Pitch", 1)
	preferred_voice_volume = config.get_value(config_voice_settings, "Volume", 50)

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

	if config.has_section(runner_config):
		arcade_sequence_save_dictionary = config.get_value(runner_config, "ArcadeProgression", {})
		story_save_dictionary = config.get_value(runner_config, "StoryProgression", {})

	else:
		parse_legacy_save(config)

	level_records = config.get_value(config_arcade_data, "ArcadeScores", {})
	voice_output_enabled = config.get_value(config_voice_settings, "Enabled")

	return err


func parse_legacy_save(config: ConfigFile) -> void:
	var level_dict: Dictionary = {}
	level_dict["LevelSequence"] = config.get_value(config_level_settings, "LevelSequence", null)
	level_dict["CurrentLevel"] = config.get_value(config_level_settings, "CurrentLevel", "")
	level_dict["LastCheckpoint"] = config.get_value(config_level_settings, "LastCheckpoint", "")
	level_dict["CustomStartLevel"] = config.get_value(config_level_settings, "CustomStartLevel", "")
	level_dict["CurrentSpeed"] = config.get_value(config_level_settings, "CurrentWPM", 0)
	level_dict["CurrentScore"] = config.get_value(config_level_settings, "CurrentScore", 0)
	level_dict["CurrentLives"] = config.get_value(config_level_settings, "CurrentLives", max_lives)

	level_dict["SpeedBuildMode"] = config.get_value(config_speed_build_settings, "SpeedBuildMode", false)
	level_dict["StartingSpeed"] = config.get_value(config_speed_build_settings, "StartingWPM", 0)
	level_dict["TargetSpeed"] = config.get_value(config_speed_build_settings, "TargetWPM", 0)
	level_dict["StepSize"] = config.get_value(config_speed_build_settings, "StepSize", 0)

	arcade_sequence_save_dictionary = level_dict


##Returns the custom theme if one has been selected, and the default theme otherwise
func get_theme() -> Theme:
	if use_custom_target_theme and custom_target_style != null:
		return custom_target_style
	else:
		return target_style


func speak_tts(text: String) -> void:
	DisplayServer.tts_speak(text, preferred_voice, preferred_voice_volume, \
	preferred_voice_pitch, preferred_voice_rate)


func save_runner(mode: RunnerGame.RunnerMode, serialized_data: Dictionary) -> void:
	match mode:
		RunnerGame.RunnerMode.PROGRESSION:
			arcade_sequence_save_dictionary = serialized_data
		RunnerGame.RunnerMode.STORY:
			story_save_dictionary
	save_game()


##Retrieve high score (speed and accuracy) for a given level path
func get_high_score(path: String) -> Array:
	var record: Array
	if level_records.has(path):
		record = level_records[path]
	else: record = [0, 0]
	@warning_ignore("unsafe_call_argument")
	record = [int(record[0]), int(record[1])]
	return record


##Update high score for a given level (speed and accurcy)
func set_high_score(data: RunnerSave, level_size: int) -> void:
	var local_path: String = ProjectSettings.localize_path(LevelLoader.active_level.level_path)
	var record: Array
	var lives_used: int = max_lives - data.current_lives
	var accuracy: float = (level_size - lives_used)
	accuracy = accuracy/level_size
	accuracy = accuracy * 100
	if level_records.has(local_path):
		record = level_records[local_path]
		if record[0] < data.current_speed:
			record = [data.current_speed, accuracy]
		elif record[0] == data.current_speed:
			if accuracy > record[1]:
				record[1] = accuracy
	else:
		record.resize(2)
		record[0] = data.current_speed
		record[1] = accuracy
	level_records[local_path] = record



func set_interact_font_color(new_color: Color) -> void:
	interact_font_color = new_color.to_html()
