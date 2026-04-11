extends Area2D

func _on_body_entered(body):
	# Cek apakah yang masuk ke air adalah Player
	if body.name == "Player":
		print("Player tenggelam!")
		call_deferred("matikan_player") 

func matikan_player():
	# Cara paling simpel: Ulangi level dari awal
	get_tree().reload_current_scene()
