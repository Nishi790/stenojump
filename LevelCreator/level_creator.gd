extends Control

signal quit_pressed
signal menu_pressed

@export var edit_existing_button: Button
@export var new_level_button: Button
@export var save_path_button: Button
@export var file_selector: FileDialog
@export var save_file_name: LineEdit
@export var level_number_selector: SpinBox
@export var level_size_selector: SpinBox
@export var level_order_selector: OptionButton
@export var checkpoint_selector: CheckBox
@export var next_level_path_edit: LineEdit
@export var next_level_file_button: Button

@export var select_targets_from_file_button: Button
@export var tsv_text_box: TextEdit
@export var parse_tsv_button: Button
@export var plain_text_box: TextEdit
@export var parse_text_button: Button

@export var save_button: Button

@export var target_list: VBoxContainer
@export var target_scene: PackedScene
@export var manual_entry_button: Button

@export var menu_button: Button
@export var quit_button: Button

var active_level_data: LevelData


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Initialize empty level data object for editting
	active_level_data = LevelData.new()
	active_level_data.target_changed.connect(target_changed)

	# set up file selection signals
	new_level_button.pressed.connect(create_new_level)
	save_path_button.pressed.connect(select_save_path)
	save_file_name.text_changed.connect(set_save_file)
	edit_existing_button.pressed.connect(open_level_selector)

	# set up general level info signals
	level_number_selector.value_changed.connect(set_level_number)
	level_size_selector.value_changed.connect(set_level_size)
	level_order_selector.item_selected.connect(set_order)
	next_level_file_button.pressed.connect(choose_next_level)
	next_level_path_edit.text_changed.connect(parse_next_level)
	checkpoint_selector.toggled.connect(set_checkpoint)

	#set up target generation signals
	select_targets_from_file_button.pressed.connect(select_file_to_parse)
	tsv_text_box.text_changed.connect(enable_parse_tsv)
	plain_text_box.text_changed.connect(enable_parse_text)
	parse_tsv_button.pressed.connect(parse_tsv)
	parse_text_button.pressed.connect(parse_text)

	manual_entry_button.pressed.connect(add_entry)

	save_button.pressed.connect(save_level)
	quit_button.pressed.connect(quit_game)
	menu_button.pressed.connect(return_to_menu)

	#initiate focus
	new_level_button.grab_focus()



func create_new_level() -> void:
	active_level_data = LevelData.new()
	active_level_data.target_changed.connect(target_changed)
	tsv_text_box.clear()
	plain_text_box.clear()
	display_level_data()
	save_path_button.grab_focus()


func open_level_selector() -> void:
	file_selector.title = "Select level to edit"
	file_selector.set_visible(true)
	file_selector.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_selector.grab_focus()
	file_selector.file_selected.connect(load_existing_level, 4)


func load_existing_level(path: String) -> void:
	LevelLoader.load_level(path)
	active_level_data.read_level_data()
	var final_slice: int = path.get_slice_count("/") - 1
	active_level_data.save_file_name = path.get_slice("/", final_slice)
	active_level_data.save_dir = path.trim_suffix(active_level_data.save_file_name)
	tsv_text_box.clear()
	plain_text_box.clear()
	display_level_data()
	select_targets_from_file_button.grab_focus()


#Restores all level data being displayed to match the data
func display_level_data() -> void:
	if active_level_data.save_path == "":
		save_path_button.text = "Select Level Path"
		save_file_name.text = ""
	else:
		save_path_button.text = active_level_data.save_dir
		save_file_name.text = active_level_data.save_file_name
	level_number_selector.value = active_level_data.level
	level_size_selector.value = active_level_data.size
	checkpoint_selector.set_pressed_no_signal(active_level_data.checkpoint)
	if active_level_data.order == LevelLoader.LevelOrder.RANDOM:
		level_order_selector.select(0)
	else:
		level_order_selector.select(1)
	next_level_path_edit.text = active_level_data.next_level
	if target_list.get_child_count() > active_level_data.targets.size():
		var number_to_free: int = target_list.get_child_count() - active_level_data.targets.size()
		while number_to_free > 0:
			number_to_free -= 1
			target_list.get_child(number_to_free).queue_free()
	for index in active_level_data.targets.size():
		target_changed(index)


func select_save_path() -> void:
	file_selector.set_visible(true)
	file_selector.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	file_selector.title = "Choose a save directory"
	file_selector.grab_focus()
	file_selector.dir_selected.connect(set_save_dir, 4)
	file_selector.ok_button_text = "Use This Folder"


func set_save_dir(dir: String) -> void:
	save_path_button.text = dir
	active_level_data.save_dir = dir


func set_save_file(text: String) -> void:
	var file_name: String = text.strip_edges()
	if not text.ends_with(".json"):
		file_name = file_name + ".json"
	active_level_data.save_file_name = file_name
	save_button.disabled = false


func set_level_number(value: float) -> void:
	active_level_data.level = int(value)


func set_level_size(value: float) -> void:
	active_level_data.size = int(value)


func set_order(index: int) -> void:
	if index == 0:
		active_level_data.order = LevelLoader.LevelOrder.RANDOM
	elif index == 1:
		active_level_data.order = LevelLoader.LevelOrder.ORDERED


func set_checkpoint(enabled: bool) -> void:
	active_level_data.checkpoint = enabled


func choose_next_level() -> void:
	file_selector.set_visible(true)
	file_selector.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_selector.title = "Select the next level"
	file_selector.file_selected.connect(set_next_level, 4)
	file_selector.ok_button_text = "Use This File"
	file_selector.grab_focus()


func set_next_level(file: String) -> void:
	next_level_path_edit.text = file


func parse_next_level(level_name: String) -> void:
	active_level_data.next_level = level_name


func select_file_to_parse() -> void:
	file_selector.set_visible(true)
	file_selector.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_selector.title = "Select Source File"
	file_selector.file_selected.connect(parse_file, 4)
	file_selector.ok_button_text = "Select File"
	file_selector.filters = ["*.txt", "*.csv", "*.tsv"]
	file_selector.grab_focus()


func parse_file(path: String) -> void:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if path.ends_with(".csv") or path.ends_with(".tsv"):
		var delimiter: String = ","
		if path.ends_with(".tsv"):
			delimiter = "\t"
		while file.get_position() < file.get_length():
			var target_dict: Dictionary = {}
			var line: PackedStringArray = file.get_csv_line(delimiter)
			match line.size():
				1:
					target_dict["word"] = line[0]
				2:
					target_dict["word"] = line[0]
					if line[1].is_valid_int():
						target_dict["score"] = line[1]
					else:
						target_dict["hint"] = line[1]
				_:
					target_dict["word"] = line[0]
					if line[1].is_valid_int():
						target_dict["score"] = line[1]
						target_dict["hint"] = line[2]
					else:
						target_dict["hint"] = line[1]
						target_dict["score"] = line[2]
			target_dict = auto_score(target_dict)
			active_level_data.add_target(target_dict)
	else:
		while file.get_position() < file.get_length():
			var words: PackedStringArray = file.get_line().split(" ")
			for word in words:
				var target_dict: Dictionary = {}
				target_dict["word"] = word.to_lower()
				target_dict = auto_score(target_dict)
				active_level_data.add_target(target_dict)


func enable_parse_tsv() -> void:
	parse_tsv_button.disabled = false


func parse_tsv() -> void:
	parse_tsv_button.disabled = true
	active_level_data.targets.clear()
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
		active_level_data.add_target(target_dict)


func enable_parse_text() -> void:
	parse_text_button.disabled = false


func parse_text() -> void:
	parse_text_button.disabled = true
	active_level_data.targets.clear()
	var text: String = plain_text_box.text
	var lines: PackedStringArray = text.split("\n")
	var tokens: PackedStringArray = PackedStringArray()
	for line in lines:
		var words: PackedStringArray = line.split(" ")
		tokens.append_array(words)
	for token in tokens:
		var target_dict: Dictionary = {}
		target_dict["word"] = token.to_lower()
		target_dict = auto_score(target_dict)
		active_level_data.add_target(target_dict)


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


func save_level() -> Error:
	if active_level_data.save_path == "":
		return ERR_FILE_BAD_PATH
	else:
		return active_level_data.save()


#Called when target data is changed
func target_changed(index: int) -> void:
	var current_size: int = target_list.get_child_count()
	if current_size - 1 < index:
		var new_entry: TargetDisplay = target_scene.instantiate()
		new_entry.display_data(active_level_data.targets[index])
		new_entry.entry_index = index
		target_list.add_child(new_entry)
		new_entry.data_updated.connect(active_level_data.update_entry)
		new_entry.entry_deleted.connect(delete_entry)
	else:
		var changed_entry: TargetDisplay  = target_list.get_child(index) as TargetDisplay
		changed_entry.display_data(active_level_data.targets[index])


#Creates blank target in the level data
func add_entry() -> void:
	active_level_data.add_blank_target()


#Deletes selected entry and re indexes all others as required
func delete_entry(index: int) -> void:
	active_level_data.targets.remove_at(index)
	var current_index: int = index
	while current_index < target_list.get_child_count():
		var target_displayer: TargetDisplay = target_list.get_child(current_index) as TargetDisplay
		target_displayer.entry_index -= 1
		current_index += 1


func quit_game() -> void:
	quit_pressed.emit()


func return_to_menu() -> void:
	menu_pressed.emit()
