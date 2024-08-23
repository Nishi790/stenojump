extends Area2D

signal start_running


func _ready() -> void:
	body_entered.connect(on_body_entered)


func on_body_entered(body: Node2D) -> void:
	if body.is_in_group("obstacles"):
		start_running.emit()
