extends GutTest


var story_manager: StoryLevelManager
var story_ui: StoryUI
var story_level: LessonLevelMap
var story_data: StoryLevelData

var line: DialogueLine

func before_each() -> void:
	story_manager = partial_double(StoryLevelManager).new()
	story_level = partial_double(load("res://story_mode/story_levels/level_1.gd")).new()
	story_level._load_event_funcs()
	story_manager.level = story_level
	story_ui = double(StoryUI).new()
	story_manager.UI = story_ui
	story_level.dialogue_started.connect(run_dialogue)
	story_data = load("res://story_mode/story_levels/level_words/level_1_story_data.tres")
	story_level.level_word_list = story_data



func after_each() -> void:
	story_data = null
	story_level.level_word_list = null

func run_dialogue(dialogue_key: String, dialogue_file: DialogueResource) -> void:
	gut.p("Running Dialogue: %s"  % [dialogue_key])
	line = await dialogue_file.get_next_dialogue_line(dialogue_key, [story_manager, story_ui])
	while line != null:
		line = await dialogue_file.get_next_dialogue_line(line.next_id, [story_manager, story_ui])


func test_finish_first_steps() -> void:
	watch_signals(story_data)
	story_data.start_quest("first_steps")
	story_data.update_event("first_move", true)
	assert_signal_emitted(story_data, "dialog_started")

	assert_true(story_data.active_quests.has("first_interact"))


func test_finish_first_interact() -> void:
	watch_signals(story_data)
	story_data.start_quest("first_interact")
	story_data.update_event("first_interact", true)
	assert_signal_emitted(story_data, "dialog_started")
	assert_true(story_data.active_quests.has("wake_up_jenny"))


func test_finish_wake_jenny() -> void:
	stub(story_level.wake_up_jenny).to_do_nothing()
	watch_signals(story_data)
	story_data.start_quest("wake_up_jenny")
	story_data.update_event("bedroom_curtains_open", true)
	story_data.update_event("sat_on_bed", true)
	story_data.update_event("book_fallen", true)

	assert_signal_emitted(story_data, "dialog_started")
	assert_true(story_data.active_quests.has("open_the_door"))


func test_finish_open_door() -> void:
	stub(story_level, "unlock_door").to_do_nothing()
	watch_signals(story_data)
	story_data.start_quest("open_the_door")
	story_data.update_event("jenny_woke_up", true)
	story_data.update_event("meowed_at_door_once", true)
	story_data.update_event("meowed_at_door_twice", true)
	story_data.update_event("bedroom_door_open", true)
	assert_true(story_data.completed_quests.has("open_the_door"))
	assert_signal_emitted(story_data, "dialog_started")
	assert_true(story_data.active_quests.has("check_bowl"))


func test_finish_check_bowl() -> void:
	watch_signals(story_data)
	story_data.start_quest("check_bowl")
	story_data.update_event("bedroom_door_open", true)
	story_data.update_event("interacted_with_bowl", true)
	assert_signal_emitted(story_data, "dialog_started")
	assert_true(story_data.active_quests.has("eat_breakfast"))


func test_start_overall_quest() -> void:
	story_data.dialog_started.emit("teach_i_vowel", story_data.dialogue_resource)
	assert_true(story_data.active_quests.has("get_jenny_out_the_door"))


func test_start_headphone_quest() -> void:
	story_level.jenny_enter_kitchen([])
	assert_true(story_data.active_quests.has("find_jennys_headphones"))


func test_end_level_dialogue() -> void:
	stub(story_level.jenny_leave_home).to_do_nothing()
	watch_signals(story_data)
	story_data.start_quest("get_jenny_out_the_door")
	story_data.update_event("headphones_revealed", true)
	story_data.update_event("bring_jenny_to_headphones", true)
	story_data.level_events["jenny_in_kitchen"].event_complete = true
	story_data.update_event("got_jennys_attention", true)
	story_data.update_event("breakfast_eaten", true)
	assert_true(story_data.completed_quests.has("get_jenny_out_the_door"))
	assert_signal_emitted_with_parameters(story_data, "dialog_started", ["end_level", story_data.dialogue_resource])
	assert_called(story_level, "jenny_leave_home")


func test_simultaneous_dialogue() -> void:
	pass
