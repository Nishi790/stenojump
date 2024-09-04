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

@export var targets: Array

var word_key: String = "word"
var score_key: String = "score"
var hint_key: String = "hint"


func read_level_data() -> void:
	level = LevelLoader.level_number
	order = LevelLoader.level_order
	size = LevelLoader.default_level_size
	next_level = LevelLoader.next_level_path
	targets = LevelLoader.level_targets
	checkpoint = LevelLoader.checkpoint


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
	var file: FileAccess = FileAccess.open(save_path, FileAccess.WRITE_READ)
	if file == null:
		printerr(FileAccess.get_open_error())
		return FileAccess.get_open_error()

	var data_dict: Dictionary = {}
	data_dict["level"] = level
	if order == LevelLoader.LevelOrder.RANDOM:
		data_dict["order"] = "random"
	else: data_dict["order"] = "ordered"
	data_dict["size"] = size
	data_dict["next_level"] = next_level
	data_dict["checkpoint"] = checkpoint
	data_dict["targets"] = targets
	var json_string: String = JSON.stringify(data_dict, "\t")
	file.store_string(json_string)
	file.close()
	return Error.OK
