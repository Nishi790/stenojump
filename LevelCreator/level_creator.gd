extends HSplitContainer

@export var edit_existing_button: Button
@export var new_level_button: Button
@export var save_path_button: Button
@export var file_selector: FileDialog
@export var save_file_name: LineEdit
@export var level_number_selector: SpinBox
@export var level_order_selector: OptionButton
@export var next_level_path_edit: LineEdit
@export var next_level_file_button: Button

@export var select_targets_from_file_button: Button
@export var tsv_text_box: TextEdit
@export var parse_tsv_button: Button
@export var plain_text_box: TextEdit
@export var parse_text_button: Button

@export var save_button: Button

@export var target_list: VBoxContainer

var active_level_data: LevelData


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Initialize empty level data object for editting
	active_level_data = LevelData.new()

	new_level_button.pressed.connect(create_new_level)
	save_path_button.pressed.connect(select_save_path)
	save_file_name.text_changed.connect(set_save_file)
	level_number_selector.value_changed.connect(set_level_number)
	level_order_selector.item_selected.connect(set_order)
	next_level_file_button.pressed.connect(choose_next_level)
	next_level_path_edit.text_submitted.connect(set_next_level)
	parse_tsv_button.pressed.connect(parse_tsv)


func create_new_level() -> void:
	active_level_data = LevelData.new()
	restore_defaults()
	save_path_button.grab_focus()


#Restores all level data being displayed to the defaults for a new level
func restore_defaults() -> void:
	save_path_button.text = "Select Level Path"
	level_number_selector.value = 0
	level_order_selector.select(0)
	next_level_path_edit.text = ""
	#Clear target list here


func select_save_path() -> void:
	file_selector.set_visible(true)
	file_selector.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	file_selector.mode_overrides_title = false
	file_selector.title = "Choose a save directory"
	file_selector.grab_focus()
	file_selector.dir_selected.connect(set_save_dir, 4)
	file_selector.ok_button_text = "Use This Folder"


func set_save_dir(dir: String) -> void:
	save_path_button.text = dir
	if save_file_name.text != "":
		if not save_file_name.text.ends_with(".json"):
			active_level_data.save_path = dir + save_file_name.text + ".json"
		else:
			active_level_data.save_path = dir + save_file_name.text


func set_save_file(text: String) -> void:
	var file_name: String = text.strip_edges()
	if not text.ends_with(".json"):
		file_name = file_name + ".json"
	active_level_data.save_path = save_button.text + file_name


func set_level_number(value: float) -> void:
	active_level_data.level_number = int(value)


func set_order(index: int) -> void:
	if index == 0:
		active_level_data.level_order = LevelLoader.LevelOrder.RANDOM
	elif index == 1:
		active_level_data.level_order = LevelLoader.LevelOrder.ORDERED


func choose_next_level() -> void:
	file_selector.set_visible(true)
	file_selector.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_selector.mode_overrides_title = false
	file_selector.title = "Select the next level"
	file_selector.file_selected.connect(set_next_level, 4)
	file_selector.ok_button_text = "Use This File"
	file_selector.grab_focus()


func set_next_level(file: String) -> void:
	next_level_path_edit.text = file
	active_level_data.next_level_path = file


func parse_tsv() -> void:
	var text: String = tsv_text_box.text
	var lines: PackedStringArray = text.split("\n")
	var separator: String = test_separator(lines[0])
	var index_1_type: String
	var index_2_type: String
	index_1_type = check_entry_order(lines[0].split(separator))
	if index_1_type == "hint":
		index_2_type = "score"
	else: index_2_type = "hint"

	for line in lines:
		var target_dict: Dictionary = {}
		var items: PackedStringArray = line.split(separator)
		target_dict["word"] = items[0]
		if items.size() > 1:
			target_dict[index_1_type] = items[1]
		if items.size() > 2:
			target_dict[index_2_type] = items[2]
		target_dict = auto_score(target_dict)
		active_level_data.targets.append(target_dict)


func test_separator(line: String) -> String:
	var supported_separators: Array[String] = ["\t", ",", ";"]
	for sep in supported_separators:
		var test_split: PackedStringArray = line.split(sep)
		if test_split.size() > 1:
			return sep
	return "\t"


func auto_score(dict: Dictionary) -> Dictionary:
	if dict.has("hint"):
		if not dict.has("score"):
			var hint: String = dict["hint"]
			dict["score"] = hint.count("/") + 1
	else:
		if not dict.has("score"):
			dict["score"] = 1
		dict["hint"] = ""
	return dict


func check_entry_order(splits: PackedStringArray) -> String:
	match splits.size():
		1:
			return ""
		2, 3:
			if splits[1].is_valid_int():
				return "score"
			else: return "hint"
		_:
			return ""
