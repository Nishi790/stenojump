class_name  RunnerLevel extends Resource

@export var level_path: String
@export var level_number: int
@export var level_targets: Array
@export var level_order: LevelLoader.LevelOrder
@export var default_level_size: int
@export var next_level_path: String
@export var checkpoint: bool

@export var level_description: String
@export var environment: Resource #TODO provide info to define the correct environment for the specific level
