extends KinematicBody2D

export var initially_flipped = false

var max_health = 100
var health = max_health

var selected = false
var velocity = Vector2.ZERO
var speed = 110
var last_position = Vector2.ZERO
onready var navigation_agent = $NavigationAgent2D
var can_be_stuck = false

var heal_amount = 5

var villager_type
var walk_animation
var sit_animation

var fishingIcon = preload("res://assets/icons/fishing-outlined-2.png")
var cuttingIcon = preload("res://assets/icons/cutting-outlined-2.png")
var activity = "none"

# Called when the node enters the scene tree for the first time.
func _ready():
	navigation_agent.set_target_location(position)
	var animation_names = $AnimatedSprite.frames.get_animation_names()
	var villager_type = (randi() % 2) + 1
	walk_animation = "walk" + str(villager_type)
	sit_animation = "sit" + str(villager_type)
	$AnimatedSprite.flip_h = initially_flipped
	$AnimatedSprite.playing = true
	
func move_to(pos: Vector2):
	navigation_agent.set_target_location(pos)
	can_be_stuck = false
	$StuckTimer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (not navigation_agent.is_navigation_finished() and \
	   position.distance_to(navigation_agent.get_target_location()) > 25):
		velocity = position.direction_to(navigation_agent.get_next_location()) * speed
		navigation_agent.set_velocity(velocity)
	else:
		velocity = Vector2.ZERO
	
	if not navigation_agent.is_navigation_finished() and \
	   can_be_stuck and \
	   get_slide_count() >= 1 and \
	   position.distance_to(last_position) < 0.01:
		navigation_agent.set_target_location(position)
		can_be_stuck = false
	
	last_position = position
	
	if velocity == Vector2.ZERO:
		$AnimatedSprite.animation = sit_animation
	else:
		$AnimatedSprite.animation = walk_animation
		$AnimatedSprite.flip_h = velocity.x < 0
	
	move_and_slide(velocity)
	
	# todo move somewhere probably
	if health < max_health:
		$HealthBar.show()
		health += heal_amount * delta
	else:
		$HealthBar.hide()
	
	$HealthBar.value = health

func set_icon(icon):
	if (icon == "fishing"):
		$IconSprite.show()
		$IconSprite.texture = fishingIcon
	elif (icon == "cutting"):
		$IconSprite.show()
		$IconSprite.texture = cuttingIcon
	else:
		$IconSprite.hide()

func select():
	selected = true
	$SelectedSprite.show()

func deselect():
	selected = false
	$SelectedSprite.hide()


func _on_StuckTimer_timeout():
	can_be_stuck = true
