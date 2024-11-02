class_name InGameMenuButtonContainer
extends VBoxContainer

signal button_selected(index: int)
signal pass_focus

@export var button_array: Array[BaseButton]

var last_selected_button: int = 0


func _ready() -> void:
	focus_entered.connect(set_focus)
	for index in button_array.size():
		button_array[index].pressed.connect(select_button.bind(index))


func display_content() -> void:
	show()
	if not button_array.is_empty():
		button_array[last_selected_button].set_pressed(true)
		button_array[last_selected_button].pressed.emit()


func select_button(index: int) -> void:
	last_selected_button = index
	button_array[index].grab_focus()
	button_selected.emit(index)


func reset_selection() -> void:
	button_array[0].set_pressed(true)
	button_array[0].pressed.emit()
	button_array[0].grab_focus()


func set_focus() -> void:
	if is_visible_in_tree():
		button_array[0].grab_focus()
	else:
		pass_focus.emit()
