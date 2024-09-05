class_name TargetDisplay
extends HBoxContainer

signal data_updated (index: int, word: String, score: int, hint: String)
signal entry_deleted(index: int)

@export var target_entry: LineEdit
@export var score_entry: SpinBox
@export var hint_entry: LineEdit
@export var edit_button: Button
@export var delete_button: TextureButton

var entry_index: int
var target_word: String
var score: int
var hint: String

var currently_editing: bool = false

func _ready() -> void:
	target_entry.editable = false
	score_entry.editable = false
	hint_entry.editable = false

	target_entry.text_changed.connect(update_target)
	score_entry.value_changed.connect(update_score)
	hint_entry.text_changed.connect(update_hint)
	edit_button.toggled.connect(enable_editing)
	delete_button.pressed.connect(delete_entry)


func enable_editing(enabled: bool) -> void:
	currently_editing = enabled
	if currently_editing:
		target_entry.editable = true
		score_entry.editable = true
		hint_entry.editable = true
		edit_button.text = "Save changes"
	else:
		target_entry.editable = false
		score_entry.editable = false
		hint_entry.editable = false
		data_updated.emit(entry_index, target_word, score, hint)
		edit_button.text = "Edit Entry"


func display_data(data: Dictionary) -> void:
	target_entry.set_text(data["word"])
	update_target(target_entry.text)
	score_entry.set_value(data["score"])
	@warning_ignore("narrowing_conversion")
	update_score(score_entry.value)
	hint_entry.set_text(data["hint"])
	update_hint(hint_entry.text)


func update_target(word: String) -> void:
	target_word = word

func update_score(points: int) -> void:
	score = points

func update_hint(hint_text: String) -> void:
	hint = hint_text


func delete_entry() -> void:
	entry_deleted.emit(entry_index)
	queue_free()
