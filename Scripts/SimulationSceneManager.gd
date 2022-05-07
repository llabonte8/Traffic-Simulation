# Scene manager for simulation mode

extends Node2D

onready var FileList = load('res://Scripts/fileViewer.gd')
onready var CarSprite = load('res://Images/car.png')

var CurrentNodeMap = {}
var Sim = null

var speed = 10
var cpt = 0.2

func _input(event):

	if event is InputEventKey and event.is_pressed():
		# Handle scene switching
		if event.scancode == KEY_B:
			if not get_tree().change_scene("res://Builder.tscn"): print("Error switching scenes")
		#Handle loading intersections
		elif event.scancode == KEY_L:
			var s = get_node("Simulation")
			if s.RUNNING: s.Stop();
			for elem in CurrentNodeMap:
				CurrentNodeMap[elem].queue_free()

			var filelist = FileList.new(self)
			get_node("CanvasLayer").add_child(filelist)

		elif event.scancode == KEY_P:
			var sim = get_node('Simulation')

			if sim.RUNNING == false:
				sim.Initialize(self, CarSprite)
				
				for elem in CurrentNodeMap:
					sim.AddNode(CurrentNodeMap[elem].position, CurrentNodeMap[elem].SystemInputNode, CurrentNodeMap[elem].SystemOutputNode)

				for elem in CurrentNodeMap:
					for c in CurrentNodeMap[elem].outputNodesAndMidpoints:
						sim.AddConnections(CurrentNodeMap[elem].position, c[0].position, c[1])
				
				sim.SetTPS(speed)
				sim.Start();

			else: 
				sim.Stop();

		elif event.scancode == KEY_PERIOD:
			cpt = min(1, cpt + 0.05)
			if(get_node('Simulation').RUNNING):
				get_node("Simulation").SetCPT(cpt)

		elif event.scancode == KEY_COMMA:
			cpt = max(0, cpt - 0.05)
			if(get_node('Simulation').RUNNING):
				get_node("Simulation").SetCPT(cpt)

		elif event.scancode == KEY_EQUAL:
			speed = min(60, speed + 5)
			if(get_node('Simulation').RUNNING):
				get_node("Simulation").SetTPS(speed)

		elif event.scancode == KEY_MINUS:
			speed = max(0, speed - 5)
			if(get_node('Simulation').RUNNING):
				get_node("Simulation").SetTPS(speed)

		elif event.scancode == KEY_S:
			if(get_node('Simulation').RUNNING):		
				get_node('Simulation').Switch()

			

#Helper function to set the CurrentNodeMap to a new intersection map, and instantiate new intersection nodes
func loadNodeMap(map):
	CurrentNodeMap = map
	for elem in map:
		add_child(map[elem])


func updateNodeColor(pos, t):
	for elem in CurrentNodeMap:
		if elem == pos:
			CurrentNodeMap[elem].updateColor(t)
			return;
