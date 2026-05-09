extends TextureRect

@export var item_id: String = "pe_de_cabra" 

func _get_drag_data(at_position: Vector2) -> Variant:
	if item_id == "":
		return null
		
	var preview = TextureRect.new()
	preview.texture = self.texture
	preview.modulate = Color(1, 1, 1, 0.5)
	
	preview.custom_minimum_size = Vector2(50, 50) 
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	
	var control = Control.new()
	control.add_child(preview)
	preview.position = -preview.custom_minimum_size / 2
	set_drag_preview(control)
	
	return {"type": "inventory_item", "id": item_id}

func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END:
		if not get_viewport().gui_is_drag_successful():
			var drop_position = get_global_mouse_position()
			print("Você tentou usar o item '", item_id, "' na posição do mapa: ", drop_position)
