extends CharacterBody2D

# ==========================================
# 1. VARIABEL SETTINGS (Bisa diubah di Inspector)
# ==========================================
@export_group("Movement")
@export var speed = 300.0        
@export var jump_velocity = -350.0 
@export var gravity_multiplier = 1.0 

@export_group("Stats")
@export var max_health = 3
@export var fall_death_limit = 520.0 

# ==========================================
# 2. REFERENSI NODE (UI, Sprite, & Audio)
# ==========================================
@onready var sprite = $PlayerSprite2D
@onready var hitbox = $Hitbox
@onready var hitbox_collision = $Hitbox/CollisionShape2D
@onready var quest_label = $HUD/QuestLabel
@onready var heart_container = $UI/HeartContainer
@onready var bgm_hutan = $BgmHutan
@onready var bgm_ending = $BgmEnding
@onready var lari = $Lari

@onready var sfx_jump = $sfx_jump
@onready var sfx_attack = $sfx_attack
@onready var sfx_hurt = $sfx_hurt

# ==========================================
# 3. STATE MANAGEMENT (Status Karakter)
# ==========================================
var current_health = 3
var is_attacking = false
var is_hurt = false
var is_locked = false

# ==========================================
# 4. FUNGSI BAWAAN GODOT
# ==========================================
func _ready():
	current_health = max_health
	update_health_ui()
	hitbox_collision.set_deferred("disabled", true)
	
	$TutorialBubble.visible = true
	await get_tree().create_timer(3).timeout
	$TutorialBubble.visible = false
	
	# --- PERBAIKAN: Ambil kembali teks misi dari memori Global ---
	if Global.teks_misi_aktif != "":
		quest_label.text = Global.teks_misi_aktif
		quest_label.visible = true

func _physics_process(delta):
	if global_position.y > fall_death_limit:
		if current_health > 0: 
			current_health = 0
			update_health_ui()
			die()
		return

	if is_locked:
		velocity.x = 0
		if not is_on_floor():
			velocity += get_gravity() * gravity_multiplier * delta
		move_and_slide()
		update_animations(0) 
		return
		
	if is_hurt:
		if not is_on_floor():
			velocity += get_gravity() * gravity_multiplier * delta
		move_and_slide()
		return

	if not is_on_floor():
		velocity += get_gravity() * gravity_multiplier * delta

	if is_attacking:
		move_and_slide() 
		return

	# Mekanik Lompat
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		sfx_jump.play() 

	# Mekanik Jalan Kiri/Kanan
	var direction = Input.get_axis("move_left", "move_right")
	if direction != 0:
		velocity.x = direction * speed
		sprite.flip_h = (direction < 0) 
		hitbox.scale.x = -1 if direction < 0 else 1
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		
	if direction != 0 and is_on_floor() and not is_locked and not is_attacking and not is_hurt:
		if not lari.playing:
			lari.play()
	else:
		# Matikan suara jika player berhenti, melompat, atau sedang animasi lain
		if lari.playing:
			lari.stop()

	# Mekanik Serang
	if Input.is_action_just_pressed("attack"):
		attack_sequence()

	update_animations(direction)
	move_and_slide()

# ==========================================
# 5. FUNGSI ANIMASI & COMBAT
# ==========================================
func update_animations(direction):
	if is_attacking or is_hurt: return
	if is_on_floor():
		if direction == 0: sprite.play("idle")
		else: sprite.play("run")
	else:
		if velocity.y < 0: sprite.play("jump")
		else: sprite.play("fall") 

func attack_sequence():
	is_attacking = true
	velocity.x = 0 
	sfx_attack.play() 
	var random_attack_index = randi_range(1, 3)
	sprite.play("attack" + str(random_attack_index))
	hitbox_collision.set_deferred("disabled", false)
	await sprite.animation_finished
	hitbox_collision.set_deferred("disabled", true)
	is_attacking = false

func _on_hitbox_area_entered(area):
	if area.is_in_group("enemy_hurtbox"):
		var target = area.get_parent()
		if not target.has_method("take_damage"): target = area.owner
		if target != null and target.has_method("take_damage"): target.take_damage(1)

# ==========================================
# 6. FUNGSI NYAWA & DAMAGE
# ==========================================
func take_damage(amount: int):
	if is_hurt: return 
	current_health -= amount
	if current_health < 0: current_health = 0
	update_health_ui()
	if current_health > 0: play_hurt_effect()
	else: die()

func play_hurt_effect():
	is_hurt = true
	sfx_hurt.play() 
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
	is_hurt = true 
	sfx_hurt.play() 
	sprite.play("die") 
	await sprite.animation_finished
	get_tree().change_scene_to_file("res://game_over.tscn")

# ==========================================
# 7. FUNGSI INTERAKSI (NPC/QUEST)
# ==========================================
func terima_quest(isi_quest: String):
	# 1. Buat teks lengkapnya
	var teks_lengkap = "- Misi Utama -\n" + isi_quest
	
	# 2. Tampilkan di UI saat ini
	quest_label.text = teks_lengkap
	quest_label.visible = true
	
	# 3. --- PERBAIKAN: Simpan ke Global agar tidak hilang saat pindah scene ---
	Global.teks_misi_aktif = teks_lengkap
