extends CharacterBody2D

# --- VARIABEL YANG BISA DIUBAH DI INSPECTOR ---
@export var speed = 400.0        # Kecepatan jalan
@export var jump_velocity = -250.0 # Kekuatan lompat (semakin minus, semakin tinggi)
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
