extends Control

enum GameStates {MENU, GAME, LEVEL_CREATOR}
@export var game_scene: PackedScene
@export var menu_scene: PackedScene
@export var level_creation_scene: PackedScene
@export var quit_confirmation: ConfirmationDialog

var menu: Node
var game: Node
var level_creator: Node
var viewport: Viewport

var game_state: GameStates

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	change_state(GameStates.MENU)
	viewport = get_viewport()
	quit_confirmation.confirmed.connect(quit_game)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if game_state == GameStates.GAME:
			game.pause_game(true)
			viewport.set_input_as_handled()
		elif game_state == GameStates.MENU:
			quit_confirmation.show()



func change_state(new_state: GameStates) -> void:
	match new_state:
		GameStates.MENU:
			if game != null:
				game.queue_free()
			if level_creator != null:
				level_creator.queue_free()
			game_state = GameStates.MENU
			menu = menu_scene.instantiate()
			add_child(menu)
			menu.start_game_pressed.connect(start_game)
			menu.quit_game_pressed.connect(quit_game)
			menu.level_creator_selected.connect(change_state.bind(GameStates.LEVEL_CREATOR))
		GameStates.GAME:
			if menu != null:
				menu.queue_free()
			game_state = GameStates.GAME
			game = game_scene.instantiate()
			add_child(game)
			game.main_menu_requested.connect(change_state.bind(GameStates.MENU))
		GameStates.LEVEL_CREATOR:
			if menu != null:
				menu.queue_free()
			game_state = GameStates.LEVEL_CREATOR
			level_creator = level_creation_scene.instantiate()
			add_child(level_creator)
			level_creator.menu_pressed.connect(change_state.bind(GameStates.MENU))
			level_creator.quit_pressed.connect(quit_game)

	return


func start_game() -> void:
	change_state(GameStates.GAME)


func quit_game() -> void:
	get_tree().quit()
