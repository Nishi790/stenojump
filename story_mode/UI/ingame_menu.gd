class_name InGameMenu
extends Control

enum MenuState {THEORY, GAMEPLAY, OPTIONS, MENU}

@export var theory_button: Button
@export var gameplay_button: Button
@export var options_button: Button
@export var menu_button: Button

@export var theory_container: VBoxContainer
@export var gameplay_container: VBoxContainer
@export var options_container: VBoxContainer
var button_containers: Array[Control]

@export var theory_content: VBoxContainer
@export var menu_content: VBoxContainer
@export var gameplay_content: VBoxContainer
@export var options_content: VBoxContainer
var content_controls: Array[Control]

var current_menu_state: MenuState

func _ready() -> void:
	pass


func set_menu_state(new_state: MenuState) -> void:
	for content: Control in content_controls:
		content.hide()
	for container: Control in button_containers:
		container.hide()
