extends VBoxContainer

@export var next_action: StringName
@export var response_scene: PackedScene

var response_buttons: Array[Button]

func _ready() -> void:
	visibility_changed.connect(_on_show_responses)


func set_responses(responses: Array[DialogueResponse]) -> void:
	for resp_button: Button in response_buttons:
		resp_button.queue_free()
	for response in responses:
		var new_scene: Button
		if response_scene:
			new_scene = response_scene.instantiate()
		else:
			new_scene = Button.new()



func _on_show_responses() -> void:
	if visible:
		get_child(0).grab_focus()
