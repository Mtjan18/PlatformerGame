extends CharacterBody2D

# Variabel untuk melacak status misi dan bubble chat
var player_di_dekat_npc = false
var status_misi = "belum_mulai" # Pilihan: "belum_mulai", "sedang_jalan", "selesai"

# Referensi ke node BubbleChat (Label)
@onready var bubble_chat = $BubbleChat # Tanda $ untuk mengambil node anak

func _ready():
	# Pastikan bubble sembunyi di awal
	bubble_chat.visible = false

func _physics_process(delta):
	# Gravitasi sederhana
	if not is_on_floor():
		velocity.y += 800 * delta
	move_and_slide()

# Signal saat Player masuk (Jangan lupa hubungkan di tab Node!)
func _on_area_2d_body_entered(body):
	if body.name == "Player":
		player_di_dekat_npc = true
		
		# TAMPILKAN BUBBLE CHAT
		bubble_chat.visible = true
		
		# (Teks Print tetap biarkan di sini sebagai backup/debugger)
		if status_misi == "belum_mulai":
			print("NPC: Halo! Saya butuh bantuanmu. (Tekan F)")
		elif status_misi == "sedang_jalan":
			print("NPC: Bagaimana pencariannya? (Tekan F)")

func _on_area_2d_body_exited(body):
	if body.name == "Player":
		player_di_dekat_npc = false
		
		# SEMBUNYIKAN BUBBLE CHAT
		bubble_chat.visible = false
		
		print("Sampai jumpa!")

func _input(event):
	if player_di_dekat_npc and event.is_action_pressed("interaksi"):
		# Saat mulai bicara, sembunyikan bubble agar tidak menutupi dialog box nanti
		bubble_chat.visible = false
		mulai_dialog()

func mulai_dialog():
	if status_misi == "belum_mulai":
		print("NPC: Anak muda, sejarah bangsa kita sedang terancam!")
		print("NPC: Pecahan Prasasti Yupa dari Kutai telah hilang tersebar di hutan ini.")
		print("NPC: Bisakah kamu menemukan 3 pecahannya agar kita bisa membaca pesan leluhur?")
		status_misi = "sedang_jalan"
		
	elif status_misi == "sedang_jalan":
		print("NPC: Tetap waspada! Pecahan itu berwarna keemasan dan terkubur di tempat tinggi.")
		print("NPC: Kembalilah jika kamu sudah menemukan semuanya.")
		
	elif status_misi == "selesai":
		print("NPC: Luar biasa! Sejarah Indonesia terselamatkan berkat bantuanmu.")
