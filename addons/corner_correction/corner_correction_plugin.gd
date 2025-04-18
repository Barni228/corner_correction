@tool
extends EditorPlugin


func _enter_tree() -> void:
	var script = preload("uid://cfs0wwl8fi625")
	add_custom_type("CornerCharacter2D", "CharacterBody2D", script, null)


func _exit_tree() -> void:
	remove_custom_type("CornerCharacter2D")
