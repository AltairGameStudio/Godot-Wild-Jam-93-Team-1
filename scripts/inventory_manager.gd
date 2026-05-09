extends VBoxContainer

func add_item(id: String, tex: Texture2D) -> bool:
	# Percorre todos os slots filhos
	for slot in get_children():
		# Verifica se o slot está vazio
		if slot.item_id == "":
			slot.item_id = id
			slot.texture = tex
			slot.modulate = Color(1, 1, 1, 1)
			return true

	return false
