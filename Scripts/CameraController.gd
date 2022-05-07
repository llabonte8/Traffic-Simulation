#Simple camera script to allow the user to pan over the scene


extends Camera2D

var MAX_ZOOM = 3
var MIN_ZOOM = .3
var ZOOM_SPEED = 0.1

var HOLDING = false

var mstartPos = Vector2()
var cStartPos = Vector2()


func _input(event):

	# Mouse input event
	if event is InputEventMouseButton and event.is_pressed():

		#Handle scrolling (zooming in or out)
		if event.button_index == BUTTON_WHEEL_UP:
			self.zoom = Vector2(clamp(self.zoom.x - ZOOM_SPEED, MIN_ZOOM, MAX_ZOOM), clamp(self.zoom.y - ZOOM_SPEED, MIN_ZOOM, MAX_ZOOM))
		elif event.button_index == BUTTON_WHEEL_DOWN:
			self.zoom = Vector2(clamp(self.zoom.x + ZOOM_SPEED, MIN_ZOOM, MAX_ZOOM), clamp(self.zoom.y + ZOOM_SPEED, MIN_ZOOM, MAX_ZOOM))

		#On middle mouse button, set initial click posisition to handle movement by dragging
		elif event.button_index == BUTTON_MIDDLE:
			mstartPos = get_local_mouse_position()
			cStartPos = position
			HOLDING = true
		
	#Handle mouse up event
	elif event is InputEventMouseButton and not event.is_pressed():
		if event.button_index == BUTTON_MIDDLE:
			HOLDING = false

	#Handle panning
	elif event is InputEventMouseMotion and HOLDING:
		position = cStartPos - (get_local_mouse_position() - mstartPos)
