extends CanvasLayer

var color_rect: ColorRect

func _ready() -> void:
	layer = 100 
	
	# Cria um retângulo preto
	color_rect = ColorRect.new()
	# Faz cobrir a tela inteira
	color_rect.set_anchors_preset(15)
	# Começa preto mas transparente
	color_rect.color = Color(0, 0, 0, 0)
	# Garante que não bloqueie cliques
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(color_rect)

func change_scene(path: String) -> void:
	# Bloqueia os cliques do jogador durante a transição
	color_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Anima o fade para a tela preta
	var tween_out = create_tween()
	tween_out.tween_property(color_rect, "color:a", 1.0, 0.5)
	await tween_out.finished
	
	# Troca a cena do jogo
	get_tree().change_scene_to_file(path)
	
	# Anima o fade de volta para a tela transparente
	var tween_in = create_tween()
	tween_in.tween_property(color_rect, "color:a", 0.0, 0.5)
	await tween_in.finished
	
	# Libera os cliques novamente
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
