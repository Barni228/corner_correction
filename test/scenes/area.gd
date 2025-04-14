@tool
extends Area2D

# if you change this doc, also change it in `template.gd`
## if `true`, the collision shape color will be green, otherwise it will be red
@export var should_be_reached := true:
	set(value):
		should_be_reached = value
		for child in get_children():
			_on_child_entered_tree(child)

# make all collision shapes green when added, so i know what is the area and what is 
# note that every time you load a scene, all its children will call the _on_child_entered_tree again
# so with current setup it is impossible to have custom color for collision shape
func _on_child_entered_tree(node: Node) -> void:
	if node is CollisionShape2D:
		var shape: CollisionShape2D = node

		if should_be_reached:
			shape.debug_color = Color("#0099006b")
		else:
			shape.debug_color = Color("ff00006b")