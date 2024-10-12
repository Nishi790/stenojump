extends AnimatedSprite2D


@export var animator: Animator
@export var audio: AudioStreamPlayer2D


func _ready() -> void:
	animator.audio_player = audio
	animator.sprite = self
	animator.play_default_animation()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		print("playing target animation")
		animator.play_animation("interact")
