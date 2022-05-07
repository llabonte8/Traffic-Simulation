extends Node

# Structure of serialized data
# {
#     "data": [
#         [
#             [xpos, ypox], [[out1x, out2y, mid1x, mid1y], [out2x, out2y, mid2x, mid2y], ...], numinputs
#         ]...
#     ]
# }

var SimIntersectionNode = load('res://Scripts/SimIntersectionNode.gd')


func serialize(ICreator, INode, filename):
	var nodes = ICreator.globalSpacialHashMap;

	var endDict = {}
	var data = []

	# Loop through values in the spacial hash map
	for node in nodes.values():
		# Skip node if it isn't an intersection
		if not node is INode: continue


		# Get necessary data for node
		var currnodedata = []
		currnodedata.append([node.global_position.x, node.global_position.y])

		var curroutputdata = []
		for output in node.outputNodes:
			var x = output.global_position.x 
			var y = output.global_position.y 
			var mid = ICreator.getControlPosition([node, output])
			if not mid:
				print("Error serializing.")
				return

			curroutputdata.append([x, y, mid.x, mid.y])
		
		currnodedata.append(curroutputdata)

		currnodedata.append(len(node.inputNodes))

		data.append(currnodedata)

	endDict["data"] = data

	var file = File.new() 
	file.open("res://IntersectionJSONs/" + filename + ".json", File.WRITE)
	file.store_string(JSON.print(endDict)) 
	file.close()


func deserialize(filename):
	var file = File.new()
	file.open(filename, File.READ)
	var content = file.get_as_text()
	file.close()

	content = JSON.parse(content)

	if not content:
		print("Error reading JSON!")
		return 

	content = content.result

	var nodeMap = {}
	
	#Populate dict
	for entry in content['data']:
		var nPos = Vector2(int(entry[0][0]), int(entry[0][1]))
		var newNode = SimIntersectionNode.new(nPos)
		nodeMap[nPos] = newNode

	#Add data to nodes in populated dict
	for entry in content['data']:
		var nPos = Vector2(int(entry[0][0]), int(entry[0][1]))

		for outNodeData in entry[1]:
			var outnpos = Vector2(outNodeData[0], outNodeData[1])
			var midpos = Vector2(outNodeData[2], outNodeData[3])
			nodeMap[nPos].addOutputNode(nodeMap[outnpos], midpos)

		if len(entry[1]) == 0: nodeMap[nPos].setAsSystemOutput(true)
		if entry[2] == 0: nodeMap[nPos].setAsSystemInput(true)

	return nodeMap

