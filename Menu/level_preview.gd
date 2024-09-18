extends PanelContainer

signal start_pressed

@export var bg_image: TextureRect
@export var level_label: Label
@export var description_label: RichTextLabel
@export var size_label: Label
@export var record_label: Label
@export var start_button: Button

var size_string: String = "Level Size: %d words"
var record_string: String = "Highest Speed: %s strokes per minute, %s%% accuracy"

var level_path: String

func _ready() -> void:
	start_button.pressed.connect(start_game)


func start_game() -> void:
	print("starting level: %s" % level_path)
	start_pressed.emit(level_path)


func set_preview(path: String) -> void:
	var path_index: int = path.get_slice_count("/") - 1
	level_path = path.get_slice("/", path_index)
	print(level_path)
	if LevelLoader.levels.has(level_path):
		var level_dat: RunnerLevel = LevelLoader.levels[level_path]
		var level_name: String = "Level: " + str(level_dat.level_number)
		level_label.text = level_name
		description_label.push_paragraph(HORIZONTAL_ALIGNMENT_CENTER)
		description_label.append_text(level_dat.level_description)
		size_label.text = size_string  % level_dat.default_level_size
		record_label.text = record_string % PlayerConfig.get_high_score(path)
