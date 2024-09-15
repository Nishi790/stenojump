@tool
class_name BaseInteractable
extends Waypoint

var ready_to_interact: bool = false


func _ready() -> void:
	super()
	area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area2D) -> void:
	if area.get_parent() is SelfNavCharacter:
		var character: SelfNavCharacter = area.get_parent()
		character.can_interact = true
		character.interactable = self
		set_ready_to_interact(true)
		target_label.visible = false
		request_target_word.emit()


func _draw() -> void:
	super()


func _interact() -> void:
	print("Interacted with %s" % self.name)


func set_ready_to_interact(value: bool) -> void:
	ready_to_interact = value
	if value:
		target_label.add_theme_color_override("default_color",Color.YELLOW)
	else: target_label.remove_theme_color_override("default_color")
