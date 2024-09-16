class_name QuestUIEntry
extends HBoxContainer

@export var completed_box: CheckBox
@export var quest_label: RichTextLabel


var quest_title: String
var quest_description: String

var quest_complete_text: String = "[s]%s[/s]" % quest_title
var quest_text: String = "%s[p]%s[/p]" % [quest_title, quest_description]


func set_quest_complete() -> void:
	completed_box.set_pressed_no_signal(true)
	quest_label.text = quest_complete_text

func start_quest(quest_data: BaseQuest) -> void:
	quest_title = quest_data.name
	quest_description = quest_data.description
	quest_label.text = quest_text
