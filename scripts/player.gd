extends CharacterBody2D

const SPEED_EQUIPPED = 200.0
const SPEED_UNEQUIPPED = 400.0

@onready var aim_raycast = $AimRayCast
@onready var interact_area = $InteractArea
@onready var tracer_line = $TracerLine
@onready var heal_bar = $HealBar

@onready var sprite_2d = $Sprite2D 

@export var sprite_idle: Texture2D
@export var sprite_walk: Texture2D
@export var sprite_equipped: Texture2D

@export var max_health: int = 5
var current_health: int = max_health
# var current_health: int = 2
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

# Soundeffects
var footstep_sfx_playing: bool = false
var gunshot_sfx_resources: Array[AudioStream] = [
	load("res://assets/sfx/gunshots/gunshot1.ogg"),
	load("res://assets/sfx/gunshots/gunshot2.mp3"),
	load("res://assets/sfx/gunshots/gunshot3.ogg"),
	load("res://assets/sfx/gunshots/gunshot4.ogg"),
	load("res://assets/sfx/gunshots/gunshot5.mp3"),
]

@export var bullet_scene: PackedScene

func _physics_process(delta: float) -> void:
	if is_healing:
		# Mantém a barra fixa acima da cabeça do player
		heal_bar.global_position = global_position + Vector2(-heal_bar.size.x / 2, -80)
		heal_bar.rotation = 0
		# Imobiliza o player
		velocity = Vector2.ZERO
		move_and_slide()
		process_healing(delta)
		aim_at_mouse()
		return

	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# Define a velocidade baseada na arma
	var current_speed = SPEED_EQUIPPED if is_weapon_equipped else SPEED_UNEQUIPPED
	
	if direction:
		velocity = direction * current_speed
		if not footstep_sfx_playing:
			footstep_sfx_playing = true
			$SFX/Footsteps.play()
	else:
		velocity = velocity.move_toward(Vector2.ZERO, current_speed)
		footstep_sfx_playing = false
		$SFX/Footsteps.stop()

	move_and_slide()
	aim_at_mouse()
	update_sprite()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("equip"):
		is_weapon_equipped = !is_weapon_equipped
		$SFX/Holster.play()
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
	
	if event.is_action_pressed("pause"):
		$/root/World/HUD/PauseMenu.pause()

func shoot() -> void:
	# Trava a arma temporariamente
	can_shoot = false

	$SFX/Gunshots.stream = gunshot_sfx_resources[randi() % gunshot_sfx_resources.size()]
	$SFX/Gunshots.play()
	
	if bullet_scene:
		# Cria uma bala
		var bullet = bullet_scene.instantiate()
		
		# Define que foi o jogador quem atirou
		bullet.shooter = self
		
		get_tree().root.add_child(bullet)
		
		# Define a posição de saída
		bullet.global_position = aim_raycast.global_position
		
		# Aplica um spread de erro na mira
		var spread_angle = deg_to_rad(randf_range(-bullet_spread, bullet_spread))
		bullet.global_rotation = aim_raycast.global_rotation + spread_angle
	
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
		GameManager.end_game("Você foi morto.")

func start_healing() -> void:
	$SFX/Healing/Start.play()
	is_healing = true
	current_heal_time = 0.0
	heal_bar.visible = true
	heal_bar.max_value = heal_time_required

func stop_healing() -> void:
	$SFX/Healing/Start.stop()
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
		$SFX/Healing/Complete.play()
		current_health = min(current_health + 2, max_health)
	stop_healing()

func update_sprite() -> void:
	if is_weapon_equipped:
		sprite_2d.texture = sprite_equipped
	elif velocity.length() > 0:
		sprite_2d.texture = sprite_walk
	else:
		sprite_2d.texture = sprite_idle

func aim_at_mouse() -> void:
	var mouse_pos = get_global_mouse_position()
	
	if is_weapon_equipped:
		var distance = global_position.distance_to(mouse_pos)
		
		# Pega a distância lateral da arma em relação ao centro do player
		var weapon_lateral_offset = aim_raycast.position.y 
		
		if distance > abs(weapon_lateral_offset):
			var base_angle = global_position.direction_to(mouse_pos).angle()
			
			# Calcula o ângulo de compensação
			var correction_angle = asin(weapon_lateral_offset / distance)
			
			# Rotaciona o player com compensação
			global_rotation = base_angle - correction_angle
		else:
			look_at(mouse_pos)
	else:
		look_at(mouse_pos)
