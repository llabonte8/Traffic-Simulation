# Script to handle the midpoints of lines between intersection nodes

extends Sprite


var ICreator
var Parents

func _init(parents, creator, pos, tex, scaleFactor):
	global_position = pos 
	texture = tex
	scale = Vector2(scaleFactor, scaleFactor)
	Parents = parents
	ICreator = creator
	
func select(): pass 
func deselect(): pass
func delete():
	Parents[0].removeOutputNode(Parents[1])
	Parents[0].update()

func updatePosition(pos):
	ICreator.changeControlPosition(position, pos, self, Parents)
	position = pos
	Parents[0].update()
