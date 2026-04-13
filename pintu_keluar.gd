extends Area2D

func _on_body_entered(body):
	# Pastikan hanya Player yang bisa memicu pindah tempat
	if body.name == "Player":
		if Global.buku_terkumpul >= 3:
			print("Buku lengkap! Kembali ke Hutan.")
			get_tree().change_scene_to_file("res://HUTAN.tscn")
		else:
			var sisa = 3 - Global.buku_terkumpul
			
			# Munculkan pesan di layar menggunakan fungsi yang sudah ada di Player
			if body.has_method("terima_quest"):
				body.terima_quest("PINTU TERKUNCI! Kamu butuh " + str(sisa) + " buku lagi.")
			
			# Tetap muncul di console untuk debugging
			print("Pintu terkunci! Kamu butuh ", sisa, " buku lagi.")
