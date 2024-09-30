extends GutTest

var one_shot_scene: PackedScene = load("res://story_mode/interactables/one_shot_interactable.tscn")
var one_shot_interact: OneShotInteractable
var connected_waypoint: Waypoint
var player: SelfNavCharacter

func before_each() -> void:
	player = double(SelfNavCharacter).new()
	one_shot_interact = partial_double(one_shot_scene).instantiate()
	one_shot_interact.interactor = player
	var player_area: Area2D = autoqfree(Area2D.new())
	player.add_child(player_area)
	player.interaction_area = player_area
	player.animations = autoqfree(AnimatedSprite2D.new())


func test_can_interact() -> void:
	one_shot_interact.has_interacted = false
	one_shot_interact.initiate_words(player.interaction_area)
	assert_true(one_shot_interact.ready_to_interact, "Should be able to interact")


func test_cant_interact() -> void:
	one_shot_interact.has_interacted = true
	one_shot_interact.initiate_words(player.interaction_area)
	assert_false(one_shot_interact.ready_to_interact, "Shouldn't be able to interact")


func test_mark_as_interacted() -> void:
	one_shot_interact.has_interacted = false
	one_shot_interact._interact()
	assert_true(one_shot_interact.has_interacted, "Should be marked as having interacted")


func test_interact_target_visibility_after_have_interacted() -> void:
	one_shot_interact.target_label.visible = false
	one_shot_interact.can_match = false
	connected_waypoint = partial_double(Waypoint).new()
	connected_waypoint.connected_points = [one_shot_interact]
	watch_signals(one_shot_interact)
	one_shot_interact.has_interacted = true

	connected_waypoint.initiate_words(player.interaction_area)
	assert_signal_emitted(one_shot_interact, "request_target_word", "Should request a word")

	one_shot_interact.set_target({"word": "something", "hint": "S-G"})
	assert_true(one_shot_interact.target_label.visible, "Should see target for movement")
	assert_true(one_shot_interact.can_match, "Should be able to match word")

	one_shot_interact.word_entered()
	assert_false(one_shot_interact.target_label.visible, "Should not see target after arriving at target")
	assert_false(one_shot_interact.ready_to_interact, "Should not be ready to interact")
	assert_false(one_shot_interact.can_match, "Should not be able to match words")


func test_enter_word_for_move_then_interact() -> void:
	#Set up as if on adjoining point
	one_shot_interact.has_interacted = false
	one_shot_interact.ready_to_interact = false
	watch_signals(one_shot_interact)
	one_shot_interact.set_target({"word": "test", "hint": "TEFT"})

	#Move to the interactable
	one_shot_interact.check_target_match("test")
	assert_signal_emitted(one_shot_interact, "move_destination_selected", "Should be moving here")
	assert_called(one_shot_interact, "word_entered")

	one_shot_interact.initiate_words(player.interaction_area)
	assert_true(one_shot_interact.ready_to_interact, "should now be ready to interact")
	assert_signal_emitted(one_shot_interact, "request_target_word", "Should request an interaction word")

	one_shot_interact.set_target({"word": "sit", "hint": "SEUT"})
	assert_eq(one_shot_interact.target_word, "sit")

	#interact with interactable
	one_shot_interact.check_target_match("sit")

	assert_called(one_shot_interact, "_interact")

	one_shot_interact.complete_interact()

	assert_false(one_shot_interact.target_label.visible, "Should not see target label")
	assert_false(one_shot_interact.ready_to_interact, "Should not be able to interact")
	assert_false(one_shot_interact.can_match, "Should not be able to match")
