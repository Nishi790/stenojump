class_name SelfNavCharacter
extends Node2D

enum GeneralActions {MEOW, USE_ITEM}

@export var animations: AnimatedSprite2D
@export var interaction_area: Area2D
@export var speed: float = 300

var nav_astar: AStar2D

var nav_path: PackedVector2Array
var nav_index: int = 0
var next_point: Vector2
var destination: Vector2

var direction: Vector2 = Vector2.ZERO
var direction_changed: bool = false

var navigating: bool = false
var at_height: bool = false


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


func nav_to_interest_point(coords: Vector2) -> void:
	navigating = true
	destination = coords
	nav_path = nav_astar.get_point_path(nav_astar.get_closest_point(position), nav_astar.get_closest_point(destination), true)
	next_nav_point()


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


func select_animation() -> void:
	if navigating == false:
		if direction.x < 0:
			animations.flip_h = true
		else:
			animations.flip_h = false
		animations.play("idle")
		direction_changed = false
		direction = Vector2.ZERO
	else:
		if at_height:
			if direction.x < 0:
				animations.flip_h = true
			else:
				animations.flip_h = false
			animations.play("jump_down")
		elif abs(direction.x) > abs(direction.y):
			if direction.x < 0:
				animations.flip_h = true
			else:
				animations.flip_h = false
			animations.play("walk")
		else:
			if direction.y > 0:
				animations.play("walk_down")
			else:
				animations.play("walk_up")


func chain_anim() -> void:
	var finished_anim: String = animations.animation
	match finished_anim:
		"reach_up":
			animations.play("paw_air")
		"paw_air":
			animations.play("paws_down")
		"paws_down":
			select_animation()
		"jump_down":
			change_height("jump_down")
			select_animation()
		"jump_up_sleep":
			animations.play("lie_down")
		"lie_down":
			animations.play("sleep")


func interact(anim_name: String, final_pos: Vector2 = Vector2.ZERO) -> void:
	if anim_name == "":
		animations.play("reach_up")
	else:
		change_height(anim_name)

		if final_pos != Vector2.ZERO:
			translate_in_anim(final_pos, anim_name)

		animations.play(anim_name)


func translate_in_anim(target_pos: Vector2, anim_name: String) -> void:
	var x_direction: float = target_pos.x - global_position.x
	if x_direction < 0:
		animations.flip_h = true
	else:
		animations.flip_h = false

	var anim_frame_length: float = animations.sprite_frames.get_frame_count(anim_name)
	var anim_speed: float = animations.sprite_frames.get_animation_speed(anim_name)
	var anim_length: float = anim_frame_length/anim_speed

	var pos_tween: Tween = get_tree().create_tween()
	pos_tween.tween_property(self, "position", target_pos, anim_length)


func change_height(anim_name: String) -> void:
	if anim_name.contains("jump_up"):
		at_height = true
	elif anim_name.contains("jump_down"):
		at_height = false
