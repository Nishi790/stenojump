extends Node

enum LevelOrder {RANDOM, ORDERED}

var default_level_path_root: String = "res://level_data/"

var level_path: String
var level_number: int
var level_targets: Array
var level_order: LevelOrder
var default_level_size: int
var next_level_path: String

func load_level(filepath : String) -> void:
	level_path = filepath
	#should error check for valid file path
	var file := FileAccess.open(filepath, FileAccess.READ)
	var json_content: String = file.get_as_text()
	var json_handler: JSON = JSON.new()
	var error: Error = json_handler.parse(json_content)
	if error == OK:
		var data: Variant = json_handler.get_data()
		level_number = data["level"]
		var order: String = data["order"]
		if order == "random":
			level_order = LevelOrder.RANDOM
		else: level_order = LevelOrder.ORDERED
		default_level_size = data["size"]
		next_level_path = data["next_level"]
		level_targets = data["targets"]
		PlayerConfig.current_level_path = ProjectSettings.globalize_path(level_path)
	else: print_debug(error_string(error))


func load_next_level() -> void:
	if not next_level_path.contains(":/"):
		next_level_path = default_level_path_root + next_level_path
	load_level(next_level_path)


func save_next_level() -> void:
	if not next_level_path.contains(":/"):
		next_level_path = default_level_path_root + next_level_path
	PlayerConfig.current_level_path = next_level_path
