extends GridContainer

signal level_selected(path: String)


##Path to the folder that will be crawled for levels
@export var sequence_folder: String

var levels: Array[String] = []


func _ready() -> void:
	if DirAccess.dir_exists_absolute(sequence_folder):
		var files: DirAccess = DirAccess.open(sequence_folder)
		var level_files: PackedStringArray = files.get_files()
		levels.resize(level_files.size())
		for file_name: String in level_files:
			var path: String = sequence_folder.path_join(file_name)
			var file_content: FileAccess = FileAccess.open(path, FileAccess.READ)
			var file_string: String = file_content.get_as_text()
			var file_data: Dictionary = JSON.parse_string(file_string)
			var index: int = file_data["level"] - 1
			levels[index] = path
	for index in levels.size():
		var level_select: Button = Button.new()
		level_select.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		level_select.size_flags_vertical = Control.SIZE_EXPAND_FILL
		level_select.text = str(index + 1)
		level_select.pressed.connect(start_level.bind(levels[index]))
		add_child(level_select)


func start_level(path: String) -> void:
	print("Level selected: %s" % path)
	level_selected.emit(path)
