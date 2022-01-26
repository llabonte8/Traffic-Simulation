extends Node2D


var inputNodes = []
var outputNodes = []
var node
var pos

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func addInputNode(n):
	inputNodes.append(n)
	
func addOutputNode(n):
	outputNodes.append(n)

func setNode(n):
	node = n
	pos = n.position
func getNode():
	return node
	
func getLineCoords():
	if len(outputNodes) > 0:
		var outputs = []
		for n in outputNodes: outputs.append([pos, n.pos])
		return outputs
	return null
