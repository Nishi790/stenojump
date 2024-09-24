extends Node

signal last_level

enum LevelOrder {RANDOM, ORDERED}

var default_level_path_root: String = "res://level_data/"
var custom_level_path_root: String = "user://custom_levels/"

var levels: Dictionary = {}

var active_level: RunnerLevel


func _ready() -> void:
	if DirAccess.dir_exists_absolute(default_level_path_root):
		var files: DirAccess = DirAccess.open(default_level_path_root)
		var built_in_files: PackedStringArray = files.get_files()
		retrieve_level_files(built_in_files)
		for dir in files.get_directories():
			var folder_path: String = default_level_path_root.path_join(dir)
			var folder_files: PackedStringArray = DirAccess.get_files_at(folder_path)
			retrieve_level_files(folder_files, folder_path)

	#Create directory for custom levels if it doesn't exist
	if DirAccess.dir_exists_absolute(custom_level_path_root) == false:
		DirAccess.make_dir_recursive_absolute(custom_level_path_root)

	#Retrieve custom levels up to 1 folder deep in custom level directory
	var custom_level_dir: DirAccess = DirAccess.open(custom_level_path_root)
	var level_files: PackedStringArray = custom_level_dir.get_files()
	retrieve_level_files(level_files)
	for dir in custom_level_dir.get_directories():
		var folder_path: String = custom_level_path_root.path_join(dir)
		var folder_files: PackedStringArray = DirAccess.get_files_at(folder_path)
		retrieve_level_files(folder_files, folder_path)


func retrieve_level_files(file_names: PackedStringArray, path_root: String = "") -> void:
	var path: String
	for file in file_names:
		if file.ends_with(".json"):
			if path_root != "":
				path = path_root.path_join(file)
			else:
				path = file
			create_level(path)


func create_level(filepath: String) -> String:
	if not filepath.contains(":/"):
		filepath = default_level_path_root + filepath
	var path_index: int = filepath.get_slice_count("/") - 1
	var level_path: String = filepath.get_slice("/", path_index)
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
		if data.has("description"):
			level_data.level_description = data["description"]
		#if data.has("theme"): TODO
		#	level_data.environment = FIND Environment resource based on theme name!
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
	if active_level.checkpoint and PlayerConfig.checkpoints_enabled:
		PlayerConfig.last_checkpoint_path = active_level.level_path
	elif PlayerConfig.checkpoint_all:
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
