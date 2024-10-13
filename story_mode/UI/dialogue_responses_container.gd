extends PanelContainer

signal response_selected

@export var next_action: StringName
@export var response_scene: PackedScene
@export var response_organizer: VBoxContainer

var response_buttons: Array[Button]

func _ready() -> void:
	visibility_changed.connect(_on_show_responses)


func set_responses(responses: Array) -> void:
	for resp_button: Button in response_buttons:
		resp_button.queue_free()
	await get_tree().process_frame
	for response in responses:
		var new_scene: Button
		if response_scene:
			new_scene = response_scene.instantiate()
		else:
			new_scene = Button.new()
		new_scene.text = response.text
		new_scene.pressed.connect(send_response.bind(response))
		response_buttons.append(new_scene)
		response_organizer.add_child(new_scene)
		new_scene.grab_focus()


func send_response(response: DialogueResponse) -> void:
	response_selected.emit(response)


func _on_show_responses() -> void:
	if visible:
		if response_organizer.get_child_count() > 0:
			response_organizer.get_child(0).grab_focus()
