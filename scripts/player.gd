extends CharacterBody2D

const SPEED = 300.0

@onready var aim_raycast = $AimRayCast

func _physics_process(delta: float) -> void:
	# Movimentação WASD
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if direction:
		velocity = direction * SPEED
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)

	move_and_slide()

	# Mira e rotação
	look_at(get_global_mouse_position())
	
	# Gatilho do tiro
	if Input.is_action_just_pressed("shoot"):
		shoot()

func shoot() -> void:
	# Força o raycast a atualizar a colisão no exato frame do tiro
	aim_raycast.force_raycast_update()
	
	if aim_raycast.is_colliding():
		# Descobre qual objeto o raio atingiu
		var target = aim_raycast.get_collider()
		var hit_point = aim_raycast.get_collision_point()
		
		# Verifica se o objeto atingido é um criminoso e se ele tem o método para receber dano
		if target.has_method("take_damage"):
			target.take_damage(1)
			print("Acertou em cheio: ", target.name)
		else:
			print("Tiro atingiu cenário/parede em: ", hit_point)
			
	else:
		print("Tiro no vazio (fora de alcance).")
