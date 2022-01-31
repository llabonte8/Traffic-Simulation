extends Node2D

var inputNodes = []
var outputNodes = []
var node
var pos
var halfwayPoints = []

var IntersectionCreatorNode;
var curveControlPoint = null;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func addInputNode(n):
	inputNodes.append(n)
	
func addOutputNode(n):
	outputNodes.append(n)

	halfwayPoints.append(Vector2((pos.x + outputNodes[0].pos.x) / 2, (pos.y + outputNodes[0].pos.y) / 2))
	halfwayPoints[-1] = IntersectionCreatorNode.getGridPosition(halfwayPoints[-1])

func setHalfwayPoint(p, index):
	halfwayPoints[index] = p;

func setNode(n):
	node = n
	pos = n.position
func getNode():
	return node
func setIntersectionCreator(n):
	IntersectionCreatorNode = n;

func constructCurve():
	var curve = Curve2D.new()
	var points = getBezierPointsFromVecs(pos, halfwayPoints[-1], outputNodes[0].pos, .1)

	#No way to just set the curve array to 'points', so we have to loop through
	for p in points:
		curve.add_point(p)

	if(!curveControlPoint):
		curveControlPoint = Sprite.new()
		curveControlPoint.texture = IntersectionCreatorNode.HIGHLIGHTED_TEX
		curveControlPoint.position = halfwayPoints[-1] 
		curveControlPoint.scale = Vector2(.03, .03)
		IntersectionCreatorNode.add_child(curveControlPoint)
		IntersectionCreatorNode.controlPointsDict[halfwayPoints[-1]] = [self, len(halfwayPoints) - 1]

	return curve

func getBezierPointsFromVecs(a, b, c, smooth):
	#Generate points on curve (see https://stackoverflow.com/questions/5634460/quadratic-b%C3%A9zier-curve-calculate-points)
	var bezier = []

	var i = 0
	while i <= 1:
		var x1 = (1 - i) * (1 - i) * a.x + 2 * (1 - i) * i * b.x + i * i * c.x
		var y1 = (1 - i) * (1 - i) * a.y + 2 * (1 - i) * i * b.y + i * i * c.y

		bezier.append(Vector2(x1, y1))

		i += smooth
	return bezier
	
func getLineCoords():
	if len(outputNodes) > 0:
		var outputs = []
		for n in outputNodes: outputs.append([pos, n.pos])
		return outputs
	return null
