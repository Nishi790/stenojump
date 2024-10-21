class_name TheoryLessonContainer
extends VBoxContainer

@export var title_label: RichTextLabel
@export var lesson_body: RichTextLabel

static var steno_open_tags: String = "[font=res://textures/UI/fonts/Stenodisplay-ClassicLarge.ttf][font size=200]"
static var steno_close_tags: String = "[/font][/font]"

static var title_open_tags: String = "[center][font size=%s]"
static var title_close_tags: String = "[/font][/center]"
var title_font_size = 32



static func parse_lesson_text(path: String) -> Dictionary:
	var return_dict: Dictionary = {}
	var file_access: FileAccess = FileAccess.open(path, FileAccess.READ)
	var file_content: String = file_access.get_as_text()
	var title_string: String = file_content.get_slice("[/title]", 0)
	title_string = title_string.trim_prefix("[title]")
	return_dict["title"] = title_string

	var body_string = file_content.get_slice("[/title]", 1)
	body_string = body_string.replace("[steno]", steno_open_tags)
	body_string = body_string.replace("[/steno]", steno_close_tags)

	return_dict["body"] = body_string

	return return_dict


func _ready() -> void:
	var lesson_dictionary: Dictionary = parse_lesson_text("res://story_mode/UI/theory_lessons/2_short_vowels_AO.txt")
	var title_text = title_open_tags % title_font_size
	title_text = title_text + lesson_dictionary["title"] + title_close_tags
	title_label.set_text(title_text)
	lesson_body.set_text(lesson_dictionary["body"])
