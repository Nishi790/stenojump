class_name StoryEvent
extends Resource

@export var name: String
@export var event_complete: bool = false
##Conditions should be name of event as key, bool as value
@export var conditions: Dictionary


func check_event_can_complete(event_dict: Dictionary) -> bool:
	var reqs_met: bool = true
	for req: String in conditions:
		if event_dict[req].event_complete == conditions[req]:
			continue
		else:
			reqs_met = false
			break
	return reqs_met
