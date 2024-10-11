extends LessonLevelMap

var jenny_scene: PackedScene = load("res://story_mode/characters/jenny.tscn")
@export var jenny_start_pos: Vector2
var jenny_character: BaseSelfNavCharacter
@export var jenny_nav_points: Array[Vector2]

@export var bedroom_door: BaseInteractable
@export var food_bowl: BaseInteractable


func _load_event_funcs() -> void:
	event_funcs = {"wake_jenny" : wake_up_jenny, "unlock_door": unlock_door, "jenny_leaves": jenny_leave_home,
	"feed_socks": feed_socks, "jenny_enters_kitchen": jenny_enter_kitchen}


func wake_up_jenny(_args: Array) -> void:
	jenny_character = jenny_scene.instantiate()
	waypoints[5].animation_controller.play_animation("jenny_wakes_up")
	add_jenny()
	level_word_list.update_event("jenny_woke_up", true)


func add_jenny() -> void:
	add_child(jenny_character)
	jenny_character.global_position = jenny_start_pos
	jenny_character.nav_astar = astar_nav_grid
	jenny_character.wake_up(Vector2(1920, 520))
	await get_tree().create_timer(5).timeout
	jenny_character.get_dressed(jenny_nav_points[4])


func unlock_door(_args: Array) -> void:
	jenny_character.nav_to_interest_point(jenny_nav_points[2])
	jenny_character.navigation_finished.connect(animate_unlock_door, CONNECT_ONE_SHOT)


func animate_unlock_door() -> void:
	print("Jenny is unlocking the door")
	bedroom_door.interaction_enabled = true


func feed_socks(_args: Array) -> void:
	print("Socks has food")
	#change animation frames to the ones for food
	#Change to a new node, of type OneShotInteractable
	#update interact event to "breakfast_eaten"


func jenny_enter_kitchen(_args: Array) -> void:
	print("Jenny is in the kitchen")
	level_word_list.update_event("jenny_in_kitchen", true)
	start_dialog("missing_headphones", level_word_list.dialogue_resource)


func jenny_leave_home() -> void:
	jenny_character.nav_to_interest_point(jenny_nav_points[3])
	jenny_character.navigation_finished.connect(jenny_character.queue_free, CONNECT_ONE_SHOT)
	print("Bye Jennv!")
