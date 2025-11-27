extends Area2D

const SPEED = 500.0
var direction = Vector2.ZERO
var damage = 20

func _ready():
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	
	await get_tree().create_timer(3.0).timeout
	queue_free()

func set_direction(new_direction: Vector2):
	direction = new_direction.normalized()
	rotation = direction.angle()

func _physics_process(delta):
	position += direction * SPEED * delta

func _on_body_entered(body):
	if body.is_in_group("enemy"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free()
	elif body is TileMap or body is StaticBody2D:
		queue_free()

func _on_area_entered(area):
	if area.is_in_group("enemy_bullet"):
		queue_free()
