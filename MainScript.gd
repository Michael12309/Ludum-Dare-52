extends Node2D

var dragging = false
var selected = []
var drag_start_pos = Vector2.ZERO
var select_rectangle = RectangleShape2D.new()
var moving_to = "any"

var villagerPackedScene
var housePackedScene
var enemyPackedScene

var villagers_in_pond = 0
var villagers_in_trees = 0

var enemy_spawn_chance = 26

var house_num = 0

var hours_lived = 1

func _ready():
	randomize()
	
	villagerPackedScene = preload("res://Villager.tscn")
	housePackedScene = preload("res://House.tscn")
	enemyPackedScene = preload("res://Enemy.tscn")

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT:
		if event.pressed:
			if selected.size() > 0:
				$ClickAnimation.frame = 0
				$ClickAnimation.play()
				$ClickAnimation.position = event.position
			for unit in selected:
				if(unit.collider.name.begins_with("Villager") or unit.collider.name.begins_with("@Villager")):
					unit.collider.move_to(event.position)
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.pressed:
			for unit in selected:
				if(unit.collider.name.begins_with("Villager") or unit.collider.name.begins_with("@Villager")):
					unit.collider.deselect()
			dragging = true
			drag_start_pos = event.position
		elif dragging:
			dragging = false
			$DrawSelectNode2D.clear()
			select_rectangle.extents = (event.position - drag_start_pos) / 2
			var space = get_world_2d().direct_space_state
			var query = Physics2DShapeQueryParameters.new()
			query.set_shape(select_rectangle)
			query.transform = Transform2D(0, (event.position + drag_start_pos) / 2)
			var selected_bodies = space.intersect_shape(query)
			selected = []
			for unit in selected_bodies:
				if(unit.collider.name.begins_with("Villager") or unit.collider.name.begins_with("@Villager")):
					unit.collider.select()
					selected.append(unit)
					
	if event is InputEventMouseMotion:
		if dragging:
			$DrawSelectNode2D.draw(drag_start_pos, event.position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$HUD.set_food_increase(villagers_in_pond * 3)
	$HUD.set_wood_increase(villagers_in_trees * 3)


func _on_PondArea_body_entered(body):
	if(body.name.begins_with("Villager") or body.name.begins_with("@Villager")):
		villagers_in_pond += 1
		body.set_icon("fishing")

func _on_PondArea_body_exited(body):
	if(body.name.begins_with("Villager") or body.name.begins_with("@Villager")):
		villagers_in_pond -= 1
		body.set_icon("none")

func _on_WoodArea_body_entered(body):
	if(body.name.begins_with("Villager") or body.name.begins_with("@Villager")):
		villagers_in_trees += 1
		body.set_icon("cutting")

func _on_WoodArea_body_exited(body):
	if(body.name.begins_with("Villager") or body.name.begins_with("@Villager")):
		villagers_in_trees -= 1
		body.set_icon("none")

func _on_VillagerArrive_timeout():
	if randi() % 2 == 0 and $HUD.is_room_for_villager():
		var villager = villagerPackedScene.instance()
		villager.position = $VillagerSpawn.position
		$YSort.add_child(villager)
		villager.move_to(Vector2(590, 315))
		$HUD.add_villager(1)

func _on_HUD_build_house():
	house_num += 1
	if (house_num <= 4):
		var house = housePackedScene.instance()
		get_node("YSort/HouseSpawn" + str(house_num)).add_child(house)

func spawn_enemy():
	var enemy = enemyPackedScene.instance()
	var loc = get_node("EnemySpawn" + str((randi() % 4) + 1)).position
	enemy.position = loc
	$YSort.add_child(enemy)
	enemy.move_to($YSort/Fire.position)

func _on_EnemyArrive_timeout():
	if randi() % enemy_spawn_chance == 0:
		spawn_enemy()

func _on_ShortenEnemySpawn_timeout():
	enemy_spawn_chance -= 1
	if (enemy_spawn_chance < 1):
		enemy_spawn_chance = 1

func _on_HoursLivedTimer_timeout():
	hours_lived += 1
	$HoursLived.text = "Hours Lived   " + str(hours_lived)

func _on_HUD_food_death():
	$HoursLivedTimer.stop()
	$HUD.death("starvation", hours_lived)

func _on_Fire_freeze_death():
	$HoursLivedTimer.stop()
	$HUD.death("freezing", hours_lived)
