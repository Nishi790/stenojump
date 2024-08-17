extends Node

enum LevelOrder {RANDOM, ORDERED}

var default_level_path_root: String = "res://in_game/level_data/"

var level_number: int
var level_targets: Array
var level_order: LevelOrder
var default_level_size: int
var next_level_path: String

func load_level(filepath : String):
	var file := FileAccess.open(filepath, FileAccess.READ)
	var json_content: String = file.get_as_text()
	var json_handler: JSON = JSON.new()
	var error: Error = json_handler.parse(json_content)
	if error == OK:
		var data = json_handler.get_data()
		level_number = data["level"]
		var order: String = data["order"]
		if order == "random":
			level_order = LevelOrder.RANDOM
		else: level_order = LevelOrder.ORDERED
		default_level_size = data["size"]
		next_level_path = data["next_level"]
		level_targets = data["targets"]
	else: print_debug(error_string(error))


func load_next_level():
	if not next_level_path.contains(":/"):
		next_level_path = default_level_path_root + next_level_path
	load_level(next_level_path)
