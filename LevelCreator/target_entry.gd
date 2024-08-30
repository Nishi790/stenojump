extends HBoxContainer

signal target_updated (word: String)
signal score_updated (score: int)
signal hint_updated (hint: String)

@export var target_entry: LineEdit
@export var score_entry: SpinBox
@export var hint_entry: LineEdit
@export var edit_button: Button

var target_word: String
var score: int
var hint: String

var currently_editing: bool = false

func _ready() -> void:
	target_entry.text_submitted.connect(update_target)
	score_entry.value_changed.connect(update_score)
	hint_entry.text_submitted.connect(update_hint)
	edit_button.toggled.connect(enable_editing)
	enable_editing(false)

func enable_editing(enabled: bool):
	currently_editing = enabled
	if currently_editing:
		target_entry.editable = true
		score_entry.editable = true
		hint_entry.editable = true
	else:
		target_entry.editable = false
		score_entry.editable = false
		hint_entry.editable = false

func update_target(word: String) -> void:
	target_word = word
	target_updated.emit(word)

func update_score(points: int) -> void:
	score = points
	score_updated.emit(points)

func update_hint(hint_text: String) -> void:
	hint = hint_text
	hint_updated.emit(hint_text)
