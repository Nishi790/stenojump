extends PanelContainer

@export var resolution_picker: OptionButton
@export var target_vis_picker: OptionButton
@export var target_background_toggle: CheckBox
@export var target_bg_picker: ColorPickerButton
@export var target_color_picker: ColorPickerButton
@export var target_preview: PanelContainer
@export var background_options_container: VBoxContainer

var custom_style: Theme

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Grab current custom style for targets
	if PlayerConfig.custom_target_style == null:
		PlayerConfig.custom_target_style = PlayerConfig.target_style.duplicate(true)
	custom_style = PlayerConfig.custom_target_style
	target_preview.theme = custom_style
	resolution_picker.item_selected.connect(update_resolution)
	target_vis_picker.item_selected.connect(update_target_visibility)
	target_background_toggle.toggled.connect(toggle_target_background)
	target_bg_picker.color_changed.connect(target_background_changed)
	target_color_picker.color_changed.connect(target_color_changed)


func update_resolution(selection_index: int) -> void:
	pass


func update_target_visibility(selection_index: int) -> void:
	pass


func toggle_target_background(pressed: bool) -> void:
	background_options_container.visible = pressed
	PlayerConfig.use_custom_target_theme = pressed


func target_background_changed(color: Color) -> void:
	var default_stylebox: StyleBoxFlat = custom_style.get_stylebox("panel", "PanelContainer")
	default_stylebox.bg_color = color
	custom_style.set_stylebox("panel", "PanelContainer", default_stylebox)


func target_color_changed(color: Color) -> void:
	custom_style.set_color("font_color", "Label", color)


func target_font_changed():
	var new_font = SystemFont.new()
	new_font.font_names.append("sans-serif")
	custom_style.set_font("default", "Label", new_font)


#Needs to call when leaving the tab to save specific settings
func leave_tab() -> void:
	PlayerConfig.custom_target_style = custom_style
