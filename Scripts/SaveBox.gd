extends LineEdit

var parent

func _init(par):
	parent = par

func _ready():
	connect("text_entered", self, "_on_text_submitted")

func _process(_delta):
	editable = true

func _on_text_submitted(text):
	parent.save(text)
	parent.SAVING = false 
	queue_free()

func _input(event):
	if event is InputEventKey and event.scancode == KEY_ESCAPE:
		parent.SAVING = false 
		queue_free()
