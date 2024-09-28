extends PanelContainer

signal menu_pressed

@export var level_size_toggle: CheckBox
@export var level_size_container: Container
@export var min_level_size: SpinBox
@export var max_level_size: SpinBox
@export var level_order_selector: OptionButton

@export var max_lives_selector: SpinBox
@export var autojump_toggle: CheckBox
@export var enable_checkpoint: CheckBox
@export var checkpoint_every_level: CheckBox

@export var menu_button: Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visibility_changed.connect(load_current_settings)
	menu_button.pressed.connect(quit_menu)
	level_size_toggle.toggled.connect(use_custom_level_size)
	min_level_size.value_changed.connect(set_minimum_size)
	max_level_size.value_changed.connect(set_maximum_size)
	level_order_selector.item_selected.connect(set_level_order)
	max_lives_selector.value_changed.connect(set_max_lives)
	autojump_toggle.toggled.connect(enable_autojump)
	enable_checkpoint.toggled.connect(enable_checkpoints)
	checkpoint_every_level.toggled.connect(enable_checkpoint_all)
	load_current_settings()

	initiate_focus()


func load_current_settings() -> void:
	if visible:
		level_size_toggle.set_pressed(PlayerConfig.use_custom_size)
		min_level_size.set_value(PlayerConfig.min_level_length)
		max_level_size.set_value(PlayerConfig.max_level_length)
		level_order_selector.select(PlayerConfig.preferred_word_order)
		max_lives_selector.set_value(PlayerConfig.max_lives)
		enable_checkpoint.set_pressed(PlayerConfig.checkpoints_enabled)
		checkpoint_every_level.set_pressed(PlayerConfig.checkpoint_all)
		autojump_toggle.set_pressed(PlayerConfig.autojump)


func use_custom_level_size(enabled: bool) -> void:
	PlayerConfig.use_custom_size = enabled
	level_size_container.visible = enabled


func set_minimum_size(min_size: float) -> void:
	PlayerConfig.min_level_length = int(min_size)


func set_maximum_size(max_size: float) -> void:
	PlayerConfig.max_level_length = int(max_size)


func set_level_order(selection_index: int) -> void:
	PlayerConfig.preferred_word_order = selection_index as PlayerConfig.WordOrder


func set_max_lives(value: float) -> void:
	PlayerConfig.max_lives = int(value)


func enable_autojump(value: bool) -> void:
	PlayerConfig.autojump = value


func enable_checkpoints(value: bool) -> void:
	PlayerConfig.checkpoints_enabled = value


func enable_checkpoint_all(value: bool) -> void:
	if value == true and enable_checkpoint.button_pressed == false:
		enable_checkpoint.set_pressed(true)
	PlayerConfig.checkpoint_all = value


func quit_menu() -> void:
	menu_pressed.emit()


func process_text(text: String) -> bool:
	var split_text:  PackedStringArray = text.split(" ")
	while split_text.size() > 0:
		var target: String = split_text[0]
		split_text.remove_at(0)
		match target:
			"lives":
				if split_text.size() == 0:
					return false
				var specifier: String = split_text[0]
				split_text.remove_at(0)
				if specifier.is_valid_int():
					max_lives_selector.value = specifier.to_float()
				else:
					return false
			"size":
				if split_text.size() == 0:
					level_size_toggle.set_pressed(!level_size_toggle.button_pressed)
					return true
				else:
					var specifier: String = split_text[0]
					match specifier:
						"on":
							level_size_toggle.set_pressed(true)
							split_text.remove_at(0)
						"off":
							level_size_toggle.set_pressed(false)
							split_text.remove_at(0)
						_:
							level_size_toggle.set_pressed(!level_size_toggle.button_pressed)
			"minimum", "min":
				if split_text.size() == 0:
					return false
				var specifier: String = split_text[0]
				split_text.remove_at(0)
				if specifier.is_valid_float():
					min_level_size.value = specifier.to_float()
				else:
					return false
			"max", "maximum":
				if split_text.size() == 0:
					return false
				var specifier: String = split_text[0]
				split_text.remove_at(0)
				if specifier.is_valid_float():
					max_level_size.value = specifier.to_float()
				else:
					return false
			"order":
				if split_text.size() == 0:
					return false
				var specifier: String = split_text[0]
				split_text.remove_at(0)
				match specifier:
					"default":
						level_order_selector.select(0)
					"random":
						level_order_selector.select(1)
					"ordered", "order":
						level_order_selector.select(2)
					_:
						return false
			"auto", "autojump":
				if split_text.size() == 0:
					autojump_toggle.set_pressed(!autojump_toggle.button_pressed)
					return true
				else:
					var specifier: String = split_text[0]
					match specifier:
						"on":
							autojump_toggle.set_pressed(true)
							split_text.remove_at(0)
						"off":
							autojump_toggle.set_pressed(false)
							split_text.remove_at(0)
						_:
							autojump_toggle.set_pressed(!level_size_toggle.button_pressed)
			"checkpoints", "checkpoint":
				if split_text.size() == 0:
					enable_checkpoint.set_pressed(!level_size_toggle.button_pressed)
					return true
				else:
					var specifier: String = split_text[0]
					match specifier:
						"on":
							enable_checkpoint.set_pressed(true)
							split_text.remove_at(0)
						"off":
							enable_checkpoint.set_pressed(false)
							split_text.remove_at(0)
						_:
							enable_checkpoint.set_pressed(!enable_checkpoint.button_pressed)
			"all":
				if split_text.size() == 0:
					return false
				elif split_text[0] == "level" or split_text[0] == "levels":
					split_text.remove_at(0)
					if split_text.size() == 0:
						checkpoint_every_level.set_pressed(!checkpoint_every_level.button_pressed)
					else:
						var specifier: String = split_text[0]
						match specifier:
							"on":
								checkpoint_every_level.set_pressed(true)
								split_text.remove_at(0)
							"off":
								checkpoint_every_level.set_pressed(false)
								split_text.remove_at(0)
							_:
								checkpoint_every_level.set_pressed(!checkpoint_every_level.button_pressed)
				else:
					return false
			"main", "menu", "save":
				quit_menu()
				return true
			_:
				return false
	return true


func initiate_focus() -> void:
	max_lives_selector.get_line_edit().grab_focus()
