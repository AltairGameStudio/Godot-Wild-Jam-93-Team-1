extends Node2D

@export var is_medkit: bool = false
@export var item_id: String = "medkit"
@export var item_icon: Texture2D

@onready var sprite_2d = $Sprite2D
@onready var sfx_player = $PickupSFX

var item_sfx = load("res://assets/sfx/click.mp3")
var medkit_sfx = load("res://assets/sfx/zipper.mp3")

func _ready() -> void:
	if item_icon and sprite_2d:
		sprite_2d.texture = item_icon

func on_interact() -> void:
	if is_medkit:
		play_sfx(medkit_sfx)

		$/root/World/HUD/DialogBox.display_text("You picked up: " + item_id, false)
		GameManager.add_medkit(1)
		queue_free()
	else:
		# Procura o inventário em toda a cena usando o grupo que criamos
		var inventories = get_tree().get_nodes_in_group("inventory")
		
		if inventories.size() > 0:
			play_sfx(item_sfx)
			var inventory = inventories[0]
			
			# Tenta adicionar o item
			var success = inventory.add_item(item_id, item_icon)
			
			if success:
				$/root/World/HUD/DialogBox.display_text("You picked up: " + item_id, false)
				# Destrói o item do chão
				queue_free()
		else:
			print("Erro: Inventário não encontrado na cena!")

func play_sfx(stream: AudioStream) -> void:
	# Play SFX and remove it after it finishes
	sfx_player.stream = stream
	sfx_player.play()
	sfx_player.finished.connect(sfx_player.queue_free)
	# Remove child before queue_free to allow sound to finish
	remove_child(sfx_player)
	$/root/World/Player.add_child(sfx_player)