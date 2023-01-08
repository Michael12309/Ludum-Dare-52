extends CanvasLayer

var villager_count = 1
var housing_count = 2
var wood_count = 0
var food_count = 100

var food_decrease_per_villager = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func add_villager(amount):
	villager_count += amount

func add_housing(amount):
	housing_count += amount

func add_wood(amount):
	wood_count += amount

func add_food(amount):
	food_count += amount

# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta):
#	pass

func _on_ResourceTimer_timeout():
	food_count -= food_decrease_per_villager * villager_count
	
	$Label.text = \
	"Villagers     " + str(villager_count) + "\n" + \
	"Housing       " + str(housing_count) + "\n" + \
	"Wood          " + str(wood_count) + "\n" + \
	"Food          " + str(food_count)
