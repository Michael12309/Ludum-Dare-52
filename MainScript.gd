extends Node2D

var dragging = false
var selected = []
var drag_start_pos = Vector2.ZERO
var select_rectangle = RectangleShape2D.new()

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.pressed:
			dragging = true
			for unit in selected:
				unit.collider.deselect()
			selected = []
			drag_start_pos = event.position
		elif dragging:
			dragging = false
			$DrawSelectNode2D.clear()
			select_rectangle.extents = (event.position - drag_start_pos) / 2
			var space = get_world_2d().direct_space_state
			var query = Physics2DShapeQueryParameters.new()
			query.set_shape(select_rectangle)
			query.transform = Transform2D(0, (event.position + drag_start_pos) / 2)
			selected = space.intersect_shape(query)
			for unit in selected:
				unit.collider.select()
	if event is InputEventMouseMotion:
		if dragging:
			$DrawSelectNode2D.draw(drag_start_pos, event.position)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
