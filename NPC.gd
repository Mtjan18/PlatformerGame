extends CharacterBody2D 

@onready var speech_bubble = $SpeechBubble

var player_in_area = false
var player_node = null
var quest_diberikan = false

func _ready():
	speech_bubble.visible = false

# Hubungkan signal 'body_entered' dari Area2D ke fungsi ini
func _on_body_entered(body):
	if body.name == "Player":
		player_in_area = true
		player_node = body
		
		if not quest_diberikan:
			speech_bubble.text = "Tekan 'F' untuk bicara"
			speech_bubble.visible = true

# Hubungkan signal 'body_exited' dari Area2D ke fungsi ini
func _on_body_exited(body):
	if body.name == "Player":
		player_in_area = false
		player_node = null
		speech_bubble.visible = false

# Mengecek tombol yang ditekan setiap frame
func _process(delta):
	# Pastikan kamu sudah mendaftarkan tombol F dengan nama "interact" di Project Settings > Input Map
	if player_in_area and Input.is_action_just_pressed("interact"): 
		if not quest_diberikan:
			# Ubah teks di atas kepala NPC
			speech_bubble.text = "Cari Genta Suara di\ndalam reruntuhan!"
			
			# Kirim quest ke Player
			player_node.terima_quest("Temukan Artefak Genta Suara")
			
			quest_diberikan = true
		else:
			# Teks jika pemain mengajak bicara lagi
			speech_bubble.text = "Semoga berhasil, Marchel!"
