extends StaticBody3D

@export var paquete_scene: PackedScene
@export var cantidad_paquetes: int = 17
@export var filas: int = 5
@export var columnas: int = 5
@export var altura_capas: int = 2
@export var separacion: float = 0.6
@export var espacio_extra: float = 0.1  # separación mínima entre paquete

@export var paquetes_totales: int = 17
@export var separacion_extra: float = 0.02
@export var crear_en_ready: bool = true
@export var forzar_static_para_instanciados: bool = true  # evita que salgan volando al crearlos



func generar_paquetes():
	if paquete_scene == null:
		push_error("Asignar paquete_scene en el inspector (PackedScene).")
		return

	if not has_node("CollisionShape3D"):
		push_error("La plataforma debe tener CollisionShape3D hijo.")
		return
	var col_shape = get_node("CollisionShape3D")
	if not col_shape.shape:
		push_error("CollisionShape3D no tiene shape asignada.")
		return

	# datos plataforma
	var base = global_transform.origin
	var plat_ext = col_shape.shape.extents
	var ancho_plat = plat_ext.x * 2.0
	var prof_plat  = plat_ext.z * 2.0
	var altura_superficie = plat_ext.y
	var base_y = base.y + altura_superficie + 0.01

	# determinar tamaño del paquete leyendo un instance temporal
	var tmp = paquete_scene.instantiate()
	var pkg_ext = Vector3(0.5, 0.5, 0.5) # fallback
	if tmp.has_node("CollisionShape3D") and tmp.get_node("CollisionShape3D").shape:
		pkg_ext = tmp.get_node("CollisionShape3D").shape.extents
	else:
		# intenta detectar como Mesh si no tiene CollisionShape3D
		if tmp.has_node("MeshInstance3D"):
			var bm = tmp.get_node("MeshInstance3D")
			# no es perfecto; se usa el fallback
	tmp.queue_free()

	var ancho_p = pkg_ext.x * 2.0 + separacion_extra
	var prof_p  = pkg_ext.z * 2.0 + separacion_extra
	var alto_p  = pkg_ext.y * 2.0 + separacion_extra

	var cols = max(1, int(ancho_plat / ancho_p))
	var filas = max(1, int(prof_plat / prof_p))
	var total_por_capa = cols * filas
	var capas = int(ceil(float(paquetes_totales) / float(total_por_capa)))

	print("DEBUG PlataformaInstanciada → cols=", cols, " filas=", filas, " capas=", capas)

	var colocados = 0
	for h in range(capas):
		for f in range(filas):
			for c in range(cols):
				if colocados >= paquetes_totales:
					return

				var inst = paquete_scene.instantiate()

				# Si el paquete es RigidBody3D y queremos evitar física al crear:
				#if forzar_static_para_instanciados and inst is RigidBody3D:
				#	inst.mode = RigidBody3D.MODE_STATIC

				var offset_x = (c - (cols - 1) / 2.0) * ancho_p
				var offset_z = (f - (filas - 1) / 2.0) * prof_p
				var offset_y = h * alto_p

				var target_pos = Vector3(base.x + offset_x, base_y + offset_y, base.z + offset_z)
				inst.global_transform = Transform3D(Basis(), target_pos)

				get_parent().add_child(inst)
				colocados += 1
