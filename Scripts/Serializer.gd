extends Node

# {
#     "data": [
#         [
#             [xpos, ypox], [[out1x, out2y, mid1x, mid1y], [out2x, out2y, mid2x, mid2y], ...], numinputs
#         ]...
#     ]
# }

func serialize(ICreator, INode, filename):
    var nodes = ICreator.globalSpacialHashMap;

    var endDict = {}
    var data = []

    for node in nodes.values():
        if not node is INode: continue

        var currnodedata = []
        currnodedata.append([node.global_position.x, node.global_position.y])

        var curroutputdata = []
        for output in node.outputNodes:
            var x = output.global_position.x 
            var y = output.global_position.y 
            var mid = ICreator.getControlPosition([node, output])
            curroutputdata.append([x, y, mid.x, mid.y])
        
        currnodedata.append(curroutputdata)

        currnodedata.append(len(node.inputNodes))

        data.append(currnodedata)

    endDict["data"] = data

    var file = File.new() 
    file.open("res://IntersectionJSONs/" + filename + ".json", File.WRITE)
    file.store_string(JSON.print(endDict)) 
    file.close()