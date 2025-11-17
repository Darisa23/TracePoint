extends Control

@onready var barra = $ProgressBar
@onready var label = $Label

var peso_total: int = 0
var peso_actual: int = 0
var inicializada: bool = false
var ya_verifico_inicio: bool = false

func _ready():
	print("\n=== BarraPeso _ready() ===")
	
	# Ocultar por defecto
	visible = false
	
	# Conectar señales del GameManager
	GameManager.connect("nodo_visitado_correcto", _on_nodo_correcto)
	GameManager.connect("mision_completada", _on_mision_completada)
	GameManager.connect("nivel_reiniciado", _on_nivel_reiniciado)
	
	print("Señales conectadas")

func _process(_delta):
	# SOLO verificar UNA VEZ cuando el juego se inicia
	if not ya_verifico_inicio and not inicializada:
		if GameManager.nivel_actual == 2 and GameManager.juego_iniciado:
			if GameManager.tipo_recorrido.to_lower() == "dijkstra":
				print("\n🎮 _process detectó que el juego ya inició - Inicializando barra")
				inicializar_barra()
			ya_verifico_inicio = true
	
	# Ocultar si ya no estamos en nivel 2
	if GameManager.nivel_actual != 2 and visible:
		visible = false
		inicializada = false
		ya_verifico_inicio = false
		print("Barra ocultada - Ya no estamos en nivel 2")

func _on_nodo_correcto(nodo_id: int):
	if not visible or not inicializada:
		return
	
	# IMPORTANTE: La señal se emite ANTES de incrementar indice_actual
	# Entonces indice_actual es el nodo ANTERIOR, y nodo_id es el nodo al que acabamos de llegar
	var indice = GameManager.indice_actual
	var recorrido = GameManager.recorrido_correcto
	var grafo = GameManager.grafo
	
	# Debug info
	var ids = []
	for n in recorrido:
		ids.append(n.id)
	
	print("\n🎯 Señal recibida: nodo %d correcto" % nodo_id)
	print("   GameManager.indice_actual (antes de incrementar): %d" % indice)
	print("   Recorrido completo: %s" % str(ids))
	
	# Encontrar el nodo actual en el recorrido por su ID
	var nodo_actual_index = -1
	for i in range(recorrido.size()):
		if recorrido[i].id == nodo_id:
			nodo_actual_index = i
			break
	
	if nodo_actual_index == -1:
		print("   ⚠️ ERROR: No se encontró el nodo %d en el recorrido" % nodo_id)
		return
	
	# Si es el primer nodo (índice 0), no restar nada
	if nodo_actual_index == 0:
		print("   ➜ Nodo inicial (índice 0), no se resta peso\n")
		return
	
	# Calcular peso de la arista que acabamos de recorrer
	var nodo_anterior = recorrido[nodo_actual_index - 1]
	var nodo_actual = recorrido[nodo_actual_index]
	
	print("   Arista: nodo[%d] (%d) -> nodo[%d] (%d)" % [nodo_actual_index-1, nodo_anterior.id, nodo_actual_index, nodo_actual.id])
	
	var peso = 1
	
	# Obtener peso real de la matriz
	if grafo.matriz_pesos.size() > nodo_anterior.id and grafo.matriz_pesos[nodo_anterior.id].size() > nodo_actual.id:
		peso = grafo.matriz_pesos[nodo_anterior.id][nodo_actual.id]
		print("   Peso de matriz[%d][%d] = %d" % [nodo_anterior.id, nodo_actual.id, peso])
	else:
		print("   ⚠️ No hay peso en matriz, usando peso=1")
	
	var peso_anterior = peso_actual
	peso_actual -= peso
	
	print("   Peso antes: %d, restando: %d, peso después: %d" % [peso_anterior, peso, peso_actual])
	print("   Progreso: %d/%d\n" % [peso_actual, peso_total])
	
	actualizar_ui()

func inicializar_barra():
	if inicializada:
		return
		
	print("\n=== Inicializando Barra de Peso ===")
	print("   - Nivel: %d" % GameManager.nivel_actual)
	print("   - Tipo recorrido: %s" % GameManager.tipo_recorrido)
	print("   - Recorrido calculado: %d nodos" % GameManager.recorrido_correcto.size())
	
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
	
	barra.max_value = peso_total
	barra.value = max(0, peso_actual)
	label.text = "Distancia: %d / %d" % [max(0, peso_actual), peso_total]
	
	# Actualizar shader
	if barra.material and barra.material is ShaderMaterial:
		barra.material.set_shader_parameter("progreso", progreso_normalizado)
	
	print("  📊 Barra actualizada: %d/%d (progreso shader: %.2f)" % [peso_actual, peso_total, progreso_normalizado])

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
		visible = false
		print("Barra reseteada - Lista para reiniciar")
