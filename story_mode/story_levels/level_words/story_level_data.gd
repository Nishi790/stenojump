class_name StoryLevelData
extends Resource

@export var level_words: Array[Dictionary]
@export var tutorial_break_points: Array[int]
@export var tutorial_dialogue_keys: Array[Resource]

var tutorial_breaks_complete: bool = false
var cur_index: int = 0

func get_next_word()-> Dictionary:
	var result_dict = level_words[cur_index]
	cur_index += 1
	if cur_index >= level_words.size():
		level_words.shuffle()
		cur_index = 0
	return result_dict
