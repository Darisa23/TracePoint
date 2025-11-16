extends Control

@onready var barra = $ProgressBar
@onready var label = $Label

var peso_total: int = 0
var peso_actual: int = 0

func _ready():
	# Ocultar por defecto
	visible = false
	
	# Conectar señales del GameManager
	GameManager.connect("nodo_visitado_correcto", _on_nodo_correcto)
	GameManager.connect("mision_completada", _on_mision_completada)
	GameManager.connect("nivel_reiniciado", _on_nivel_reiniciado)
	
	# Esperar un poco y verificar si activar
	await get_tree().create_timer(0.5).timeout
	verificar_activacion()

func _process(_delta):
	# Verificar continuamente si seguimos en nivel 2
	if GameManager.nivel_actual != 2 and visible:
		visible = false
		print("Barra ocultada - Ya no estamos en nivel 2")

func verificar_activacion():
	print("=== Verificando activación de barra ===")
	print("Nivel actual: %d" % GameManager.nivel_actual)
	print("Tipo recorrido: %s" % GameManager.tipo_recorrido)
	
	# Solo activar en nivel 2 con dijkstra
	if GameManager.nivel_actual == 2 and GameManager.tipo_recorrido == "dijkstra":
		inicializar_barra()

func inicializar_barra():
	print("=== Inicializando Barra de Peso ===")
	
	# Esperar a que haya recorrido
	var intentos = 0
	while GameManager.recorrido_correcto.size() == 0 and intentos < 30:
		await get_tree().create_timer(0.1).timeout
		intentos += 1
	
	if GameManager.recorrido_correcto.size() == 0:
		print("ERROR: No hay recorrido calculado después de esperar")
		return
	
	# Calcular peso total
	calcular_peso_total()
	
	# Mostrar barra
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
		
		var peso = 1  # peso por defecto
		
		# Obtener peso de la matriz
		if grafo.matriz_pesos.size() > nodo_a.id:
			if grafo.matriz_pesos[nodo_a.id].size() > nodo_b.id:
				peso = grafo.matriz_pesos[nodo_a.id][nodo_b.id]
		
		peso_total += peso
		print("  %d -> %d : peso %d" % [nodo_a.id, nodo_b.id, peso])
	
	peso_actual = peso_total
	actualizar_ui()

func _on_nodo_correcto(nodo_id: int):
	if not visible:
		return
	
	# El índice se incrementa DESPUÉS de emitir la señal, así que sumamos 1
	var indice = GameManager.indice_actual + 1
	var recorrido = GameManager.recorrido_correcto
	
	# Crear array de IDs para debug
	var ids = []
	for n in recorrido:
		ids.append(n.id)
	
	print("\n🎯 Señal recibida: nodo %d correcto" % nodo_id)
	print("   GameManager.indice_actual: %d (usaremos: %d)" % [GameManager.indice_actual, indice])
	print("   Recorrido completo: %s" % str(ids))
	
	# Si es el primer salto (índice sería 1 = segundo nodo), restar el primer peso
	if indice == 0:
		print("   ➜ Índice 0, no se resta peso\n")
		return
	
	# Restar peso de la arista que acabamos de recorrer
	var grafo = GameManager.grafo
	
	# Verificar que tenemos los índices correctos
	if indice >= recorrido.size():
		print("    ERROR: Índice %d fuera de rango (tamaño: %d)\n" % [indice, recorrido.size()])
		return
	
	var nodo_anterior = recorrido[indice - 1]
	var nodo_actual = recorrido[indice]
	
	print("   Arista: nodo[%d] (%d) -> nodo[%d] (%d)" % [indice-1, nodo_anterior.id, indice, nodo_actual.id])
	
	var peso = 1
	
	# Obtener peso real de la matriz
	if grafo.matriz_pesos.size() > nodo_anterior.id and grafo.matriz_pesos[nodo_anterior.id].size() > nodo_actual.id:
		peso = grafo.matriz_pesos[nodo_anterior.id][nodo_actual.id]
		print("   Peso de matriz[%d][%d] = %d" % [nodo_anterior.id, nodo_actual.id, peso])
	else:
		print("    No hay peso en matriz, usando peso=1")
	
	var peso_anterior = peso_actual
	peso_actual -= peso
	
	print("   Peso antes: %d, restando: %d, peso después: %d" % [peso_anterior, peso, peso_actual])
	print("   Progreso: %d/%d\n" % [peso_actual, peso_total])
	
	actualizar_ui()

func actualizar_ui():
	if not barra or not label:
		return
	
	barra.max_value = peso_total
	barra.value = max(0, peso_actual)
	label.text = "Distancia: %d / %d" % [max(0, peso_actual), peso_total]
	
	print("   Barra actualizada: %d/%d" % [peso_actual, peso_total])

func _on_mision_completada():
	# Ocultar la barra cuando se completa la misión
	if visible:
		await get_tree().create_timer(2.0).timeout  # Esperar 2 segundos antes de ocultar
		visible = false
		print("Barra oculta - Misión completada")

func _on_nivel_reiniciado():
	# Si se reinicia el nivel 2, reiniciar la barra
	if GameManager.nivel_actual == 2:
		peso_actual = peso_total
		actualizar_ui()
		visible = true
		print("Barra reiniciada")
