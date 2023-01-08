extends Node2D


func _ready():
	$AnimationPlayer.play("Fade in")
	$IntroLabel.text = "\n\n" + \
	"You're alone in a forest\n\n" + \
	"Keep enough food to stay alive\n\n" + \
	"Don't let your fire burn out"
	yield(get_tree().create_timer(6), "timeout")
	$AnimationPlayer.play("Fade out")
	yield(get_tree().create_timer(1), "timeout")
	$AnimationPlayer.play("Fade in")
	$IntroLabel.text = "\n" + \
	"Click and drag to select villagers,\nclick to tell them where to go\n\n" + \
	"Sit by the trees to harvest logs\n" + \
	"Sit by the pond to fish\n" + \
	"Sit by thieves to kill them\n" + \
	"Build houses for new villagers\n" + \
	"Each villager needs fish to eat"
	yield(get_tree().create_timer(12), "timeout")
	$AnimationPlayer.play("Fade out")
	yield(get_tree().create_timer(2), "timeout")
	get_tree().change_scene("res://Main.tscn")
