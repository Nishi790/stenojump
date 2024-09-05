class_name CrawlObstacle
extends Obstacle

@export var crawl_area: Area2D
@export var front_sprite: Sprite2D

func _ready() -> void:
	super()
	crawl_area.body_exited.connect(_on_crawl_exited)



func set_textures() -> void:
	super()
	front_sprite.texture = chosen_texture.front_texture
	front_sprite.scale = chosen_texture.req_scale
	front_sprite.position = chosen_texture.req_offset


func _on_crawl_exited(body: Node2D) -> void:
	if body is PlayerPhysics:
		body.stand_up()
