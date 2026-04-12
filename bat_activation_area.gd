extends Area2D

func _on_body_entered(body):
	if body.name == "Player":
		# Bangunkan SEMUA kelelawar yang ada di grup "kelelawar_rintangan_1"
		# dengan menyuruh mereka menjalankan fungsi "mulai_nembak"
		get_tree().call_group("kelelawar_rintangan_1", "mulai_nembak")
		
		# Hancurkan area pemicu ini agar tidak terpanggil dua kali
		# jika player mondar-mandir
		queue_free()
