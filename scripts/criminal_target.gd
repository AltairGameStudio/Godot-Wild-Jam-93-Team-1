extends CharacterBody2D

# Estados possíveis para o criminoso
enum State { IDLE, SURRENDERING, HOSTILE }
var current_state: State = State.IDLE

@export var detection_radius: float = 800.0
# Chance de se render ao ver o player
@export var surrender_chance: float = 0.6
# Chance de trair e atirar se estiver rendido
@export var betray_chance: float = 0.4
@export var health: int = 3

var player: Node2D
var will_betray: bool = false
var betray_distance: float = 0.0

func _ready() -> void:
	# Encontra o jogador
	player = get_tree().get_first_node_in_group("player")
	
	# Define a distância de traição aleatória
	betray_distance = randf() * 0.8 * detection_radius

func _physics_process(delta: float) -> void:
	if not player:
		return

	var distance = global_position.distance_to(player.global_position)

	match current_state:
		State.IDLE:
			# Fica parado esperando o jogador entrar no raio de visão
			velocity = Vector2.ZERO
			if distance <= detection_radius:
				decide_initial_reaction()
				
		State.SURRENDERING:
			# Fica olhando para o player
			look_at(player.global_position)
			var direction = global_position.direction_to(player.global_position)
			# Movimenta-se levemente para trás
			velocity = -direction * 30.0
			move_and_slide()
			
			# Se ele tem a intenção de trair e o player chegar perto demais, ele ataca
			if will_betray and distance <= betray_distance:
				enter_hostile_state()
			
		State.HOSTILE:
			# Olha para o player e avança de forma agressiva e rápida
			look_at(player.global_position)
			var direction = global_position.direction_to(player.global_position)
			velocity = direction * 150.0
			move_and_slide()

func decide_initial_reaction() -> void:
	if randf() <= surrender_chance:
		enter_surrender_state()
	else:
		enter_hostile_state()

func enter_surrender_state() -> void:
	current_state = State.SURRENDERING
	modulate = Color(1, 1, 0, 1) 
	
	# Define internamente se ele vai trair o player
	if randf() <= betray_chance:
		will_betray = true

func enter_hostile_state() -> void:
	current_state = State.HOSTILE
	modulate = Color(1, 0, 0, 1) 

func take_damage(amount: int) -> void:
	health -= amount
	print("Criminoso levou tiro! Vida: ", health)
	
	# Se o jogador atirar num rendido, ele imediatamente fica hostil
	if current_state == State.SURRENDERING:
		enter_hostile_state()
	
	if health <= 0:
		die()

func die() -> void:
	queue_free()
