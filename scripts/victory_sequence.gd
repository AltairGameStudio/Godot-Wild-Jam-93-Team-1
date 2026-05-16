extends Control

@onready var story_label = $Label

var cutscene_ended: bool = false
var story_lines = []

var story_lines_bad = [
	"My clean-up crew is inside... and it's a damn bloodbath.",
	"I told you I needed them breathing. Dead men don't talk, you idiot.",
	"Now I'll have to tear this entire city apart to find where they hid my shipment.",
	"Take this miserable cut and get out of my sight. Let's look at the damage..."
]

var story_lines_mid = [
	"My extraction team is sweeping the building right now.",
	"You left a few bodies behind, but we got enough of them alive to make them talk.",
	"It wasn't a pretty job, but I'll get the location of my goods out of them.",
	"Here is your cut. Let's see your final numbers..."
]

var story_lines_good = [
	"My extraction team just secured the perimeter.",
	"A clean sweep. You bagged them alive, exactly as ordered. I am truly impressed.",
	"They'll be screaming the exact location of my goods before the hour is up.",
	"You earned every penny. Let's see the final numbers..."
]

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	story_label.text = ""

func play_cutscene() -> void:
	visible = true
	
	# Pausa o jogo
	get_tree().paused = true
	
	var enemy_score = GameManager.points
	
	print(enemy_score)
	
	if enemy_score <= 300:
		story_lines = story_lines_bad
	elif enemy_score <= 600:
		story_lines = story_lines_mid
	else:
		story_lines = story_lines_good
	
	var typing_speed = 0.03
	
	for sentence in story_lines:
		if cutscene_ended: return
		
		story_label.text = sentence
		story_label.visible_characters = 0
		
		for i in range(story_label.get_total_character_count()):
			if cutscene_ended: return
			
			story_label.visible_characters += 1
			await get_tree().create_timer(typing_speed).timeout
			
		if cutscene_ended: return
		await get_tree().create_timer(2.5).timeout
		story_label.text = ""
		if cutscene_ended: return
		await get_tree().create_timer(0.5).timeout
		
	# Quando a cutscene termina, chama a tela final de pontuação
	if not cutscene_ended:
		end_cutscene()

func end_cutscene() -> void:
	if cutscene_ended: return
	cutscene_ended = true
	
	visible = false
	GameManager.show_victory_screen()

func _input(event: InputEvent) -> void:
	# Permite pular a cutscene
	if visible and event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
		end_cutscene()
