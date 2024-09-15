@tool
class_name ConnectionInteractable
extends BaseInteractable

signal change_connection(points: Vector2i)

var connected_by_door: Vector2i

@export var door_open: bool = false

##Sets which two Astar points are connected by the door
func set_door_points(id_1: int, id_2: int) -> void:
	connected_by_door = Vector2i(id_1, id_2)


func _draw() -> void:
	super()


func _interact() -> void:
	door_open = false if door_open else true
	change_connection.emit(connected_by_door)
