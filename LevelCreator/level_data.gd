class_name LevelData
extends Resource

signal target_changed (target_index: int)

@export var save_path: String :
	get():
		return save_dir.path_join(save_file_name)
@export var save_dir: String
@export var save_file_name: String
@export var level: int
@export var order: LevelLoader.LevelOrder
@export var size: int
@export var next_level: String
@export var checkpoint: bool
@export var description: String
@export var theme: String

@export var targets: Array

var word_key: String = "word"
var score_key: String = "score"
var hint_key: String = "hint"


func load_from_runner_data(runner: RunnerLevel) -> void:
	level = runner.level_number
	order = runner.level_order
	size = runner.default_level_size
	next_level = runner.next_level_path
	checkpoint = runner.checkpoint
	targets = runner.level_targets
	description = runner.level_description
	#theme = runner.environment.theme_name


func convert_to_runner_data() -> RunnerLevel:
	var new_level: RunnerLevel = RunnerLevel.new()

	new_level.level_number = level
	new_level.level_order = order
	new_level.default_level_size = size
	new_level.next_level_path = next_level
	new_level.checkpoint = checkpoint
	new_level.level_targets = targets
	new_level.level_description = description

	return new_level


func read_level_data(path: String) -> void:
	var path_index: int = path.get_slice_count("/") - 1
	var level_key: String = path.get_slice("/", path_index)
	save_file_name = level_key
	load_from_runner_data(LevelLoader.levels[level_key])


func add_target(target_data: Dictionary) -> void:
	var addition_index: int = targets.size()
	targets.append(target_data)
	target_changed.emit(addition_index)


func add_blank_target() -> void:
	var dict: Dictionary = {word_key: "", score_key: 1, hint_key: ""}
	add_target(dict)


func update_entry(index: int, word: String, score: int, hint: String) -> void:
	var entry: Dictionary = targets[index]
	entry[word_key] = word
	entry[score_key] = score
	entry[hint_key] = hint
	target_changed.emit(index)


func save() -> Error:
#Return the updated data to the level dictionary
	var run_data: RunnerLevel = convert_to_runner_data()
	LevelLoader.levels[save_file_name] = run_data

#Open the required file
	var file: FileAccess = FileAccess.open(save_path, FileAccess.WRITE_READ)
	if file == null:
		printerr(FileAccess.get_open_error())
		return FileAccess.get_open_error()

#Store the file as a json for later use
	var data_dict: Dictionary = {}
	data_dict["level"] = level
	if order == LevelLoader.LevelOrder.RANDOM:
		data_dict["order"] = "random"
	else: data_dict["order"] = "ordered"
	data_dict["size"] = size
	data_dict["next_level"] = next_level
	data_dict["checkpoint"] = checkpoint
	data_dict["targets"] = targets
	data_dict["description"] = description

	var json_string: String = JSON.stringify(data_dict, "\t")
	file.store_string(json_string)
	file.close()
	return Error.OK
