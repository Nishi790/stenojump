extends CenterContainer

signal return_to_level_select

func _ready() -> void:
	$DemoOver/VBoxContainer/CustomFocusButton.grab_focus()
	$DemoOver/VBoxContainer/CustomFocusButton.pressed.connect(func menu() -> void:
		return_to_level_select.emit()
		queue_free())
