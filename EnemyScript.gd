extends KinematicBody2D

var max_health = 100
var health = max_health

onready var navigation_agent = $NavigationAgent2D
var velocity = Vector2.ZERO
var speed = 55

var taking_damage_stack = 0
var damage_taken = 40

# Called when the node enters the scene tree for the first time.
func _ready():
	navigation_agent.set_target_location(position)

func move_to(pos):
	navigation_agent.set_target_location(pos)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (not navigation_agent.is_navigation_finished() and \
	   position.distance_to(navigation_agent.get_target_location()) > 25):
		velocity = position.direction_to(navigation_agent.get_next_location()) * speed
		navigation_agent.set_velocity(velocity)
	else:
		velocity = Vector2.ZERO

	$AnimatedSprite.flip_h = velocity.x < 0
	
	move_and_slide(velocity)
	
	health -= taking_damage_stack * damage_taken * delta
	
	# not really necessary since it'll be invisible but probably good anyway
	if health < max_health:
		$HealthBar.show()
	else:
		$HealthBar.hide()
	
	# step is 10, should only disappear if health == 0
	$HealthBar.value = health + 9
	
	if (health <= 0):
		queue_free()


func _on_Area2D_body_entered(body):
	if (body.name.begins_with("Villager") or body.name.begins_with("@Villager")):
		taking_damage_stack += 1


func _on_Area2D_body_exited(body):
	if (body.name.begins_with("Villager") or body.name.begins_with("@Villager")):
		taking_damage_stack -= 1
