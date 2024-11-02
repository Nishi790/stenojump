extends VBoxContainer

@export var title_label: RichTextLabel
@export var tip_body: RichTextLabel

static var title_open_tags: String = "[center][font size=%s]"
static var title_close_tags: String = "[/font][/center]"
var title_font_size: int = 32

static func parse_tip_text(path: String) -> Dictionary:
	var return_dict: Dictionary = {}
	var file_access: FileAccess = FileAccess.open(path, FileAccess.READ)
	var file_content: String = file_access.get_as_text()
	var title_string: String = file_content.get_slice("[/title]", 0)
	title_string = title_string.trim_prefix("[title]")
	return_dict["title"] = title_string

	var body_string: String = file_content.get_slice("[/title]", 1)

	return_dict["body"] = body_string

	return return_dict


func _ready() -> void:
	var tip_dict: Dictionary = parse_tip_text("res://story_mode/UI/game_play_tips/0_basic_movement.txt")
	display_tip(tip_dict)


func display_tip(dict: Dictionary) -> void:
	var title_text: String = title_open_tags % title_font_size
	title_text += dict["title"]
	title_text += title_close_tags
	title_label.set_text(title_text)
	tip_body.set_text(dict["body"])
