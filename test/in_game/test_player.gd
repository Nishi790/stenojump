extends GutTest

var player_double: Player

func before_each() -> void:
	player_double = partial_double(Player).new()
	player_double.physics_body = double(PlayerPhysics).new()


func test_die_state_changes() -> void:
	player_double.movement_state = Player.State.DIE
	for key: String in Player.State:
		var state: Player.State = Player.State[key]
		player_double.change_states(state, -1)
		if state == Player.State.IDLING:
			assert_eq(player_double.movement_state, Player.State.IDLING, "Player should be idling and is %s" % state)
		else:
			assert_eq(player_double.movement_state, \
			Player.State.DIE, "Only idle should be reached from death, reached %s" % \
			player_double.movement_state)
		player_double.movement_state = Player.State.DIE


func test_auto_jump_init() -> void:
	PlayerConfig.autojump = true
	stub(player_double.check_jump_range).to_return(true)
	player_double.avoid_obstacle(Obstacle.ObstacleType.JUMP, true)
	assert_true(player_double.jump_queued, "Player Jump should be queued")

	player_double.jump_queued = false
	player_double.avoid_obstacle(Obstacle.ObstacleType.CRAWL, true)
	assert_false(player_double.jump_queued, "No jump should be queued for crawl obstacle")
	player_double.movement_state = Player.State.RUNNING

	player_double.jump_queued = false
	stub(player_double.check_jump_range).to_return(false)
	stub(player_double.jump).to_do_nothing()
	player_double.avoid_obstacle(Obstacle.ObstacleType.JUMP, true)
	assert_false(player_double.jump_queued, "Jump not queued when out of range")
	assert_called(player_double, "jump")


func test_transition_to_crawl(params = use_parameters([true, false])) -> void:
	gut.p("----testing crawl transitions with autojump set to %s----" % params)
	PlayerConfig.autojump = params
	for key: String in Player.State:
		if key == "DIE":
			continue
		player_double.movement_state = Player.State[key]
		player_double.crawl_queued = false
		player_double.avoid_obstacle(Obstacle.ObstacleType.CRAWL, true)
		if [Player.State.STARTING_JUMP, Player.State.SOARING, Player.State.ENDING_JUMP].has(player_double.movement_state):
			assert_eq(player_double.movement_state, Player.State[key], "Cannot transition to crawl from jump")
			assert_true(player_double.crawl_queued, "Crawl should be queued from jump")
		else:
			assert_false(player_double.crawl_queued, "Crawl should not be queued from %s" % key)
			assert_eq(player_double.movement_state, Player.State.CRAWLING, "Should transition to crawl from %s" % key)


func test_use_queued_crawl() -> void:
	gut.p("--Testing transition to crawl when queued--")
	stub(player_double.play_sfx).to_do_nothing()
	player_double.crawl_queued = true
	player_double.movement_state = Player.State.ENDING_JUMP
	player_double.change_states(Player.State.RUNNING, -1)
	assert_eq(player_double.movement_state, Player.State.CRAWLING, "Player should be crawling")


func test_use_crawl_move_queue(params = use_parameters([[Obstacle.ObstacleType.JUMP], [Obstacle.ObstacleType.CRAWL, Obstacle.ObstacleType.JUMP],
[Obstacle.ObstacleType.CRAWL, Obstacle.ObstacleType.CRAWL, Obstacle.ObstacleType.JUMP]])) -> void:
	stub(player_double.check_jump_range).to_return(false)
	for value in params:
		player_double.move_queue.append(value)
	player_double.movement_state = Player.State.CRAWLING
	for index in player_double.move_queue.size():
		player_double.stand_up()
	player_double.stand_up()

	assert_eq(player_double.movement_state, Player.State.RUNNING, "Should transition to running")
	var total_jumps_expected: int = params.count(Obstacle.ObstacleType.JUMP)
	var total_crawl_expected: int = params.count(Obstacle.ObstacleType.CRAWL)
	var num_obst = params.size()
	assert_call_count(player_double, "jump", total_jumps_expected)
	assert_call_count(player_double, "crawl", total_crawl_expected)
	assert_call_count(player_double, "avoid_obstacle", num_obst)


func after_all() -> void:
	pass
