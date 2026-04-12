extends Area2D

var speed = 250.0
var direction = Vector2.LEFT # Default nembak ke kiri

func _physics_process(delta):
	# Menggerakkan peluru setiap frame
	position += direction * speed * delta

# Hubungkan sinyal 'body_entered' dari Area2D ke fungsi ini
func _on_body_entered(body):
	if body.name == "Player":
		if body.has_method("take_damage"):
			body.take_damage(1)
		queue_free() # Peluru hancur setelah mengenai player
	elif body.name != "Bat": # Jika kena lantai/tembok (selain kelelawar itu sendiri)
		queue_free()

# Hubungkan sinyal 'screen_exited' dari VisibleOnScreenNotifier2D ke fungsi ini
func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free() # Peluru otomatis hancur jika keluar dari layar pemain
