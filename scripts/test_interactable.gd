extends StaticBody2D

#ID do item necessário para quebrar esse obstáculo
@export var required_item: String = "pliers"

# Interação para dar dicas ao jogador
func on_interact() -> void:
<<<<<<< HEAD
	$/root/World/HUD/DialogBox.display_text("A sturdy wire fence is blocking the way. I need something to cut through it.")

func on_item_used(used_item_id: String) -> bool:
	if used_item_id == required_item:
		$/root/World/HUD/DialogBox.display_text("You used " + used_item_id + " and opened the way!")
=======
	$/root/World/HUD/DialogBox.display_text("Uma tela de arame resistente bloqueia o caminho. Preciso de algo para cortá-la.")

func on_item_used(used_item_id: String) -> bool:
	if used_item_id == required_item:
		$/root/World/HUD/DialogBox.display_text("Você usou o(a) " + used_item_id + " e abriu o caminho!")
>>>>>>> 45327c7 (update)
		# Destrói a cerca de arame
		queue_free()
		# Retorna verdadeiro para que o inventário saiba que o item foi gasto
		return true
	else:
<<<<<<< HEAD
		$/root/World/HUD/DialogBox.display_text("This doesn't seem to work here...")
=======
		$/root/World/HUD/DialogBox.display_text("Isso não parece funcionar aqui...")
>>>>>>> 45327c7 (update)
		return false
