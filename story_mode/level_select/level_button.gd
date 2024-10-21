class_name LevelSelectButton
extends TextureButton

signal level_selected(level_name: String, level_type)
signal add_curve(curve: Line2D)
signal level_unlocked(level_number: int)


@export var level_type: StoryLevelSelector.LevelType
@export var level_name: String
@export var next_level_button: LevelSelectButton
@export var curve_to_next: Curve2D
@export var level_number: int

var line_to_next: Line2D
var curve_points: PackedVector2Array
var growth_speed: int = 100

@export var focus_text: String = "Story level %s"

func _ready() -> void:
	focus_entered.connect(speak_tts)
	pressed.connect(start_level)


func speak_tts() -> void:
	if PlayerConfig.voice_all_ui:
		PlayerConfig.speak_tts(focus_text %  level_number)


func start_level() -> void:
	print("Starting %s" % level_name)
	level_selected.emit(level_name, level_type)


func unlock() -> void:
	disabled = false
	var tween = create_tween()
	modulate.a = 0
	show()
	tween.tween_property(self, "modulate:a", 1, 0.5)
	level_unlocked.emit(level_number)



func unlock_next_level() -> void:
	curve_points = curve_to_next.tessellate()
	var point_count: int = curve_points.size()

	line_to_next = Line2D.new()
	line_to_next.default_color = Color.WHITE_SMOKE
	add_curve.emit(line_to_next)

	var tween: Tween = create_tween()
	for index: int in point_count:
		if index == 0:
			line_to_next.add_point(curve_points[index])
		else:
			var line_segment: Vector2 = curve_points[index] - curve_points[index - 1]
			var line_length: float = line_segment.length()
			var tween_time: float = line_length / growth_speed
			tween.tween_method(line_to_next.add_point, curve_points[index - 1], curve_points[index - 1], 0)
			tween.tween_method(grow_line.bind(index), curve_points[index - 1], curve_points[index], tween_time)
	if next_level_button != null:
		tween.finished.connect(next_level_button.unlock)

func grow_line(point: Vector2, point_index: int) -> void:
	line_to_next.set_point_position(point_index, point)
