extends AnimatedSprite2D

enum State {SITTING, STANDING}


var current_state: State = State.SITTING
var  queued_anims: Array[String] = []
var anim_state: Dictionary = {
	"eat": State.STANDING,
	"idle": State.SITTING,
	"idle_stand": State.STANDING,
	"jump_up": State.STANDING,
	"look_at_player": State.STANDING,
	"run": State.STANDING,
	"sit_down": State.STANDING,
	"stand_up": State.SITTING,
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_finished.connect(next_anim)
	animation_looped.connect(next_anim)
	play("idle")


# Takes string and plans transition to new animation
func command(command_name: String) -> void:
	match command_name:
		"sit":
			if current_state == State.SITTING:
				return
			else:
				queued_anims.append("sit_down")
		"stand":
			if current_state == State.STANDING:
				return
			else:
				queued_anims.append("stand_up")
		"snack time", "eat":
			queued_anims.append("eat")
		"jump":
			queued_anims.append("jump_up")
		"hello":
			queued_anims.append("look_at_player")
		"go":
			queued_anims.append("run")


func next_anim() -> void:
	if check_for_anim_chain():
		return
	elif queued_anims.size() == 0:
		if current_state == State.SITTING and animation != "idle":
			play("idle")
		elif current_state == State.STANDING and animation != "idle_stand":
			play("idle_stand")
	else:
		var next_anim_name: String = queued_anims[0]
		if anim_state.has(next_anim_name):
			if anim_state[next_anim_name] != current_state:
				if anim_state[next_anim_name] == State.STANDING:
					play("stand_up")
					current_state = State.STANDING
				elif anim_state[next_anim_name] == State.SITTING:
					play("sit_down")
					current_state = State.SITTING
			else:
				if next_anim_name == "stand_up":
					current_state = State.STANDING
				elif next_anim_name == "sit_down":
					current_state = State.SITTING
				play(next_anim_name)
				queued_anims.remove_at(0)


func check_for_anim_chain() -> bool:
	match animation:
		"jump_up":
			play("jump_down")
		"look_at_player":
			play("stare_at_player")
		"stare_at_player":
			play("look_ahead")
		_:
			return false
	return true
