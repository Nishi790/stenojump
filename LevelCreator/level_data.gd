class_name LevelData
extends Resource

@export var save_path: String
@export var level_number: int
@export var level_order: LevelLoader.LevelOrder
@export var next_level_path: String

@export var targets: Array[Dictionary]

var word_key: String = "word"
var score_key: String = "score"
var hint_key: String = "hint"
