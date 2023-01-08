extends KinematicBody2D

var max_health = 100
var health = 0

var selected
var velocity = Vector2.ZERO
var speed = 100
var move_to_pos = Vector2.ZERO

var villager_type
var walk_animation
var sit_animation

# Called when the node enters the scene tree for the first time.
func _ready():
	move_to_pos = position
	var animation_names = $AnimatedSprite.frames.get_animation_names()
	var villager_type = (randi() % 2) + 1
	walk_animation = "walk" + str(villager_type)
	sit_animation = "sit" + str(villager_type)
	$AnimatedSprite.playing = true

func move_to(pos):
	move_to_pos = pos

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if position.distance_to(move_to_pos) > 25:
		velocity = (move_to_pos - position).normalized() * speed
	else:
		velocity = Vector2.ZERO
	
	if velocity != Vector2.ZERO:
		$AnimatedSprite.animation = walk_animation
		$AnimatedSprite.flip_h = velocity.x < 0
	else:
		$AnimatedSprite.animation = sit_animation
	
	move_and_slide(velocity)
	
	# todo move somewhere probably
	if health < max_health:
		$HealthBar.show()
		health += 10.0 * delta
	else:
		$HealthBar.hide()
	
	$HealthBar.value = health

func select():
	selected = true
	$SelectedSprite.show()

func deselect():
	selected = false
	$SelectedSprite.hide()
