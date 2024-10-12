class_name BaseSelfNavCharacter

extends Node2D

signal navigation_finished

@export var animations: AnimationPlayer
@export var sprite: AnimatedSprite2D
@export var interaction_area: Area2D
@export var speed: float = 300

var has_situational_idle: bool = false
var situational_idle: StringName

var nav_astar: AStar2D

var nav_path: PackedVector2Array
var nav_index: int = 0
var next_point: Vector2
var destination: Vector2

var direction: Vector2 = Vector2.ZERO
var direction_changed: bool = false

var navigating: bool = false


func _ready() -> void:

	animations.animation_finished.connect(chain_anim)
	select_animation()



func _process(_delta: float) -> void:
	if direction_changed:
		select_animation()



func _physics_process(delta: float) -> void:

	if nav_astar == null:
		return

	if navigating:
		direction_changed = false
		var old_dir: Vector2 = direction
		direction = (next_point - position).normalized()
		if not direction.is_equal_approx(old_dir):
			direction_changed = true
		position = position.move_toward(next_point, speed * delta)
		if position.is_equal_approx(next_point):
			next_nav_point()


func nav_to_astar_point(id: int, current_point_id: int = -1) -> bool:
	navigating = true
	destination = nav_astar.get_point_position(id)
	if current_point_id == -1:
		current_point_id = nav_astar.get_closest_point(global_position)
	nav_path = nav_astar.get_point_path(current_point_id, id, false)
	if nav_path.is_empty():
		end_navigation()
		return false
	else:
		next_nav_point()
		return true


func nav_to_coords(coords: Vector2) -> bool:
	navigating = true
	destination = coords
	nav_path = nav_astar.get_point_path(nav_astar.get_closest_point(position), nav_astar.get_closest_point(destination), false)
	if nav_path.is_empty():
		end_navigation()
		return false
	else:
		next_nav_point()
		return true


func next_nav_point() -> void:
	if nav_path.size() == nav_index:
		end_navigation()
	else:
		next_point = nav_path[nav_index]
		nav_index += 1


func end_navigation() -> void:
	nav_index = 0
	navigating = false
	destination = Vector2.ZERO
	next_point = Vector2.ZERO
	nav_path.clear()
	select_animation()
	navigation_finished.emit()


func select_animation() -> void:
	if navigating:
		if abs(direction.x) > abs(direction.y):
			if direction.x < 0:
				animations.play("walk_left")
			else:
				animations.play("walk_right")
		else:
			if direction.y > 0:
				animations.play("walk_down")
			else:
				animations.play("walk_up")
	elif has_situational_idle:
		animations.play(situational_idle)
	else:
		animations.play("idle_down")


func chain_anim(_finished_anim: StringName) -> void:
	pass


func translate_in_anim(target_pos: Vector2, _anim_name: String) -> void:
	var x_direction: float = target_pos.x - global_position.x
	if x_direction < 0:
		sprite.flip_h = true
	else:
		sprite.flip_h = false

	var anim_length: float = animations.current_animation_length

	var pos_tween: Tween = get_tree().create_tween()
	pos_tween.tween_property(self, "position", target_pos, anim_length)
