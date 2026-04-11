extends CharacterBody2D

# ==========================================
# 1. VARIABEL SETTINGS
# ==========================================
@export var speed = 150.0
@export var wander_speed = 50.0 
@export var wander_range = 100.0 
@export var detection_range = 300.0
@export var attack_range = 50.0
@export var health = 3

# ==========================================
# 2. REFERENSI NODE & STATE
# ==========================================
@onready var sprite = $ForestSprite2D

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
		move_and_slide()
		return
	
	if not is_on_floor():
		velocity += get_gravity() * delta

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
		# Hitung jarak musuh saat ini dari titik awal
		var current_distance = global_position.x - start_position.x
		
		# Jika terlalu jauh ke kiri, paksa balik kanan
		if current_distance < -wander_range and wander_direction == -1:
			wander_direction = 1
		# Jika terlalu jauh ke kanan, paksa balik kiri
		elif current_distance > wander_range and wander_direction == 1:
			wander_direction = -1

		velocity.x = wander_direction * wander_speed
		if not is_attacking and not is_hurt:
			sprite.play("run") # Ganti ke "walk" jika kamu punya animasinya
			sprite.flip_h = wander_direction > 0
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
	
	var direction = (player.global_position - global_position).normalized()
	velocity.x = direction.x * speed
	sprite.play("run")
	sprite.flip_h = direction.x > 0

func attack():
	if is_attacking or is_hurt: return
	
	is_attacking = true
	velocity.x = 0
	
	if player:
		sprite.flip_h = player.global_position.x > global_position.x

	sprite.play("attack")
	await sprite.animation_finished
	
	if player and not is_dead:
		if global_position.distance_to(player.global_position) <= attack_range:
			if player.has_method("take_damage"):
				player.take_damage(1)
				
	await get_tree().create_timer(0.5).timeout 
	is_attacking = false

# ==========================================
# 5. FUNGSI NYAWA & DAMAGE
# ==========================================
func take_damage(amount):
	if is_dead or is_hurt: return
	
	health -= amount
	is_hurt = true
	
	velocity.y = -100
	velocity.x = 150 if sprite.flip_h else -150
	
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
