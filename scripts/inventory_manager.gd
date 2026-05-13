extends VBoxContainer

func _ready() -> void:
	reorganize()

func add_item(id: String, tex: Texture2D) -> bool:
	# Encontra o primeiro slot livre
	for slot in get_children():
		if slot.item_id == "":
			slot.item_id = id
			slot.texture = tex
			# Reorganiza para puxar os itens e revelar o slot
			reorganize()
			return true
			
<<<<<<< HEAD
	$/root/World/HUD/DialogBox.display_text("Inventory full!")
=======
	$/root/World/HUD/DialogBox.display_text("Inventário cheio!")
>>>>>>> 45327c7 (update)
	return false

func reorganize() -> void:
	var active_items = []
	
	for slot in get_children():
		if slot.item_id != "":
			active_items.append({"id": slot.item_id, "tex": slot.texture})
		
		slot.item_id = ""
		slot.texture = null
		slot.visible = false
		
	# Recoloca os itens de volta em ordem sem deixar buracos e torna visível
	for i in range(active_items.size()):
		var slot = get_child(i)
		slot.item_id = active_items[i]["id"]
		slot.texture = active_items[i]["tex"]
		slot.modulate = Color(1, 1, 1, 1)
		slot.visible = true
