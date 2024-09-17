class_name StoryLevelData
extends Resource

signal quest_started(quest_data:BaseQuest)
signal quest_finished(name: String)
signal dialog_started(dialog_key: String, dialogue: DialogueResource)

@export var level_words: Array[Dictionary]
@export var dialogue_resource: DialogueResource

@export var level_events: Dictionary ##EventName: EventInfo

##Dictionary in format Name(String): BaseQuest
@export var quests: Dictionary

var active_quests: Dictionary ##EventName: EventInfo
var completed_quests: Array[String] ##Event names

var cur_index: int = 0


func get_next_word() -> Dictionary:
	if cur_index == level_words.size():
		level_words.shuffle()
		cur_index = 0
	var result_dict: Dictionary = level_words[cur_index]
	cur_index += 1
	return result_dict


func start_level() -> void:
	dialog_started.emit("intro", dialogue_resource)


##Called when an in level event occurs to update data
func update_event(event_name: String, value: bool) -> void:
	if level_events.has(event_name):
		var can_complete: bool = level_events[event_name].check_event_can_complete(level_events)
		if can_complete:
			level_events[event_name].event_complete = value
	for key: String in active_quests.keys():
		var quest_complete: bool = check_quest_complete(key)


func update_action_event(event_name: String, action_type: SelfNavCharacter.GeneralActions) -> void:
	if level_events.has(event_name):
		if level_events[event_name].action_type == action_type:
			update_event(event_name, true)


##Call on events with toggle subtype te flip value
func update_toggle_event(event_name: String) -> void:
	if level_events.has(event_name):
		var can_complete: bool = level_events[event_name].check_event_can_complete(level_events)
		if can_complete:
			level_events[event_name].event_complete = !level_events[event_name].event_complete
	for key: String in active_quests.keys():
		var quest_complete: bool = check_quest_complete(key)


##Checks whether doing an event has completed any quests
func check_quest_complete(quest_id: String) -> bool:
	var quest_data: BaseQuest = active_quests[quest_id]
	var quest_complete: bool = quest_data.check_complete(level_events)

	#Transfer quest to complete if finished
	if quest_complete:
		completed_quests.append(quest_id)
		active_quests.erase(quest_id)
		if quest_data.finished_dialog_key != "":
			dialog_started.emit(quest_data.finished_dialog_key, dialogue_resource)
		quest_finished.emit(quest_data.name)

	return quest_complete


func start_quest(quest_id: String) -> void:
	if quests.has(quest_id):
		var quest_data: BaseQuest = quests[quest_id]
		active_quests[quest_id] = quest_data
		quest_started.emit(quest_data)
		if quest_data.start_dialog_key != "":
			dialog_started.emit(quest_data.start_dialog_key, dialogue_resource)
		check_quest_complete(quest_id)
