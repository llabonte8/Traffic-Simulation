extends Node2D

var GRID_SPACING = 25
var MOUSE_HOLD = false

onready var HIGHLIGHTED_TEX = load("res://Images/Highlighted.png")
onready var UNHIGHLIGHTED_TEX = load("res://Images/Unhighlighted.png")
onready var IntersectionNode = load("res://Scripts/IntersectionNode.gd")
onready var ControlNodeDictElem = load('res://Scripts/ControlNodeDictElem.gd')
onready var ControlNode = load('res://Scripts/ControlNode.gd')

#  {Vector2(x, y), class}
var globalSpacialHashMap = {}
var selectedNode = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:	
			handleMouseClick(getGridPosition(get_global_mouse_position()))
			MOUSE_HOLD = true
		elif event.button_index == BUTTON_LEFT and !event.pressed:
			MOUSE_HOLD = false
			
	elif event is InputEventMouseMotion:
		if MOUSE_HOLD:
			if selectedNode and selectedNode is ControlNode:
				if not globalSpacialHashMap.has(getGridPosition(get_global_mouse_position())):
					selectedNode.updatePosition(getGridPosition(get_global_mouse_position()))
					
	elif event is InputEventKey and event.scancode == KEY_ESCAPE:
		if selectedNode: selectedNode.deselect()
		selectedNode = null
		
	elif event is InputEventKey and event.scancode == KEY_BACKSPACE:
		if selectedNode:
			selectedNode.delete()
			selectedNode = null
	
func handleMouseClick(position):
	#There is nothing at our click position, spawn a new node
	if not globalSpacialHashMap.has(position):
		spawnIntersectionNode(position)
	elif globalSpacialHashMap[position] is IntersectionNode:
		if selectedNode and selectedNode is IntersectionNode:
			selectedNode.deselect()
			selectedNode.addOutputNode(globalSpacialHashMap[position])
			globalSpacialHashMap[position].addInputNode(selectedNode)
			
		selectedNode = globalSpacialHashMap[position]
		selectedNode.select()
		selectedNode.update()
	elif globalSpacialHashMap[position] is ControlNodeDictElem:
		if selectedNode: selectedNode.deselect()
		selectedNode = globalSpacialHashMap[position].getTopNode()
	

func spawnIntersectionNode(position):
	var newnode = IntersectionNode.new(position, 0.05, self, HIGHLIGHTED_TEX, UNHIGHLIGHTED_TEX)
	add_child(newnode)
	globalSpacialHashMap[position] = newnode 
	
	if selectedNode and selectedNode is IntersectionNode: 
		selectedNode.addOutputNode(newnode)
		newnode.addInputNode(selectedNode)
		selectedNode.deselect()
	selectedNode = newnode

func getGridPosition(position):
	return Vector2(roundToNearest(position.x, GRID_SPACING), roundToNearest(position.y, GRID_SPACING));
func roundToNearest(num, roundto):
	return round(num / roundto) * roundto
	
		
func addControlNode(node, parents, position):
	if globalSpacialHashMap.has(position):
		if globalSpacialHashMap[position] is ControlNodeDictElem:
			globalSpacialHashMap[position].addNode(parents, node)
	else:
		var tmpElm = ControlNodeDictElem.new()
		tmpElm.addNode(parents, node)
		globalSpacialHashMap[position] = tmpElm
		
func getControlPosition(parents):
	for elem in globalSpacialHashMap.values():
		if elem is ControlNodeDictElem:
			if elem.nodes.has(parents):
				return elem.nodes[parents].global_position
	return null
	
func removeControlPoint(parents):
	for elem in globalSpacialHashMap.values():
		if elem is ControlNodeDictElem:
			if elem.nodes.has(parents):
				var obj = elem.nodes[parents]
				elem.removeNode(obj)
				obj.queue_free()
				
				if len(elem.nodes) == 0: 
					var ind = globalSpacialHashMap.values().find(elem)
					globalSpacialHashMap.erase(globalSpacialHashMap.keys()[ind])
				return
	
func changeControlPosition(pos, newpos, node, parents):
	if globalSpacialHashMap.has(pos) and globalSpacialHashMap[pos] is ControlNodeDictElem:
		globalSpacialHashMap[pos].removeNode(node) 
		if(len(globalSpacialHashMap[pos].nodes) == 0): globalSpacialHashMap.erase(pos)
		addControlNode(node, parents, newpos)
