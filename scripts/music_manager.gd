extends Node

@onready var detection_music = $DetectionMusic
@onready var exploration_music = $ExplorationMusic
@onready var action_music = $ActionMusic

@onready var all_music = [detection_music, exploration_music, action_music]

# Configurações do crossfade
const TRANSITION_TIME = 1.5
const MIN_VOL = -80.0
const MAX_VOL = 0.0

var fade_tween: Tween 

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func crossfade_to(music_in: AudioStreamPlayer, transition_time: float) -> void:
	if music_in.playing and music_in.volume_db >= MAX_VOL:
		return
		
	if fade_tween and fade_tween.is_valid():
		fade_tween.kill()
		
	# Prepara a nova música no silêncio e dá o play
	music_in.volume_db = MIN_VOL
	music_in.play()
	
	fade_tween = create_tween()
	fade_tween.set_parallel(true)
	
	# Faz um loop por todas as nossas músicas
	for music_out in all_music:
		if music_out != music_in and music_out.playing:
			fade_tween.tween_property(music_out, "volume_db", MIN_VOL, transition_time)
			
	# Sobe a música nova
	fade_tween.tween_property(music_in, "volume_db", MAX_VOL, transition_time)
	
	fade_tween.set_parallel(false)
	
	# Desliga as músicas que foram silenciadas
	for music_out in all_music:
		if music_out != music_in:
			fade_tween.tween_callback(music_out.stop)

func play_detection_music() -> void:
	crossfade_to(detection_music, 1.0)

func play_exploration_music() -> void:
	crossfade_to(exploration_music, 1.5)
	
func play_action_music() -> void:
	crossfade_to(action_music, 0.1)

func stop_all_music() -> void:
	if fade_tween and fade_tween.is_valid():
		fade_tween.kill()
		
	fade_tween = create_tween()
	fade_tween.set_parallel(true)
	
	# Abaixa o volume de todas que estiverem tocando
	for music in all_music:
		if music.playing:
			fade_tween.tween_property(music, "volume_db", MIN_VOL, 1.0)
			
	fade_tween.set_parallel(false)
	
	# Para totalmente todas as músicas
	for music in all_music:
		fade_tween.tween_callback(music.stop)
