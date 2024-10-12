class_name AnimationContainer
extends Resource

@warning_ignore("unused_signal")
signal change_animations(new_pairs: Dictionary)
@warning_ignore("unused_signal")
signal default_changed(new_default: AnimationContainer)

@export var frames: SpriteFrames = null
var sprite: AnimatedSprite2D
var audio_player: AudioStreamPlayer2D

@export var oneshot: bool

@export_group("animation_names")
@export var pre_animation_name: StringName
@export var animation_name: StringName
@export var post_animation_name: StringName

@export_group("animation_sounds")
@export var pre_animation_sound: AudioStream
@export var animation_sound: AudioStream
@export var post_animation_sound: AudioStream


func _before_animation_hook() -> void:
	pass


func _pre_animation() -> void:
	if not pre_animation_sound == null:
		audio_player.stream = pre_animation_sound
		audio_player.play()
	if not pre_animation_name.is_empty():
		sprite.play(pre_animation_name)
		await sprite.animation_finished


func _after_pre_animation_hook() -> void:
	pass


func _play() -> void:
	if not animation_sound == null:
		audio_player.stream = animation_sound
		audio_player.play()
	if not animation_name.is_empty():
		sprite.play(animation_name)
		if sprite.get_sprite_frames().get_animation_loop(animation_name):
			await sprite.animation_looped
		else:
			await sprite.animation_finished


func _before_post_animation_hook() -> void:
	pass


func _post_animation() -> void:
	if not post_animation_sound == null:
		audio_player.stream = post_animation_sound
		audio_player.play()
	if not post_animation_name.is_empty():
		sprite.play(post_animation_name)
		await sprite.animation_finished


func _after_animation_hook() -> void:
	pass
