@tool
extends BaseInteractable

@export var secondary_sprite: AnimatedSprite2D
@export var secondary_offset: Vector2 = Vector2(0, -16):
	set(new_offset):
		if not is_node_ready():
			await ready
		secondary_offset = new_offset
		secondary_sprite.set_position((secondary_offset + sprite.offset) * 6)


func set_animation_offset() -> void:
	super()
	if secondary_sprite:
		secondary_sprite.set_position((secondary_offset + sprite.offset) * 6)


func _ready() -> void:
	super()
	sprite.animation_changed.connect(set_secondary_anim)


func set_secondary_anim() -> void:
	var anim_name: StringName = sprite.animation
	secondary_sprite.play(anim_name)
