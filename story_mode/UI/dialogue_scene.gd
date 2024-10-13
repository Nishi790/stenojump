class_name DialogueScene
extends HBoxContainer

signal dialogue_finished

@export var speaker_texture: TextureRect
@export var speaker_name_label: Label
@export var dialogue_label: DialogueLabel
@export var response_container: PanelContainer
@export var portrait_dict: Dictionary #String: Texture

## The action to use for advancing the dialogue
@export var next_action: StringName = &"ui_accept"

## The action to use to skip typing the dialogue
@export var skip_action: StringName = &"ui_cancel"

var resource: DialogueResource

## Temporary game states
var temporary_game_states: Array = []

## See if we are waiting for the player
var is_waiting_for_input: bool = false

## See if we are running a long mutation and should hide the balloon
var will_hide_balloon: bool = false

var _locale: String = TranslationServer.get_locale()

## The current line
var dialogue_line: DialogueLine:

	get:
		return dialogue_line


func _ready() -> void:
	hide()
	Engine.get_singleton("DialogueManager").mutated.connect(_on_mutated)

	# If the responses menu doesn't have a next action set, use this one
	if response_container.next_action.is_empty():
		response_container.next_action = next_action
	response_container.response_selected.connect(_on_responses_menu_response_selected)
	dialogue_label.finished_typing.connect(wait_for_input)


func _unhandled_input(_event: InputEvent) -> void:
	# Only the balloon is allowed to handle input while it's showing
	get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	## Detect a change of locale and update the current dialogue line to show the new language
	if what == NOTIFICATION_TRANSLATION_CHANGED and _locale != TranslationServer.get_locale() and is_instance_valid(dialogue_label):
		_locale = TranslationServer.get_locale()
		var visible_ratio = dialogue_label.visible_ratio
		self.dialogue_line = await resource.get_next_dialogue_line(dialogue_line.id)
		if visible_ratio < 1:
			dialogue_label.skip_typing()


## Start some dialogue
func start(dialogue_resource: DialogueResource, title: String, extra_game_states: Array = []) -> void:
	temporary_game_states =  [self] + extra_game_states
	is_waiting_for_input = false
	resource = dialogue_resource
	set_dialogue_line(await resource.get_next_dialogue_line(title, temporary_game_states))
	display_dialogue()


## Go to the next line
func next(next_id: String) -> void:
	set_dialogue_line(await resource.get_next_dialogue_line(next_id, temporary_game_states))
	display_dialogue()


func set_dialogue_line(next_dialogue_line: DialogueLine) -> void:
	dialogue_line = next_dialogue_line
	is_waiting_for_input = false
	focus_mode = Control.FOCUS_ALL
	grab_focus()

	# The dialogue has finished so close the balloon
	if not next_dialogue_line:
		end_dialogue()
		return




func set_character_portrait(character_name: String) -> void:
	var mood: String = dialogue_line.get_tag_value("mood")
	var portrait_key: String = character_name
	if not mood.is_empty():
		portrait_key = portrait_key + mood
	if portrait_dict.has(portrait_key):
		speaker_texture.set_texture(portrait_dict[portrait_key])
	else:
		speaker_texture.texture = PlaceholderTexture2D.new()


func end_dialogue() -> void:
	dialogue_finished.emit()
	hide()


func display_dialogue() -> void:
	if not dialogue_line:
		return

	# If the node isn't ready yet then none of the labels will be ready yet either
	if not is_node_ready():
		await ready

	speaker_name_label.visible = not dialogue_line.character.is_empty()
	speaker_name_label.text = tr(dialogue_line.character, "dialogue")
	set_character_portrait(dialogue_line.character)

	dialogue_label.hide()
	dialogue_label.dialogue_line = dialogue_line

	response_container.hide()
	if not dialogue_line.responses.is_empty():
		response_container.set_responses(dialogue_line.responses) ##TODO create set responses function for the container, grab focus when made visible

	# Show our balloon
	show()
	will_hide_balloon = false

	dialogue_label.show()
	if not dialogue_line.text.is_empty():
		dialogue_label.type_out()


func skip_dialogue() -> void:
	while dialogue_line:
		set_dialogue_line(await resource.get_next_dialogue_line(dialogue_line.next_id, temporary_game_states))


#region Signals


func _on_mutated(_mutation: Dictionary) -> void:
	is_waiting_for_input = false
	will_hide_balloon = true
	get_tree().create_timer(0.1).timeout.connect(func():
		if will_hide_balloon:
			will_hide_balloon = false
			hide()
	)


func _gui_input(event: InputEvent) -> void:
	# See if we need to skip typing of the dialogue
	if dialogue_label.is_typing:
		var mouse_was_clicked: bool = event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed()
		var skip_button_was_pressed: bool = event.is_action_pressed(skip_action)
		if mouse_was_clicked or skip_button_was_pressed:
			get_viewport().set_input_as_handled()
			dialogue_label.skip_typing()
			return

	if not is_waiting_for_input: return
	if dialogue_line.responses.size() > 0: return

	# When there are no response options the balloon itself is the clickable thing
	get_viewport().set_input_as_handled()

	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		next(dialogue_line.next_id)
	elif event.is_action_pressed(next_action) and get_viewport().gui_get_focus_owner() == self:
		next(dialogue_line.next_id)


func _on_responses_menu_response_selected(response: DialogueResponse) -> void:
	next(response.next_id)


func wait_for_input() -> void:
	if not visible:
		return
	# Wait for input
	if dialogue_line.responses.size() > 0:
		focus_mode = Control.FOCUS_NONE
		response_container.show()

	elif dialogue_line.time != "":
		var time = dialogue_line.text.length() * 0.02 if dialogue_line.time == "auto" else dialogue_line.time.to_float()
		await get_tree().create_timer(time).timeout
		next(dialogue_line.next_id)
	else:
		is_waiting_for_input = true
		focus_mode = Control.FOCUS_ALL
		grab_focus()
		print(get_viewport().gui_get_focus_owner())
