extends Node

@onready var detection_music = $DetectionMusic
@onready var exploration_music = $ExplorationMusic

# Configurações do Crossfade
const TRANSITION_TIME = 1.5
const MIN_VOL = -80.0
const MAX_VOL = 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func crossfade(music_in: AudioStreamPlayer, music_out: AudioStreamPlayer) -> void:
	if music_in.playing and music_in.volume_db >= MAX_VOL:
		return
		
	# Prepara a nova música no silêncio e dá o play
	music_in.volume_db = MIN_VOL
	music_in.play()
	
	# Cria o animador
	var tween = create_tween()
	tween.set_parallel(true) 
	
	# Abaixa a música atual
	if music_out.playing:
		tween.tween_property(music_out, "volume_db", MIN_VOL, TRANSITION_TIME)
		
	# Sobe a música nova
	tween.tween_property(music_in, "volume_db", MAX_VOL, TRANSITION_TIME)
	
	tween.set_parallel(false)
	tween.tween_callback(music_out.stop)

func play_detection_music() -> void:
	crossfade(detection_music, exploration_music)

func play_exploration_music() -> void:
	crossfade(exploration_music, detection_music)

func stop_all_music() -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	
	if detection_music.playing:
		tween.tween_property(detection_music, "volume_db", MIN_VOL, 1.0)
	if exploration_music.playing:
		tween.tween_property(exploration_music, "volume_db", MIN_VOL, 1.0)
		
	tween.set_parallel(false)
	tween.tween_callback(detection_music.stop)
	tween.tween_callback(exploration_music.stop)
