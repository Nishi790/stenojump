class_name SelfNavCharacter
extends Node2D

@export var animations: AnimatedSprite2D

var nav_astar: AStar2D

var nav_path: PackedVector2Array
var nav_index: int = 0
var next_point: Vector2
var destination: Vector2

var direction: Vector2 = Vector2.ZERO
var direction_changed: bool = false
@export var speed: float = 300
var navigating: bool = false

var can_interact: bool = false
var interactable: BaseInteractable

func _ready() -> void:

	animations.animation_finished.connect(chain_anim)
	select_animation()


#TODO remove when interaction system is in place
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		nav_to_interest_point(Vector2(1312, 428))
	elif event.is_action_pressed("ui_left"):
		print("Trying interact")
		if can_interact:
			interact()


func _process(delta: float) -> void:
	if direction_changed:
		select_animation()



func _physics_process(delta: float) -> void:

	if nav_astar == null:
		return

	if navigating:
		var old_dir: Vector2 = direction
		direction = (next_point - position).normalized()
		if direction != old_dir:
			direction_changed = true
		position = position.move_toward(next_point, speed * delta)
		if position.is_equal_approx(next_point):
			next_nav_point()


func nav_to_interest_point(coords: Vector2) -> void:
	print("Navigating to %s" % coords)
	navigating = true
	destination = coords
	nav_path = nav_astar.get_point_path(nav_astar.get_closest_point(position), nav_astar.get_closest_point(destination))
	next_nav_point()


func next_nav_point() -> void:
	if nav_path.size() == nav_index:
		end_navigation()
	else:
		next_point = nav_path[nav_index]
		nav_index += 1


func end_navigation() -> void:
	navigating = false
	destination = Vector2.ZERO
	next_point = Vector2.ZERO
	nav_path.clear()


func select_animation() -> void:
	if navigating == false:
		if direction.x < 0:
			animations.flip_h = true
		else:
			animations.flip_h = false
		animations.play("idle")
		direction_changed = false
	else:
		if abs(direction.x) > abs(direction.y):
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
			interactable._interact()
			animations.play("paws_down")
		"paws_down":
			select_animation()


func interact() -> void:
	print("interaction started")
	animations.play("reach_up")
