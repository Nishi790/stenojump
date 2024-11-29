class_name ExtendableObstacle
extends CrawlObstacle

var number_of_word_slots: int = 2
var obstacle_width: int
var obstacle_space_per_word: int
var total_number_of_targets: int

var target_data_array: Array[Dictionary] = []
var stand_up_rays: Array[RayCast2D] = []

@export var sprite_size_variants: Array[ObstacleSpriteData]


func _ready() -> void:
	super()
	obstacle_width = chosen_texture.collider.get_rect().size.x


func _physics_process(delta: float) -> void:
	super(delta)
	for ray: RayCast2D in stand_up_rays:
		if ray.is_colliding():
			var collider: PhysicsBody2D = ray.get_collider()
			if collider is PlayerPhysics:
				collider.stand_up()
				stand_up_rays.erase(ray)
				ray.queue_free()


func parse_targets(upcoming_word: Array[Dictionary]) -> void:
	var words_per_label: int = ceili(float(upcoming_word.size())/float(number_of_word_slots))
	total_number_of_targets = upcoming_word.size()

	for index in number_of_word_slots:
		var label_words: Array[Dictionary] = upcoming_word.slice(index * words_per_label, (index + 1) * words_per_label)
		var target_words: PackedStringArray = []
		var point_value: int = 0
		var hints: PackedStringArray = []
		for word in label_words:
			@warning_ignore("unsafe_call_argument")
			target_words.append(word["word"])
			point_value += word["score"]
			@warning_ignore("unsafe_call_argument")
			hints.append(word["hint"])
		var separator: String = " "
		var final_target: String = separator.join(target_words)
		var final_hint: String = separator.join(hints)
		var number_of_targets_for_label: int = target_words.size()
		var target_is_not_empty: bool = not final_target.is_empty()

		var label_panel: PanelContainer

		if index > 0 and target_is_not_empty:
			label_panel = target_container.duplicate()
			add_child(label_panel)

			var stand_up_ray: RayCast2D = RayCast2D.new()
			stand_up_rays.append(stand_up_ray)
			add_child(stand_up_ray)
			stand_up_ray.position = Vector2(index * obstacle_space_per_word, label_panel.position.y)
			stand_up_ray.collision_mask = 1
			stand_up_ray.target_position = Vector2(0, 200)
			stand_up_ray.z_index = 5

			label_panel.position.x = stand_up_ray.position.x - (label_panel.size.x/2)


		else: label_panel = target_container

		if target_is_not_empty:
			label_panel.get_child(0).set_text(final_target)
			var target_data: Dictionary = {"word": final_target, "hint": final_hint, "score": point_value, "number_of_targets": number_of_targets_for_label}
			target_data_array.push_back(target_data)

	update_targets()


func update_targets() -> void:
	var target_data: Dictionary = target_data_array.pop_front()
	target_word = target_data["word"]
	score = target_data["score"]
	hint = target_data["hint"]
	number_of_targets = target_data["number_of_targets"]


func check_fit(obstacle_space: float) -> int:
	if chosen_texture is LongObstacleSpriteData:
		sprite_size_variants = chosen_texture.alternate_sizes

	obstacle_space_per_word = obstacle_space
	var width_ratio: float = float(obstacle_width)/float(obstacle_space_per_word)
	number_of_word_slots = ceili(width_ratio)
	var space_consumed: int = number_of_word_slots * obstacle_space_per_word
	var jump_space: int = space_consumed - obstacle_width

	if jump_space < 150:
		number_of_word_slots += 1

		var min_pixels_to_add: int = jump_space + 10
		var max_pixels_to_add: int = jump_space + obstacle_space_per_word - 150

		var min_obstacle_width: int = obstacle_width + min_pixels_to_add
		var max_obstacle_width: int = obstacle_width + max_pixels_to_add

		var alt_sprite_index: int = -1

		for index: int in sprite_size_variants.size():
			var alt_data: ObstacleSpriteData = sprite_size_variants[index]
			var width: int = alt_data.collider.get_rect().size.x
			if width > min_obstacle_width and width < max_obstacle_width:
				alt_sprite_index = index
				break
		if alt_sprite_index == -1:
			for index: int in sprite_size_variants.size():
				var alt_data: ObstacleSpriteData = sprite_size_variants[index]
				var width: int = alt_data.collider.get_rect().size.x

				var test_width_ratio: float = float(width)/float(obstacle_space_per_word)
				var test_number_of_word_slots: int = ceili(test_width_ratio)
				var test_space_consumed: int = test_number_of_word_slots * obstacle_space_per_word
				var test_jump_space: int = test_space_consumed - width
				if test_jump_space > 150:
					number_of_word_slots = test_number_of_word_slots
					alt_sprite_index = index

		if alt_sprite_index == -1:
			printerr("No valid texture available for word interval %f pixels." % obstacle_space_per_word)
			return -1

		chosen_texture = sprite_size_variants[alt_sprite_index]
		set_textures()

	return number_of_word_slots


func get_total_score() -> int:

	var total_score: int = score
	for word_data: Dictionary in target_data_array:
		total_score += word_data["score"]

	return total_score


func get_total_number_of_targets() -> int:
	return total_number_of_targets
