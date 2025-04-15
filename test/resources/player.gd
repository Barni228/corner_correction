class_name Player extends CornerCharacter2D

## Player speed, pixels per second
var speed := 200

var constant_movement := Vector2.ZERO

func _physics_process(delta: float) -> void:
	velocity = Input.get_vector(&"ui_left", &"ui_right", &"ui_up", &"ui_down")
	velocity += constant_movement
	velocity *= speed
	move_and_slide_corner(delta)