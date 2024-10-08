class_name ActionDisplay
extends VBoxContainer

signal word_requested
signal action_taken(action_type)

@export var target_label: RichTextLabel
@export var action_name: Label

@export var action_type: SelfNavCharacter.GeneralActions

var target_data: Dictionary
var target_word: String

var hints_active: bool
var minimum_label_height: float = 24


func _ready() -> void:
	action_name.set_text(SelfNavCharacter.GeneralActions.find_key(action_type))


func check_target_match(word: String) -> void:
	var attempted_match: String = word.strip_edges()
	if target_word.matchn(attempted_match):
		action_taken.emit(action_type)
		word_requested.emit()


func set_target_word(word_data: Dictionary) -> void:
	target_data = word_data
	target_word = word_data["word"]

	target_label.text = ""
	target_label.text = "[center]%s[/center]" % target_word

	if hints_active and target_data.has("hint"):
		target_label.push_context()
		target_label.push_paragraph(HORIZONTAL_ALIGNMENT_CENTER)
		target_label.push_font(load("res://textures/UI/fonts/Stenodisplay-ClassicLarge.ttf"), 80)
		@warning_ignore("unsafe_call_argument")
		target_label.append_text(target_data["hint"])
	else:
		target_label.size.y = minimum_label_height
