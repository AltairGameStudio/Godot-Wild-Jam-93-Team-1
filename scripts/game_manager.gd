extends Node

# Tempo até o jogo acabar
var total_time: float = 120.0
var time_remaining: float
var points: int = 0
var is_game_over: bool = true
var medkit_count: int = 0

func _ready() -> void:
	time_remaining = total_time

func _process(delta: float) -> void:
	if is_game_over:
		return
		
	# Reduz o tempo frame a frame
	time_remaining -= delta
	
	if time_remaining <= 0.0:
		time_remaining = 0.0
		end_game("O seu tempo acabou.")

func start_game() -> void:
	time_remaining = total_time
	points = 0
	is_game_over = false
	get_tree().paused = false

func end_game(reason: String) -> void:
	is_game_over = true
	$/root/World/HUD/GameOverScreen/ReasonLabel.text = reason
	$/root/World/HUD/GameOverScreen/ScoreLabel.text = "Pontos: " + str(points)
	$/root/World/HUD/GameOverScreen.fade_in()
	
	get_tree().paused = true

func win_game() -> void:
	points += int(time_remaining) * 5  # Bônus por tempo restante
	is_game_over = true
	$/root/World/HUD/VictoryScreen/ScoreLabel.text = "Pontos: " + str(points)
	$/root/World/HUD/VictoryScreen.fade_in()
	
	get_tree().paused = true

func update_points(amount: int) -> void:
	points += amount
	$/root/World/HUD/PointsLabel.text = str(points)

func add_medkit(amount: int) -> void:
	medkit_count += amount

func use_medkit() -> bool:
	if medkit_count > 0:
		medkit_count -= 1
		return true
	return false
