extends GutHookScript

## this file will be run before all tests
## if you set it in the `Hooks > Pre-Run Hook`
## file name is not important

## the `run` method will be executed by gut
func run() -> void:
	# make all collision shapes visible,
	# because all tests have just collision shapes without textures
	set_visible_collision_shapes(true)
	# speed EVERYTHING up by 4 times, so our tests are 4 times faster
	Engine.time_scale = 4


func set_visible_collision_shapes(visibility: bool) -> void:
	# in GutHookScript, you cannot do `get_tree` because script is not attached to a scene
	# but you can ge the main loot scene and use that
	# var tree := get_tree()
	var tree := Engine.get_main_loop() as SceneTree
	tree.debug_collisions_hint = visibility

	# Traverse tree to call queue_redraw on instances of
	# CollisionShape2D and CollisionPolygon2D.
	var node_stack: Array[Node] = [tree.get_root()]
	while not node_stack.is_empty():
		var node: Node = node_stack.pop_back()
		if is_instance_valid(node):
			if node is CollisionShape2D or node is CollisionPolygon2D:
				node.queue_redraw()
			node_stack.append_array(node.get_children())