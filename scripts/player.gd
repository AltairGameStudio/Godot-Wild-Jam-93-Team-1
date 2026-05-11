extends CharacterBody2D

const SPEED_EQUIPPED = 150.0
const SPEED_UNEQUIPPED = 300.0

@onready var aim_raycast = $AimRayCast
@onready var interact_area = $InteractArea
@onready var tracer_line = $TracerLine
@onready var heal_bar = $HealBar

@export var max_health: int = 5
# var current_health: int = max_health
var current_health: int = 2
var can_shoot: bool = true
# Tempo entre cada tiro
@export var shoot_cooldown: float = 0.5
# Ângulo máximo de erro do tiro em graus
@export var bullet_spread: float = 8.0

# Estado da arma
var is_weapon_equipped: bool = false

# Tempo em segundos para curar
@export var heal_time_required: float = 2.0
var current_heal_time: float = 0.0
var is_healing: bool = false

func _physics_process(delta: float) -> void:
	if is_healing:
		# Imobiliza o player
		velocity = Vector2.ZERO
		move_and_slide()
		process_healing(delta)
		look_at(get_global_mouse_position())
		return

	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# Define a velocidade baseada na arma
	var current_speed = SPEED_EQUIPPED if is_weapon_equipped else SPEED_UNEQUIPPED
	
	if direction:
		velocity = direction * current_speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, current_speed)

	move_and_slide()
	look_at(get_global_mouse_position())

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("equip"):
		is_weapon_equipped = !is_weapon_equipped
		if is_weapon_equipped:
			print("Arma empunhada.")
		else:
			print("Arma guardada.")

	if event.is_action_pressed("shoot") and can_shoot and is_weapon_equipped:
		shoot()
		
	if event.is_action_pressed("interact"):
		try_interact()
		
	# Início da cura
	if event.is_action_pressed("heal") and GameManager.medkit_count > 0 and current_health < max_health:
		start_healing()
	
	# Interrupção da cura
	if event.is_action_released("heal"):
		stop_healing()

func shoot() -> void:
	# Trava a arma temporariamente
	can_shoot = false
	
	# Adiciona a imprecisão no tiro
	var original_rotation = aim_raycast.rotation
	aim_raycast.rotation += deg_to_rad(randf_range(-bullet_spread, bullet_spread))
	
	aim_raycast.force_raycast_update()
	
	# Limpa os pontos anteriores e adiciona o ponto de origem
	tracer_line.clear_points()
	tracer_line.add_point(aim_raycast.position)
	
	if aim_raycast.is_colliding():
		var target = aim_raycast.get_collider()
		
		# Se o tiro bateu em algo, desenha a linha até o ponto de impacto
		tracer_line.add_point(to_local(aim_raycast.get_collision_point()))
		
		if target.has_method("take_damage"):
			target.take_damage(1)
			print("Acertou: ", target.name)
	else:
		# Se o tiro foi no vazio, desenha a linha até o limite
		var max_range_point = aim_raycast.position + Vector2(800, 0).rotated(aim_raycast.rotation)
		tracer_line.add_point(max_range_point)
	
	# Faz a linha desaparecer rapidamente
	get_tree().create_timer(0.05).timeout.connect(func(): tracer_line.clear_points())
	
	# Devolve a arma para a posição reta
	aim_raycast.rotation = original_rotation
	
	# Cooldown do tiro
	await get_tree().create_timer(shoot_cooldown).timeout
	can_shoot = true

func try_interact() -> void:
	var overlapping_bodies = interact_area.get_overlapping_bodies()
	for body in overlapping_bodies:
		if body == self:
			continue
		if body.has_method("on_interact"):
			body.on_interact()
			break

func take_damage(amount: int) -> void:
	current_health -= amount
	print("Player levou tiro! Vida restante: ", current_health)
	var hurt_overlay = $/root/World/HUD/HurtOverlay
	var tween = get_tree().create_tween()
	tween.tween_property(hurt_overlay, "color", Color(1, 0, 0, 0.1), 0.1)
	tween.tween_property(hurt_overlay, "color", Color(1, 0, 0, 0), 0.2)
	
	if current_health <= 0:
		print("VOCÊ MORREU! Fim de jogo.")
		get_tree().paused = true

func start_healing() -> void:
	is_healing = true
	current_heal_time = 0.0
	heal_bar.visible = true
	heal_bar.max_value = heal_time_required

func stop_healing() -> void:
	is_healing = false
	current_heal_time = 0.0
	heal_bar.visible = false

func process_healing(delta: float) -> void:
	current_heal_time += delta
	heal_bar.value = current_heal_time
	
	if current_heal_time >= heal_time_required:
		complete_healing()

func complete_healing() -> void:
	if GameManager.use_medkit():
		current_health = min(current_health + 2, max_health)
	stop_healing()
