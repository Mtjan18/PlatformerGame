extends Area2D

# Variabel untuk efek visual agar item terlihat spesial
var waktu = 0.0

func _process(delta):
	waktu += delta * 3.0
	# Efek melayang sedikit lebih lambat agar terasa tenang/elegan
	$Sprite2D.position.y = sin(waktu) * 3.0
	# Efek berputar perlahan (opsional, biar keren)
	$Sprite2D.rotation_degrees += 20 * delta 

func _on_body_entered(body):
	# Cek apakah yang menyentuh adalah Player
	if body.has_method("terima_quest"):
		print("Item Terakhir Diambil! Game Selesai.")
		
		# 1. Update UI Quest terakhir
		body.terima_quest("MISI SELESAI: Cari jalan keluar!")
		
		# 2. Kunci pergerakan player agar tidak bisa lari-lari lagi (opsional)
		#if "is_locked" in body:
			#body.is_locked = true
		
		# 3. Tunggu sebentar agar player bisa membaca pesan kemenangannya
		#await get_tree().create_timer(3.0).timeout
		
		# 4. Pindah ke Scene Kemenangan (Ganti nama file sesuai scene kamu)
		# Jika belum punya, kamu bisa pakai scene game_over yang sudah ada
		#get_tree().change_scene_to_file("res://game_over.tscn")
		
		# Hapus item
		queue_free()
