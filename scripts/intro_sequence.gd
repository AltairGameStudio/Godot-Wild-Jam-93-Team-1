extends Control

@onready var audio_player = $AudioStreamPlayer
@onready var story_label = $Label

var game_scene = load("res://scenes/world.tscn")

var story_lines = [
	"You are the best bounty hunter around. Prove it.",
	"A rival gang is laying low in that building after hitting one of my spots.",
	"They locked themselves deep inside, waiting for their extraction team.",
	"I need you to break in, but listen: I want them alive.",
	"They know where my stolen goods are. Only shoot if you really have to.",
	"The more guys you capture alive, the more money you make.",
	"And if you do it fast, I will give you a big bonus.",
	"Look around for items and keys to open their safe rooms.",
	"Always keep your weapon drawn when approaching. It makes them give up... sometimes.",
	"If you walk up with your gun down, they will attack...",
	"...and you will have to kill them. I don't want that.",
	"Their heavy backup is already on the way.",
	"The moment you break the front door, you have exactly 10 minutes.",
	"Get the guys, get the info, and get out fast."
]

func _ready():
	# Garante que a tela comece sem texto
	story_label.text = ""
	play_intro()

func play_intro():
	# Toca o som do telefone e espera ele terminar
	audio_player.play()
	print("oi1")
	
	# Aguarda até que o áudio termine de tocar
	await audio_player.finished
	await get_tree().create_timer(1.0).timeout
	
	# Tempo de espera entre cada letra
	var typing_speed = 0.03
	print("oi1")
	for sentence in story_lines:
		story_label.text = sentence
		# Começa com 0 letras visíveis
		story_label.visible_characters = 0
		
		# Revela uma letra por vez
		for i in range(story_label.get_total_character_count()):
			story_label.visible_characters += 1
			await get_tree().create_timer(typing_speed).timeout
			
		await get_tree().create_timer(2.5).timeout
		
		# Limpa a tela para a próxima frase
		story_label.text = ""
		await get_tree().create_timer(0.5).timeout
		
	# Transição para o jogo principal após a história
	start_game()

func start_game():
	GameManager.start_game()
	var error = get_tree().change_scene_to_packed(game_scene)
	if error != OK:
		print("Erro ao carregar a cena do jogo: ", error)

func _input(event):
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
		start_game()
