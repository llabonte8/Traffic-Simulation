extends Node

var nodes = {}

func addNode(parents, n): nodes[parents] = n
func removeNode(n):
	if n in nodes.values():
		var ind = nodes.values().find(n) 
		nodes.erase(nodes.keys()[ind])

func getTopNode(): 
	if len(nodes) > 0: return nodes[nodes.keys()[-1]]
	return null
