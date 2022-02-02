extends Node2D


func _input(event):

	if event is InputEventKey and event.scancode == KEY_B and event.is_pressed():
		if not get_tree().change_scene("res://Main.tscn"): print("Error switching scenes")