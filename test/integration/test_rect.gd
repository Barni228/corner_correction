extends TestTemplate

const wait_time := 1

func before_all() -> void:
	setup(preload("res://test/scenes/test_rect.tscn"))

func test_can_corner_correct() -> void:
	watch_signals(area)
	input_sender.action_down("ui_right")
	await wait_for_signal(area.body_entered, wait_time)
	assert_signal_emitted(area, "body_entered")

func test_dont_correct_too_much() -> void:
	watch_signals(area)
	area.should_be_reached = false
	# move player one pixel down, so he should not corner correct now
	player.position += Vector2.DOWN

	input_sender.action_down("ui_right")
	await wait_for_signal(area.body_entered, wait_time)
	assert_signal_not_emitted(area, "body_entered")