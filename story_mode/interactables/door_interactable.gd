@tool
class_name ConnectionInteractable
extends BaseInteractable

signal change_connection(points: Vector2i)

var connected_by_door: Vector2i

@export var door_open: bool = false

func _ready() -> void:
	super()


##Sets which two Astar points are connected by the door
func set_door_points(id_1: int, id_2: int) -> void:
	connected_by_door = Vector2i(id_1, id_2)


func _draw() -> void:
	super()



func complete_interact(_animation_name: StringName) -> void:
	if not door_open:
		animation_controller.play_animation("interact_open")
	else:
		animation_controller.play_animation("interact_close")


	door_open = false if door_open else true
	change_connection.emit(connected_by_door)
	for event_name in interact_events:
		tried_event.emit(event_name, door_open)


func get_tex_rect() -> Rect2:
	return Rect2(Vector2.ZERO, Vector2.ZERO)
