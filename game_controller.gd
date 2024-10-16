extends Control

enum GameStates {MENU, RUNNER, LEVEL_CREATOR, ARCADE_MENU, STORY}
@export var game_scene: PackedScene
@export var menu_scene: PackedScene
@export var level_creation_scene: PackedScene
@export var arcade_scene: PackedScene
@export var story_scene: PackedScene
@export var quit_confirmation: ConfirmationDialog

var menu: Node
var runner: Node
var level_creator: Node
var arcade_menu: Node
var story: Node
var viewport: Viewport

var game_state: GameStates

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	change_state(GameStates.MENU)
	viewport = get_viewport()
	quit_confirmation.confirmed.connect(quit_game)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if game_state == GameStates.RUNNER:
			runner.pause_game(true)
			viewport.set_input_as_handled()
		elif game_state == GameStates.MENU:
			quit_confirmation.show()


func change_state(new_state: GameStates) -> void:
	match new_state:
		GameStates.MENU:
			if runner != null:
				runner.queue_free()
			if level_creator != null:
				level_creator.queue_free()
			if arcade_menu != null:
				arcade_menu.queue_free()
			game_state = GameStates.MENU
			menu = menu_scene.instantiate()
			add_child(menu)
			menu.story_started.connect(start_story)
			menu.quit_game_pressed.connect(quit_game)
			menu.level_creator_selected.connect(change_state.bind(GameStates.LEVEL_CREATOR))
			menu.arcade_mode_selected.connect(change_state.bind(GameStates.ARCADE_MENU))
		GameStates.RUNNER:
			if menu != null:
				menu.queue_free()
			if arcade_menu != null:
				arcade_menu.queue_free()
			game_state = GameStates.RUNNER
			runner = game_scene.instantiate()
			add_child(runner)

		GameStates.LEVEL_CREATOR:
			if menu != null:
				menu.queue_free()
			game_state = GameStates.LEVEL_CREATOR
			level_creator = level_creation_scene.instantiate()
			add_child(level_creator)
			level_creator.menu_pressed.connect(change_state.bind(GameStates.MENU))
			level_creator.quit_pressed.connect(quit_game)
		GameStates.ARCADE_MENU:
			if menu != null:
				menu.queue_free()
			if runner != null:
				runner.queue_free()
			game_state = GameStates.ARCADE_MENU
			arcade_menu = arcade_scene.instantiate()
			add_child(arcade_menu)
			arcade_menu.return_to_main.connect(change_state.bind(GameStates.MENU))
			arcade_menu.start_runner.connect(start_runner)

	return


func start_runner(save_data: RunnerSave, mode: RunnerGame.RunnerMode) -> void:
	change_state(GameStates.RUNNER)
	if mode != RunnerGame.RunnerMode.STORY:
		runner.main_menu_requested.connect(change_state.bind(GameStates.ARCADE_MENU))
	else:
		runner.main_menu_requested.connect(change_state.bind(GameStates.MENU))
	runner.start_level(save_data, mode)


func start_story(path: String) -> void:
	change_state(GameStates.STORY)
	if path == "":
		story.start_new_story()
	else:
		story.load(path)



func quit_game() -> void:
	get_tree().quit()
