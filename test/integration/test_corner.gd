extends TestTemplate

const wait_time := 1

func before_all() -> void:
	setup(preload("res://test/scenes/test_corner.tscn"))

func test_corner_collision_works() -> void:
	watch_signals(area)

	# we can also press keys instead of actions
	input_sender.key_down(KEY_UP)
	input_sender.key_down(KEY_RIGHT)
	await wait_for_signal(area.body_entered, wait_time)

	assert_signal_emitted(area, "body_entered")

func test_corner_with_ignore() -> void:
	watch_signals(area)

	# if we ignore collisions at the bottom, it shouldn't matter
	player.corner_correction.ignore_sides = [SIDE_BOTTOM]
	input_sender.key_down(KEY_UP)
	input_sender.key_down(KEY_RIGHT)
	await wait_for_signal(area.body_entered, wait_time)

	assert_signal_emitted(area, "body_entered")
