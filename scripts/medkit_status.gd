extends HBoxContainer

@onready var count_label = $CountLabel

func _process(delta: float) -> void:
	visible = GameManager.medkit_count > 0
	
	# Atualiza o texto da label com a quantidade atual
	if visible:
		count_label.text = "x" + str(GameManager.medkit_count)
