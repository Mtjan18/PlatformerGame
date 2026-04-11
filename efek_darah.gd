extends CPUParticles2D

func _ready():
	# Pastikan partikel mulai menyembur
	emitting = true
	
	# Buat Timer otomatis lewat kode selama Lifetime (0.5 detik)
	# Setelah waktunya habis, panggil queue_free() untuk menghapus diri sendiri
	await get_tree().create_timer(lifetime).timeout
	queue_free()
