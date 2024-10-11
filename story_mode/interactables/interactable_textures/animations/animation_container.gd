class_name AnimationContainer
extends Resource

signal change_animations(new_pairs: Dictionary)
signal default_changed(new_default: AnimationContainer)

@export var frames: SpriteFrames = null
var sprite: AnimatedSprite2D

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
	if not pre_animation_name.is_empty():
		sprite.play(pre_animation_name)
		await sprite.animation_finished


func _after_pre_animation_hook() -> void:
	pass


func _play() -> void:
	if not animation_name.is_empty():
		sprite.play(animation_name)
		if sprite.get_sprite_frames().get_animation_loop(animation_name):
			await sprite.animation_looped
		else:
			await sprite.animation_finished


func _before_post_animation_hook() -> void:
	pass


func _post_animation() -> void:
	if not post_animation_name.is_empty():
		sprite.play(post_animation_name)
		await sprite.animation_finished


func _after_animation_hook() -> void:
	pass
