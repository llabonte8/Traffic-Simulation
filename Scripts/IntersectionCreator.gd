# Script to allow the user to create intersections


extends Node2D

var GRID_SPACING = 25
var MOUSE_HOLD = false
var SAVING = false


#Required textures and scripts
onready var HIGHLIGHTED_TEX = load("res://Images/Highlighted.png")
onready var UNHIGHLIGHTED_TEX = load("res://Images/Unhighlighted.png")
onready var IntersectionNode = load("res://Scripts/IntersectionNode.gd")
onready var ControlNodeDictElem = load('res://Scripts/ControlNodeDictElem.gd')
onready var ControlNode = load('res://Scripts/ControlNode.gd')
onready var Serializer = load('res://Scripts/Serializer.gd')
onready var SaveBox = load('res://Scripts/SaveBox.gd')

# Lines to help user line up nodes
var LinesToDraw = []
var IntersectionNodePlaceholder = Sprite.new()

#  {Vector2(x, y), class}
var globalSpacialHashMap = {}
var selectedNode = null

# Called when the node enters the scene tree for the first time.
func _ready():
	IntersectionNodePlaceholder.texture = HIGHLIGHTED_TEX
	IntersectionNodePlaceholder.scale = Vector2(0.03, 0.03)
	add_child(IntersectionNodePlaceholder)

func _process(_delta):
	var pos = getGridPosition(get_global_mouse_position())
	
	IntersectionNodePlaceholder.position = pos;

	LinesToDraw.clear()

	for n in globalSpacialHashMap.values():
		if n is IntersectionNode:
			# If the node is an intersection node, and it has the same x or y value as the current grid space, draw a line along that axis
			if n.global_position.x == pos.x:
				LinesToDraw.append([Vector2(pos.x, -10000), Vector2(pos.x, 10000)])
			if n.global_position.y == pos.y:
				LinesToDraw.append([Vector2(-10000, pos.y), Vector2(10000, pos.y)])
	update()
	
func _draw():
	for line in LinesToDraw:
		draw_line(line[0], line[1], Color.green, 1, true)


func _input(event):

	# Mouse button event
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:	
			handleMouseClick(getGridPosition(get_global_mouse_position()))
			MOUSE_HOLD = true
		elif event.button_index == BUTTON_LEFT and !event.pressed:
			MOUSE_HOLD = false
			
	# Mouse motion
	elif event is InputEventMouseMotion:
		if MOUSE_HOLD:
			# If the selected node is a control node and the node is allowed to move to the current mouse position, move it
			if selectedNode and selectedNode is ControlNode:
				if (globalSpacialHashMap.has(getGridPosition(get_global_mouse_position())) and globalSpacialHashMap[getGridPosition(get_global_mouse_position())] is ControlNodeDictElem)\
					or not globalSpacialHashMap.has(getGridPosition(get_global_mouse_position())):
					selectedNode.updatePosition(getGridPosition(get_global_mouse_position()))
					
	# Deselect current node on escape
	elif event is InputEventKey and event.scancode == KEY_ESCAPE:
		if selectedNode: selectedNode.deselect()
		selectedNode = null
		
	# Delete node on backspace
	elif event is InputEventKey and event.scancode == KEY_BACKSPACE:
		if selectedNode:
			selectedNode.delete()
			selectedNode = null

	# Save intersection on s key
	elif event is InputEventKey and event.scancode == KEY_S and event.is_pressed() and not SAVING:
		#lineEdit is a UI element that accepts a line of text
		var lineedit = SaveBox.new(self)
		#Set lineedit properties
		lineedit.max_length = 256;
		lineedit.placeholder_text = "File Name..."
		lineedit.rect_min_size = Vector2(200, 30)
		lineedit.add_font_override("font", load('res://Images/mainfont.tres'))
		lineedit.rect_position = Vector2(get_viewport_rect().size.x / 2 - (lineedit.rect_min_size.x / 2), 10)
		get_node("../CanvasLayer").add_child(lineedit)
		lineedit.editable = false
		lineedit.caret_blink = true;
		#Grab focus and set saving
		lineedit.grab_focus()
		SAVING = true

	# Switch to simulation mode on B
	elif event is InputEventKey and event.scancode == KEY_B and event.is_pressed() and not SAVING:
		get_tree().change_scene("res://Simulation.tscn")

func save(filename):
	var s = Serializer.new()
	s.serialize(self, IntersectionNode, filename)
	
func handleMouseClick(position):
	#There is nothing at our click position, spawn a new node
	if SAVING: return
	if not globalSpacialHashMap.has(position):
		spawnIntersectionNode(position)

	#Else if there is a node at the click position, add that node as an output to the currently selected node
	elif globalSpacialHashMap[position] is IntersectionNode:
		if selectedNode and selectedNode is IntersectionNode:
			selectedNode.deselect()
			selectedNode.addOutputNode(globalSpacialHashMap[position])
			globalSpacialHashMap[position].addInputNode(selectedNode)
			
		selectedNode = globalSpacialHashMap[position]
		selectedNode.select()

	# Else if there is a control node at the click position, allow user to move that node
	elif globalSpacialHashMap[position] is ControlNodeDictElem:
		if selectedNode: selectedNode.deselect()
		selectedNode = globalSpacialHashMap[position].getTopNode()
	


# Helper function to spawn an intersection node and select it
func spawnIntersectionNode(position):
	var newnode = IntersectionNode.new(position, 0.05, self, HIGHLIGHTED_TEX, UNHIGHLIGHTED_TEX)
	add_child(newnode)
	globalSpacialHashMap[position] = newnode 
	
	if selectedNode and selectedNode is IntersectionNode: 
		selectedNode.addOutputNode(newnode)
		newnode.addInputNode(selectedNode)
		selectedNode.deselect()
	selectedNode = newnode

# Helper functions to convert to grid space. Self explanatory.
func getGridPosition(position):
	return Vector2(roundToNearest(position.x, GRID_SPACING), roundToNearest(position.y, GRID_SPACING));
func roundToNearest(num, roundto):
	return round(num / roundto) * roundto
	

# Helper function to spawn a control node, select it, and set its parents
func addControlNode(node, parents, position):
	if globalSpacialHashMap.has(position):
		if globalSpacialHashMap[position] is ControlNodeDictElem:
			globalSpacialHashMap[position].addNode(parents, node)
	else:
		var tmpElm = ControlNodeDictElem.new()
		tmpElm.addNode(parents, node)
		globalSpacialHashMap[position] = tmpElm
	
# Helper function to get the global position of a control node given a list containg its two parents. Useful due to the way the hashmap is structured.
func getControlPosition(parents):
	for elem in globalSpacialHashMap.values():
		if elem is ControlNodeDictElem:
			if elem.nodes.has(parents):
				return elem.nodes[parents].global_position
	return null
	

# Helper function to allow deletion of control points, updating the parent input/output lists
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
	
# Helper function to allow changing the position of a control node, updating parents
func changeControlPosition(pos, newpos, node, parents):
	if globalSpacialHashMap.has(pos) and globalSpacialHashMap[pos] is ControlNodeDictElem:
		globalSpacialHashMap[pos].removeNode(node) 
		if(len(globalSpacialHashMap[pos].nodes) == 0): globalSpacialHashMap.erase(pos)
		addControlNode(node, parents, newpos)
