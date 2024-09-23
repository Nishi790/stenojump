extends PopupPanel

@export var pop_up_text: Label


func _ready() -> void:
	pass


func save_failed(err: Error) -> void:
	pop_up_text.set_text("Save Failed: %s" % error_string(err))
	get_tree().create_timer(2).timeout.connect(hide)


func save_success() -> void:
	pop_up_text.set_text("Save Successful!")
	get_tree().create_timer(2).timeout.connect(hide)


func loading_level() -> void:
	pop_up_text.set_text("Loading existing level")
