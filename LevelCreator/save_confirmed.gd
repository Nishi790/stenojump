extends PopupPanel

@export var pop_up_text: Label


func _ready() -> void:
	about_to_popup.connect(_on_about_to_pop_up)


func save_failed(err: Error) -> void:
	pop_up_text.set_text("Save Failed: %s" % error_string(err))


func save_success() -> void:
	pop_up_text.set_text("Save Successful!")


func _on_about_to_pop_up() -> void:
	get_tree().create_timer(2).timeout.connect(hide)
