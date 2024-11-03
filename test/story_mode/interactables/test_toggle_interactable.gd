extends GutTest

var toggle_interact_scene: PackedScene = load("res://story_mode/interactables/toggle_interactable.tscn")

var toggle_interact: ToggleInteractable
var character: Socks

func before_each() -> void:
	character = double(Socks).new()
	var interact_area: Area2D = autoqfree(Area2D.new())
	character.add_child(interact_area)
	toggle_interact = partial_double(toggle_interact_scene).instantiate()
	toggle_interact.interactor = character
	toggle_interact.animation_controller = autoqfree(Animator.new())
	toggle_interact.animation_controller.sprite = autoqfree(AnimatedSprite2D.new())
	toggle_interact.default_animation = AnimationContainer.new()
	toggle_interact.default_animation.frames = SpriteFrames.new()
	toggle_interact.interaction_enabled = true

	add_child(toggle_interact)
	character.animations = autoqfree(AnimationPlayer.new())
	character.sprite = autoqfree(AnimatedSprite2D.new())


func test_complete_interact_interact_anim_exists(params = use_parameters([true, false])) -> void:
	toggle_interact.animation_list["interact"] = AnimationContainer.new()
	watch_signals(toggle_interact)
	watch_signals(toggle_interact.animation_controller)

	toggle_interact.interact_events = ["Knock down book"]
	toggle_interact.toggle_value = params
	toggle_interact.ready_to_interact = false

	toggle_interact.complete_interact(&"Animation")

	assert_eq(toggle_interact.toggle_value, !params, "After interact, the interactable's toggled state should be false")
	toggle_interact.animation_controller.post_animation_hook.emit()
	assert_signal_emitted_with_parameters(toggle_interact, "tried_event", [toggle_interact.interact_events[0], !params])

	assert_true(toggle_interact.ready_to_interact, "Should be ready to interact after interact anim completes")
	assert_signal_emitted(toggle_interact, "request_target_word", "Should request a new word after interacting")

func test_complete_interact_no_interact_anim(params = use_parameters([true, false])) -> void:
	toggle_interact.animation_list["idle"] = AnimationContainer.new()
	watch_signals(toggle_interact)
	watch_signals(toggle_interact.animation_controller)

	toggle_interact.interact_events = ["An event"]
	toggle_interact.toggle_value = params
	toggle_interact.ready_to_interact = false

	toggle_interact.complete_interact(&"Animation")
	assert_eq(toggle_interact.toggle_value, !params, "After interact, toggle value should have switched")
	toggle_interact.animation_controller.post_animation_hook.emit()

	assert_signal_emitted(toggle_interact, "tried_event", [toggle_interact.interact_events[0], !params])
	assert_true(toggle_interact.ready_to_interact, "Given no interact anim, should be ready to interact again")
	assert_signal_emitted(toggle_interact, "request_target_word", "Should request a new word")
