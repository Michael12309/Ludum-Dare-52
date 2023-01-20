extends CanvasLayer

var villager_count = 2
var housing_count = 2
var wood_count = 0
var wood_increase = 0
var food_count = 50
var food_increase = 0

var stoke_cost = 4
var house_cost = 70

var outro = false

signal stoke_fire
signal build_house

signal food_death

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func add_villager(amount):
	villager_count += amount

func add_housing(amount):
	housing_count += amount

func add_wood(amount):
	wood_count += amount

func set_wood_increase(amount):
	wood_increase = amount

func add_food(amount):
	food_count += amount
	
func set_food_increase(amount):
	food_increase = amount

func is_room_for_villager():
	return villager_count < housing_count

func _on_ResourceTimer_timeout():
	if (not outro):
		food_count += food_increase - villager_count
		wood_count += wood_increase
		
		$ResourcesLabel.text = \
		"Villagers     " + str(villager_count) + "\n" + \
		"Housing       " + str(villager_count) + "/" + str(housing_count) + "\n" + \
		"Wood          " + str(wood_count) + "\n" + \
		"Fish          " + str(food_count)
		
		$ChangeLabel.text = \
		"" + "\n" + \
		"" + "\n" + \
		("+" if wood_increase > 0 else "") + str(wood_increase) + "/s\n" + \
		("+" if food_increase - villager_count > 0 else "") + str(food_increase - villager_count) + "/s\n"
		
		$StokeFireCostLabel.text = "(Requires " + str(stoke_cost) + " wood)"
		$HouseCostLabel.text = "(Requires " + str(house_cost) + " wood)"
		
		# losing food and
		# 12 ticks (seconds) from death
		if food_increase - villager_count < 0 and \
		   food_count + ((food_increase - villager_count) * 12) <= 0:
			$WarningLabel.show()
		else:
			$WarningLabel.hide()

func _process(delta):
	if (not outro):
		if (wood_count < house_cost):
			$BuildHouseButton.disabled = true
		else:
			$BuildHouseButton.disabled = false
			
		if (wood_count < stoke_cost):
			$StokeFireButton.disabled = true
		else:
			$StokeFireButton.disabled = false
		
		if (food_count < 1):
			emit_signal("food_death")


func _on_BuildHouseButton_pressed():
	if (not outro):
		$ButtonClickAudioStreamPlayer.play()
		wood_count -= house_cost
		house_cost = round(house_cost * 3.7)
		housing_count += 2
		$HouseCostLabel.text = "(Requires " + str(house_cost) + " wood)"
		emit_signal("build_house")


func _on_StokeFireButton_pressed():
	if (not outro):
		$ButtonClickAudioStreamPlayer.play()
		wood_count -= stoke_cost
		stoke_cost = round(stoke_cost * 1.8)
		$StokeFireCostLabel.text = "(Requires " + str(stoke_cost) + " wood)"
		emit_signal("stoke_fire")


func alive():
	outro = false

func death(cause, hours):
	$ResourcesLabel.hide()
	$StokeFireButton.hide()
	$BuildHouseButton.hide()
	$ChangeLabel.hide()
	$HouseCostLabel.hide()
	$FireHealthLabel.hide()
	$ColorRect.show()
	$DeathLabel.show()
	$RestartButton.show()
	outro = true
	$DeathLabel.text = "You died.\n" + \
	"Cause of death: " + str(cause) + "\n" + \
	"Hours lived: " + str(hours)


func _on_RestartButton_pressed():
	get_tree().change_scene("res://Main.tscn")

