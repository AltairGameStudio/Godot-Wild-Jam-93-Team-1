extends StaticBody2D

#ID do item necessário para quebrar esse obstáculo
@export var required_item: String = "pliers"

# Interação para dar dicas ao jogador
func on_interact() -> void:
	$/root/World/HUD/DialogBox.display_text("A sturdy wire fence is blocking the way. I need something to cut through it.", false)

func on_item_used(used_item_id: String) -> bool:
	if used_item_id == required_item:
		$/root/World/HUD/DialogBox.display_text("You used " + used_item_id + " and opened the way!", false)
		# Destrói a cerca de arame
		queue_free()
		# Retorna verdadeiro para que o inventário saiba que o item foi gasto
		return true
	else:
		$/root/World/HUD/DialogBox.display_text("This doesn't seem to work here...")
		return false
