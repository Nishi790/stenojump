extends LessonLevelMap

var jenny_scene: PackedScene = load("res://story_mode/characters/jenny.tscn")
@export var jenny_start_pos: Vector2
var jenny_character: BaseSelfNavCharacter
@export var jenny_nav_points: Array[Vector2]


func _ready() -> void:
	super()
	event_funcs = {"wake_jenny" : wake_up_jenny}


func wake_up_jenny(_args: Array) -> void:
	jenny_character = jenny_scene.instantiate()
	if waypoints[5].animation_frames.has_animation("get up"):
		waypoints[5].animation.play("get up")
		waypoints[5].animation.animation_finished.connect(add_jenny, CONNECT_ONE_SHOT)
	else:
		waypoints[5].animation.play("idle_jenny_awake")
		add_jenny()


func add_jenny() -> void:
	add_child(jenny_character)
	jenny_character.global_position = jenny_start_pos
	jenny_character.nav_astar = astar_nav_grid
	jenny_character.wake_up(Vector2(1920, 520))
