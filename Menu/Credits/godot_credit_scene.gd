extends VBoxContainer


@export var license_label: Label

func _ready() -> void:
	license_label.text = Engine.get_license_text()
