extends MarginContainer

signal new_processed_text (text: String)

@export var text_control: LineEdit
@export var animation: AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text_control.text_submitted.connect(process_text)
	text_control.grab_focus()


func provide_options_focus_neighbor(neighbors: Array[Control]) -> void:
	text_control.options_focus_neighbors = neighbors
	text_control.reset_focus_neighbors(1)


func set_menu_focus_neighbors() -> void:
	text_control.reset_focus_neighbors(0)


func set_start_focus_neighbors(neighbors: Array[Control]) -> void:
	text_control.start_game_focus_neigbors = neighbors
	text_control.reset_focus_neighbors(2)


#  clean submitted text and send for processing
func process_text(submitted_text: String) -> void:
	var processed_text: String = submitted_text.strip_edges()
	processed_text = processed_text.to_lower()
	text_control.clear()
	if check_anim(processed_text):
		return
	new_processed_text.emit(processed_text)


func unknown_command(command: String) -> void:
	text_control.editable = false
	text_control.set_text("I don't know how to \"%s\"" % command)
	await get_tree().create_timer(2).timeout
	text_control.clear()
	text_control.editable = true


func check_anim(text: String) -> bool:
	match text:
		"sit", "snack time", "eat", "stand", "jump", "hello", "go":
			animation.command(text)
			return true
		_:
			return false
