class_name QuestPanel
extends PanelContainer


@export var quest_item_scene: PackedScene
@export var quest_list: VBoxContainer

var quest_entries: Array[QuestUIEntry]

func add_quest_entry(quest_data: BaseQuest) -> void:
	var new_quest: QuestUIEntry = quest_item_scene.instantiate()
	quest_entries.append(new_quest)
	new_quest.start_quest(quest_data)


func finish_quest(quest_title: String) -> void:
	for entry: QuestUIEntry in quest_entries:
		if entry.quest_title == quest_title:
			entry.set_quest_complete()
			break
