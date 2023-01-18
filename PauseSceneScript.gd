extends CanvasLayer

var paused = false

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		paused = not paused
		get_tree().paused = paused
		if paused:
			$PausedColoredRect.show()
			$PausedLabel.show()
		else:
			$PausedColoredRect.hide()
			$PausedLabel.hide()
