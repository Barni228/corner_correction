class_name CornerCharacter2D extends CharacterBody2D

## Corner Corrected character body 2D


## this contains a KinematicCollision2D, bool of whether it corner corrected or no, and new player position
class CornerCorrectionResult:
	var corrected: bool
	var collision: KinematicCollision2D
	var new_pos: Vector2

	func _init(p_corrected: bool, p_collision: KinematicCollision2D, p_new_pos: Vector2) -> void:
		corrected = p_corrected
		collision = p_collision
		new_pos = p_new_pos

# because this is a class, it is nullable
## This is nullable vector2, use `.value` to get the `Vector2`
class Vector2OrNull:
	var value: Vector2

	func _init(vec: Vector2) -> void:
		value = vec

## Maximum normal angle at which we will still corner correct.
## So if it is `0.1` and we hit something with normal `(0.1, 0.9)`,
## we will still corner correct
const norm_angle_max := 0.1

## If player ignores bottom, and moves 80px down and 20px right (fall)
## and he hits corner of something to hit right (platform), should he:
## - hit it and just fall down, because he was moving mostly down (false)
## - corner correct and keep moving right, because he ignores bottom (true)
## The default value is `true`
var ignore_is_special := true

## How much we can corner correct, in pixels.
## If it is 8, player can only move 8 pixels at maximum to corner correct.
## Bigger values result in move noticeable corner correction, and 0 results in no corner correction at all
@export var corner_correction_amount: int = 8

## Sides that will not have any corner correction.
## For platformer games, you might want to ignore bottom (ignore_sides = [SIDE_BOTTOM])
## so player does not fall down when he lands on an edge of a platform
@export var ignore_sides: Array[Side] = []

## This method behaves almost the same as `move_and_slide` but with corner correction
## It will use `velocity` to calculate movement
func move_and_slide_corner(delta: float) -> void:
	# if we can corner correct, do it
	var corner_correct_result := move_and_correct(velocity * delta, true)
	if corner_correct_result.corrected:
		global_position = corner_correct_result.new_pos

	# otherwise use move and slide
	else:
		move_and_slide()


## This method works almost exactly the same as `move_and_collide`
## It modifies `global_position`, and uses `move_and_collide`
## - motion: Characters motion, for frame independence multiply by `delta`
## - test_only: If `true`, dont actually move the player
## returns `CornerCorrectionResult` with:
## - corrected: `true` if this function corner corrected
## - collision: collision that could not be corner corrected (if corrected is true this is null)
## - new_pos: if `test_only` is true, this is APPROXIMATELY where the player would be if it was false
func move_and_correct(motion: Vector2, test_only := false) -> CornerCorrectionResult:
	var from := global_transform

	var collision := move_and_collide(motion, test_only)

	if collision == null:
		return CornerCorrectionResult.new(false, null, from.origin)

	from.origin += collision.get_travel()

	var normal := collision.get_normal()

	# if we hit something diagonally, dont corner correct
	if is_diagonal(normal):
		return CornerCorrectionResult.new(false, collision, from.origin)

	# the direction of the collision
	var direction := normal.round() * -1
	# we are sure that direction is either (±1, 0) or (0, ±1)
	assert(direction.length_squared() == 1)

	# direction that player was going, integer only
	var logical_motion := normalize_sum_1(motion).round()

	for ignore: Side in ignore_sides:
		var ignore_vec: Vector2 = side_to_vec(ignore)

		if ignore_vec == direction:
			return CornerCorrectionResult.new(false, collision, from.origin)

		# this is the only place where we use `ignore_is_special`
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
		return CornerCorrectionResult.new(false, collision, from.origin)

	# logical motion is (±1, 0) or (0, ±1)
	assert(logical_motion.length_squared() == 1)

	#region actually corner correcting
	var corrected_pos := _wiggle(from, corner_correction_amount, normal)

	if corrected_pos == null:
		return CornerCorrectionResult.new(false, collision, from.origin)

	from.origin = corrected_pos.value

	if !test_only:
		global_position = corrected_pos.value
		# if you uncomment this line, when test_only is true return values are different
		# but the player will move the remaining movement instead of skipping it
		# I UNCOMMENTED IT, SO BE AWARE
		move_and_correct(collision.get_remainder())
		# ^^^ THIS IS THE LINE ^^^

	return CornerCorrectionResult.new(
		true,
		null,
		from.origin,
	)

## This method works almost exactly the same as `move_and_collide`.
## See `move_and_correct` (this method just uses that but only returns the collision)
## It modifies `global_position`, and uses `move_and_collide`
## - motion: Characters motion, for frame independence multiply by `delta`
## - test_only: If true, don't actually move the player
## returns collision object
func move_and_collide_corner(motion: Vector2, test_only := false) -> KinematicCollision2D:
	return move_and_correct(motion, test_only).collision


## This method will pretend moving back and forth the player by no more than `range`.
## It has no side effects
## - from: the player global transform
## - range: maximum movement that could be performed
## - normal: normal of the collision (`KinematicCollision2D.get_normal()`)
## returns `Vector2OrNull` of player position, or `null` if it was not found
func _wiggle(from: Transform2D, range: int, norm: Vector2) -> Vector2OrNull:
	# Axis on which we will be moving
	var v := norm.rotated(deg_to_rad(90))

	for i: int in range + 1:
		for move: Vector2 in [v * i, v * -i]:
			if check_if_works(from, move, -norm):
				return Vector2OrNull.new(global_position + move)
	
	return null

## Checks if the `init_motion` results in player being able
## to move with `check_motion` without any collisions
## This method has no side effects (does not modify anything)
## - from: the player global transform
## - init_motion: The initial motion to perform
## - check_motion: The motion that player should be able to do from the `init_motion`
## 
## returns `true` if player can do `check_movement` without collision after applying the `init_movement`
## or `false` if player collides when trying to do `check_movement` after `init_movement`
func check_if_works(from: Transform2D, init_motion: Vector2, check_motion: Vector2) -> bool:
	# if we cannot move to the initial position, then this does not work
	if test_move(from, init_motion):
		return false

	# move to the initial position
	# origin is basically Position
	from.origin += init_motion

	# return whether there was no collision
	return not test_move(from, check_motion)

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
