extends LessonLevelMap

var jenny_scene: PackedScene = load("res://story_mode/characters/jenny.tscn")
@export var jenny_start_pos: Vector2
var jenny_character: BaseSelfNavCharacter
@export var jenny_nav_points: Array[Vector2]

@export var bedroom_door: BaseInteractable
@export var food_bowl: BaseInteractable
@export var bed: BaseInteractable
@export var sink: BaseInteractable
@export var shoe_rack: BaseInteractable


func _load_event_funcs() -> void:
	event_funcs = {"wake_jenny" : wake_up_jenny, "unlock_door": unlock_door, "jenny_leaves": jenny_leave_home,
	"feed_socks": feed_socks, "jenny_enters_kitchen": jenny_enter_kitchen, "jenny_finds_headphones": jenny_finds_headphones}


func wake_up_jenny(_args: Array) -> void:
	jenny_character = jenny_scene.instantiate()
	bed.animation_controller.play_animation("jenny_wakes_up")
	add_jenny()
	level_word_list.update_event("jenny_woke_up", true)


func add_jenny() -> void:
	add_child(jenny_character)
	jenny_character.global_position = jenny_start_pos
	jenny_character.nav_astar = astar_nav_grid
	jenny_character.wake_up(jenny_nav_points[0])
	await get_tree().create_timer(5).timeout
	jenny_character.get_dressed(jenny_nav_points[4])


func unlock_door(_args: Array) -> void:
	jenny_character.nav_to_coords(jenny_nav_points[2])
	await jenny_character.navigation_finished
	bedroom_door.interaction_enabled = true
	start_dialog("jenny_opens_door", level_word_list.dialogue_resource)


func feed_socks(_args: Array) -> void:
	if level_word_list.level_events["bedroom_door_open"].event_complete == false and jenny_character.global_position.x > 1250:
		jenny_character.nav_to_astar_point(bedroom_door.astar_point)
		await jenny_character.navigation_finished
		bedroom_door._interact()

	jenny_character.nav_to_coords(jenny_nav_points[5])
	await jenny_character.navigation_finished

	food_bowl.animation_controller.play_animation("fill_bowl")
	food_bowl.interact_events.clear()
	food_bowl.interact_events.append("breakfast_eaten")
	#change animation frames to the ones for food
	#Change to a new node, of type OneShotInteractable
	#update interact event to "breakfast_eaten"


func jenny_enter_kitchen(_args: Array) -> void:
	while sink.sprite.animation != "idle_after_interact":
		await sink.sprite.animation_changed
	jenny_character.nav_to_astar_point(sink.astar_point)
	await jenny_character.navigation_finished
	sink.complete_interact("interact")

	level_word_list.update_event("jenny_in_kitchen", true)
	start_dialog("missing_headphones", level_word_list.dialogue_resource)


func jenny_finds_headphones(_args: Array) -> void:
	jenny_character.nav_to_coords(jenny_nav_points[6])
	await jenny_character.navigation_finished
	start_dialog("headphones_found", level_word_list.dialogue_resource)
	shoe_rack.animation_controller.play_animation("take_headphones")
	level_word_list.update_event("headphones_taken", true)



func jenny_leave_home() -> void:
	jenny_character.nav_to_coords(jenny_nav_points[3])
	jenny_character.navigation_finished.connect(jenny_character.queue_free, CONNECT_ONE_SHOT)
	print("Bye Jennv!")
