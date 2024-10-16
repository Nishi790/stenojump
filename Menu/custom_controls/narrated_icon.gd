class_name AltTextTextureRect
extends TextureRect

@export var alt_text: String


func _ready() -> void:
	if PlayerConfig.voice_all_ui:
		focus_entered.connect(_on_focus_entered)
		focus_mode = FocusMode.FOCUS_ALL


func _on_focus_entered():
	PlayerConfig.speak_tts("alt_text")
