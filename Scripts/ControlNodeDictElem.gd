# Helper class to hold control nodes as a single element in a dictionary.
# Necessary because positions are held in a spacial hashmap, and control nodes can overlap

extends Node

var nodes = {}

func addNode(parents, n): nodes[parents] = n
func removeNode(n):
	if n in nodes.values():
		var ind = nodes.values().find(n) 
		assert(nodes.has(nodes.keys()[ind]))
		nodes.erase(nodes.keys()[ind])
	else: assert(1 == 0)

func getTopNode(): 
	if len(nodes) > 0: return nodes[nodes.keys()[-1]]
	return null
