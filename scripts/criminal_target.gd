extends CharacterBody2D

enum State { IDLE, SURRENDERING, HOSTILE }
var current_state: State = State.IDLE

enum KillType { LEGITIMATE, ILLEGITIMATE }
var kill_classification: KillType = KillType.LEGITIMATE

@export var detection_radius: float = 800.0
@export var surrender_chance: float = 0.6
@export var betray_chance: float = 0.4
@export var health: int = 3

@export var min_shoot_cooldown: float = 0.5
@export var max_shoot_cooldown: float = 1.5
@export var enemy_spread: float = 15.0

var player: Node2D
var will_betray: bool = false
var betray_distance: float = 0.0

var capture_points: int = 100
var legitimate_kill_points: int = 75
var illegitimate_kill_points: int = 50

# Variáveis para movimento
var current_strafe_angle: float = 0.0
var movement_timer: Timer
var shoot_timer: Timer

@onready var aim_raycast = $AimRayCast
@onready var tracer_line = $TracerLine

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	betray_distance = randf_range(150.0, detection_radius * 0.8)
	
	# Ficar mudando de direção
	movement_timer = Timer.new()
	movement_timer.autostart = true
	movement_timer.timeout.connect(_on_movement_timer_timeout)
	add_child(movement_timer)
	
	# Timer de cooldown da arma
	shoot_timer = Timer.new()
	shoot_timer.one_shot = true
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	add_child(shoot_timer)

func _physics_process(delta: float) -> void:
	if not player:
		return

	var distance = global_position.distance_to(player.global_position)

	match current_state:
		State.IDLE:
			velocity = Vector2.ZERO
			if distance <= detection_radius and is_player_visible():
				decide_initial_reaction()
				
		State.SURRENDERING:
			look_at(player.global_position)
			
			# Direção base (para longe) com desvio aleatório
			var base_dir = -global_position.direction_to(player.global_position)
			var organic_dir = base_dir.rotated(current_strafe_angle)
			
			velocity = organic_dir * 35.0
			move_and_slide()
			
			if not player.is_weapon_equipped:
				# Culpa do player
				kill_classification = KillType.ILLEGITIMATE
				enter_hostile_state()
			elif will_betray and distance <= betray_distance:
				# Legítima defesa
				kill_classification = KillType.LEGITIMATE
				enter_hostile_state()
			
		State.HOSTILE:
			look_at(player.global_position)
			
			# Direção base (ir para cima) com desvio aleatório
			var base_dir = global_position.direction_to(player.global_position)
			var organic_dir = base_dir.rotated(current_strafe_angle)
			
			velocity = organic_dir * 120.0
			move_and_slide()

func decide_initial_reaction() -> void:
	if not player.is_weapon_equipped:
		# Culpa do player por andar desarmado
		kill_classification = KillType.ILLEGITIMATE
		enter_hostile_state()
	elif randf() <= surrender_chance:
		enter_surrender_state()
	else:
		kill_classification = KillType.LEGITIMATE
		enter_hostile_state()

func enter_surrender_state() -> void:
	if current_state == State.SURRENDERING: return
	current_state = State.SURRENDERING
	modulate = Color(1, 1, 0, 1) 
	if randf() <= betray_chance:
		will_betray = true

func enter_hostile_state() -> void:
	if current_state == State.HOSTILE: return
	current_state = State.HOSTILE
	modulate = Color(1, 0, 0, 1) 
	
	# Prepara a arma e começa o cooldown antes do primeiro tiro
	start_shoot_cooldown()

func start_shoot_cooldown() -> void:
	# Define um tempo aleatório para puxar o gatilho novamente
	shoot_timer.wait_time = randf_range(min_shoot_cooldown, max_shoot_cooldown)
	shoot_timer.start()

func _on_shoot_timer_timeout() -> void:
	if current_state != State.HOSTILE or not player:
		return
		
	shoot_at_player()
	start_shoot_cooldown()

func shoot_at_player() -> void:
	# Adiciona a imprecisão
	var original_rotation = aim_raycast.rotation
	aim_raycast.rotation += deg_to_rad(randf_range(-enemy_spread, enemy_spread))
	
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

func _on_movement_timer_timeout() -> void:
	# A cada tick desse timer, o criminoso escolhe um desvio para esquivar
	current_strafe_angle = deg_to_rad(randf_range(-45.0, 45.0))
	# O próximo zigue-zague vai acontecer em um tempo aleatório
	movement_timer.wait_time = randf_range(0.5, 1.5)

func take_damage(amount: int) -> void:
	health -= amount
	print("Criminoso levou tiro! Vida: ", health)
	
	if current_state == State.SURRENDERING:
		print("Você atirou num suspeito rendido!")
		kill_classification = KillType.ILLEGITIMATE
		enter_hostile_state()
	
	if health <= 0:
		die()

func die() -> void:
	if kill_classification == KillType.LEGITIMATE:
		$/root/World/HUD/DialogBox.display_text("Legitimate kill: +" + str(legitimate_kill_points), false)
		GameManager.update_points(legitimate_kill_points)
	else:
		$/root/World/HUD/DialogBox.display_text("Illegitimate kill: +" + str(illegitimate_kill_points), false)
		GameManager.update_points(illegitimate_kill_points)
		
	remove_from_scene()

func on_interact() -> void:
	# A prisão só é possível se o criminoso estiver rendido
	if current_state == State.SURRENDERING:
		arrest()
	# elif current_state == State.HOSTILE:
	# 	$/root/World/HUD/DialogBox.display_text("Impossível prender agora. O criminoso está reagindo.")
	# else:
	#	$/root/World/HUD/DialogBox.display_text("O suspeito ainda não foi confrontado.")

func arrest() -> void:
	$/root/World/HUD/DialogBox.display_text("Arrest: +" + str(capture_points), false)
	GameManager.update_points(capture_points)
	
	# Por enquanto, ele apenas desaparece da cena
	remove_from_scene()

func remove_from_scene() -> void:
	queue_free()
	if get_parent().get_child_count() <= 1:
		GameManager.win_game()

func is_player_visible() -> bool:
	var space_state = get_world_2d().direct_space_state
	
	# Cria uma linha do criminoso até o player
	var query = PhysicsRayQueryParameters2D.create(global_position, player.global_position)
	# Garante que o raio não colida com o próprio criminoso
	query.exclude = [self]
	# Dispara o raio e pega o primeiro objeto que ele atinge
	var result = space_state.intersect_ray(query)
	
	# Se bateu no player, não há paredes bloqueando a visão
	if result and result.collider == player:
		return true
		
	return false
