extends CharacterBody2D

const SPEED = 300.0

var health = 100

@onready var animated_sprite = $AnimatedSprite2D

var player_bullet_scene = preload("res://escenas/player_bullet.tscn")

var can_shoot = true

var shoot_cooldown = 0.3 

var last_direction = Vector2.RIGHT

func _ready():
	add_to_group("player")

func _physics_process(delta):
	var direction = Vector2.ZERO
	

	if Input.is_key_pressed(KEY_D):
		direction.x += 1
	if Input.is_key_pressed(KEY_A):
		direction.x -= 1
	if Input.is_key_pressed(KEY_S):
		direction.y += 1
	if Input.is_key_pressed(KEY_W):
		direction.y -= 1
	

	direction = direction.normalized()
	

	if direction != Vector2.ZERO:
		last_direction = direction
	

	velocity = direction * SPEED
	move_and_slide()
	

	update_animation(direction)
	

	if Input.is_action_just_pressed("ui_accept") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if can_shoot:
			shoot()

func update_animation(direction):
	if direction != Vector2.ZERO:
		animated_sprite.play("run")
		
		if direction.x > 0:
			animated_sprite.flip_h = false
		elif direction.x < 0:
			animated_sprite.flip_h = true
	else:
		animated_sprite.play("idle")

func shoot():
	can_shoot = false
	var bullet = player_bullet_scene.instantiate()
	get_parent().add_child(bullet)
	var spawn_offset = last_direction * 30.0 
	bullet.global_position = global_position + spawn_offset
	var shoot_direction = get_shoot_direction()
	if bullet.has_method("set_direction"):
		bullet.set_direction(shoot_direction)
	await get_tree().create_timer(shoot_cooldown).timeout
	can_shoot = true

func get_shoot_direction() -> Vector2:
	var mouse_pos = get_global_mouse_position()
	var direction_to_mouse = (mouse_pos - global_position).normalized()
	if global_position.distance_to(mouse_pos) < 20:
		return last_direction
	return direction_to_mouse

func take_damage(amount):
	health -= amount
	print("Jugador recibió ", amount, " de daño. Vida: ", health)
	flash_damage()
	if health <= 0:
		die()

func flash_damage():
	animated_sprite.modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	animated_sprite.modulate = Color.WHITE

func die():
	print("Jugador murió")
