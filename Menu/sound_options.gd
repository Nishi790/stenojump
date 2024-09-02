extends PanelContainer

signal menu_pressed

@export var speak_UI: CheckBox
@export var voice_selector: OptionButton

@export var menu_button: Button

var system_voices: PackedStringArray

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	system_voices = DisplayServer.tts_get_voices_for_language("en")
	for voice in system_voices:
		var voice_name: String = voice.replace("\\", "/")
		var path_sections: PackedStringArray = voice_name.split("/")
		voice_selector.add_item(path_sections[-1])
	voice_selector.item_selected.connect(set_default_voice)
	speak_UI.toggled.connect(set_voice_ui)

	menu_button.pressed.connect(quit_to_menu)


func set_voice_ui(enabled: bool) -> void:
	PlayerConfig.voice_all_ui = enabled


func set_default_voice(index: int) -> void:
	PlayerConfig.preferred_voice = system_voices[index]
	test_play_voice()


func test_play_voice() -> void:
	DisplayServer.tts_speak("These are your current voice settings", PlayerConfig.preferred_voice, \
	PlayerConfig.preferred_voice_volume, PlayerConfig.preferred_voice_pitch, \
	PlayerConfig.preferred_voice_rate, 0, true)


func quit_to_menu () -> void:
	menu_pressed.emit()


func process_text(text: String) -> bool:
	return false


func initiate_focus() -> void:
	speak_UI.grab_focus()
