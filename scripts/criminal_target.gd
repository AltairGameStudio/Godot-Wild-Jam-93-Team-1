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

@export var patrol_points: Array[Node2D] = []

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
@onready var sprite_2d = $Sprite2D

@export var sprite_idle: Texture2D
@export var sprite_walk: Texture2D
@export var sprite_hostile: Texture2D
@export var bullet_scene: PackedScene

var gunshot_sfx_resources: Array[AudioStream] = [
	load("res://assets/sfx/gunshots/gunshot1.ogg"),
	load("res://assets/sfx/gunshots/gunshot2.mp3"),
	load("res://assets/sfx/gunshots/gunshot3.ogg"),
	load("res://assets/sfx/gunshots/gunshot4.ogg"),
	load("res://assets/sfx/gunshots/gunshot5.mp3"),
]

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
			patrol()
			if distance <= detection_radius and is_player_visible():
				decide_initial_reaction()
				
		State.SURRENDERING:
			aim_at_player()
			
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
				$SFX/Betrayal.play()
				# Legítima defesa
				kill_classification = KillType.LEGITIMATE
				enter_hostile_state()
			
		State.HOSTILE:
			aim_at_player()
			
			# Direção base (ir para cima) com desvio aleatório
			var base_dir = global_position.direction_to(player.global_position)
			var organic_dir = base_dir.rotated(current_strafe_angle)
			
			velocity = organic_dir * 120.0
			move_and_slide()
			
	update_sprite()

func decide_initial_reaction() -> void:
	MusicManager.play_detection_music()
	
	if not player.is_weapon_equipped:
		$SFX/Surprise.play()
		# Culpa do player por andar desarmado
		kill_classification = KillType.ILLEGITIMATE
		enter_hostile_state()
	elif randf() <= surrender_chance:
		enter_surrender_state()
	else:
		$SFX/Surprise.play()
		kill_classification = KillType.LEGITIMATE
		enter_hostile_state()

func enter_surrender_state() -> void:
	$SFX/Surrender.play()
	if current_state == State.SURRENDERING: return
	current_state = State.SURRENDERING
	if randf() <= betray_chance:
		will_betray = true

func enter_hostile_state() -> void:
	if current_state == State.HOSTILE: return
	MusicManager.play_action_music()
	current_state = State.HOSTILE
	
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
	$SFX/Gunshots.stream = gunshot_sfx_resources[randi() % gunshot_sfx_resources.size()]
	$SFX/Gunshots.play()
	if bullet_scene:
		# Cria a cópia da bala
		var bullet = bullet_scene.instantiate()
		
		# Define que este criminoso foi quem atirou
		bullet.shooter = self
		
		get_tree().root.add_child(bullet)
		
		# Define a posição de saída na ponta da arma
		bullet.global_position = aim_raycast.global_position
		
		# Aplica o spread
		var spread_angle = deg_to_rad(randf_range(-enemy_spread, enemy_spread))
		bullet.global_rotation = aim_raycast.global_rotation + spread_angle

func _on_movement_timer_timeout() -> void:
	# A cada tick desse timer, o criminoso escolhe um desvio para esquivar
	current_strafe_angle = deg_to_rad(randf_range(-45.0, 45.0))
	# O próximo zigue-zague vai acontecer em um tempo aleatório
	movement_timer.wait_time = randf_range(0.5, 1.5)

func take_damage(amount: int) -> void:
	# $SFX/Damage.play()
	health -= amount
	print("Criminoso levou tiro! Vida: ", health)
	
	if current_state == State.SURRENDERING:
		print("Você atirou num suspeito rendido!")
		kill_classification = KillType.ILLEGITIMATE
		enter_hostile_state()
	
	if health <= 0:
		die()

func die() -> void:
	# Play SFX and remove it after it finishes
	var death_sfx = $SFX/Death
	death_sfx.play()
	death_sfx.finished.connect(death_sfx.queue_free)
	# Remove child before queue_free to allow sound to finish
	$SFX.remove_child(death_sfx)
	player.add_child(death_sfx)

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
	# Play SFX and remove it after it finishes
	var cuff_sfx = $SFX/Cuff
	cuff_sfx.play()
	cuff_sfx.finished.connect(cuff_sfx.queue_free)
	# Remove child before queue_free to allow sound to finish
	$SFX.remove_child(cuff_sfx)
	player.add_child(cuff_sfx)

	$/root/World/HUD/DialogBox.display_text("Arrest: +" + str(capture_points), false)
	GameManager.update_points(capture_points)
	
	# Por enquanto, ele apenas desaparece da cena
	remove_from_scene()

func remove_from_scene() -> void:
	queue_free()
	MusicManager.play_exploration_music()
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

func aim_at_player() -> void:
	var distance = global_position.distance_to(player.global_position)
	var weapon_lateral_offset = aim_raycast.position.y
	
	if distance > abs(weapon_lateral_offset):
		var base_angle = global_position.direction_to(player.global_position).angle()
		var correction_angle = asin(weapon_lateral_offset / distance)
		global_rotation = base_angle - correction_angle
	else:
		look_at(player.global_position)

func update_sprite() -> void:
	if current_state == State.HOSTILE:
		sprite_2d.texture = sprite_hostile
	elif velocity.length() > 0:
		sprite_2d.texture = sprite_walk
	else:
		sprite_2d.texture = sprite_idle

func patrol() -> void:
	if patrol_points.size() == 0:
		return
	
	var target_point = patrol_points[0]
	var direction = (target_point.global_position - global_position).normalized()
	velocity = direction * 120.0
	move_and_slide()
	
	if global_position.distance_to(target_point.global_position) < 10.0:
		# Move first point to the end of the list to create a loop
		patrol_points.append(patrol_points.pop_front())
		look_at(patrol_points[0].global_position)
