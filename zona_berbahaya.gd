extends Area2D

func _on_body_entered(body: Node2D) -> void:
	# Pastikan hanya Player yang terpengaruh
	if body.name == "Player":
		print("Player tengelam!")
		
		# Cek apakah Player memiliki fungsi take_damage
		if body.has_method("take_damage"):
			# Pilihan A: Berikan damage besar agar langsung mati beranimasi
			body.take_damage(99) 
			
			# Pilihan B: Berikan damage 1 saja jika ingin player mental dulu baru mati
			# body.take_damage(1)

func matikan_player():
	# Ganti get_tree().reload_current_scene() dengan kode pindah scene ini:
	get_tree().change_scene_to_file("res://game_over.tscn")
