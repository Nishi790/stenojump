extends Control

enum GameStates {MENU, GAME}
@export var game_scene: PackedScene
@export var menu_scene: PackedScene
@export var quit_confirmation: ConfirmationDialog

var menu: Node
var game: Node
var viewport: Viewport

var game_state: GameStates

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	change_state("MENU")
	viewport = get_viewport()
	quit_confirmation.confirmed.connect(quit_game)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if game_state == GameStates.GAME:
			game.pause_game(true)
			viewport.set_input_as_handled()
		elif game_state == GameStates.MENU:
			quit_confirmation.show()



func change_state(new_state: String):
	new_state=new_state.to_upper()
	match new_state:
		"MENU":
			if game != null:
				game.queue_free()
			game_state = GameStates.MENU
			menu = menu_scene.instantiate()
			add_child(menu)
			menu.start_game_pressed.connect(start_game)
			menu.quit_game_pressed.connect(quit_game)
		"GAME":
			if menu != null:
				menu.queue_free()
			game_state = GameStates.GAME
			game = game_scene.instantiate()
			add_child(game)
			game.main_menu_requested.connect(change_state.bind("MENU"))

	return


func start_game():
	change_state("GAME")


func quit_game():
	get_tree().quit()
