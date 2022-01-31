extends Sprite

onready var ControlNode = load("res://Scripts/ControlNode.gd")
onready var TriangleTexture = load("res://Images/triangle.png")

var pos 
var htex
var unhtex
var scaleFactor
var ICreator

var outputNodes = []
var inputNodes = []

func _init(position, scalingFactor, creator, highlightedTexture, unhighlightedTexture):
	pos = position 
	htex = highlightedTexture 
	unhtex = unhighlightedTexture
	scaleFactor = scalingFactor
	ICreator = creator
	
	self.texture = htex
	self.position = pos 
	self.scale = Vector2(scaleFactor, scaleFactor)

	
func addOutputNode(n):
	outputNodes.append(n)
	
	var ctrlGlobalPos = ICreator.getGridPosition(Vector2((global_position.x + n.global_position.x) / 2, (global_position.y + n.global_position.y) / 2))
	var ctrlPoint = ControlNode.new([self, n], ICreator, ctrlGlobalPos, TriangleTexture, .03)
	ICreator.addControlNode(ctrlPoint, [self, n], ctrlGlobalPos)
	ICreator.add_child(ctrlPoint)
	
func addInputNode(n):
	inputNodes.append(n)
	
func deselect():
	self.texture = unhtex
func select():
	self.texture = htex
	
func getBezierPoints(p0, p1, p2, tstep):
	var points = []
	var t = 0
	
	while t <= 1:
		var x = (1 - t) * (1 - t) * p0.x + 2 * (1 - t) * t * p1.x + t * t * p2.x;
		var y = (1 - t) * (1 - t) * p0.y + 2 * (1 - t) * t * p1.y + t * t * p2.y;
		points.append((Vector2(x, y)-global_position) / scaleFactor)
		t += tstep
		
	return points
	
func delete():
	for o in outputNodes:
		if not o: continue
		o.removeInputNode(self)
		removeOutputNode(o)
	for i in inputNodes:
		if not i: continue
		i.removeOutputNode(self)
		i.update()
		
	assert(ICreator.globalSpacialHashMap.has(position))
	ICreator.globalSpacialHashMap.erase(position)
	queue_free()
		
func removeInputNode(n):
	inputNodes.erase(n)
	
func removeOutputNode(n):
	outputNodes.erase(n)
	ICreator.removeControlPoint([self, n])
	
func _draw():
	for n in outputNodes:
		var ctrlPoint = ICreator.getControlPosition([self, n])
		if ctrlPoint:
			draw_polyline(getBezierPoints(global_position, ctrlPoint, n.global_position, 0.1), Color.red)
