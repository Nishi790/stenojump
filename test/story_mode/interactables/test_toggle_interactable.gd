extends GutTest

var toggle_interact_scene: PackedScene = load("res://story_mode/interactables/toggle_interactable.tscn")

var toggle_interact: ToggleInteractable
var character: SelfNavCharacter

func before_each() -> void:
	character = double(SelfNavCharacter).new()
	var interact_area: Area2D = autoqfree(Area2D.new())
	character.add_child(interact_area)
	toggle_interact = partial_double(toggle_interact_scene).instantiate()
	toggle_interact.interactor = character

	add_child(toggle_interact)
	character.animations = autoqfree(AnimatedSprite2D.new())
	character.animations.sprite_frames = load("res://textures/character_animations/player_sprite_frames.tres")


func test_complete_interact_interact_anim_exists(params = use_parameters([true, false])) -> void:
	var anim_frames: SpriteFrames = autofree(load("res://story_mode/interactables/interactable_textures/curtain_anims.tres"))
	toggle_interact.animation_frames = anim_frames
	watch_signals(toggle_interact)
	watch_signals(toggle_interact.animation)

	toggle_interact.interact_events = ["Knock down book"]
	toggle_interact.toggle_value = params
	toggle_interact.ready_to_interact = false

	toggle_interact.complete_interact()

	assert_eq(toggle_interact.toggle_value, !params, "After interact, the interactable's toggled state should be false")
	assert_signal_emitted_with_parameters(toggle_interact, "tried_event", [toggle_interact.interact_events[0], !params])
	assert_false(toggle_interact.ready_to_interact, "After interaction is complete, should not be ready to interact again until idle")
	assert_connected(toggle_interact.animation, toggle_interact, "animation_finished", "return_to_idle")

	await wait_for_signal(toggle_interact.animation.animation_finished, 5)

	assert_called(toggle_interact, "return_to_idle")
	assert_true(toggle_interact.ready_to_interact, "Should be ready to interact after interact anim completes")
	assert_signal_emitted(toggle_interact, "request_target_word", "Should request a new word after interacting")

func test_complete_interact_no_interact_anim(params = use_parameters([true, false])) -> void:
	var anim_frames: SpriteFrames = autofree(SpriteFrames.new())
	anim_frames.add_animation("idle")
	toggle_interact.animation_frames = anim_frames
	watch_signals(toggle_interact)

	toggle_interact.interact_events = ["An event"]
	toggle_interact.toggle_value = params
	toggle_interact.ready_to_interact = false

	toggle_interact.complete_interact()
	assert_eq(toggle_interact.toggle_value, !params, "After interact, toggle value should have switched")
	assert_signal_emitted(toggle_interact, "tried_event", [toggle_interact.interact_events[0], !params])
	assert_true(toggle_interact.ready_to_interact, "Given no interact anim, should be ready to interact again")
	assert_signal_emitted(toggle_interact, "request_target_word", "Should request a new word")
