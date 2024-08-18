extends Node

enum LevelSequence {LEARN_PLOVER, LAPWING, OTHER}
enum WordOrder {DEFAULT, RANDOM, ORDERED}

@export var lapwing_level_1: String = "res://in_game/level_data/lapwing_1.json"
@export var learn_plover_level_1: String

var min_level_length: int = 0
var max_level_length: int = 0
var preferred_word_order: WordOrder = WordOrder.DEFAULT

var level_sequence: LevelSequence:
	set(sequence):
		level_sequence = sequence
		match sequence:
			LevelSequence.LEARN_PLOVER:
				current_level_path = learn_plover_level_1
			LevelSequence.LAPWING:
				current_level_path = lapwing_level_1
			LevelSequence.OTHER:
				current_level_path = ""
var current_level_path: String = lapwing_level_1
var starting_wpm: int
var speed_building_mode: bool
var target_wpm: int
var step_size: int

var voice_output_enabled: bool
var preferred_voice: String
var preferred_voice_rate: float = 1
var preferred_voice_pitch: float = 1
var preferred_voice_volume: int = 50

var current_wpm: int
