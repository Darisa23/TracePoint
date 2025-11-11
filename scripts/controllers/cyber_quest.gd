extends Node
# Script para el nodo raíz de CyberQuest.tscn

# Referencias a los niveles
@onready var nivel_1 = $Nivel1_NetworkTracer
@onready var nivel_2 = $Nivel2_SafeRoute if has_node("Nivel2_SafeRoute") else null
@onready var nivel_3 = $Nivel3_RebuildNet if has_node("Nivel3_RebuildNet") else null

# Referencias al player
@onready var player = $"../player"

var nivel_actual: int = 1

func _ready():
	print("\n" + "=".repeat(50))
	print("CYBERQUEST - GUARDIANES DE LA RED GLOBAL")
	print("=".repeat(50) + "\n")
	
	# Registrar player en GameManager
	if player:
		GameManager.registrar_player(player)
	else:
		push_error("No se encontró el Player en CyberQuest")
	
	# Configurar niveles iniciales
	activar_solo_nivel(1)
	
	# Esperar a que todo cargue
	await get_tree().create_timer(0.1).timeout
	posicionar_player_en_nivel_actual()
	
	# Conectar señales del GameManager
	GameManager.mision_completada.connect(_on_cualquier_mision_completada)
	GameManager.nivel_reiniciado.connect(_on_nivel_reiniciado)

func _input(event):
	# Atajos de teclado para testing
	if event.is_action_pressed("ui_page_down"):
		cambiar_a_nivel(nivel_actual + 1)
	elif event.is_action_pressed("ui_page_up"):
		cambiar_a_nivel(nivel_actual - 1)
	elif event.is_action_pressed("ui_home"):
		reiniciar_nivel_actual()

func cambiar_a_nivel(numero: int):
	if numero < 1 or numero > 3:
		print("Nivel fuera de rango: ", numero)
		return
	
	print("\nCambiando a nivel %d..." % numero)
	nivel_actual = numero
	activar_solo_nivel(numero)
	
	# Esperar un poco y posicionar player
	await get_tree().create_timer(0.2).timeout
	posicionar_player_en_nivel_actual()

func activar_solo_nivel(numero: int):
	# Desactivar todos
	if nivel_1:
		if nivel_1.has_method("desactivar"):
			nivel_1.desactivar()
		else:
			nivel_1.visible = false
	if nivel_2:
		if nivel_2.has_method("desactivar"):
			nivel_2.desactivar()
		else:
			nivel_2.visible = false
	if nivel_3:
		if nivel_3.has_method("desactivar"):
			nivel_3.desactivar()  
		else:
			nivel_3.visible = false
	
	# Activar el nivel solicitado
	match numero:
		1:
			if nivel_1:
				if nivel_1.has_method("activar"):
					nivel_1.activar() 
				else:
					nivel_1.visible = true
		2:
			if nivel_2:
				if nivel_2.has_method("activar"):
					nivel_2.activar() 
				else:
					nivel_2.visible = true
			else:
				push_warning("Nivel 2 no existe aún")
		3:
			if nivel_3:
				if nivel_3.has_method("activar"):
					nivel_3.activar()
				else:
					nivel_3.visible = true
			else:
				push_warning("Nivel 3 no existe aún")

func reiniciar_nivel_actual():
	print("Reiniciando nivel actual...")
	GameManager.reiniciar_nivel()

func _on_cualquier_mision_completada():
	print("\nMisión completada detectada en CyberQuest")
	
	# Esperar 3 segundos y pasar al siguiente nivel
	await get_tree().create_timer(3.0).timeout
	
	if nivel_actual < 3:
		cambiar_a_nivel(nivel_actual + 1)
	else:
		print("\n¡HAS COMPLETADO TODOS LOS NIVELES!")
		print("¡NEMESIS HA SIDO DERROTADO!")

func _on_nivel_reiniciado():
	print("Reinicio detectado en CyberQuest")
	posicionar_player_en_nivel_actual()

func posicionar_player_en_nivel_actual():
	if not player:
		push_error("No hay player para posicionar")
		return
	
	if not GameManager.grafo or GameManager.grafo.nodos.size() == 0:
		push_warning("No hay grafo cargado aún")
		return
	
	# Posicionar en el primer nodo del grafo actual
	var pos_inicial = GameManager.grafo.nodos[0].posicion_3d + Vector3(0, 2, 0)
	player.global_position = pos_inicial
	
	# Resetear velocidad
	if "velocity" in player:
		player.velocity = Vector3.ZERO
	
	print("Player posicionado en nivel %d: %s" % [nivel_actual, pos_inicial])
