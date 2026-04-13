extends Area2D

var waktu = 0.0
var posisi_awal_y = 0.0

func _ready():
	posisi_awal_y = position.y

func _process(delta):
	waktu += delta * 4.0
	position.y = posisi_awal_y + sin(waktu) * 5.0

func _on_body_entered(body):
	if body.name == "Player":
		# 1. Tambah hitungan di Global
		Global.buku_terkumpul += 1
		
		# 2. Cek apakah sudah terkumpul semua (3 buku)
		if Global.buku_terkumpul >= 3:
			Global.status_misi = "siap_lapor"
			if body.has_method("terima_quest"):
				body.terima_quest("Misi: Kembalikan buku ke NPC di Hutan!")
		else:
			# Jika belum 3, tampilkan progres angka seperti biasa
			if body.has_method("terima_quest"):
				body.terima_quest("Misi: Kumpulkan Buku Misterius (" + str(Global.buku_terkumpul) + "/3)")
		
		# 3. Hapus item buku dari layar
		queue_free()
