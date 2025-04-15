extends TestTemplate

const wait_time := 0.8

func before_all() -> void:
	setup(preload("res://test/scenes/test_snap_platform.tscn"))

func before_each() -> void:
	# call the parents before each
	super.before_each()
	player.ignore_sides = [SIDE_BOTTOM]


func test_snap_platform() -> void:
	watch_signals(area)

	move_player(0.6, 0.4)
	await wait_for_signal(area.body_entered, wait_time)
	assert_signal_emitted(area, "body_entered")

func test_no_snap_platform() -> void:
	watch_signals(area)
	player.ignore_is_special = false
	area_should_be_reached(false)

	move_player(0.4, 0.6)
	await wait_for_signal(area.body_entered, wait_time)
	assert_signal_not_emitted(area, "body_entered")

func test_ignore_is_special() -> void:
	watch_signals(area)
	player.ignore_is_special = true
	move_player(0.4, 0.6)
	await wait_for_signal(area.body_entered, wait_time)
	assert_signal_emitted(area, "body_entered")
