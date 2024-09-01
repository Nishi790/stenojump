class_name CustomFocusButton
extends Button


@export var text_to_speak: String

func _ready() -> void:
	if text_to_speak == "":
		text_to_speak = text
	focus_entered.connect(_on_focus_enter)

func _on_focus_enter() -> void:
	if PlayerConfig.voice_all_ui:
		DisplayServer.tts_speak(text_to_speak, PlayerConfig.preferred_voice, \
		PlayerConfig.preferred_voice_volume, PlayerConfig.preferred_voice_pitch, \
		PlayerConfig.preferred_voice_rate)
