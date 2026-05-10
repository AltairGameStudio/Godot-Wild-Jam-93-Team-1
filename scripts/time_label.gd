extends Label

func _process(delta: float) -> void:
	var time = GameManager.time_remaining
	
	var minutes = int(time) / 60
	var seconds = int(time) % 60
	
	text = "%02d:%02d" % [minutes, seconds]
