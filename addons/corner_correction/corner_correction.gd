class_name CornerCorrection extends Node

## maximum normal angle at which we will still corner correct
## so if it is `0.1` and we hit something with normal `(0.1, 0.9)`,
## we will still corner correct
const norm_angle_max := 0.1

## if player ignores bottom, and moves 80px down and 20px right (fall)
## and he hits corner of something to hit right (platform), should he:
## - hit it and just fall down, because he was moving mostly down (false)
## - corner correct and keep moving right, because he ignores bottom (true)
## by default or if there was no ignoring he would just hit it and fall down (false)
var ignore_is_special = false

## The character to move
@export var character: CharacterBody2D

## how much we can corner correct, in pixels
## if it is 8, player can only move 8 pixels at maximum to corner correct
## bigger values result in move noticeable corner correction, and 0 results in no corner correction at all
@export var corner_correction_amount: int = 8

## Sides that will not have any corner correction
## For platformer games, you might want to ignore bottom (IgnoreSides = [Vector2.Down])
## so player does not fall down when he lands on an edge of a platform
@export var ignore_sides: Array[Side] = []

## This method behaves almost the same as `MoveAndSlide` but with corner correction
## It will use `Velocity` to calculate movement
func move_and_slide_corner(delta: float) -> void:
	# move regularly
	var collision = move_and_collide_corner(character.velocity * delta)

	if collision == null:
		return
	
	# Get the velocity that we still need to move, with delta applied
	character.velocity = collision.get_remainder()

	# for some reason move and slide does not work properly if i move character position

	# velocity /= delta
	# character.move_and_slide()

	# you need the loop in case of slopes
	const max_slides = 4
	var slide_count = 0
	while (character.velocity.length_squared() > 0.001 and slide_count < max_slides):
		var _collision = character.move_and_collide(character.velocity)
		if _collision == null:
			break

		# Slide along the collision normal
		var normal = _collision.get_normal()
		character.velocity = character.velocity.slide(normal)
		slide_count += 1

## This method works almost exactly the same as `move_and_collide`
## It modifies `position`, and uses `move_and_collide`
## - motion: Characters motion, for frame independence use `delta`
## - test_only: If true, don't actually move the player
func move_and_collide_corner(motion: Vector2, test_only := false) -> KinematicCollision2D:
	var collision = character.move_and_collide(motion, test_only)

	#region checking if we should corner correct
	if collision == null:
		return null

	var normal = collision.get_normal()

	# if we hit something diagonally, dont corner correct
	if is_diagonal(normal):
		return collision

	# the direction of the collision
	var direction = normal.round() * -1
	# we are sure that direction is either (±1, 0) or (0, ±1)
	assert(direction.length_squared() == 1)

	# direction that player was going, integer only
	var logical_motion = normalize_sum_1(motion).round()

	for ignore: Side in ignore_sides:
		var ignore_vec: Vector2 = side_to_vec(ignore)

		if ignore_vec == direction:
			return collision

		# this is the only place where we use `IgnoreIsSpecial`
		if ignore_is_special:
			# basically, if we ignore our current logical movement, but we also were moving slightly diagonally
			# then we say the other way we were moving will be the main way we were moving
			# technically, we dont need to do the checks with 0, because if we lie about logical movement
			# then next check (comparing it to direction of collision) will result in `return collision;`
			# but why would I make the code intentionally lie to me
			if logical_motion.y == ignore_vec.y:
				logical_motion = Vector2.ZERO
				if motion.x != 0:
					logical_motion = Vector2.RIGHT if motion.x > 0 else Vector2.LEFT

			if logical_motion.x == ignore_vec.x:
				logical_motion = Vector2.ZERO
				if motion.y != 0:
					logical_motion = Vector2.DOWN if motion.y > 0 else Vector2.UP


	# if we hit something, but we were not going that direction, dont corner correct
	# so if we were moving top, and very slightly left, we only want corner correct to the top
	if direction != logical_motion:
		return collision

	# logical motion is (±1, 0) or (0, ±1)
	assert(logical_motion.length_squared() == 1)

	#endregion

	#region actually corner correcting
	var successful_correction = _wiggle(corner_correction_amount, normal, test_only)

	if not successful_correction:
		return collision

	return move_and_collide_corner(collision.get_remainder(), test_only);
	#endregion

## This method will move back and forth the player by no more that `range`
## - range: maximum movement that could be performed
## - normal: normal of the collision (`KinematicCollision2D.GetNormal()`)
## - test_only: if `true`, do not actually move the player
## returns `true` if the player could be moved to a valid position
func _wiggle(range: int, norm: Vector2, test_only := false) -> bool:
	# Axis on which we will be moving
	var v = norm.rotated(deg_to_rad(90))

	for i in range + 1:
		for move: Vector2 in [v * i, v * -i]:
			if check_if_works(move, -norm):
				if not test_only:
					character.position += move
				return true
	
	return false

## Checks if the `init_motion` results in player being able
## to move with `checkMovement` without any collisions
## This method has no side effects (does not modify anything)
## - init_motion: The initial motion to perform
## check_motion - The motion that player should be able to do from the `init_motion`
## 
## returns `true` if player can do `check_movement` without collision after applying the `init_movement`
## or `false` if player collides when trying to do `check_movement` after `init_movement`
func check_if_works(init_motion: Vector2, check_motion: Vector2) -> bool:
	var transform = character.global_transform
	# if we cannot move to the initial position, then this does not work
	if character.test_move(transform, init_motion):
		return false

	# move to the initial position
	# origin is basically Position
	transform.origin += init_motion

	# return whether there was no collision
	return not character.test_move(transform, check_motion)

## convert `Side` to `Vector2`, so `SIDE_TOP` is `Vector2.UP`
func side_to_vec(side: Side) -> Vector2:
	match side:
		SIDE_TOP:
			return Vector2.UP
		SIDE_RIGHT:
			return Vector2.RIGHT
		SIDE_BOTTOM:
			return Vector2.DOWN
		SIDE_LEFT:
			return Vector2.LEFT

	push_error("Invalid `side` (%s)" % side)
	return Vector2.ZERO

func is_diagonal(vec: Vector2) -> bool:
	return min(abs(vec.x), abs(vec.y)) > norm_angle_max

## Will normalize Vector so that its sum (x + y) will always will be 1,
## If the vector is Vector2.ZERO, then it will return Vector2.ZERO
func normalize_sum_1(vec: Vector2) -> Vector2:
	if vec.is_zero_approx():
		return Vector2.ZERO
	
	var sum: float = abs(vec.x) + abs(vec.y)
	return vec / sum
