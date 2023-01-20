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

var enemy_spawn_chance = 29

var house_num = 0

var hours_lived = 1

func _ready():
	randomize()
	
	villagerPackedScene = preload("res://Villager.tscn")
	housePackedScene = preload("res://House.tscn")
	enemyPackedScene = preload("res://Enemy.tscn")
	
func isVillager(body):
	return body.name.begins_with("Villager") or body.name.begins_with("@Villager")

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT:
		if event.pressed:
			if selected.size() > 0:
				$ClickAnimation.frame = 0
				$ClickAnimation.play()
				$ClickAnimation.position = event.position
				$SelectAudioStreamPlayer.pitch_scale = (float(randi() % 3) / 2) + 1.5
				$SelectAudioStreamPlayer.play()
			for unit in selected:
				if isVillager(unit.collider):
					unit.collider.move_to(event.position)
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.pressed:
			for unit in selected:
				if isVillager(unit.collider):
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
				if isVillager(unit.collider):
					unit.collider.select()
					selected.append(unit)

	if event is InputEventMouseMotion:
		if dragging:
			$DrawSelectNode2D.draw(drag_start_pos, event.position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$HUD.set_food_increase(villagers_in_pond * 3)
	$HUD.set_wood_increase(villagers_in_trees * 3)

func _physics_process(delta):
	if $FireAudioStreamPlayer.playing == false:
		$FireAudioStreamPlayer.play()
	if $ChoppingAudioStreamPlayer.playing == false:
		$ChoppingAudioStreamPlayer.play()
	if $WaterAudioStreamPlayer.playing == false:
		$WaterAudioStreamPlayer.play()

func closestVillagerTo(pos):
	var closest = 99999
	var closest_villager
	for villager in get_tree().get_nodes_in_group("villagers"):
		if villager.position.distance_to(pos) < closest:
			closest = villager.position.distance_to(pos)
			closest_villager = villager
	return [closest_villager, closest]

func _on_PondArea_body_entered(body):
	if isVillager(body):
		villagers_in_pond += 1
		body.set_icon("fishing")

func _on_PondArea_body_exited(body):
	if isVillager(body):
		villagers_in_pond -= 1
		body.set_icon("none")

func _on_WoodArea_body_entered(body):
	if isVillager(body):
		villagers_in_trees += 1
		body.set_icon("cutting")

func _on_WoodArea_body_exited(body):
	if isVillager(body):
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

func _on_HUD_stoke_fire():
	$YSort/Fire.add_health(35)

func spawn_enemy():
	var enemy = enemyPackedScene.instance()
	var loc = get_node("EnemySpawn" + str((randi() % 4) + 1)).position
	enemy.position = loc
	$YSort.add_child(enemy)
	var move_to_pos = $YSort/Fire.position
	move_to_pos.x += (randi() % 20) - 10
	move_to_pos.y += 30
	enemy.move_to(move_to_pos)

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


func _on_AudioTimer_timeout():
	# this is expensive, so I'm doing it in a timer rather than every frame
	var closestDistanceFromFire = closestVillagerTo($YSort/Fire.position)[1]
	# 60 to give a consistant area around fire before it falls off
	closestDistanceFromFire = clamp(closestDistanceFromFire, 70, 500)
	$FireAudioStreamPlayer.volume_db = range_lerp(closestDistanceFromFire, 70, 500, -8, -45)
	
	var closestDistanceFromWater = closestVillagerTo($WaterAudioSource.position)[1]
	# 60 to give a consistant area around fire before it falls off
	closestDistanceFromWater = clamp(closestDistanceFromWater, 0, 600)
	$WaterAudioStreamPlayer.volume_db = range_lerp(closestDistanceFromWater, 0, 600, 0, -90)
	
	if villagers_in_trees >= 1:
		$ChoppingAudioStreamPlayer.volume_db = -21
	else:
		$ChoppingAudioStreamPlayer.volume_db = -100
