extends Node2D

var GRID_SPACING = 25;

onready var HIGHLIGHTED_TEX = load("res://Images/Highlighted.png")
onready var UNHIGHLIGHTED_TEX = load("res://Images/Unhighlighted.png")
onready var ControlNodes = load("res://Scripts/ControlNode.gd")

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
		
	if event is InputEventKey && event.scancode == KEY_ESCAPE:
		if(selectedNode): selectedNode.getNode().texture = UNHIGHLIGHTED_TEX;
		selectedNode = null


func Instantiate(position):
	var gridPosition = Vector2(roundToNearest(position.x, GRID_SPACING), roundToNearest(position.y, GRID_SPACING));

	if(!nodeDict.has(gridPosition)):
		var node = Sprite.new()
		var control = ControlNodes.new()

		node.texture = HIGHLIGHTED_TEX
		node.position = gridPosition
		node.scale = Vector2(.05, .05)
		
		control.setNode(node)

		if selectedNode:
			selectedNode.addOutputNode(control)
			control.addInputNode(selectedNode)
			selectedNode.getNode().texture = UNHIGHLIGHTED_TEX;
			selectedNode = control;
		else: selectedNode = control

		add_child(node)
		nodeDict[gridPosition] = control

	else:
		if selectedNode: 
			selectedNode.addOutputNode(nodeDict[gridPosition])
			nodeDict[gridPosition].addInputNode(selectedNode)
			selectedNode.getNode().texture = UNHIGHLIGHTED_TEX;
			
		selectedNode = nodeDict[gridPosition];
		selectedNode.getNode().texture = HIGHLIGHTED_TEX;
		
	#CanvasItem.update, built in
	update()
	
func roundToNearest(num, roundto):
	return round(num / roundto) * roundto
	
	
func _draw():
	for n in nodeDict.values():
		if(n.getLineCoords()):
			for l in n.getLineCoords(): draw_line(l[0], l[1], Color(255, 255, 255))
