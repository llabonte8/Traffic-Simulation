extends Node2D

var GRID_SPACING = 25;

onready var HIGHLIGHTED_TEX = load("res://Images/Highlighted.png")
onready var UNHIGHLIGHTED_TEX = load("res://Images/Unhighlighted.png")

var selectedNode = null

var nodeDict = {}

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _input(event):
	if event is InputEventMouseButton && event.is_pressed() && event.button_index == BUTTON_LEFT:
		Instantiate(get_global_mouse_position())


func Instantiate(position):

	var gridPosition = Vector2(roundToNearest(position.x, GRID_SPACING), roundToNearest(position.y, GRID_SPACING));

	if(!nodeDict.has(gridPosition)):
		print("creating node");
		var node = Sprite.new()
		var control = ControlNode.new()

		node.texture = HIGHLIGHTED_TEX
		node.position = gridPosition
		node.scale = Vector2(.05, .05)

		if selectedNode:
			selectedNode.texture = UNHIGHLIGHTED_TEX;
			selectedNode = node;
		else: selectedNode = node

		add_child(node)
		nodeDict[gridPosition] = node

	else:
		if selectedNode: selectedNode.texture = UNHIGHLIGHTED_TEX;
		selectedNode = nodeDict[gridPosition];
		selectedNode.texture = HIGHLIGHTED_TEX;

func roundToNearest(num, roundto):
	return round(num / roundto) * roundto


class ControlNode:
	var node;
	var connectedTo;

	func new(): pass
