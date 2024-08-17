extends Node2D

enum GameStates {MENU, GAME}
@export var menu_screen: Node
@export var game_screen: Node

var game_state: GameStates

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func change_state(new_state: String):
	new_state=new_state.to_upper()
	match new_state:
		"MENU":
			pass
		"Game":
			pass
	return
