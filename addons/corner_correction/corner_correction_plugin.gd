@tool
extends EditorPlugin


func _enter_tree() -> void:
	var script := preload("corner_correction.gd")
	add_custom_type("CornerCorrection", "Node", script, null)


func _exit_tree() -> void:
	remove_custom_type("CornerCorrection")
