class_name BaseQuest
extends Resource

enum QuestTypes {ALL, SOME}

@export var name: String
@export var description: String
@export var quest_type: QuestTypes
@export var req_total: int = 0 ##Number of requirements to meet, 0 for quest_type ALL

##Event name: Value
@export var reqs: Dictionary
@export var start_dialog_key: String = ""
@export var finished_dialog_key: String = ""

@export var events_triggered: Dictionary #Event Name as key, value is Array of values to pass


func check_complete(event_dict: Dictionary) -> bool:
	match quest_type:
		QuestTypes.ALL:
			var reqs_met: bool = true
			for req: String in reqs:
				if event_dict[req].event_complete == reqs[req]:
					continue
				else:
					reqs_met = false
					break
			return reqs_met
		QuestTypes.SOME:
			var reqs_met: int = 0
			for req: String in reqs:
				if event_dict[req].event_complete == reqs[req]:
					reqs_met += 1
				if reqs_met == req_total:
					return true
			return false
		_:
			return false
