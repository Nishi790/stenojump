class_name ActionDisplay
extends VBoxContainer

signal word_requested
signal action_taken(action_type: Socks.GeneralActions)

@export var target_label: RichTextLabel
@export var action_name: Label
@export var texture_rect: TextureRect
@export var action_texture: AtlasTexture
@export var animation_frames: Array[Vector2]

@export var action_type: Socks.GeneralActions

var tween: Tween

var target_data: Dictionary
var target_word: String

var hints_active: bool
var minimum_label_height: float = 24


func _ready() -> void:
	action_name.set_text(Socks.GeneralActions.find_key(action_type))
	texture_rect.texture = action_texture


func check_target_match(word: String) -> void:
	var attempted_match: String = word.strip_edges()
	if target_word.matchn(attempted_match):
		if not animation_frames.is_empty():
			play_animation()
		action_taken.emit(action_type)
		word_requested.emit()


func set_target_word(word_data: Dictionary) -> void:
	target_data = word_data
	target_word = word_data["word"]

	target_label.text = ""
	target_label.text = "[center]%s[/center]" % target_word

	if hints_active and target_data.has("hint"):
		target_label.push_context()
		target_label.push_paragraph(HORIZONTAL_ALIGNMENT_CENTER)
		target_label.push_font(load("res://textures/UI/fonts/Stenodisplay-ClassicLarge.ttf"), 80)
		@warning_ignore("unsafe_call_argument")
		target_label.append_text(target_data["hint"])
	else:
		target_label.size.y = minimum_label_height


func set_hints_active(value: bool) -> void:
	hints_active = value
	if target_data:
		set_target_word(target_data)


func play_animation() -> void:
	if tween and tween.is_valid():
		tween.kill()
	tween = create_tween()
	for frame_coordinate: Vector2 in animation_frames:
		tween.tween_property(action_texture,"region:position", frame_coordinate, 0)
		tween.tween_interval(0.08)
	tween.tween_interval(0.05)
	var start_frame:Vector2 = animation_frames[0]
	tween.tween_property(action_texture, "region:position", start_frame, 0)
