extends Control

enum GameStates {MENU, GAME}
@export var game_scene: PackedScene
@export var menu_scene: PackedScene

var menu: Node
var game: Node

var game_state: GameStates

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	change_state("MENU")


# Called every frame. 'delta' is the elapsed time since the previous frame.
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
		"GAME":
			if menu != null:
				menu.queue_free()
			game_state = GameStates.GAME
			game = game_scene.instantiate()
			add_child(game)

	return


func start_game():
	change_state("GAME")
