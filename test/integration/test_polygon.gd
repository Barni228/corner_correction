extends TestTemplate

const scene = preload("res://test/scenes/test_polygon.tscn")
const wait_time := 1

func before_all() -> void:
	setup(scene)

# NOTE: the polygon has scale of (1, -1)
func test_polygon_corrects() -> void:
	watch_signals(area)
	input_sender.action_down("ui_right")
	await wait_for_signal(area.body_entered, wait_time)
	assert_signal_emitted(area, "body_entered")

func test_polygon_dont_correct_too_much() -> void:
	watch_signals(area)
	area.should_be_reached = false
	player.position += Vector2.DOWN

	input_sender.action_down("ui_right")
	await wait_for_signal(area.body_entered, wait_time)
	assert_signal_not_emitted(area, "body_entered")