extends CharacterBody2D

# ==========================================
# 1. VARIABEL SETTINGS
# ==========================================
@export var speed = 150.0
@export var detection_range = 300.0
@export var attack_range = 50.0
@export var health = 2

# ==========================================
# 2. REFERENSI NODE & STATE
# ==========================================
@onready var sprite = $ForestSprite2D

var player = null
var is_attacking = false
var is_hurt = false
var is_dead = false

# ==========================================
# 3. FUNGSI BAWAAN GODOT
# ==========================================
func _physics_process(delta):
	if is_dead: return
	
	# Jika terluka, kunci AI agar musuh tidak menyerang balik saat terpental
	if is_hurt:
		if not is_on_floor():
			velocity += get_gravity() * delta
		move_and_slide()
		return
	
	# Gravitasi dasar
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
			idle_behavior()
	else:
		idle_behavior()

	move_and_slide()

# ==========================================
# 4. LOGIKA AI (Perilaku)
# ==========================================
func idle_behavior():
	velocity.x = move_toward(velocity.x, 0, speed)
	if not is_attacking and not is_hurt:
		sprite.play("idle")

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
	
	# FIX MENGHADAP: Paksa musuh nengok ke Player sebelum nyerang
	if player:
		# Jika sprite asli musuhmu menghadap KANAN, gunakan '<'
		# Jika sprite asli musuhmu menghadap KIRI, ganti '<' menjadi '>'
		sprite.flip_h = player.global_position.x > global_position.x

	sprite.play("attack")
	await sprite.animation_finished
	
	# Beri damage jika player masih di dekatnya
	if player and not is_dead:
		if global_position.distance_to(player.global_position) <= attack_range:
			if player.has_method("take_damage"):
				player.take_damage(1)
				
	# FIX DELAY: Tunggu 1.5 detik (cooldown) sebelum bisa nyerang lagi
	await get_tree().create_timer(0.5).timeout 
	is_attacking = false

# ==========================================
# 5. FUNGSI NYAWA & DAMAGE
# ==========================================
func take_damage(amount):
	if is_dead or is_hurt: return
	
	health -= amount
	is_hurt = true
	
	# Efek Knockback Musuh
	velocity.y = -100
	velocity.x = 100 if sprite.flip_h else -100
	
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
