extends CharacterBody2D

# --- VARIABEL YANG BISA DIUBAH DI INSPECTOR ---
@export var speed = 250.0        # Kecepatan jalan
@export var jump_velocity = -430.0 # Kekuatan lompat (semakin minus, semakin tinggi)
@export var gravity_multiplier = 1.0 # Pengali gravitasi (opsional)

# --- REFERENSI KE NODE ANAK ---
@onready var sprite = $PlayerSprite2D

# --- STATE MANAGEMENT ---
var is_attacking = false

func _physics_process(delta):
	# 1. Menangani Gravitasi (Hanya berlaku jika tidak di lantai)
	if not is_on_floor():
		# get_gravity() mengambil nilai gravitasi default dari Project Settings
		velocity += get_gravity() * gravity_multiplier * delta

	# 2. Jika sedang menyerang, kunci pergerakan
	if is_attacking:
		move_and_slide() # Tetap jalankan collision agar tidak tembus tembok
		return

	# 3. Menangani Lompatan (Hanya bisa lompat jika di lantai)
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# 4. Input Gerakan Kiri/Kanan
	var direction = Input.get_axis("move_left", "move_right")
	
	if direction != 0:
		velocity.x = direction * speed
		sprite.flip_h = (direction < 0) # Balik badan jika ke kiri
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	# 5. Input Serang
	if Input.is_action_just_pressed("attack"):
		attack_sequence()

	# 6. Menangani Animasi
	update_animations(direction)

	# 7. Eksekusi Pergerakan Akhir
	move_and_slide()
	
	# 8. Cek apakah kena duri setelah bergerak
	check_spike_collision()

# --- FUNGSI KHUSUS UNTUK ANIMASI ---
func update_animations(direction):
	# Jika sedang menyerang, jangan ubah animasi
	if is_attacking: return

	if is_on_floor():
		if direction == 0:
			sprite.play("idle")
		else:
			sprite.play("run")
	else:
		if velocity.y < 0:
			sprite.play("jump")
		else:
			sprite.play("fall") 

func attack_sequence():
	is_attacking = true
	var random_attack_index = randi_range(1, 3)
	var attack_name = "attack" + str(random_attack_index)
	
	sprite.play(attack_name)
	
	# Tunggu sampai animasi selesai (Pastikan animasi attack tidak di-loop)
	await sprite.animation_finished
	
	is_attacking = false
	
	
# --- DETEKSI DURI/SPIKE ---
func check_spike_collision():
	# Pastikan nama node di sini sama dengan nama di Scene Tree kamu (misal: "spike_tilemap")
	var spike_map = get_parent().get_node("spike_tilemap") 
	
	if spike_map:
		# 1. Ambil posisi ubin (Cell) berdasarkan posisi ksatria
		var tile_pos = spike_map.local_to_map(global_position)
		
		# 2. Ambil data ubin (Gunakan 2 argumen untuk TileMapLayer atau 3 untuk TileMap lama)
		# Untuk Godot 4.3+, biasanya cukup: spike_map.get_cell_tile_data(tile_pos)
		# Jika error 3 argumen muncul, gunakan ini:
		var tile_data = spike_map.get_cell_tile_data(0, tile_pos) # Angka 0 adalah Layer ke-1
		# 3. Cek apakah ubin tersebut berbahaya
		if tile_data:
			var is_danger = tile_data.get_custom_data("is_dangerous")
			if is_danger:
				die()

func die():
	print("Ksatria terkena duri!")
	# Restart level atau kurangi darah di sini
	get_tree().reload_current_scene()
	
