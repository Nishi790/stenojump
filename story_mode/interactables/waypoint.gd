@tool
class_name Waypoint
extends Area2D

signal request_target_word
signal move_destination_selected(destination: Waypoint)
signal tried_event(event_name: String, event_value: bool)
signal tried_action(event_name: String, action:Socks.GeneralActions)
signal became_current_point(current_point: Waypoint)

@export var target_label: RichTextLabel
@export var label_offset: Vector2i = Vector2i(0, -50)
@export var connected_points: Array[Waypoint]:
	set(points):
		connected_points = points
		if Engine.is_editor_hint():
			reciprocate_connection(connected_points, points)
			queue_redraw()
		else:
			connected_points = points

@export var hints_active: bool = true:
	set(value):
		hints_active = value
		if target_label and target_word != "":
			display_target()

@export var movement_events: Array[String] ##Names of events that can be triggered by moving to this point
@export var action_events: Array[String] ##Names of events triggered with an action at this location

var minimum_label_size: Vector2 = Vector2(160, 30)

var target_data: Dictionary
var target_word: String
var default_height: float = 20

var can_match: bool = false

var astar_point: int

##Helper function to make connections reciprocal between waypoints - used only in editor
func reciprocate_connection(old_points: Array, new_points: Array) -> void:
	if new_points.size() >= old_points.size():
		for point: Waypoint in new_points:
			if point.connected_points.find(self) == -1:
				point.connected_points.append(self)
	else:
		var removed_connection: Array = old_points.filter(func (element: Waypoint) -> bool: return new_points.find(element) == -1)
		for element: Waypoint in removed_connection:
			element.connected_points.erase(self)


func _ready() -> void:
	area_entered.connect(initiate_words)
	area_exited.connect(hide_words)
	target_label.custom_minimum_size = minimum_label_size
	target_label.position = Vector2(target_label.custom_minimum_size.x/-2, -50)
	target_label.visible = false
	print("%s is ready" % name)


func _draw() -> void:
	print("redraw called")
	draw_circle(Vector2.ZERO, 10, Color.REBECCA_PURPLE)
	if Engine.is_editor_hint():
		for connection in connected_points:
			draw_line(Vector2.ZERO, to_local(connection.global_position), Color.PURPLE)


func set_target(data: Dictionary) -> void:
	target_data = data
	target_word = target_data["word"]
	display_target()


func display_target() -> void:
	can_match = true
	target_label.visible = true

	target_label.text = ""
	target_label.text = "[center]%s[/center]" % target_word

	if hints_active and target_data.has("hint"):
		target_label.push_context()
		target_label.push_paragraph(HORIZONTAL_ALIGNMENT_CENTER)
		target_label.push_font(load("res://textures/UI/fonts/Stenodisplay-ClassicLarge.ttf"), 80)
		@warning_ignore("unsafe_call_argument")
		target_label.append_text(target_data["hint"])
		target_label.position.y = label_offset.y - target_label.get_combined_minimum_size().y
	else:
		target_label.size = minimum_label_size
		target_label.position.y = label_offset.y - minimum_label_size.y


##Called when the character enters the area of the waypoint; tries movement events
func initiate_words(area: Area2D) -> void:
	if not area.get_parent() is Socks:
		return
	became_current_point.emit(self)
	if not movement_events.is_empty():
		for event_name in movement_events:
			tried_event.emit(event_name, true)
	for connection in connected_points:
		if connection.target_data.is_empty():
			connection.request_target_word.emit()
		else:
			connection.display_target()


func try_action_event(action: Socks.GeneralActions) -> void:
	for event in action_events:
		tried_action.emit(event, action)


func hide_words(area: Area2D)-> void:
	if area.get_parent() is Socks:
		for connection in connected_points:
			connection.hide_label()


func hide_label()-> void:
	target_label.visible = false
	can_match = false


##Test whether entered string matches target and respond to match
func check_target_match(test_string: String)-> bool:
	if can_match:
		var test: String = test_string.strip_edges()
		if test.matchn(target_word):
			word_entered()
			return true
		else:
			return false
	else: return false


##Respond to correct word entry
func word_entered() -> void:
	clear_target()
	move_destination_selected.emit(self)


##Called to clear target_word data and hide label
func clear_target() -> void:
	target_data = {}
	target_word = ""
	hide_label()
