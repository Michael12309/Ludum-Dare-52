extends KinematicBody2D


var selected


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func select():
	selected = true
	$SelectedSprite.show()

func deselect():
	selected = false
	$SelectedSprite.hide()
