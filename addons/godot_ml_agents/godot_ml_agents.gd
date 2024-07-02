@tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("AgentsManager", "Node", preload ("res://addons/godot_ml_agents/manager.gd"), preload ("res://icon.svg"))

func _exit_tree():
	remove_custom_type("AgentsManager")
