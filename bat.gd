extends Node2D # Atau CharacterBody2D, tidak masalah karena dia diam

# Kolom ini akan muncul di Inspector untuk memasukkan file BatBullet.tscn
@export var bullet_scene: PackedScene 
@export var shoot_direction = Vector2.LEFT # Arah tembakan (bisa diubah di Inspector)

@onready var spawn_point = $SpawnPoint
@onready var sprite = $AnimatedSprite2D # Ganti dengan nama sprite-mu jika berbeda

# Hubungkan sinyal 'timeout' dari ShootTimer ke fungsi ini
func _on_shoot_timer_timeout():
	shoot()

func shoot():
	if bullet_scene:
		# 1. Cetak peluru baru
		var bullet = bullet_scene.instantiate()
		
		# 2. Masukkan peluru ke dunia game utama (bukan ke dalam kelelawar)
		get_tree().current_scene.call_deferred("add_child", bullet)
		
		# 3. Atur posisi awal peluru sama dengan posisi mulut kelelawar
		bullet.global_position = spawn_point.global_position
		
		# 4. Beri tahu peluru arah tembakannya
		bullet.direction = shoot_direction
		
		# Opsional: Mainkan animasi nembak sesaat jika punya
		# sprite.play("attack") 

# Fungsi ini akan dipanggil oleh Area2D Trigger nanti
func mulai_nembak():
	if $Timer.is_stopped():
		shoot() # Langsung tembak 1 peluru saat itu juga
		$Timer.start() # Mulai hitungan mundur (ritme 2 detik)
