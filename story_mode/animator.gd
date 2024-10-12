class_name Animator
extends Node

var sprite: AnimatedSprite2D
var audio_player: AudioStreamPlayer2D

@export var animations: Dictionary #Animation Name: animation_container resource
@export var default_animation: AnimationContainer


var current_animation: AnimationContainer:
	set(animation):
		if current_animation:
			current_animation.sprite = null
			current_animation.audio_player = null

		current_animation = animation.duplicate()
		if not current_animation.change_animations.is_connected(change_named_anims):
			current_animation.change_animations.connect(change_named_anims)
		if not current_animation.default_changed.is_connected(change_default_anim):
			current_animation.default_changed.connect(change_default_anim)

		current_animation.sprite = sprite
		if current_animation.frames == null:
			current_animation.frames = sprite.sprite_frames
		else:
			sprite.sprite_frames = current_animation.frames
		current_animation.audio_player = audio_player


func set_up() -> void:
	current_animation = default_animation
	_play_anim(current_animation)


func play_animation(animation_name: String) -> void:
	var next_anim: AnimationContainer
	if animations.has(animation_name):
		next_anim = animations[animation_name]
	else:
		next_anim = default_animation
	if current_animation == next_anim:
		return
	else:
		await _play_anim(next_anim)


func play_default_animation() -> void:
	if current_animation != default_animation:
		await _play_anim(default_animation)


func _play_anim(animation: AnimationContainer) -> void:
	if current_animation:
		await current_animation._post_animation()
		await current_animation._after_animation_hook()
	current_animation = animation
	await current_animation._before_animation_hook()
	await current_animation._pre_animation()
	await current_animation._after_pre_animation_hook()
	if current_animation.oneshot:
		await current_animation._play()
		await current_animation._before_post_animation_hook()
		play_default_animation()
	else:
		await current_animation._play()
		await current_animation._before_post_animation_hook()



func change_default_anim(new_anim: AnimationContainer) -> void:
	default_animation = new_anim


func change_named_anims(new_pairs: Dictionary) -> void:
	for key: String in new_pairs:
		var new_animation: AnimationContainer = load(new_pairs[key])
		animations[key] = new_animation
