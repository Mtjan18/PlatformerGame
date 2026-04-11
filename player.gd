extends CharacterBody2D

# ==========================================
# 1. VARIABEL SETTINGS (Bisa diubah di Inspector)
# ==========================================
@export_group("Movement")
@export var speed = 400.0        
@export var jump_velocity = -350.0 
@export var gravity_multiplier = 1.0 

@export_group("Stats")
@export var max_health = 3

# ==========================================
# 2. REFERENSI NODE (UI & Sprite)
# ==========================================
@onready var sprite = $PlayerSprite2D
@onready var hitbox = $Hitbox
@onready var hitbox_collision = $Hitbox/CollisionShape2D
@onready var quest_label = $HUD/QuestLabel
@onready var heart_container = $UI/HeartContainer

# ==========================================
# 3. STATE MANAGEMENT (Status Karakter)
# ==========================================
var current_health = 3
var is_attacking = false
var is_hurt = false

# ==========================================
# 4. FUNGSI BAWAAN GODOT
# ==========================================
func _ready():
	current_health = max_health
	update_health_ui()
	current_health = max_health
	update_health_ui()
	# Matikan pedang saat game baru mulai
	hitbox_collision.set_deferred("disabled", true)

func _physics_process(delta):
	# Jika sedang terluka, kunci kontrol dan terapkan gravitasi (efek terpental)
	if is_hurt:
		if not is_on_floor():
			velocity += get_gravity() * gravity_multiplier * delta
		move_and_slide()
		return

	# Gravitasi normal
	if not is_on_floor():
		velocity += get_gravity() * gravity_multiplier * delta

	# Kunci pergerakan jika sedang menyerang
	if is_attacking:
		move_and_slide() 
		return

	# Mekanik Lompat
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Mekanik Jalan Kiri/Kanan
	var direction = Input.get_axis("move_left", "move_right")
	if direction != 0:
		velocity.x = direction * speed
		sprite.flip_h = (direction < 0) 
		# --- TAMBAHAN BARU: Balik arah hitbox pedang ---
		hitbox.scale.x = -1 if direction < 0 else 1
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	# Mekanik Serang
	if Input.is_action_just_pressed("attack"):
		attack_sequence()

	# Update Animasi & Terapkan Pergerakan
	update_animations(direction)
	move_and_slide()

# ==========================================
# 5. FUNGSI ANIMASI & COMBAT
# ==========================================
func update_animations(direction):
	if is_attacking or is_hurt: return

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
	velocity.x = 0 # TAMBAHKAN INI: Hentikan laju pemain seketika
	
	var random_attack_index = randi_range(1, 3)
	sprite.play("attack" + str(random_attack_index))
	
	hitbox_collision.set_deferred("disabled", false)
	await sprite.animation_finished
	hitbox_collision.set_deferred("disabled", true)
	
	is_attacking = false

# Saat pedang Player (Hitbox) mengenai Musuh (Hurtbox)
func _on_hitbox_area_entered(area):
	if area.is_in_group("enemy_hurtbox"):
		# Cek apakah musuh punya fungsi take_damage agar game tidak crash
		if area.get_parent().has_method("take_damage"):
			area.get_parent().take_damage(1)

# ==========================================
# 6. FUNGSI NYAWA & DAMAGE
# ==========================================
func take_damage(amount: int):
	if is_hurt: return # Hindari kena damage double dalam satu waktu
	
	current_health -= amount
	if current_health < 0:
		current_health = 0
		
	update_health_ui()
	
	if current_health > 0:
		play_hurt_effect()
	else:
		die()

func play_hurt_effect():
	is_hurt = true
	
	# Efek Knockback: Terpental ke belakang dan sedikit ke atas
	velocity.y = -150 
	velocity.x = 200 if sprite.flip_h else -200 
	
	sprite.play("hurt")
	await sprite.animation_finished
	is_hurt = false

func update_health_ui():
	var hearts = heart_container.get_children()
	for i in range(hearts.size()):
		hearts[i].visible = (i < current_health)

func die():
	is_hurt = true # Kunci agar mayat tidak bisa digerakkan
	sprite.play("die") # Pastikan kamu punya animasi "die"
	await sprite.animation_finished
	
	get_tree().change_scene_to_file("res://game_over.tscn")

# ==========================================
# 7. FUNGSI INTERAKSI (NPC/QUEST)
# ==========================================
func terima_quest(isi_quest: String):
	quest_label.text = "- Misi Utama -\n" + isi_quest
	quest_label.visible = true
