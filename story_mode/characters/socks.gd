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
		animations.play("Socks/idle")
		direction_changed = false
		direction = Vector2.ZERO
	else:
		if at_height:
			if direction.x < 0:
				sprite.flip_h = true
			else:
				sprite.flip_h = false
			animations.play("Socks/jump_down")
		elif abs(direction.x) > abs(direction.y):
			if direction.x < 0:
				sprite.flip_h = true
			else:
				sprite.flip_h = false
			animations.play("Socks/walk")
		else:
			if direction.y > 0:
				animations.play("Socks/walk_down")
			else:
				animations.play("Socks/walk_up")


func chain_anim(finished_anim: StringName) -> void:
	match finished_anim:
		"Socks/reach_up":
			animations.play("Socks/paw_air")
		"Socks/paw_air":
			animations.play("Socks/paws_down")
		"Socks/paws_down":
			select_animation()
		"Socks/jump_down":
			change_height("Socks/jump_down")
			select_animation()
		"Socks/jump_up_sleep":
			animations.play("Socks/lie_down")
		"Socks/lie_down":
			animations.play("Socks/sleep")
		"Socks/meow":
			select_animation()


func interact(anim_name: String, final_pos: Vector2 = Vector2.ZERO) -> void:
	if anim_name == "":
		animations.play("Socks/reach_up")
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
			animations.play("Socks/meow")
		GeneralActions.HISS:
			return
		GeneralActions.USE_ITEM:
			return
