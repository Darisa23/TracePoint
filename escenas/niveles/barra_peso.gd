extends Control

@onready var barra = $ProgressBar
@onready var label = $Label

var peso_total: int = 0
var peso_actual: int = 0
var inicializada: bool = false
var ya_verifico_inicio: bool = false
var crash : bool = false
var antt : int = 0
func _ready():
	
	# Ocultar por defecto
	visible = false
	
	# Conectar señales del GameManager
	GameManager.connect("nodo_visitado_correcto", _on_nodo_correcto)
	GameManager.connect("nodo_visitado_incorrecto", _on_nodo_incorrecto)
	GameManager.connect("mision_completada", _on_mision_completada)
	GameManager.connect("nivel_reiniciado", _on_nivel_reiniciado)
	
	print("Señales conectadas")

func _process(_delta):
	# SOLO verificar UNA VEZ cuando el juego se inicia
	if not ya_verifico_inicio and not inicializada:
		if GameManager.nivel_actual == 2 and GameManager.juego_iniciado:
			if GameManager.tipo_recorrido.to_lower() == "dijkstra":
				#print(" _process detectó que el juego ya inició - Inicializando barra")
				inicializar_barra()
			ya_verifico_inicio = true
	
	# Ocultar si ya no estamos en nivel 2
	if GameManager.nivel_actual != 2 and visible:
		visible = false
		inicializada = false
		ya_verifico_inicio = false

func _on_nodo_correcto(nodo_id: int):
	if not visible or not inicializada:
		return
	if nodo_id == antt:
		return	
	var grafo = GameManager.grafo
	var indice = nodo_id
	#print("1. EL NODO ES: ",indice)
	#print("1. El ANTERIOR ES: ",antt)
	# Nodo actual según GameManager
	var nodo_actual = grafo.obtener_nodo(nodo_id)
	# Nodo anterior según el recorrido correcto
	var nodo_anterior = grafo.obtener_nodo(antt)

	# Pedimos el peso REAL directamente al grafo
	#print("2. EL NODO ES: ",nodo_actual.id)
	#print("2. El ANTERIOR ES: ",nodo_anterior.id)
	var peso = grafo.obtener_peso(nodo_anterior, nodo_actual)
	var peso_anterior = peso_actual
	peso_actual -= peso
	
	if peso_actual < 0:
		print("PESO EXCEDIDO")
		crash = true
	else:
		print("Peso antes: %d | después: %d" % [peso_anterior, peso_actual])

		# Actualizar barra o UI
	antt = nodo_id
	actualizar_ui()
func _on_nodo_incorrecto(nodo_id:int):
	print("aca se restaría para ese incorrecto")
	if not visible or not inicializada:
		return
	if nodo_id == antt:
		return	
	var grafo = GameManager.grafo
	var indice = nodo_id
	#print("1. EL NODO ES: ",indice)
	#print("1. El ANTERIOR ES: ",antt)
	# Nodo actual según GameManager
	var nodo_actual = grafo.obtener_nodo(nodo_id)
	if nodo_actual == null:
		print("ERROR: nodo %d no existe en el grafo" % nodo_id)
		return

	# Si estamos en el primer nodo, no restamos nada
	if indice == 0:
		print("Nodo inicial, no descuenta peso")
		return

	# Nodo anterior según el recorrido correcto
	var nodo_anterior = grafo.obtener_nodo(antt)

	# Pedimos el peso REAL directamente al grafo
	#print("2. EL NODO ES: ",nodo_actual.id)
	#print("2. El ANTERIOR ES: ",nodo_anterior.id)
	var peso = grafo.obtener_peso(nodo_anterior, nodo_actual)

	# Aplicamos el descuento
	var anterior = peso_actual
	peso_actual -= peso
	if peso_actual < 0:
		print("PESO EXCEDIDO")
		crash = true
	else:
		print("Peso antes: %d | después: %d" % [anterior, peso_actual])
		
	antt = nodo_id
		# Actualizar barra o UI
	actualizar_ui()
	
func inicializar_barra():
	if inicializada:
		return
		
	# Ajustar altura de la barra
	if barra:
		barra.custom_minimum_size.y = 15
	
	# Verificar que haya recorrido calculado
	if GameManager.recorrido_correcto.size() == 0:
		print("⚠️ No hay recorrido calculado todavía")
		return
	
	# Calcular peso total
	calcular_peso_total()
	
	# Inicializar shader
	if barra and barra.material and barra.material is ShaderMaterial:
		barra.material.set_shader_parameter("progreso", 1.0)
		print("✓ Shader inicializado con progreso = 1.0")
	
	# Marcar como inicializada y mostrar
	inicializada = true
	visible = true
	print("✓ Barra activada - Peso total: %d" % peso_total)

func calcular_peso_total():
	peso_total = 0
	var grafo = GameManager.grafo
	var recorrido = GameManager.recorrido_correcto
	
	print("Calculando peso del camino:")
	
	for i in range(recorrido.size() - 1):
		var nodo_a = recorrido[i]
		var nodo_b = recorrido[i + 1]
		
		var peso = 1
		
		# Obtener peso de la matriz
		if grafo.matriz_pesos.size() > nodo_a.id:
			if grafo.matriz_pesos[nodo_a.id].size() > nodo_b.id:
				peso = grafo.matriz_pesos[nodo_a.id][nodo_b.id]
		
		peso_total += peso
		print("  %d -> %d : peso %d" % [nodo_a.id, nodo_b.id, peso])
	
	peso_actual = peso_total
	actualizar_ui()

func actualizar_ui():
	if not barra or not label:
		return
	
	# Progreso normalizado: 1.0 (inicio) -> 0.0 (final)
	var progreso_normalizado = float(peso_actual) / float(peso_total) if peso_total > 0 else 0.0
	if not crash:
		barra.max_value = peso_total
		barra.value = max(0, peso_actual)
		label.text = "Distancia: %d / %d" % [max(0, peso_actual), peso_total]
	else:
		
		label.text = "ERROR, EXCEDISTE LA DISTANCIA PERMITIDA"
		await get_tree().create_timer(0.5).timeout
		GameManager.perder_vida()
	# Actualizar shader
	if barra.material and barra.material is ShaderMaterial:
		barra.material.set_shader_parameter("progreso", progreso_normalizado)
	
	print("Barra actualizada: %d/%d (progreso shader: %.2f)" % [peso_actual, peso_total, progreso_normalizado])

func _on_mision_completada():
	if visible:
		await get_tree().create_timer(2.0).timeout
		visible = false
		inicializada = false
		ya_verifico_inicio = false
		print("Barra ocultada - Misión completada")

func _on_nivel_reiniciado():
	if GameManager.nivel_actual == 2:
		# Resetear banderas para reinicializar
		inicializada = false
		ya_verifico_inicio = false
		antt = 0
		visible = false
		crash = false
		print("Barra reseteada - Lista para reiniciar")
