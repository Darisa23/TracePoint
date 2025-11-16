extends Node3D

@export var packet_scene: PackedScene  # Arrastra DataPacket.tscn aquí

var source_position: Vector3

func _ready():
	await get_tree().create_timer(1.0).timeout
	
	# Obtener posición del source
	if GameManager.grafo and GameManager.grafo.nodos.size() > 0:
		source_position = GameManager.grafo.nodos[0].posicion_3d

func spawn_paquetes(cantidad: int):
	if not packet_scene:
		push_error("No hay PacketScene asignado")
		return
	
	for i in range(cantidad):
		var paquete = packet_scene.instantiate()
		add_child(paquete)
		
		# Posicionar alrededor del source
		var offset = Vector3(
			randf_range(-1.5, 1.5),
			1.0 + i * 0.5,
			randf_range(-1.5, 1.5)
		)
		paquete.global_position = source_position + offset
		
		print("Paquete spawneado en: ", paquete.global_position)
