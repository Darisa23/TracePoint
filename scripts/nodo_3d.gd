extends Node3D

# Datos del nodo lógico
var nodo_logico: Nodo = null

# Referencias visuales
@onready var mesh_instance = $MeshInstance3D
@onready var area_deteccion = $Area3D
@onready var label_3d = $Label3D if has_node("Label3D") else null
@onready var nom = $nombre if has_node("nombre") else null
@onready var material: StandardMaterial3D = null

# Animación
var esta_quebrando: bool = false
var tiempo_quiebre: float = 0.0
var duracion_quiebre: float = 1.5
# Colores
var color_normal: Color = Color(0.2, 0.5, 0.8)  # Azul
var color_correcto: Color = Color(0.2, 0.8, 0.2)  # Verde
var color_incorrecto: Color = Color(0.8, 0.2, 0.2)  # Rojo
var color_visitado: Color = Color(0.4, 0.8, 0.8)  # Cyan
# Variables para nivel 4 (flujo)
var capacidad_maxima: int = 0
var paquetes_entregados: Array = []
var paquetes_actuales: Array = []
var esta_cerrado: bool = false
var nodosv:Array = []
func _ready():
	# Crear y asignar material único para este nodo
	if mesh_instance:
		material = StandardMaterial3D.new()
		material.albedo_color = color_normal
		mesh_instance.set_surface_override_material(0, material)
	
	# Conectar señal del Area3D
	if area_deteccion:
		area_deteccion.body_entered.connect(_on_body_entered)

func _process(delta):
	# Animación de quiebre
	if esta_quebrando:
		tiempo_quiebre += delta
		var progreso = tiempo_quiebre / duracion_quiebre
		
		# Animación de caída y rotación
		rotation.x = lerp(0.0, PI * 0.5, progreso)
		position.y = lerp(position.y, position.y - 5.0, progreso * delta * 2)
		
		# Hacer semitransparente
		if material:
			material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			material.albedo_color.a = lerp(1.0, 0.0, progreso)
		
		# Destruir cuando termine
		if progreso >= 1.0:
			queue_free()
			
		#ACA LLAMAR A GAME OVER DEL NIVEL**********************

func inicializar(p_nodo_logico: Nodo):
	paquetes_entregados.resize(GameManager.grafo.obtener_num_nodos())
	paquetes_actuales.resize(GameManager.grafo.obtener_num_nodos())
	nodosv.resize(GameManager.grafo.obtener_num_nodos())
	nodo_logico = p_nodo_logico
	paquetes_entregados[nodo_logico.id] = 0
	paquetes_actuales[nodo_logico.id] = 0
	
	# Asignar referencia visual al nodo lógico
	if nodo_logico:
		nodo_logico.nodo_visual = self
		#nodosv[nodo_logico.id] = self
		#if nodosv[nodo_logico.id] == null:
			#print("OHH NO RECORCHOLIS VIEJO")
		nodo_logico.material_original = material
		
		# Posicionar en el mundo 3D
		global_position = nodo_logico.posicion_3d
		
		# Asignar letra (A, B, C, etc.)
		if label_3d:
			var letra = char(65 + nodo_logico.id)  # 65 = 'A' en ASCII
			label_3d.text = letra
			if GameManager.nivel_actual == 1 or GameManager.nivel_actual == 3:
				nom.text = GameManager.nombre_nodos[nodo_logico.id]
			#Agregar nombre de nodo
		if GameManager.nivel_actual == 4:
			capacidad_maxima = GameManager.capacidades_nodos[nodo_logico.id]
			print("se asignó capacidad max: ",capacidad_maxima, " a nodo ",nodo_logico.id)

func _on_body_entered(body):
	# Verificar si es el jugador
	if body.is_in_group("player") or body.name == "Player":
		#print("Jugador entró al nodo: ", nodo_logico.id if nodo_logico else "sin ID")
		#if nodo_logico.esA:		
		if nodo_logico:
			# Validar con GameManager (singleton)
			var es_correcto = GameManager.validar_salto_a_nodo(nodo_logico.id)
			#print("el id es: ",nodo_logico.id)
			if nodo_logico.id == 0:
				return
			if es_correcto:
				#print("Nodo correcto!")
				if nodosv[nodo_logico.id]==null:
					nodosv[nodo_logico.id]=nodo_logico.nodo_visual
				nodo_logico.vc=true
				# El color ya lo cambia GameManager → nodo_logico.marcar_correcto()
			if not es_correcto:
				#print("Nodo incorrecto!")
				if nodosv[nodo_logico.id]==null:
					nodosv[nodo_logico.id]=nodo_logico.nodo_visual
				await get_tree().create_timer(0.5).timeout  # Pequeña pausa dramática
				# Iniciar animación de quiebre		
				if GameManager.vidas_actuales == 0:
					iniciar_quiebre()
	
func recibir_paquete(id : int):
	print("paquete entregado a nodo ",id)
	paquetes_entregados[id] +=1
	var nv = GameManager.grafo.obtener_nodo(id).nodo_visual
	if paquetes_entregados[id] == nv.capacidad_maxima:
		nv.esta_cerrado = true
		print("CERRAMOS EL NODO: ",id)
	if verificar_fin():
		GameManager.mision_completada

func verificar_fin():
	var r:bool
	for n in nodosv:
		if n == null:
			return false
		else:
			r = n.esta_cerrado	
	return r
	#paquetes_actuales[id] +=1
func restar(id:int):
	paquetes_actuales[id] +=1	
func marcar_correcto():
	if material:
		material.albedo_color = color_correcto
	
	# Animación de pulso
	crear_animacion_pulso()
	
	# Efecto de partículas (opcional - agregar después)
	# spawn_particulas_exito()

func marcar_incorrecto():
	if material:
		material.albedo_color = color_incorrecto
	
	# Shake/temblor
	var tween = create_tween()
	tween.set_loops(3)
	tween.tween_property(self, "position:x", position.x + 0.1, 0.05)
	tween.tween_property(self, "position:x", position.x - 0.1, 0.05)
	tween.tween_property(self, "position:x", position.x, 0.05)

func marcar_visitado():
	if material:
		material.albedo_color = color_visitado

func restaurar_color():
	if material:
		material.albedo_color = color_normal
		material.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
		material.albedo_color.a = 1.0
	
	rotation = Vector3.ZERO
	esta_quebrando = false
	tiempo_quiebre = 0.0

func iniciar_quiebre():
	print("Iniciando animación de quiebre del nodo ", nodo_logico.id)
	esta_quebrando = true
	tiempo_quiebre = 0.0
	
	# Opcional: desactivar colisiones
	if area_deteccion:
		area_deteccion.monitoring = false

func crear_animacion_pulso():
	# Crear un tween para hacer que el nodo pulse
	var tween = create_tween()
	tween.set_loops(2)
	tween.tween_property(self, "scale", Vector3(1.2, 1.2, 1.2), 0.2)
	tween.tween_property(self, "scale", Vector3(1.0, 1.0, 1.0), 0.2)

# Métodos auxiliares para efectos visuales
func mostrar_highlight():
	# Hacer que el nodo brille cuando es el siguiente esperado
	if material:
		material.emission_enabled = true
		material.emission = Color(0.5, 0.8, 1.0)
		material.emission_energy = 0.5

func ocultar_highlight():
	if material:
		material.emission_enabled = false
