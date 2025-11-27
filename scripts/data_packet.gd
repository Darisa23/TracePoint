extends RigidBody3D
@export var icon: Texture   # <- icono para el inventario
signal secayo()
signal llamar_efectos(pos : Vector3)
func _ready():
	# Agregar al grupo
	add_to_group("paquete")
	# Iniciar animación
	#if has_node("AnimationPlayer"):
	#	$AnimationPlayer.play("float")
	
func _process(_delta):
	if global_position.y < -8:
		print("Un Paquete se cayó y se perdió")
		emit_signal("secayo")
		queue_free() 
func animacion_recoger():
	# Desactivar físicas para que no siga rebotando
	freeze = true  
	
	# Crear tween
	var tween = create_tween()
	tween.set_parallel(false)  # Configurar para secuencial
	
	# 1. Movimiento hacia arriba
	tween.tween_property(self, "global_position:y", global_position.y + 0.8, 0.25).set_trans(Tween.TRANS_CUBIC)
	
	# 2. Rotación y escala en paralelo
	tween.set_parallel(true)
	tween.tween_property(self, "rotation_degrees", rotation_degrees + Vector3(0, 360, 0), 0.35)
	tween.tween_property(self, "scale", Vector3.ZERO, 0.35)
	
	# Cuando termine → dispara partículas + texto + borra el paquete
	tween.finished.connect(func():
		emit_signal("llamar_efectos",global_position)
		queue_free()
	)

func animacion_spawn():
	# Aparece congelado y pequeño para no explotar en física
	freeze = true
	scale = Vector3(0.1, 0.1, 0.1)
	
	# Tween de aparición
	var tween = create_tween()

	# 1. Crece y hace una rotación
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector3.ONE, 0.35).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "rotation_degrees", rotation_degrees + Vector3(0, -360, 0), 0.35)

	tween.finished.connect(func():
		# Ya puede caer como objeto normal
		freeze = false
	)
