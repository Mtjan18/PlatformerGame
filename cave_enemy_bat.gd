extends CharacterBody2D

# ==========================================
# 1. VARIABEL SETTINGS
# ==========================================
@export var speed = 200.0
@export var detection_range = 400.0
@export var attack_range = 40.0
@export var health = 2
@export var descend_speed = 150.0 # Kecepatan turun saat bangun

# ==========================================
# 2. REFERENSI NODE & STATE
# ==========================================
@onready var sprite = $BatSprite2D

enum State { SLEEP, WAKE, CHASE, ATTACK, IDLE, HURT, DIE }
var current_state = State.SLEEP

var player = null
var is_dead = false

# ==========================================
# 3. FUNGSI BAWAAN GODOT
# ==========================================
func _physics_process(delta):
	if current_state == State.DIE: return
	
	match current_state:
		State.SLEEP:
			velocity = Vector2.ZERO
			sprite.play("sleep")
			check_for_player()
			
		State.CHASE:
			chase_behavior(delta)
			
		State.IDLE:
			velocity.x = move_toward(velocity.x, 0, speed * delta)
			velocity.y = move_toward(velocity.y, 0, speed * delta)
			sprite.play("idle")
			check_for_player()

	move_and_slide()

# ==========================================
# 4. LOGIKA PERILAKU (AI)
# ==========================================

func check_for_player():
	if player:
		var dist = global_position.distance_to(player.global_position)
		if dist <= detection_range:
			if current_state == State.SLEEP:
				start_wake_up()
			elif current_state == State.IDLE:
				current_state = State.CHASE

func start_wake_up():
	current_state = State.WAKE
	sprite.play("wake")
	await sprite.animation_finished
	current_state = State.CHASE

func chase_behavior(delta):
	if not player or current_state == State.HURT: return
	
	var target_pos = player.global_position
	var direction = (target_pos - global_position).normalized()
	
	# 1. Pergerakan X (Mengejar Horizontal)
	velocity.x = direction.x * speed
	
	# 2. Pergerakan Y (Menyamakan Ketinggian dengan Player secara halus)
	# Kita gunakan move_toward agar dia turun perlahan, tidak langsung 'teleport'
	velocity.y = move_toward(velocity.y, direction.y * speed, descend_speed * delta * 10)
	
	sprite.play("fly")
	sprite.flip_h = direction.x < 0 # Bat hadap kiri default? Sesuaikan jika terbalik
	
	# Cek Jarak Serang
	if global_position.distance_to(target_pos) <= attack_range:
		attack()

func attack():
	if current_state == State.ATTACK or current_state == State.HURT: return
	
	current_state = State.ATTACK
	velocity = Vector2.ZERO
	
	var attack_anim = "attack" + str(randi_range(1, 2))
	sprite.play(attack_anim)
	
	# Impact Frame (Damage dikirim di tengah animasi)
	await get_tree().create_timer(0.2).timeout
	if player and global_position.distance_to(player.global_position) <= attack_range + 10:
		if player.has_method("take_damage"):
			player.take_damage(1)
			
	await sprite.animation_finished
	current_state = State.CHASE

# ==========================================
# 5. FUNGSI DAMAGE & SINYAL
# ==========================================

func take_damage(amount):
	if is_dead: return
	health -= amount
	current_state = State.HURT
	
	# Knockback sedikit
	velocity = (global_position - player.global_position).normalized() * 200
	sprite.play("hurt")
	
	await sprite.animation_finished
	
	if health <= 0:
		die()
	else:
		current_state = State.CHASE

func die():
	is_dead = true
	current_state = State.DIE
	sprite.play("die")
	
	# Saat mati, kelelawar jatuh ke tanah karena gravitasi
	set_collision_mask_value(1, true) # Aktifkan tabrakan dengan lantai
	velocity.y = 100 
	
	await sprite.animation_finished
	queue_free()

func _on_detection_area_body_entered(body):
	if body.is_in_group("Player"):
		player = body

func _on_detection_area_body_exited(body):
	if body.is_in_group("Player"):
		# Jika player keluar radius, dia berhenti mengejar dan jadi idle
		if current_state != State.SLEEP:
			current_state = State.IDLE
		player = null
