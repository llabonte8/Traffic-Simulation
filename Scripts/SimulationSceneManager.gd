extends Node2D

func _ready():
	connect("item_activated", self, "_on_item_activated")

onready var list : ItemList = get_node("CanvasLayer/ItemList") 

func _input(event):

	if event is InputEventKey and event.is_pressed():
		if event.scancode == KEY_B:
			if not get_tree().change_scene("res://Main.tscn"): print("Error switching scenes")
		elif event.scancode == KEY_L:
			list.clear()
			loadFiles(list, "res://IntersectionJSONs/")
			
func _on_item_activated(index):
	print(list.get_item_at_position(index))

func loadFiles(itemlist, filepath):
	var dir = Directory.new()
	dir.open(filepath)
	dir.list_dir_begin()
	
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with('.'):
			itemlist.add_item(file.replace('.json', ""))
	dir.list_dir_end()
