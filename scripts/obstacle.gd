extends StaticBody2D

#ID do item necessário para quebrar esse obstáculo
@export var required_item: String = "pliers"
# Textos personalizados
@export_multiline var interaction_text: String = "..."
@export_multiline var success_text: String = "..."
@export_multiline var wrong_item_text: String = "This doesn't seem to work here..."

@onready var unlocked_sound = $UnlockingSound

# Interação para dar dicas ao jogador
func on_interact() -> void:
	$/root/World/HUD/DialogBox.display_text(interaction_text, false)

func on_item_used(used_item_id: String) -> bool:
	if used_item_id == required_item:
		$/root/World/HUD/DialogBox.display_text(success_text, false)
		
		unlocked_sound.reparent(get_tree().current_scene)
		unlocked_sound.play()
		
		# Programa o som para se autodestruir assim que terminar de tocar
		unlocked_sound.finished.connect(unlocked_sound.queue_free)
		
		queue_free()
		
		return true
	else:
		$/root/World/HUD/DialogBox.display_text(wrong_item_text, false)
		return false
