extends Node2D

var GRID_SPACING = 25
var DRAGGING_CTRL = false
var CONTROL_POINT_INDEX = -1
var ORIG_CTRL_POINT

onready var HIGHLIGHTED_TEX = load("res://Images/Highlighted.png")
onready var UNHIGHLIGHTED_TEX = load("res://Images/Unhighlighted.png")
onready var ControlNodes = load("res://Scripts/ControlNode.gd")

var selectedNode = null

var nodeDict = {}
var controlPointsDict = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	if DRAGGING_CTRL:
		selectedNode.curveControlPoint.position = getGridPosition(get_global_mouse_position())
		selectedNode.setHalfwayPoint(getGridPosition(get_global_mouse_position()), CONTROL_POINT_INDEX)
		update() 

func _input(event):
	if event is InputEventMouseButton && event.is_pressed() && event.button_index == BUTTON_LEFT:
		HandleLeftClick(get_global_mouse_position())
		
	if event is InputEventKey && event.scancode == KEY_ESCAPE:
		if(selectedNode): selectedNode.getNode().texture = UNHIGHLIGHTED_TEX;
		selectedNode = null

	if event is InputEventMouseButton && event.is_pressed() == false && event.button_index == BUTTON_LEFT && DRAGGING_CTRL:
		if selectedNode:
			selectedNode.setHalfwayPoint(getGridPosition(get_global_mouse_position()), CONTROL_POINT_INDEX)
			controlPointsDict[getGridPosition(get_global_mouse_position())] = [selectedNode, CONTROL_POINT_INDEX]
			controlPointsDict.erase(ORIG_CTRL_POINT)
			selectedNode = null
			update()
		DRAGGING_CTRL = false


func HandleLeftClick(position):
	var gridPosition = getGridPosition(position)

	if(!nodeDict.has(gridPosition)):
		if controlPointsDict.has(gridPosition):
			if(selectedNode): selectedNode.getNode().texture = UNHIGHLIGHTED_TEX;
			selectedNode = controlPointsDict[gridPosition][0]
			CONTROL_POINT_INDEX = controlPointsDict[gridPosition][1]
			DRAGGING_CTRL = true
			ORIG_CTRL_POINT = gridPosition

		else: spawnNewNode(gridPosition)

	else:
		switchFocusToNode(gridPosition)
		
	#CanvasItem.update, built in
	update()

func spawnNewNode(gridPosition):
	var node = Sprite.new()
	var control = ControlNodes.new()

	node.texture = HIGHLIGHTED_TEX
	node.position = gridPosition
	node.scale = Vector2(.05, .05)

	control.setNode(node)
	control.setIntersectionCreator(self)

	if selectedNode:
		selectedNode.addOutputNode(control)
		control.addInputNode(selectedNode)
		selectedNode.getNode().texture = UNHIGHLIGHTED_TEX;
		selectedNode = control;
	else: selectedNode = control

	add_child(node)
	nodeDict[gridPosition] = control
	

func switchFocusToNode(gridPosition):
	if selectedNode: 
		selectedNode.addOutputNode(nodeDict[gridPosition])
		nodeDict[gridPosition].addInputNode(selectedNode)
		selectedNode.getNode().texture = UNHIGHLIGHTED_TEX;
		
	selectedNode = nodeDict[gridPosition];
	selectedNode.getNode().texture = HIGHLIGHTED_TEX;

func getGridPosition(position):
	return Vector2(roundToNearest(position.x, GRID_SPACING), roundToNearest(position.y, GRID_SPACING));

func roundToNearest(num, roundto):
	return round(num / roundto) * roundto
	
	
func _draw():
	for n in nodeDict.values():
		if len(n.outputNodes) > 0:
			draw_polyline(n.constructCurve().get_baked_points(), Color.red, 2.0)
