# Script to handle file dialogue when user loads a file

extends ItemList

onready var Serializer = load('res://Scripts/Serializer.gd')

var parent = null

func _ready():
	connect("item_activated", self, "_on_item_activated")


func _init(par):
	loadFiles("res://IntersectionJSONs/")
	grow_horizontal = Control.GROW_DIRECTION_BOTH
	grow_vertical = Control.GROW_DIRECTION_BOTH
	rect_min_size = Vector2(250, 300)
	set_anchors_and_margins_preset(8)
	set_anchor_and_margin(0, 0.5, 0)
	parent = par


func loadFiles(filepath):
	var dir = Directory.new()
	dir.open(filepath)
	dir.list_dir_begin()
	
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with('.'):
			add_item(file.replace('.json', ""))
	dir.list_dir_end()

func _on_item_activated(index):
	var s = Serializer.new()
	parent.loadNodeMap(s.deserialize("res://IntersectionJSONs/" + get_item_text(index) + '.json'))
	queue_free()
