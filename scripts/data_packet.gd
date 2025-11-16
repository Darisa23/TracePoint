extends Area3D

var recogido: bool = false

func _ready():
	body_entered.connect(_on_body_entered)
	
	# Iniciar animación
	if has_node("AnimationPlayer"):
		$AnimationPlayer.play("float")

func _on_body_entered(body):
	if body.is_in_group("player") and not recogido:
		ser_recogido(body)

func ser_recogido(player):
	recogido = true
	print("Paquete recogido")
	
	# Notificar al player que recogió un paquete
	if player.has_method("recoger_paquete"):
		player.recoger_paquete()
	
	# Animación de recoger (opcional)
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector3.ZERO, 0.3)
	tween.tween_property(self, "position", player.global_position + Vector3(0, 2, 0), 0.3)
	
	await tween.finished
	queue_free()
