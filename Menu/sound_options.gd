extends PanelContainer

signal menu_pressed

@export var menu_button: Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	menu_button.pressed.connect(quit_to_menu)


func quit_to_menu () -> void:
	menu_pressed.emit()
