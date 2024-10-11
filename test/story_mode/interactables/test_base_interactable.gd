extends GutTest


var interactable_scene: PackedScene = load("res://story_mode/interactables/base_interactable.tscn")

var interactable: BaseInteractable
var character: Socks

func before_each() -> void:
	interactable = partial_double(interactable_scene).instantiate()
	add_child(interactable)
	character = partial_double(Socks).new()
	character.animations = autoqfree(AnimatedSprite2D.new())
	character.animations.sprite_frames = load("res://textures/character_animations/player_sprite_frames.tres")
	add_child(character)
	var interact_area: Area2D = Area2D.new()
	character.interaction_area = interact_area
	character.add_child(interact_area)

func test_enable_interact() -> void:
	watch_signals(interactable)
	interactable.initiate_words(character.interaction_area)
	assert_true(interactable.ready_to_interact, "Interaction not enabled on area entered")
	assert_signal_emitted(interactable, "request_target_word", "Should request a new word")


func test_disable_interact() -> void:
	interactable.hide_words(character.interaction_area)
	assert_false(interactable.ready_to_interact, "Should not be able to interact when words are not visible")


func test_interact() -> void:
	interactable.interactor = character
	interactable.interact_events = ["Did it"]
	watch_signals(interactable)
	stub(character.interact).to_do_nothing()

	interactable._interact()
	assert_called(character, "interact")
	assert_false(interactable.ready_to_interact, "Interactable should be disabled after interacting")

	character.animations.animation_finished.emit()
	assert_called(interactable, "complete_interact")
	assert_signal_emitted_with_parameters(interactable, "tried_event", [interactable.interact_events[0], true])


func test_word_entered() -> void:
	watch_signals(interactable)
	interactable.ready_to_interact = true
	stub(interactable, "_interact").to_do_nothing()
	interactable.word_entered()
	assert_called(interactable, "_interact")

	interactable.ready_to_interact = false
	interactable.word_entered()
	assert_signal_emit_count(interactable, "move_destination_selected", 1)
