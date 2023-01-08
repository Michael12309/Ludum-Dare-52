extends KinematicBody2D

var max_health = 100
var health = max_health

var velocity = Vector2.ZERO
var speed = 60
var move_to_pos = Vector2.ZERO

var taking_damage_stack = 0
var damage_taken = 40

# Called when the node enters the scene tree for the first time.
func _ready():
	move_to_pos = position

func move_to(pos):
	move_to_pos = pos

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if position.distance_to(move_to_pos) > 25:
		velocity = (move_to_pos - position).normalized() * speed
	else:
		velocity = Vector2.ZERO

	$AnimatedSprite.flip_h = velocity.x < 0
	
	move_and_slide(velocity)
	
	health -= taking_damage_stack * damage_taken * delta
	
	# todo move somewhere probably
	if health < max_health:
		$HealthBar.show()
	else:
		$HealthBar.hide()
	
	$HealthBar.value = health
	
	if (health <= 0):
		queue_free()


func _on_Area2D_body_entered(body):
	if (body.name.begins_with("Villager") or body.name.begins_with("@Villager")):
		taking_damage_stack += 1


func _on_Area2D_body_exited(body):
	if (body.name.begins_with("Villager") or body.name.begins_with("@Villager")):
		taking_damage_stack -= 1
