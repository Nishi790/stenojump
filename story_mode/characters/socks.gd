class_name Socks
extends BaseSelfNavCharacter

@export var soundfx: AudioStreamPlayer2D
@export var sfx: Dictionary #int: AudioStream

enum GeneralActions {MEOW, USE_ITEM, HISS}
enum Sounds {MEOW, HISS, PAW, SCRATCH, PURR}

var at_height: bool = false


func select_animation() -> void:
	if navigating == false:
		if direction.x < 0:
			sprite.flip_h = true
		else:
			sprite.flip_h = false
		animations.play("idle")
		direction_changed = false
		direction = Vector2.ZERO
	else:
		if at_height:
			if direction.x < 0:
				sprite.flip_h = true
			else:
				sprite.flip_h = false
			animations.play("jump_down")
		elif abs(direction.x) > abs(direction.y):
			if direction.x < 0:
				sprite.flip_h = true
			else:
				sprite.flip_h = false
			animations.play("walk")
		else:
			if direction.y > 0:
				animations.play("walk_down")
			else:
				animations.play("walk_up")


func chain_anim(finished_anim: StringName) -> void:
	match finished_anim:
		"reach_up":
			animations.play("paw_air")
		"paw_air":
			animations.play("paws_down")
		"paws_down":
			select_animation()
		"jump_down":
			change_height("jump_down")
			select_animation()
		"jump_up_sleep":
			animations.play("lie_down")
		"lie_down":
			animations.play("sleep")
		"meow":
			select_animation()


func interact(anim_name: String, interactee_x_pos: float, final_pos: Vector2 = Vector2.ZERO) -> void:
	if interactee_x_pos < global_position.x + sprite.offset.x:
		sprite.flip_h = true
	else: sprite.flip_h = false
	if anim_name == "":
		animations.play("reach_up")
	else:
		change_height(anim_name)
		animations.current_animation = anim_name
		if final_pos != Vector2.ZERO:
			translate_in_anim(final_pos, anim_name)
		animations.play()



func change_height(anim_name: String) -> void:
	if anim_name.contains("jump_up"):
		at_height = true
		z_index = 1
	elif anim_name.contains("jump_down"):
		at_height = false
		z_index = 0



func do_action(action: GeneralActions) -> void:
	match action:
		GeneralActions.MEOW:
			animations.play("meow")
		GeneralActions.HISS:
			return
		GeneralActions.USE_ITEM:
			return
