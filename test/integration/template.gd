class_name TestTemplate extends GutTest

## A test parent that will give you `level`, `player`, `area`, and 'input_sender` variables when 
## you call `setup` function, with scene that should inherit from `template.tscn`

var _level_scene: PackedScene
var level: Node2D
var player: Player
var area: Area2D
var input_sender := GutInputSender.new(Input)

#region template helper functions

## expects scene, which should inherits from `test_scene`
func setup(level_scene: PackedScene) -> void:
	_level_scene = level_scene

# if you change this doc, also change it in `area.gd`
## if `true`, the collision shape color will be green, otherwise it will be red
func area_should_be_reached(b: bool) -> void:
	area.should_be_reached = b

## A constant motion that player should have
## both x and y will get multiplied by player speed
func move_player(x: float, y: float) -> void:
	player.constant_movement = Vector2(x, y)

#endregion

#region special GutTest functions

func before_each() -> void:
	if _level_scene == null:
		push_error("you forgot to provide a scene, do it with `setup`, " + \
		"example: ```before_each(): setup(preload(...))```")

	level = add_child_autofree(_level_scene.instantiate())
	player = level.get_node("Player")
	area = level.get_node("Area2D")

func after_each() -> void:
	input_sender.release_all()
	input_sender.clear()
#endregion