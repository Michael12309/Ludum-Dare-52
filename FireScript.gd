extends StaticBody2D

var max_health = 100
var health = 50 # max_health
var health_regen = 0.5

var damage_taken = 1
var taking_damage_stack = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# health -= taking_damage_stack * damage_taken * delta
	
	health += health_regen * delta
	
	health -= taking_damage_stack * damage_taken * delta
	
	$HealthBar.value = health
	
	if (health <= 0):
		# queue_free()
		pass


func _on_Area2D_body_entered(body):
	if (body.name.begins_with("Enemy") or body.name.begins_with("@Enemy")):
		taking_damage_stack += 1


func _on_Area2D_body_exited(body):
	if (body.name.begins_with("Enemy") or body.name.begins_with("@Enemy")):
		taking_damage_stack -= 1
