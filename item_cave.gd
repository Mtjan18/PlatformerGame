extends Area2D

var waktu = 0.0
var posisi_awal_y = 0.0

func _ready():
	posisi_awal_y = position.y

func _process(delta):
	waktu += delta * 4.0
	position.y = posisi_awal_y + sin(waktu) * 5.0

func _on_body_entered(body):
	if body.has_method("terima_quest"):
		print("Genta Suci diambil!")
		# Narasi: Mengarahkan ke item terakhir yang masih di dalam Goa
		body.terima_quest("Misi: Cari Pusaka Tersembunyi di Kedalaman Goa!")
		queue_free()
