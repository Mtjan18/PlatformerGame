extends Area2D

func _on_body_entered(body):
	if body.name == "Player":
		print("Player tertusuk!")
		# GANTI INI: matikan_player()
		# MENJADI INI:
		call_deferred("matikan_player") 

func matikan_player():
	get_tree().reload_current_scene()
