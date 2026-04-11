extends CharacterBody2D 

@onready var speech_bubble = $SpeechBubble
# Pastikan kamu punya Label kecil di dalam SpeechBubble untuk hint
# Jika belum, kamu bisa gabungkan saja teksnya menggunakan kode di bawah

var player_in_area = false
var player_node = null
var quest_diberikan = false
var dialogue_step = 0

# Daftar cerita pendek
var dialogues = [
	"Player, syukurlah kau sampai.
	Candi kuno ini sedang dalam bahaya besar.",
	"Legenda menceritakan tentang Genta Suara, 
	pusaka yang menjaga keseimbangan hutan kita.",
	"Getarannya melemah... Jika benda itu hancur, 
	seluruh tempat ini akan terkubur selamanya!",
	"Tolonglah, masuklah ke reruntuhan 
	dan ambilkan Genta Suara itu untukku!",
	"Cepatlah, Player. Waktu kita tidak banyak!"
]

func _ready():
	speech_bubble.visible = false

func _on_body_entered(body):
	if body.name == "Player":
		player_in_area = true
		player_node = body
		if not quest_diberikan:
			show_dialogue("Tekan 'F' untuk bicara")

func _on_body_exited(body):
	if body.name == "Player":
		player_in_area = false
		# Jangan sembunyikan jika sedang bicara (biar tidak kaget)
		if not player_node.is_locked:
			speech_bubble.visible = false

func _process(_delta):
	if player_in_area and Input.is_action_just_pressed("interact"):
		if not quest_diberikan:
			# Kunci pergerakan player
			player_node.is_locked = true
			
			if dialogue_step < dialogues.size() - 1:
				# Tampilkan dialog berurutan dengan hint
				show_dialogue(dialogues[dialogue_step] + "\nTekan F untuk lanjut")
				dialogue_step += 1
			else:
				# Dialog terakhir (Quest diberikan)
				show_dialogue(dialogues[dialogue_step]) # Baris "Cepatlah..."
				player_node.terima_quest("Cari Genta Suara di Reruntuhan")
				
				# Buka jalan
				var tembok = get_tree().get_first_node_in_group("tembok_quest")
				if tembok: tembok.queue_free()
				
				# Lepas kunci pergerakan
				player_node.is_locked = false
				quest_diberikan = true
		else:
			# Jika sudah beres, hanya munculkan pengingat tanpa mengunci player
			show_dialogue(dialogues[dialogues.size() - 1])

func show_dialogue(text: String):
	speech_bubble.text = text
	speech_bubble.visible = true
