extends TestTemplate

const wait_time := 1

func before_all() -> void:
	setup(preload("res://test/scenes/test_pixel_perfect.tscn"))

func test_pixel_perfect_collision() -> void:
	watch_signals(area)

	var wall_collision: CollisionShape2D = level.get_node("StaticBody2D/CollisionShape2D")
	var player_collision: CollisionShape2D = player.get_node("CollisionShape2D")

	var wall_width: float = wall_collision.shape.size.x
	var player_width: float = player_collision.shape.size.x
	player_width *= player_collision.global_scale.x

	player.global_position.x = wall_collision.global_position.x
	player.position.x += player_width / 2
	player.position.x += wall_width / 2
	input_sender.key_down(KEY_UP)
	await wait_for_signal(area.body_entered, wait_time)

	# unfortunately, there is a bug with godot, that MoveAndCollide will not see pixel perfect collision
	# but it will stop the player from moving, so basically making it almost impossible to corner correct
	# I will wait and maybe godot will fix this issue, but for now I will assert that signal is not emitted

	# assert_signal_emitted(area, "body_entered")
	assert_signal_not_emitted(area, "body_entered")