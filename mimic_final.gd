extends CharacterBody2D

# Status Mimic
var hp = 5
var is_dead = false

# Memuat scene item dan darah (Pastikan path res:// sudah benar)
@onready var scene_darah = preload("res://efek_darah.tscn")
@onready var scene_item = preload("res://item_final.tscn") # Menggunakan nama scene item1

func _physics_process(delta):
	if is_dead:
		return
		
	if not is_on_floor():
		velocity.y += 800 * delta
	move_and_slide()

func take_damage(jumlah):
	if is_dead: return

	hp -= jumlah
	munculkan_efek_darah()

	if hp <= 0:
		mati()

func munculkan_efek_darah():
	var darah = scene_darah.instantiate()
	get_parent().add_child(darah)
	darah.global_position = self.global_position

func mati():
	is_dead = true
	print("Mimic Kalah!")
	
	# 1. Nonaktifkan Hurtbox (Sudah benar)
	$Hurtbox/CollisionShape2D.set_deferred("disabled", true)
	
	# 2. Mainkan Animasi Mati
	$AnimatedSprite2D.play("dead")
	
	# 3. Jatuhkan Item (DIUBAH DISINI)
	var item = scene_item.instantiate()
	## Gunakan call_deferred agar tidak bentrok dengan proses fisika
	get_parent().call_deferred("add_child", item)
	#
	## Karena add_child ditunda, kita juga harus sedikit menunda setting posisinya
	## atau set posisinya sebelum dimasukkan ke tree (lebih aman)
	item.global_position = global_position - Vector2(0, 20)
	
	# 4. Berubah Menjadi Peti Terbuka
	await get_tree().create_timer(1.5).timeout
	$AnimatedSprite2D.play("open")
	
	# Matikan collision utama peti (Sudah benar)
	$CollisionShape2D.set_deferred("disabled", true)
