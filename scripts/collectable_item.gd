extends Node2D

@export var is_medkit: bool = false
@export var item_id: String = "medkit"
@export var item_icon: Texture2D

func on_interact() -> void:
	if is_medkit:
		GameManager.add_medkit(1)
		queue_free()
	else:
		# Procura o inventário em toda a cena usando o grupo que criamos
		var inventories = get_tree().get_nodes_in_group("inventory")
		
		if inventories.size() > 0:
			var inventory = inventories[0]
			
			# Tenta adicionar o item
			var success = inventory.add_item(item_id, item_icon)
			
			if success:
				$/root/World/HUD/DialogBox.display_text("Você pegou: " + item_id)
				# Destrói o item do chão
				queue_free()
		else:
			print("Erro: Inventário não encontrado na cena!")
