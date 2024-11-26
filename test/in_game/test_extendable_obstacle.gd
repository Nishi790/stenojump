class_name TestExtendableObstacle
extends GutTest

var extendable_obstacle: ExtendableObstacle
var obstacle_data_array: Array[ObstacleSpriteData]
var max_speed: int = 50
var alt_sizes: Array = [[Vector2(60, 16), Vector2(44, 16), Vector2(76, 16)],
[Vector2(48, 16), Vector2(64, 16), Vector2(80, 16)],
[Vector2(36, 16), Vector2(48, 16), Vector2(64, 16)],
[Vector2(64, 16), Vector2(80, 16), Vector2(96, 16)],
[Vector2(32, 16), Vector2(44, 16), Vector2(60, 16)]]

func before_each() -> void:
	extendable_obstacle = partial_double(ExtendableObstacle).new()

	extendable_obstacle.chosen_texture = LongObstacleSpriteData.new()
	var collider: RectangleShape2D = RectangleShape2D.new()
	collider.size = Vector2(64, 16) * 6
	extendable_obstacle.chosen_texture.collider = collider
	extendable_obstacle.obstacle_width = extendable_obstacle.chosen_texture.collider.get_rect().size.x


	obstacle_data_array.clear()

func test_alternate_sizes(params=use_parameters(alt_sizes)) -> void:
	print("------- Testing ", params, " ----------")

	extendable_obstacle.chosen_texture.collider.size = params[0] * 6
	extendable_obstacle.obstacle_width = extendable_obstacle.chosen_texture.collider.get_rect().size.x
	var long_obstacle: LongObstacleSpriteData = extendable_obstacle.chosen_texture

	for sprite_size in params:
		var new_collider: RectangleShape2D = RectangleShape2D.new()
		new_collider.size = sprite_size * 6
		var temp_sprite_data: ObstacleSpriteData = ObstacleSpriteData.new()
		temp_sprite_data.collider = new_collider
		obstacle_data_array.append(temp_sprite_data)

	extendable_obstacle.chosen_texture.alternate_sizes = obstacle_data_array

	stub(extendable_obstacle.set_textures).to_do_nothing()

	for wpm: int in max_speed + 1:
		if wpm == 0:
			continue
		var obstacle_interval: float = 60/float(wpm)
		var number_of_word_slots: int = extendable_obstacle.check_fit(obstacle_interval)
		assert_ne(number_of_word_slots, -1, "There is a valid texture size for speed %d" % wpm)
		extendable_obstacle.chosen_texture = long_obstacle

	if is_passing():
		gut.p("-----test is passing-----")
		gut.p(params)

	extendable_obstacle.chosen_texture.alternate_sizes.assign([])
	var at_least_one_fails: bool = false

	for wpm: int in max_speed + 1:
		if wpm == 0:
			continue
		var interval: float = 60/float(wpm)
		assert_lt(interval, 61)
		var number_of_word_slots: int = extendable_obstacle.check_fit(interval)
		if number_of_word_slots == -1:
			at_least_one_fails = true
			break

	assert_true(at_least_one_fails, "given only one sprite size, at least one speed should fail")
