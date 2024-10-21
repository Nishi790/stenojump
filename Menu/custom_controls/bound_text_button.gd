class_name BoundTextButton
extends CustomFocusButton

signal pressed_with_text(string_to_return: String)

@export var text_to_return: String

func _ready() -> void:
	pressed.connect(on_pressed)


func on_pressed() -> void:
	pressed_with_text.emit(text_to_return)
