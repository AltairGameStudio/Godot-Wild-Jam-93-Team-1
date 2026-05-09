extends TextureRect

@export var item_id: String = "pliers" 

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
			
			var space_state = get_tree().root.get_world_2d().direct_space_state
			
			# Configura a busca no exato pixel onde o mouse soltou o item
			var query = PhysicsPointQueryParameters2D.new()
			query.position = drop_position
			
			# Pega tudo que colidiu com aquele ponto
			var results = space_state.intersect_point(query)
			
			# Verifica se acertou um obstáculo válido
			for result in results:
				var object = result.collider
				
				if object.has_method("on_item_used"):
					var success = object.on_item_used(item_id)
					
					# Se o obstáculo retornar true, consome o item do inventário
					if success:
						item_id = ""
						# Limpa a imagem
						texture = null
						modulate = Color(0, 0, 0, 1) 
					break
