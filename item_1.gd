extends Area2D

func _on_body_entered(body):
	# Kita cek apakah yang menyentuh item ini punya fungsi 'terima_quest'
	# Ini cara paling aman daripada cek nama node
	if body.has_method("terima_quest"):
		print("Buku Merah diambil!")
		
		# Update misi di UI Player kamu
		body.terima_quest("Cari Genta Suci di dalam Goa")
		
		# Tambahkan efek suara di sini jika ada
		
		# Hapus item dari map
		queue_free()

var waktu = 0.0

func _process(delta):
	waktu += delta * 5.0
	# Membuat item naik turun pelan
	$Sprite2D.position.y = sin(waktu) * 5.0
