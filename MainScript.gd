extends Node2D

var dragging = false
var selected = []
var drag_start_pos = Vector2.ZERO
var select_rectangle = RectangleShape2D.new()
var villagerPackedScene
var housePackedScene
var moving_to = "any"

# entered on startup I dont know why
var villagers_in_pond = -1
var villagers_in_trees = -1

var house_num = 0

func _ready():
	randomize()
	
	villagerPackedScene = preload("res://Villager.tscn")
	housePackedScene = preload("res://House.tscn")

func _on_TreesStaticBody2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		# I don't know why this works
		if event.pressed:
			for unit in selected:
				if(unit.collider is KinematicBody2D):
					var move_to = $WoodCuttingPath/PathFollow2D
					move_to.offset = randi()
					unit.collider.move_to(move_to.position)


func _on_PondStaticBody_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.pressed:
			for unit in selected:
				if(unit.collider is KinematicBody2D):
					var move_to = $PondPath/PathFollow2D
					move_to.offset = randi()
					unit.collider.move_to(move_to.position)

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.pressed:
			# todo only add to selected if its a villager
			for unit in selected:
				if(unit.collider is KinematicBody2D):
					unit.collider.move_to(event.position)
			
			dragging = true
			for unit in selected:
				if(unit.collider is KinematicBody2D):
					unit.collider.deselect()
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
				# todo fix so you can't select enemies
				if(unit.collider is KinematicBody2D):
					unit.collider.select()
	if event is InputEventMouseMotion:
		if dragging:
			$DrawSelectNode2D.draw(drag_start_pos, event.position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$HUD.set_food_increase(villagers_in_pond * 3)
	$HUD.set_wood_increase(villagers_in_trees * 3)


func _on_PondArea_body_entered(body):
	villagers_in_pond += 1

func _on_PondArea_body_exited(body):
	villagers_in_pond -= 1

func _on_WoodArea_body_entered(body):
	villagers_in_trees += 1

func _on_WoodArea_body_exited(body):
	villagers_in_trees -= 1


func _on_VillagerArrive_timeout():
	if randi() % 3 == 0 and $HUD.is_room_for_villager():
		var villager = villagerPackedScene.instance()
		villager.position = $VillagerSpawn.position
		$YSort.add_child(villager)
		villager.move_to(Vector2(590, 315))
		$HUD.add_villager(1)


func _on_HUD_build_house():
	house_num += 1
	if (house_num <= 5):
		var house = housePackedScene.instance()
		get_node("YSort/HouseSpawn" + str(house_num)).add_child(house)
