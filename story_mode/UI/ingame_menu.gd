class_name InGameMenu
extends Control

enum MenuState {THEORY, GAMEPLAY, OPTIONS, MENU}

signal resume_game_pressed
signal quit_game_pressed

@export var theory_button: Button
@export var gameplay_button: Button
@export var options_button: Button
@export var menu_button: Button

@export var theory_container: PanelContainer
@export var gameplay_container: PanelContainer
@export var options_container: PanelContainer
var button_containers: Array[Control]

@export var theory_content: VBoxContainer
@export var menu_content: VBoxContainer
@export var gameplay_content: VBoxContainer
@export var options_content: VBoxContainer

@export var resume_button: BaseButton
@export var quit_button: BaseButton

@export_group("Content Files")
@export var steno_lesson_dict: Dictionary
@export var gameplay_tip_dict: Dictionary

var content_controls: Array[Control]

var current_menu_state: MenuState

func _ready() -> void:
	content_controls = [theory_content, gameplay_content, menu_content, options_content]
	button_containers = [theory_container, gameplay_container, options_container]

	theory_button.pressed.connect(set_menu_state.bind(MenuState.THEORY))
	gameplay_button.pressed.connect(set_menu_state.bind(MenuState.GAMEPLAY))
	menu_button.pressed.connect(set_menu_state.bind(MenuState.MENU))
	options_button.pressed.connect(set_menu_state.bind(MenuState.OPTIONS))

	theory_container.button_selected.connect(display_theory_lesson)
	theory_container.pass_focus.connect(pass_focus.bind(gameplay_container))
	gameplay_container.button_selected.connect(display_gameplay_tip)
	gameplay_container.pass_focus.connect(pass_focus.bind(options_container))
	options_container.button_selected.connect(display_options_page)
	options_container.pass_focus.connect(pass_focus.bind(theory_button))

	resume_button.pressed.connect(resume_game)
	quit_button.pressed.connect(quit_story)

	open(MenuState.MENU, 0)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		resume_game()
		get_viewport().set_input_as_handled()


func set_menu_state(new_state: MenuState) -> void:
	for content: Control in content_controls:
		content.hide()
	for container: Control in button_containers:
		container.hide()

	match new_state:
		MenuState.THEORY:
			theory_container.display_content()
			theory_content.show()
		MenuState.GAMEPLAY:
			gameplay_container.display_content()
			gameplay_content.show()
		MenuState.OPTIONS:
			options_container.display_content()
			options_content.show()
		MenuState.MENU:
			menu_content.show()
			resume_button.grab_focus()


func display_theory_lesson(index: int) -> void:
	if steno_lesson_dict.has(index):
		var theory_lesson_dict: Dictionary = theory_content.parse_lesson_text(steno_lesson_dict[index])
		theory_content.display_lesson(theory_lesson_dict)
	else:
		print_debug("Invalid lesson index - there's no lesson with the ID %d" % index)
		theory_container.reset_selection()


func display_gameplay_tip(index: int) -> void:
	if gameplay_tip_dict.has(index):
		var tip_dict = gameplay_content.parse_tip_text(gameplay_tip_dict[index])
		gameplay_content.display_tip(tip_dict)
	else:
		print_debug("Invalid tip index - there is no tip with the ID %d" % index)
		gameplay_container.reset_selection()


func display_options_page(index: int) -> void:
	options_content.show_options(index)


func open(open_type: MenuState, page_index: int = 0) -> void:
	show()
	print("Menu visibility is %s" % visible)
	match open_type:
		MenuState.MENU:
			set_menu_state(MenuState.MENU)
		MenuState.THEORY:
			set_menu_state(MenuState.THEORY)
			theory_container.select_button(page_index)
		MenuState.GAMEPLAY:
			set_menu_state(MenuState.GAMEPLAY)
			gameplay_container.select_button(page_index)
		MenuState.OPTIONS:
			set_menu_state(MenuState.OPTIONS)


func pass_focus(new_focus: Control) -> void:
	new_focus.grab_focus()
	print("Current Focus is %" % get_viewport().gui_get_focus_owner())


func resume_game() -> void:
	hide()
	resume_game_pressed.emit()


func quit_story() -> void:
	quit_game_pressed.emit()
