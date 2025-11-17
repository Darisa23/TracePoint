extends Node3D
@onready var label = $Label3D

func spawn_text(pos: Vector3):
	label.visible = true
	label.global_position = pos

	# Restablece el alpha en caso de que esté en 0
	label.modulate.a = 1.0

	var tween = create_tween()
	tween.tween_property(label, "position:y", label.position.y + 1.5, 0.7)
	tween.tween_property(label, "modulate:a", 0.0, 0.7)

	# En vez de destruirlo → lo escondemos
	tween.finished.connect(func():
		label.visible = false
		# También puedes resetear posición si quieres
		label.position.y -= 1.5
	)
