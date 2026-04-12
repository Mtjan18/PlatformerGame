extends CharacterBody2D

# ==========================================
# 1. VARIABEL SETTINGS
# ==========================================
@export var speed = 100.0
@export var wander_speed = 50.0 
@export var wander_range = 100.0 
@export var detection_range = 300.0
@export var attack_range = 50.0
@export var health = 6

# ==========================================
# 2. REFERENSI NODE & STATE
# ==========================================
@onready var sprite = $GolemSprite2D
@onready var edge_detector = $EdgeDetector

var player = null
var is_attacking = false
var is_hurt = false
var is_dead = false

# --- VARIABEL BARU UNTUK PATROLI ---
var start_position: Vector2
var wander_direction: int = 0
var wander_timer: float = 0.0

# ==========================================
# 3. FUNGSI BAWAAN GODOT
# ==========================================
func _ready():
	# Rekam posisi awal musuh saat game baru dimulai
	start_position = global_position
	# Pancing AI untuk langsung mulai mengacak pergerakan
	pick_random_wander()

func _physics_process(delta):
	if is_dead: return
	
	if is_hurt:
		if not is_on_floor():
			velocity += get_gravity() * delta
		else:
			velocity.x = move_toward(velocity.x, 0, 300 * delta)
			
		move_and_slide()
		return
	
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	edge_detector.position.x = -20 if sprite.flip_h else 20

	# Logika AI Musuh
	if player:
		var distance = global_position.distance_to(player.global_position)
		
		if distance <= attack_range:
			attack()
		elif distance <= detection_range:
			chase_player()
		else:
			wander_behavior(delta)
	else:
		wander_behavior(delta)

	move_and_slide()

# ==========================================
# 4. LOGIKA AI (Perilaku)
# ==========================================

# --- FUNGSI BARU UNTUK PATROLI ---
func wander_behavior(delta):
	wander_timer -= delta
	
	# Jika waktu habis, pilih aksi baru (diam, ke kiri, atau ke kanan)
	if wander_timer <= 0:
		pick_random_wander()

	if wander_direction != 0:
		var current_distance = global_position.x - start_position.x
		
		# --- CEK JURANG SAAT PATROLI ---
		if not edge_detector.is_colliding() and is_on_floor():
			wander_direction *= -1 
		elif current_distance < -wander_range and wander_direction == -1:
			wander_direction = 1
		elif current_distance > wander_range and wander_direction == 1:
			wander_direction = -1

		velocity.x = wander_direction * wander_speed
		if not is_attacking and not is_hurt:
			sprite.play("walk")
			sprite.flip_h = wander_direction < 0
	else:
		# Jika sedang memilih aksi diam
		velocity.x = move_toward(velocity.x, 0, speed)
		if not is_attacking and not is_hurt:
			sprite.play("idle")

# --- FUNGSI MENGACAK AKSI ---
func pick_random_wander():
	# Menghasilkan angka acak: -1 (kiri), 0 (diam), atau 1 (kanan)
	var random_choice = randi() % 3 - 1
	wander_direction = random_choice
	
	# Acak durasi aksi tersebut (antara 1 sampai 3 detik)
	wander_timer = randf_range(1.0, 3.0)

func chase_player():
	if is_attacking or is_hurt: return
	
	if not edge_detector.is_colliding() and is_on_floor():
		velocity.x = 0
		sprite.play("idle") 
		return
	
	var direction = (player.global_position - global_position).normalized()
	velocity.x = direction.x * speed
	sprite.play("walk")
	sprite.flip_h = direction.x < 0

func attack():
	if is_attacking or is_hurt: return
	
	is_attacking = true
	velocity.x = 0
	
	if player:
		sprite.flip_h = player.global_position.x < global_position.x

	# 1. MULAI ANIMASI SERANGAN
	sprite.play("attack")
	
	# 2. TUNGGU SEBENTAR SAMPAI TITIK PUKULAN (IMPACT FRAME)
	# Ubah angka 0.3 ini agar pas dengan gambar pukulan musuhmu!
	await get_tree().create_timer(0.7).timeout 
	
	# 3. BERIKAN DAMAGE
	if player and not is_dead:
		if global_position.distance_to(player.global_position) <= attack_range:
			if player.has_method("take_damage"):
				player.take_damage(1)
				
	# 4. TUNGGU SISA ANIMASINYA SELESAI
	await sprite.animation_finished
	
	# 5. JEDA SEBELUM BISA NYERANG LAGI (COOLDOWN)
	await get_tree().create_timer(1).timeout 
	is_attacking = false

# ==========================================
# 5. FUNGSI NYAWA & DAMAGE
# ==========================================
func take_damage(amount):
	if is_dead or is_hurt: return
	
	health -= amount
	is_hurt = true
	
	velocity.y = -100
	velocity.x = 50 if sprite.flip_h else -50
	
	sprite.play("hurt")
	await sprite.animation_finished
	
	is_hurt = false
	
	if health <= 0:
		die()

func die():
	is_dead = true
	velocity.x = 0
	sprite.play("die")
	await sprite.animation_finished
	queue_free() 

# ==========================================
# 6. SIGNAL DETEKSI PLAYER
# ==========================================
func _on_detection_area_body_entered(body):
	if body.is_in_group("Player"):
		player = body

func _on_detection_area_body_exited(body):
	if body.is_in_group("Player"):
		player = null
