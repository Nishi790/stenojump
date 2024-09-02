extends PanelContainer

signal menu_pressed

@export var level_size_toggle: CheckBox
@export var level_size_container: Container
@export var min_level_size: SpinBox
@export var max_level_size: SpinBox
@export var level_order_selector: OptionButton
@export var menu_button: Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	menu_button.pressed.connect(quit_menu)
	level_size_toggle.toggled.connect(use_custom_level_size)
	min_level_size.value_changed.connect(set_minimum_size)
	max_level_size.value_changed.connect(set_maximum_size)
	level_order_selector.item_selected.connect(set_level_order)
	level_size_toggle.set_pressed(PlayerConfig.use_custom_size)
	min_level_size.set_value(PlayerConfig.min_level_length)
	max_level_size.set_value(PlayerConfig.max_level_length)
	level_order_selector.select(PlayerConfig.preferred_word_order)

	level_size_toggle.grab_focus()


func use_custom_level_size(enabled: bool) -> void:
	PlayerConfig.use_custom_size = enabled
	level_size_container.visible = enabled


func set_minimum_size(min_size: float) -> void:
	PlayerConfig.min_level_length = int(min_size)


func set_maximum_size(max_size: float) -> void:
	PlayerConfig.max_level_length = int(max_size)


func set_level_order(selection_index: int) -> void:
	PlayerConfig.preferred_word_order = selection_index as PlayerConfig.WordOrder


func quit_menu() -> void:
	menu_pressed.emit()
