extends CharacterBody2D 

@onready var speech_bubble = $SpeechBubble
var player_in_area = false
var player_node = null
var dialogue_step = 0
var ending_dimulai = false

# Daftar cerita pendek
var dialogues = [
	"Ksatria, syukurlah kau sampai.",
	"Penyihir jahat mencuri 3 Buku Sihir pelindung hutan.",
	"Dia menyembunyikannya di dalam Gua Reruntuhan.",
	"Aku akan membuka segel guanya.",
	"Cepat rebut kembali buku itu!"
]

func _ready():
	speech_bubble.visible = false

func _on_body_entered(body):
	if body.name == "Player":
		player_in_area = true
		player_node = body
		_update_hint()

func _update_hint():
	# Memunculkan gelembung "Tekan F" sesuai status misi
	if Global.status_misi == "belum_mulai": 
		show_dialogue("Tekan 'F' untuk bicara")
	elif Global.status_misi == "sedang_mencari": 
		show_dialogue("Tekan 'F' untuk info quest")
	elif Global.status_misi == "siap_lapor": 
		show_dialogue("Tekan 'F' untuk serahkan buku")
	else: 
		show_dialogue("Tekan 'F' untuk menyapa")

func _on_body_exited(body):
	if body.name == "Player":
		player_in_area = false
		# Jangan sembunyikan gelembung jika player sedang dikunci (sedang dialog)
		if player_node and not player_node.is_locked:
			speech_bubble.visible = false

func _process(_delta):
	if player_in_area and Input.is_action_just_pressed("interact"):
		
		# ====================================================
		# LOGIKA 1: BELUM MULAI (Menerima Quest & Buka Jalan)
		# ====================================================
		if Global.status_misi == "belum_mulai":
			player_node.is_locked = true
			
			if dialogue_step < dialogues.size() - 1:
				show_dialogue(dialogues[dialogue_step] + "\n(F untuk lanjut)")
				dialogue_step += 1
			else:
				show_dialogue(dialogues[dialogue_step])
				player_node.terima_quest("Cari 3 Buku Misterius di Gua")
				
				# 1. Nyalakan musik hutan
				if player_node.bgm_hutan and not player_node.bgm_hutan.playing: 
					player_node.bgm_hutan.play()
				
				# 2. Hancurkan tembok transparan yang menghalangi jalan
				var tembok = get_tree().get_first_node_in_group("tembok_quest")
				if tembok: 
					tembok.queue_free()
				
				# 3. Simpan status ke Global & lepas kunci
				Global.status_misi = "sedang_mencari"
				player_node.is_locked = false

		# ====================================================
		# LOGIKA 2: SEDANG MENCARI (Pesan Pengingat)
		# ====================================================
		elif Global.status_misi == "sedang_mencari":
			show_dialogue("Cepat, Ksatria! Ambil 3 buku sihiritu di dalam gua!")

		# ====================================================
		# LOGIKA 3: SIAP LAPOR (Transisi Ending & Reset Game)
		# ====================================================
		elif Global.status_misi == "siap_lapor" and not ending_dimulai:
			ending_dimulai = true
			player_node.is_locked = true
			
			# 1. Matikan musik hutan, nyalakan musik ending saat itu juga
			if player_node.bgm_hutan and player_node.bgm_hutan.playing: 
				player_node.bgm_hutan.stop()
				
			if player_node.bgm_ending: 
				player_node.bgm_ending.play()
			
			# 2. Dialog Kemenangan
			show_dialogue("Hebat! Kau berhasil merebut buku-bukunya.")
			await get_tree().create_timer(3.5).timeout # Beri waktu pemain untuk membaca
			
			# 3. Dialog Penutup
			show_dialogue("Kutukan penyihir telah patah. Terima kasih, Ksatria!")
			player_node.terima_quest("TAMAT")
			
			# 4. Tunggu sampai lagu ending benar-benar selesai
			await get_tree().create_timer(10.0).timeout
			
			# 5. Reset semua data memori agar bisa main lagi dari awal
			Global.buku_terkumpul = 0
			Global.status_misi = "belum_mulai"
			Global.teks_misi_aktif = ""
			
			print("Menjalankan perintah pindah scene!")
			
			# 6. Kembali ke layar awal (Pastikan nama file start_game.tscn sudah benar!)
			get_tree().change_scene_to_file("res://game_start.tscn")

		# ====================================================
		# LOGIKA 4: SELESAI (Jaga-jaga jika ada delay pindah scene)
		# ====================================================
		elif Global.status_misi == "selesai":
			show_dialogue("Terima kasih sudah menyelamatkan kami, ksatria!")

# Fungsi bantuan untuk memperbarui teks di gelembung
func show_dialogue(text: String):
	speech_bubble.text = text
	speech_bubble.visible = true
