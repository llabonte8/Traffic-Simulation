# Similar to the IntersectionNode script. However, the way nodes are handled in simulation mode is slightly different, and the easiest way to handle that is just with a new script.

extends Sprite

onready var TEX = load("res://Images/Highlighted.png")
onready var TriangleTex = load("res://Images/triangle.png")

#[[node, vector2 midpos], [node, vector2 midpos], ...]
var outputNodesAndMidpoints = []

var SystemInputNode = false
var SystemOutputNode = false

var SCALE_FAC = 0.05


func _init(coords):
	position = coords
	self.position = coords

func _ready():
    self.scale = Vector2(SCALE_FAC, SCALE_FAC)
    self.texture = TEX;
    self.updateColor(0)

func updateColor(t):
    self.modulate = lerp(Color.green, Color.red, t)


func addOutputNode(node, midpoint):
	outputNodesAndMidpoints.append([node, midpoint])


func setAsSystemOutput(b):
	SystemOutputNode = b


func setAsSystemInput(b):
	SystemInputNode = b

func getBezierPoints(p0, p1, p2, tstep):
    var points = PoolVector2Array()
    var t = 0
    
    while t <= 1:
        var x = (1 - t) * (1 - t) * p0.x + 2 * (1 - t) * t * p1.x + t * t * p2.x;
        var y = (1 - t) * (1 - t) * p0.y + 2 * (1 - t) * t * p1.y + t * t * p2.y;
        points.append((Vector2(x, y)-global_position) / SCALE_FAC)
        t += tstep
        
    return points


func _draw():
    for n in outputNodesAndMidpoints:
        var point = n[1]
        var node = n[0]

        var line = Line2D.new()
        line.points = getBezierPoints(position, point, node.position, 0.1)
        line.texture = TriangleTex
        line.width = 180 
        line.texture_mode = Line2D.LINE_TEXTURE_TILE
        add_child(line)
