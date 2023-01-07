extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var start_pos = Vector2.ZERO
var end_pos = Vector2.ZERO
var should_draw = false

var color = Color("#ffecd6")

func _draw():
	if should_draw:
		draw_rect(Rect2(start_pos, end_pos - start_pos), color, false)

func draw(start, end):
	should_draw = true
	start_pos = start
	end_pos = end
	update()

func clear():
	should_draw = false
	update()
