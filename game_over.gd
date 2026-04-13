extends Control 

func _on_ulangi_pressed() -> void:
	# 1. Reset semua memori di Global ke kondisi awal mula
	Global.buku_terkumpul = 0
	Global.status_misi = "belum_mulai"
	Global.teks_misi_aktif = ""
	
	# 2. Setelah reset bersih, baru muat ulang layar Hutan
	get_tree().change_scene_to_file("res://HUTAN.tscn")

func _on_keluar_pressed() -> void:
	get_tree().quit()
