extends Node

signal last_level

enum LevelOrder {RANDOM, ORDERED}

var default_level_path_root: String = "res://level_data/"

var levels: Dictionary = {}

var active_level: RunnerLevel


func _ready() -> void:
	if DirAccess.dir_exists_absolute(default_level_path_root):
		var files: DirAccess = DirAccess.open(default_level_path_root)
		var level_files: PackedStringArray = files.get_files()
		for file in level_files:
			if file.ends_with(".json"):
				create_level(file)


func create_level(filepath: String) -> String:
	if not filepath.contains(":/"):
		filepath = default_level_path_root + filepath
	var level_path: String = filepath.get_slice("/", -1)
	#should error check for valid file path
	var file := FileAccess.open(filepath, FileAccess.READ)
	if file == null:
		printerr(error_string(FileAccess.get_open_error()))
		return ""
	var json_content: String = file.get_as_text()
	var json_handler: JSON = JSON.new()
	var error: Error = json_handler.parse(json_content)
	if error == OK:
		var data: Dictionary = json_handler.get_data()
		var level_data: RunnerLevel = RunnerLevel.new()
		level_data.level_path = filepath
		level_data.level_number = data["level"]
		var order: String = data["order"]
		if order == "random":
			level_data.level_order = LevelOrder.RANDOM
		else: level_data.level_order = LevelOrder.ORDERED
		level_data.default_level_size = data["size"]
		level_data.next_level_path = data["next_level"]
		level_data.level_targets = data["targets"]
		if data.has("checkpoint"):
			level_data.checkpoint = data["checkpoint"]
		else: level_data.checkpoint = false
		levels[level_path] = level_data
		return level_path
	else: print_debug(error_string(error))
	return ""


func load_level(file_name : String) -> void:
	if levels.has(file_name):
		active_level = levels[file_name]
	else:
		var level_key: String = create_level(file_name)
		active_level = levels[level_key]
	if active_level.next_level_path == "":
		last_level.emit()
	PlayerConfig.current_level_path = ProjectSettings.globalize_path(active_level.level_path)
	if active_level.checkpoint:
		PlayerConfig.last_checkpoint_path = active_level.level_path


func load_next_level() -> void:
	var next_level: String
	if active_level.next_level_path.contains(":/"):
		next_level = create_level(active_level.next_level_path)
		if next_level == "":
			push_error("Next level failed to load from %s" % active_level.next_level_path)
		load_level(next_level)
	else:
		load_level(active_level.next_level_path)


func save_next_level() -> void:
	if not active_level.next_level_path.contains(":/"):
		active_level.next_level_path = default_level_path_root + active_level.next_level_path
	PlayerConfig.current_level_path = active_level.next_level_path
