extends CharacterBody2D

const SPEED = 150.0
const DETECTION_RANGE = 500.0
const SAFE_DISTANCE = 250.0
const TOO_CLOSE = 150.0
signal boss_defeated
const MAX_HEALTH = 1100
var current_health = MAX_HEALTH

enum State { IDLE, PATROL, CHASE, ATTACK, RETREAT }
var current_state = State.IDLE

@onready var animated_sprite = $AnimatedSprite2D
@onready var shoot_timer = $ShootTimer
@onready var navigation_agent = $NavigationAgent2D
@onready var health_bar = $HealthBar
@onready var health_bar_fill = $HealthBar/Fill

var player = null
var player_detected = false

var patrol_points = []
var current_patrol_index = 0
var patrol_wait_time = 0.0

var bullet_scene = preload("res://escenas/bullet.tscn")

func _ready():
	shoot_timer.wait_time = 2.0
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	
	navigation_agent.path_desired_distance = 10.0
	navigation_agent.target_desired_distance = 10.0
	
	call_deferred("setup_player")
	
	generate_patrol_points()
	
	update_health_bar()
	add_to_group("enemy")

func setup_player():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

func generate_patrol_points():
	for i in range(4):
		var random_offset = Vector2(
			randf_range(-300, 300),
			randf_range(-300, 300)
		)
		patrol_points.append(global_position + random_offset)

func _physics_process(delta):
	if player == null:
		return
	
	var distance_to_player = global_position.distance_to(player.global_position)
	
	update_state(distance_to_player)
	
	match current_state:
		State.IDLE:
			handle_idle(delta)
		State.PATROL:
			handle_patrol(delta)
		State.CHASE:
			handle_chase(delta)
		State.ATTACK:
			handle_attack(delta)
		State.RETREAT:
			handle_retreat(delta)
	
	move_using_navigation(delta)

func update_state(distance: float):
	if distance < TOO_CLOSE:
		current_state = State.RETREAT
	elif distance < SAFE_DISTANCE:
		current_state = State.ATTACK
	elif distance < DETECTION_RANGE:
		current_state = State.CHASE
	else:
		if current_state != State.PATROL:
			current_state = State.PATROL

func handle_idle(delta):
	animated_sprite.play("idle")
	patrol_wait_time += delta
	if patrol_wait_time > 2.0:
		current_state = State.PATROL
		patrol_wait_time = 0.0

func handle_patrol(delta):
	animated_sprite.play("run")
	
	if patrol_points.size() == 0:
		return
	
	var target = patrol_points[current_patrol_index]
	navigation_agent.target_position = target
	
	if global_position.distance_to(target) < 20.0:
		current_patrol_index = (current_patrol_index + 1) % patrol_points.size()
		current_state = State.IDLE

func handle_chase(delta):
	animated_sprite.play("run")
	navigation_agent.target_position = player.global_position

func handle_attack(delta):
	animated_sprite.play("idle")
	
	velocity = velocity.move_toward(Vector2.ZERO, SPEED * delta * 5)
	
	if shoot_timer.is_stopped():
		shoot_timer.start()
	
	look_at_player()

func handle_retreat(delta):
	animated_sprite.play("run")
	
	var direction_away = (global_position - player.global_position).normalized()
	var retreat_position = global_position + direction_away * 200.0
	navigation_agent.target_position = retreat_position

func move_using_navigation(delta):
	if navigation_agent.is_navigation_finished():
		velocity = velocity.move_toward(Vector2.ZERO, SPEED * delta * 5)
		move_and_slide()
		return
	
	var next_path_position = navigation_agent.get_next_path_position()
	var direction = (next_path_position - global_position).normalized()
	
	velocity = direction * SPEED
	move_and_slide()
	
	if direction.x != 0:
		animated_sprite.flip_h = direction.x < 0

func look_at_player():
	if player.global_position.x < global_position.x:
		animated_sprite.flip_h = true
	else:
		animated_sprite.flip_h = false

func _on_shoot_timer_timeout():
	if current_state == State.ATTACK and player != null:
		shoot()

func shoot():
	animated_sprite.play("shoot")
	
	var bullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)
	
	bullet.global_position = global_position
	
	var direction = (player.global_position - global_position).normalized()
	
	if bullet.has_method("set_direction"):
		bullet.set_direction(direction)
	
	await get_tree().create_timer(0.5).timeout
	if current_state == State.ATTACK:
		animated_sprite.play("idle")

func take_damage(amount: int):
	current_health -= amount
	current_health = max(0, current_health)
	
	update_health_bar()
	
	flash_damage()
	
	print("Boss recibió ", amount, " de daño. Vida: ", current_health, "/", MAX_HEALTH)
	
	if current_health <= 0:
		die()

func update_health_bar():
	var health_percentage = float(current_health) / float(MAX_HEALTH)
	health_bar_fill.scale.x = health_percentage
	
	if health_percentage > 0.6:
		health_bar_fill.modulate = Color.GREEN
	elif health_percentage > 0.3:
		health_bar_fill.modulate = Color.YELLOW
	else:
		health_bar_fill.modulate = Color.RED

func flash_damage():
	animated_sprite.modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	animated_sprite.modulate = Color.WHITE

func die():
	boss_defeated.emit()
	queue_free()
