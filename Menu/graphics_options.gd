extends PanelContainer

signal menu_pressed

@export var target_vis_picker: OptionButton
@export var target_background_toggle: CheckBox
@export var target_bg_picker: ColorPickerButton
@export var target_color_picker: ColorPickerButton
@export var target_preview: PanelContainer
@export var background_options_container: VBoxContainer
@export var menu_button: Button

var custom_style: Theme

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Grab current custom style for targets
	if PlayerConfig.custom_target_style == null:
		PlayerConfig.custom_target_style = PlayerConfig.target_style.duplicate(true)
		var style_box = PlayerConfig.custom_target_style.get_stylebox("panel", "PanelContainer")
		style_box.bg_color = Color.BLACK
		PlayerConfig.custom_target_style.set_stylebox("panel", "PanelContainer", style_box)
	custom_style = PlayerConfig.custom_target_style
	target_preview.theme = custom_style
	toggle_target_background(PlayerConfig.use_custom_target_theme)
	target_vis_picker.item_selected.connect(update_target_visibility)
	target_background_toggle.toggled.connect(toggle_target_background)
	target_bg_picker.color_changed.connect(target_background_changed)
	target_color_picker.color_changed.connect(target_color_changed)
	menu_button.pressed.connect(back_to_menu)


func update_target_visibility(selection_index: int) -> void:
	match selection_index:
		0:
			PlayerConfig.target_visibility = PlayerConfig.TargetVisibility.ALL
		1:
			PlayerConfig.target_visibility = PlayerConfig.TargetVisibility.NEXT
		2:
			PlayerConfig.target_visibility = PlayerConfig.TargetVisibility.IN_RANGE
		3:
			PlayerConfig.target_visibility = PlayerConfig.TargetVisibility.NONE


func toggle_target_background(pressed: bool) -> void:
	background_options_container.visible = pressed
	PlayerConfig.use_custom_target_theme = pressed


func target_background_changed(color: Color) -> void:
	var default_stylebox: StyleBoxFlat = custom_style.get_stylebox("panel", "PanelContainer")
	default_stylebox.bg_color = color
	custom_style.set_stylebox("panel", "PanelContainer", default_stylebox)


func target_color_changed(color: Color) -> void:
	custom_style.set_color("font_color", "Label", color)

#Option not yet available, will need to have some built in options, and hopefully option to select own font
func target_font_changed() -> void:
	var new_font: Font = SystemFont.new()
	new_font.font_names.append("sans-serif")
	custom_style.set_font("default", "Label", new_font)


#Needs to call when leaving the tab to save specific settings
func leave_tab() -> void:
	PlayerConfig.custom_target_style = custom_style


func back_to_menu() -> void:
	leave_tab()
	menu_pressed.emit()
