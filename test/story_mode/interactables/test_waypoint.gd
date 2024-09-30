extends GutTest

var waypoint_scene: PackedScene = load("res://story_mode/interactables/way_point.tscn")


var waypoint_double: Waypoint
var connected_waypoint: Waypoint
var character: SelfNavCharacter

func before_each() -> void:
	waypoint_double = partial_double(waypoint_scene).instantiate()
	connected_waypoint = partial_double(waypoint_scene).instantiate()
	character = double(SelfNavCharacter).new()
	var interact_area: Area2D = autoqfree(Area2D.new())
	character.add_child(interact_area)
	character.interaction_area = interact_area
	add_child(waypoint_double)
	add_child(connected_waypoint)
	waypoint_double.connected_points = [connected_waypoint]
	add_child(character)


func test_connected_target_show() -> void:
	#Test no change w/o target  data
	waypoint_double.initiate_words(character.interaction_area)
	assert_false(connected_waypoint.target_label.visible)

	#Test make existing target visible
	connected_waypoint.target_data = {"word": "run", "hint": "RUPB"}
	waypoint_double.initiate_words(character.interaction_area)
	assert_true(connected_waypoint.target_label.visible)


func test_hide_target() -> void:
	waypoint_double.hide_label()
	assert_false(waypoint_double.can_match, "Matching should be disabled")
	assert_false(waypoint_double.target_label.visible, "Target word should be hidden")


func test_hide_connected_target() -> void:
	connected_waypoint.target_label.visible = true
	connected_waypoint.can_match = true

	waypoint_double.hide_words(character.interaction_area)
	assert_false(connected_waypoint.target_label.visible, "Label should not be visible")
	assert_false(connected_waypoint.can_match, "Matching should be disabled")


func test_check_match() -> void:
	waypoint_double.target_word = "word"
	waypoint_double.can_match = true
	stub(waypoint_double.word_entered).to_do_nothing()

	assert_true(waypoint_double.check_target_match(" word"), "Word should match with extra whitespace")
	assert_true(waypoint_double.check_target_match("word"), "Word should match when identical")
	assert_false(waypoint_double.check_target_match("nword"), "Word should not match when error word contains target")
	assert_false(waypoint_double.check_target_match("different"), "Word shouldn't match different word")
	assert_false(waypoint_double.check_target_match("wo rd"), "Word shouldn't match with mid-word whitespace")


func test_word_entered() -> void:
	waypoint_double.target_data = {"word": "rap", "hint": "RAP"}
	waypoint_double.target_word = "rap"
	waypoint_double.target_label.visible = true
	watch_signals(waypoint_double)

	waypoint_double.word_entered()
	assert_eq_deep(waypoint_double.target_data, {})
	assert_eq(waypoint_double.target_word, "", "Target word should be cleared")
	assert_false(waypoint_double.target_label.visible, "Label should be hidden")
	assert_signal_emitted_with_parameters(waypoint_double, "move_destination_selected", [waypoint_double])


func test_connected_target_request_word() -> void:
	#Test connected point requests target word
	watch_signals(connected_waypoint)
	waypoint_double.initiate_words(character.interaction_area)
	assert_signal_emitted(connected_waypoint, "request_target_word", "Target word should be requested for connections")


func test_movement_multi_event_firing()-> void:
	watch_signals(waypoint_double)
	waypoint_double.movement_events = ["First Steps", "Find Nap Spot"]
	waypoint_double.initiate_words(character.interaction_area)
	assert_signal_emit_count(waypoint_double, "tried_event", 2, "Signal should be emitted for each movement event")


func test_movement_event_firing() -> void:
	watch_signals(waypoint_double)
	waypoint_double.movement_events = ["First Steps"]
	waypoint_double.initiate_words(character.interaction_area)
	assert_signal_emitted_with_parameters(waypoint_double, "tried_event", [waypoint_double.movement_events[0], true])
