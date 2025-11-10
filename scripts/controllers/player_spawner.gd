extends Node
# Adjunta este script como hijo de tu Player o al mismo Player

@export var altura_spawn: float = 2.0
@export var proteccion_caida: bool = true

var player: CharacterBody3D

func _ready():
	# Obtener referencia al player (padre o este mismo nodo)
	if get_parent() is CharacterBody3D:
		player = get_parent()
	elif owner is CharacterBody3D:
		player = owner
	
	# Esperar a que todo esté listo
	await get_tree().create_timer(0.5).timeout
	reposicionar_en_nodo_inicial()

func _physics_process(_delta):
	# Protección contra caídas al vacío
	if proteccion_caida and player and player.global_position.y < -10:
		print("Player cayó! Reposicionando...")
		reposicionar_en_nodo_inicial()

func reposicionar_en_nodo_inicial():
	if not player:
		return
	
	# Intentar obtener la posición del primer nodo del grafo
	if GameManager.grafo and GameManager.grafo.nodos.size() > 0:
		var pos_spawn = GameManager.grafo.nodos[0].posicion_3d + Vector3(0, altura_spawn, 0)
		player.global_position = pos_spawn
		
		# Resetear física
		if "velocity" in player:
			player.velocity = Vector3.ZERO
		
		print("Player reposicionado en: ", pos_spawn)
	else:
		# Posición de respaldo
		player.global_position = Vector3(0, altura_spawn, 0)
		print("No hay grafo, usando posición por defecto")
