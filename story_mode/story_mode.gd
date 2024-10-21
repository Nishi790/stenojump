class_name StoryMode extends Node

@export var story_level_manager: StoryLevelManager
@export var story_level_select_screen: StoryLevelSelector
var runner: StoryRunner

@export var level_list: Dictionary #String name: packed_scene

var theory_name: String = "lapwing_"
var current_level: String
var required_speed: int = 40

func _ready() -> void:
	story_level_select_screen.story_started.connect(start_story_level)
	story_level_select_screen.runner_started.connect(start_runner_level)
	remove_child(story_level_manager)
	story_level_manager.level_complete.connect(start_next_level)

	for level: String in LevelLoader.levels:
		if level.begins_with(theory_name):
			var level_name: String = "runner_" + level.trim_prefix(theory_name).trim_suffix(".json")
			level_list[level_name] = level



func start_story_level(level_name: String) -> void:
	if level_name == "":
		open_level_select_screen()
		return
	current_level = level_name
	if not story_level_manager.is_inside_tree():
		add_child(story_level_manager)
	if story_level_select_screen.is_inside_tree():
		remove_child(story_level_select_screen)
	var story_level: LessonLevelMap = level_list[level_name].instantiate()
	story_level_manager.set_level(story_level)


func start_runner_level(level_name: String) -> void:
	current_level = level_name
	runner = StoryRunner.new(level_list[level_name], required_speed)
	runner.next_level_requested.connect(start_next_level)
	runner.main_menu_requested.connect(open_level_select_screen)
	add_child(runner)


func start_next_level() -> void:
	var next_level: String = story_level_select_screen.retrieve_next_level(current_level)
	if next_level.begins_with("runner"):
		start_runner_level(next_level)
	else:
		start_story_level(next_level)


func open_level_select_screen() -> void:
	if story_level_manager.is_inside_tree():
		remove_child(story_level_manager)
	if not story_level_select_screen.is_inside_tree():
		add_child(story_level_select_screen)
		story_level_select_screen.initiate_focus()
