extends Node2D

@export var runner_level: PackedScene



@export var house_jump_obstacle_textures: Array[Texture]
@export var house_crawl_obstacle_textures: Array[Texture]
@export var house_long_obstacles: PackedScene
@export var house_parallax_layers: Dictionary

var runner: RunnerGame


func _init(level_theme: RunnerGame.RunnerThemes = RunnerGame.RunnerThemes.HOUSE_CLEAN, speed_required: int = 20) -> void:
	runner = runner_level.instantiate()
	match level_theme:
		RunnerGame.RunnerThemes.HOUSE_CLEAN:
			runner.obstacle_manager.theme_jump_texture = house_jump_obstacle_textures
			runner.obstacle_manager.theme_crawl_texture = house_crawl_obstacle_textures
			runner.obstacle_manager.theme_long_texture = house_long_obstacles
# address set up of background
		RunnerGame.RunnerThemes.HOUSE_MESSY:
			pass
		RunnerGame.RunnerThemes.STREET_DIRTY:
			pass
		RunnerGame.RunnerThemes.PARK:
			pass
		RunnerGame.RunnerThemes.STREET_SUBURB:
			pass

	runner.target_speed = speed_required
	runner.current_speed = speed_required - 10
	runner.speed_step = 5

	add_child(runner)


func _ready() -> void:
	pass
