extends CanvasLayer

var villager_count = 1
var housing_count = 2
var wood_count = 0
var wood_increase = 0
var food_count = 20
var food_increase = 0

var house_cost = 30

signal build_house

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
	food_count += food_increase - villager_count
	wood_count += wood_increase
	
	$ResourcesLabel.text = \
	"Villagers     " + str(villager_count) + "\n" + \
	"Housing       " + str(villager_count) + "/" + str(housing_count) + "\n" + \
	"Wood          " + str(wood_count) + "\n" + \
	"Food          " + str(food_count)
	
	$ChangeLabel.text = \
	"" + "\n" + \
	"" + "\n" + \
	("+" if wood_increase > 0 else "") + str(wood_increase) + "/s\n" + \
	("+" if food_increase - villager_count > 0 else "") + str(food_increase - villager_count) + "/s\n"
	
	$HouseCostLabel.text = "(Requires " + str(house_cost) + " wood)"


func _process(delta):
	if (wood_count < house_cost):
		$Button.disabled = true
	else:
		$Button.disabled = false

func _on_Button_pressed():
	wood_count -= house_cost
	house_cost = round(house_cost * 4.2)
	housing_count += 2
	emit_signal("build_house")
