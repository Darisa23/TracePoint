extends Node

# Referencias
@export var paquete_scene: PackedScene  # Arrastra DataPacket.tscn aquí
@export var plataforma_inicial: StaticBody3D  # Arrastra tu plataforma desde el editor
@onready var ParticlesManager = $"../ParticlesManeger"
@onready var FloatingLabels = $"../FloatingLabels"
var player: CharacterBody3D

# Nodos especiales
var source_nodo: Nodo
var sink_nodo: Nodo

# Estado del juego
var flujo_objetivo: int = 0  # Se calcula desde GameManager
var paquetes_totales: int = 0
var paquetes_en_plataforma: int = 0
var paquetes_entregados_sink: int = 0
var paquetes_perdidos: int = 0
var max_paquetes_perdidos: int = 3
var id_nodo_ac:int = 0
var juego_activo: bool = false
var en_nodo: bool = false
# Popups de nodos
var popup_actual: Control = null
var iniciado : bool = false
# Señales
signal flujo_actualizado(entregados: int, objetivo: int)
signal paquetes_perdidos_actualizado(perdidos: int, max: int)
signal nivel_completado()
signal nivel_fallido()
signal entrega(id:int)
signal sacar(id:int)




func inicializar_nivel():
	
	if not GameManager.grafo:
		push_error("No hay grafo cargado para nivel 4")
		return
	
	# Obtener datos del GameManager
	flujo_objetivo = GameManager.flujo_maximo_calculado
	paquetes_totales = flujo_objetivo + max_paquetes_perdidos
	paquetes_en_plataforma = paquetes_totales
	
	player = GameManager.player
	player.soltar_paquete.connect(_soltar_paquete)
	player.recoger_pack.connect(_recoger_pack)
	source_nodo = GameManager.grafo.nodos[0]
	sink_nodo = GameManager.grafo.nodos[3]
	
	print("Nivel 4 Flow Control inicializado")
	print("  Flujo objetivo: %d" % flujo_objetivo)
	print("  Paquetes totales: %d" % paquetes_totales)
	print("  SOURCE: Nodo %d" % source_nodo.id)
	print("  SINK: Nodo %d" % sink_nodo.id)
	
	# Configurar capacidades de nodos
	#configurar_capacidades_nodos()
	
	# Marcar visualmente source y sink
	marcar_nodos_especiales()
	
	# Posicionar player en la plataforma
	posicionar_player_plataforma()
	
	# Crear paquetes en la plataforma
	crear_paquetes_en_plataforma()
	
	# Agregar detectores en todos los nodos
	agregar_detectores_nodos()
	
	# Conectar input del player para recoger paquetes
	if player:
		player.set_meta("flow_manager", self)
	
	juego_activo = true

func configurar_capacidades_nodos():
	for nodo in GameManager.grafo.nodos:
		var capacidad = GameManager.capacidades_nodos.get(nodo.id, 0)
		if nodo.nodo_visual and capacidad > 0:
			nodo.nodo_visual.configurar_capacidad(capacidad)

func marcar_nodos_especiales():
	# SOURCE verde
	if source_nodo.nodo_visual:
		source_nodo.nodo_visual.material.albedo_color = Color.GREEN
		source_nodo.nodo_visual.material.emission_enabled = true
		source_nodo.nodo_visual.material.emission = Color.GREEN
		source_nodo.nodo_visual.material.emission_energy = 2.0
	
	# SINK azul
	if sink_nodo.nodo_visual:
		sink_nodo.nodo_visual.material.albedo_color = Color.BLUE
		sink_nodo.nodo_visual.material.emission_enabled = true
		sink_nodo.nodo_visual.material.emission = Color.BLUE
		sink_nodo.nodo_visual.material.emission_energy = 2.0

func posicionar_player_plataforma():
	if not plataforma_inicial:
		push_error("No hay plataforma asignada en FlowManager")
		return
	
	if player:
		# Posicionar encima de la plataforma
		player.global_position = plataforma_inicial.global_position + Vector3(0, 3, 0)
		if "velocity" in player:
			player.velocity = Vector3.ZERO
		#print("Player posicionado en plataforma: ", player.global_position)

func crear_paquetes_en_plataforma():
	if not paquete_scene:
		push_error("No hay paquete_scene asignado en FlowManager")
		return
	
	if not plataforma_inicial or not is_instance_valid(plataforma_inicial):
		push_error("Plataforma no válida")
		return
	
	if not plataforma_inicial.is_inside_tree():
		await plataforma_inicial.ready
	
	#print("Creando %d paquetes en plataforma..." % paquetes_totales)
	plataforma_inicial.position = Vector3(-3, -6.6, 5)
	var pbe = plataforma_inicial.position + Vector3(0, 0.8, 0)
	#print("  Posición base: ", pbe)
	# Tomamos posición global real de la plataforma
	#var base = plataforma_inicial.global_transform.origin

	# Un poquito por encima para que caigan
	var pos_base =  Vector3(-8, 3.5, -3)

	#print("   Base real plataforma:", pbe)
	#print("   Pos base spawn paquetes:", pos_base)

	for i in range(paquetes_totales):
		await get_tree().create_timer(0.101).timeout
		var paquete = paquete_scene.instantiate()
		paquete.llamar_efectos.connect(_on_llamar_efectos)
		plataforma_inicial.get_parent().add_child(paquete) 
		# IMPORTANTÍSIMO:
		# ↑ así la física funciona normal. No lo pongas como hijo de StaticBody!!!
		
		# Tirarlos dentro de un volumen (como una caja de spawn)
		var random_x = randf_range(-2.5, 2.5)
		var random_z = randf_range(-2.5, 2.5)
		var random_y = randf_range(0.0, 1.5)

		paquete.global_transform.origin = pos_base + Vector3(random_x, random_y, random_z)

		# Evita explosiones físicas al instanciar
		if paquete is RigidBody3D:
			paquete.linear_velocity = Vector3.ZERO
			paquete.angular_velocity = Vector3.ZERO
	
	iniciado = true
	
	#print("Listo: %d paquetes creados y cayendo" % paquetes_totales)


func agregar_detectores_nodos():
	for nodo in GameManager.grafo.nodos:
		if not nodo.nodo_visual:
			continue
		
		var area = Area3D.new()
		area.name = "NodeDetector"
		nodo.nodo_visual.add_child(area)
		
		var collision = CollisionShape3D.new()
		var shape = SphereShape3D.new()
		shape.radius = 1.5
		collision.shape = shape
		area.add_child(collision)
		
		area.body_entered.connect(_on_nodo_entered.bind(nodo))
		area.body_exited.connect(_on_nodo_exited.bind(nodo))

func _on_nodo_entered(body, nodo: Nodo):
	if iniciado:
		id_nodo_ac = nodo.id
	if body != player and iniciado:
		#print("SE DETECTÓ UN PAQUETEE")
		#marcar(nodo.id)
		return
	en_nodo = true
	print("Player entró al nodo %d" % nodo.id)
	mostrar_popup_nodo(nodo)
func _on_nodo_exited(body,nodo : Nodo):
	if iniciado:
		id_nodo_ac = nodo.id
	if body != player and iniciado:
		#print("SE DETECTÓ UN PAQUETEE")
		#marcar(nodo.id)
		return
	en_nodo = false
	print("Player salió del nodo %d" % nodo.id)
func mostrar_popup_nodo(nodo: Nodo):
	# TODO: Crear UI popup que muestre capacidad y entregados
	if nodo.nodo_visual:
		print(" Capacidad: %d | Entregados: %d" % [nodo.nodo_visual.capacidad_maxima, nodo.nodo_visual.paquetes_entregados[nodo.id]])
	
func depositar_en_sink():
	var cantidad = player.depositar_paquetes()
	paquetes_entregados_sink += cantidad
	
	print("Entregados al SINK: %d/%d" % [paquetes_entregados_sink, flujo_objetivo])
	emit_signal("flujo_actualizado", paquetes_entregados_sink, flujo_objetivo)
	
	# Verificar victoria
	if paquetes_entregados_sink >= flujo_objetivo:
		victoria()
	elif paquetes_entregados_sink > flujo_objetivo:
		game_over("Entregaste más del flujo máximo")

func perder_paquetes():
	var cantidad = player.paquetes_llevando
	player.perder_paquetes()
	
	paquetes_perdidos += cantidad
	print("Paquetes perdidos: %d/%d" % [paquetes_perdidos, max_paquetes_perdidos])
	emit_signal("paquetes_perdidos_actualizado", paquetes_perdidos, max_paquetes_perdidos)
	
	if paquetes_perdidos >= max_paquetes_perdidos:
		game_over("Perdiste demasiados paquetes")

func victoria():
	juego_activo = false
	print("¡FLUJO MÁXIMO ALCANZADO!")
	emit_signal("nivel_completado")
	GameManager.completar_mision()

func game_over(razon: String):
	juego_activo = false
	iniciado = false
	print("Game Over: %s" % razon)
	emit_signal("nivel_fallido")
	GameManager.gameOver()

# Llamar desde el Player cuando presiona E
func _on_llamar_efectos(pos):
	#print("SE CONECTÓ disparar particulas y hacer visible label")
	ParticlesManager.emitir_en(pos)
	FloatingLabels.spawn_text(pos)

func _soltar_paquete():
	print("el jugador dejó un paquete")
	# Crear un paquete nuevo
	var paquete = paquete_scene.instantiate()

	# Agregarlo al mundo
	get_tree().current_scene.add_child(paquete)

	# Posición donde aparecerá
	var drop_pos = player.global_position + Vector3(0, 1.2, 0)
	paquete.global_position = drop_pos

	# Llamar animación inversa
	paquete.animacion_spawn()
	marcar(id_nodo_ac)
func _recoger_pack():
	if en_nodo:
		print("jugador sacó un paquete de un nodo")
		saca(id_nodo_ac)
	
func saca(id:int):
	var nodoV = GameManager.grafo.obtener_nodo(id).nodo_visual
	nodoV.restar(id)
	emit_signal("sacar",id)
	
func marcar(id:int):
	#print("ENTRA A MARCAR")
	var nodoV = GameManager.grafo.obtener_nodo(id).nodo_visual
	
	if not nodoV.esta_cerrado:		
		nodoV.recibir_paquete(id)
		#Mandar señal para actualizar los entregados
		print("ENTREGANDO AL NODO: ",id)
		emit_signal("entrega",id)
	else:
		print("PAQUETE NO ADMITIDO, LO PERDISTE")
		#perder_paquetes()
