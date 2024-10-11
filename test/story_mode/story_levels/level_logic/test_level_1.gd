extends GutTest


var level_data: StoryLevelData
var level: LessonLevelMap

func before_each():
	gut.p("running set up, loading fresh level_data")
	level = partial_double(load("res://story_mode/story_levels/level_1.gd")).new()
	level_data = load("res://story_mode/story_levels/level_words/level_1_story_data.tres")
	level.level_word_list = level_data
	level._load_event_funcs()


func after_each() -> void:
	level_data = null
	level.level_word_list = null


func test_first_steps() -> void:
	watch_signals(level_data)
	level_data.start_quest("first_steps")
	level_data.update_event("first_move", true)
	assert_true(level_data.completed_quests.has("first_steps"))
	assert_signal_emitted(level_data, "dialog_started")


func test_first_interact() -> void:
	watch_signals(level_data)
	level_data.update_event("first_steps", true)
	level_data.start_quest("first_interact")
	level_data.update_event("first_interact", true)
	assert_true(level_data.completed_quests.has("first_interact"))
	assert_signal_emitted(level_data, "dialog_started")

func test_jenny_wakes(params = use_parameters([["book_fallen", "bedroom_curtains_open", "meowed_beside_bed"], ["book_fallen", "bedroom_curtains_open", "sat_on_bed"],  ["book_fallen", "knocked_over_alarm_clock", "bedroom_curtains_open"],
["bedroom_curtains_open, knocked_over_alarm_clock", "meowed_beside_bed"], ["bedroom_curtains_open", "knocked_over_alarm_clock", "sat_on_bed"], ["knocked_over_alarm_clock", "sat_on_bed", "meowed_beside_bed"]])) -> void:
	watch_signals(level_data)
	stub(level.wake_up_jenny).to_call(func lambda(_args): level_data.update_event("jenny_woke_up", true))

	level_data.start_quest("wake_up_jenny")
	assert_false(level_data.level_events["jenny_woke_up"].event_complete)
	for index: int in params.size():
		level_data.update_event(params[index], true)
		if index < 2:
			assert_false(level_data.completed_quests.has("wake_up_jenny"))
		else:
			assert_true(level_data.completed_quests.has("wake_up_jenny"))
			assert_signal_emitted(level_data, "dialog_started")
			assert_signal_emitted_with_parameters(level_data, "event_triggered", ["wake_jenny", []])
			assert_called(level, "call_event", ["wake_jenny", []])
			assert_called(level, "wake_up_jenny")
			assert_true(level_data.level_events["jenny_woke_up"].event_complete)


func test_open_bedroom_door() -> void:
	var door: ConnectionInteractable = double(ConnectionInteractable).new()
	door.interaction_enabled = false
	level.bedroom_door = door

	watch_signals(level_data)
	assert_false(door.interaction_enabled)
	level_data.update_event("jenny_woke_up", true)
	stub(level.unlock_door).to_call(func lambda(_args): level.animate_unlock_door())

	level_data.start_quest("open_the_door")
	assert_true(level_data.active_quests.keys().has("open_the_door"))

	level_data.update_action_event("meowed_at_door_once", Socks.GeneralActions.MEOW)
	level_data.update_action_event("meowed_at_door_twice", Socks.GeneralActions.MEOW)
	assert_signal_emitted_with_parameters(level_data, "event_triggered", ["unlock_door", []])
	assert_called(level, "unlock_door")
	assert_called(level, "animate_unlock_door")
	assert_true(door.interaction_enabled)

	level_data.update_event("bedroom_door_open", true)
	assert_true(level_data.completed_quests.has("open_the_door"))
	assert_signal_emitted(level_data, "dialog_started")


func test_check_bowl() -> void:
	level_data.start_quest("check_bowl")
	level_data.update_event("bedroom_door_open", true)
	level_data.update_event("interacted_with_bowl", true)
	assert_true(level_data.completed_quests.has("check_bowl"))


func test_eat_breakfast() -> void:
	level_data.level_events["bedroom_door_open"].event_complete = true
	var food_bowl: BaseInteractable = double(BaseInteractable).new()
	food_bowl.interact_events = ["interacted_with_bowl"]
	level.food_bowl = food_bowl
	food_bowl.tried_event.connect(level_data.update_event)
	assert_false(food_bowl.interact_events.has("breakfast_eaten"))

	level_data.start_quest("eat_breakfast")
	assert_false(level_data.completed_quests.has("eat_breakfast"))
	level_data.update_event("sink_overflow", true)
	assert_called(level, "jenny_enter_kitchen")

	assert_true(level_data.level_events["jenny_in_kitchen"].event_complete)
	level_data.update_event("got_jennys_attention", true)

	assert_true(level.food_bowl.interact_events.has("breakfast_eaten"))
	level_data.update_event("breakfast_eaten", true)
	assert_true(level_data.completed_quests.has("eat_breakfast"))


func test_find_headphones() -> void:
	stub(level.jenny_leave_home).to_do_nothing()
	level_data.start_quest("find_jennys_headphones")
	assert_true(level_data.active_quests.has("find_jennys_headphones"))

	level_data.update_event("headphones_revealed", true)
	assert_false(level_data.completed_quests.has("headphones_revealed"))

	level_data.update_event("bring_jenny_to_headphones", true)
	assert_true(level_data.completed_quests.has("find_jennys_headphones"))
