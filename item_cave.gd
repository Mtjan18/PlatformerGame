extends Area2D

# Variabel untuk efek melayang
var waktu = 0.0
var posisi_awal_y = 0.0

func _ready():
	# Menyimpan posisi Y awal saat item diletakkan di dalam Goa
	posisi_awal_y = position.y

func _process(delta):
	# Efek item melayang naik-turun dengan mulus
	waktu += delta * 4.0
	position.y = posisi_awal_y + sin(waktu) * 5.0

func _on_body_entered(body):
	# Cek apakah yang menyentuh punya fungsi 'terima_quest' (yaitu Player)
	if body.has_method("terima_quest"):
		print("Genta Suci berhasil diambil!")
		
		# Update misi di UI Player
		# Kamu bisa mengganti teks ini sesuai alur ceritamu selanjutnya
		body.terima_quest("Misi Selesai: Kembali ke Desa dan temui Kepala Desa!")
		
		# (OPSIONAL) Jika kamu mau langsung memunculkan layar menang:
		# get_tree().change_scene_to_file("res://win_screen.tscn")
		
		# Hapus item dari Goa karena sudah masuk kantong
		queue_free()
