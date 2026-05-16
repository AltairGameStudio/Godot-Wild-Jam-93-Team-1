extends Node

# Tempo até o jogo acabar
var total_time: float = 1200.0
var time_remaining: float
var points: int = 0
var is_game_over: bool = true
var medkit_count: int = 0

var audio_player: AudioStreamPlayer
var ticking_sfx = load("res://assets/sfx/clock ticking.mp3")
var has_played_ticking_sfx: bool = false

var victory_screen_shown: bool = false

func _ready() -> void:
	time_remaining = total_time
	audio_player = AudioStreamPlayer.new()
	audio_player.stream = ticking_sfx
	add_child(audio_player)

func _process(delta: float) -> void:
	if is_game_over:
		return
		
	# Reduz o tempo frame a frame
	time_remaining -= delta

	if time_remaining <= 15.0 and not has_played_ticking_sfx:
		has_played_ticking_sfx = true
		audio_player.play()
	
	if time_remaining <= 0.0:
		time_remaining = 0.0
		end_game("O seu tempo acabou.")

func start_game() -> void:
	victory_screen_shown = false
	time_remaining = total_time
	points = 0
	is_game_over = false
	get_tree().paused = false
	MusicManager.play_exploration_music()

func end_game(reason: String) -> void:
	is_game_over = true
	$/root/World/HUD/GameOverScreen/ReasonLabel.text = reason
	$/root/World/HUD/GameOverScreen/ScoreLabel.text = "Pontos: " + str(points)
	$/root/World/HUD/GameOverScreen.fade_in()
	
	get_tree().paused = true

func win_game() -> void:
	if is_game_over: return
	
	is_game_over = true 
	
	var victory_sequence = get_tree().current_scene.find_child("VictorySequence", true, false)
	
	if victory_sequence:
		victory_sequence.play_cutscene()
	else:
		print("ERRO: O Godot não achou o VictorySequence na cena!")
		show_victory_screen()

func show_victory_screen() -> void:
	if victory_screen_shown: return
	victory_screen_shown = true
	
	points += int(time_remaining)  # Bônus por tempo restante
	
	$/root/World/HUD/VictoryScreen/ScoreLabel.text = "Bounty: " + str(points)
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
