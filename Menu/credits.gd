extends Control

signal main_menu_pressed

@export var credit_container: VBoxContainer
@export var development_credits: Array[String]
@export var font_credit: Array[String]
@export var credit_list: Array[String]
@export var sound_credit_list: Array[String]
@export var menu_button: Button

@export var dev_header: RichTextLabel
@export var font_header: RichTextLabel
@export var art_header: RichTextLabel
@export var audio_header: RichTextLabel

@export var godot_credit_scene: PackedScene


func _ready() -> void:
	var last_section_node: Node = dev_header
	for credit: String in development_credits:
		var list_entry: Label = Label.new()
		list_entry.text = credit
		list_entry.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		last_section_node.add_sibling(list_entry)
		last_section_node = list_entry

	last_section_node = font_header
	for credit: String in font_credit:
		var list_entry: Label = Label.new()
		list_entry.text = credit
		list_entry.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		last_section_node.add_sibling(list_entry)
		last_section_node = list_entry

	last_section_node = art_header
	for entry: String in credit_list:
		var list_entry: Label = Label.new()
		list_entry.text = entry
		list_entry.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		last_section_node.add_sibling(list_entry)
		last_section_node = list_entry

	last_section_node = audio_header
	for entry: String in sound_credit_list:
		var list_entry: Label = Label.new()
		list_entry.text = entry
		list_entry.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		last_section_node.add_sibling(list_entry)
		last_section_node = list_entry

	credit_container.add_child(HSeparator.new())
	var godot_credits: Control = godot_credit_scene.instantiate()
	credit_container.add_child(godot_credits)

	menu_button.pressed.connect(return_to_menu)
	menu_button.grab_focus()



func return_to_menu() -> void:
	main_menu_pressed.emit()
	queue_free()
