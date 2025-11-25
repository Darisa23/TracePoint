extends Node3D
@onready var niveles = $"../Niveles"
@onready var hospital = $Hospital
@onready var hud = $"../HUD"
#@onready var banco = $"../Niveles"
var nivel_actual: int = 1
# Referencias al player
#@onready var player = $"../player"
func _ready():
	print("\n" + "=".repeat(50))
	print("TRACEPOINT BY: TINYTARDIGRADE")
	print("=".repeat(50) + "\n")
	
	#player.visible = false
	#player.set_process(false)
	hud.visible = false
	hud.set_process(false)
	activar_solo_core(1)
	
	# Esperar a que todo cargue
	await get_tree().create_timer(0.1).timeout
	#niveles.posicionar_player_en_nivel_actual()
	
	# Conectar señales del GameManager
	GameManager.mision_completada.connect(_on_cualquier_mision_completada)
func _on_cualquier_mision_completada():
	print("\nMisión completada detectada en CyberQuest")
	
	# Esperar 3 segundos y pasar al siguiente nivel
	await get_tree().create_timer(1.0).timeout
	
	if nivel_actual < 4:
		niveles.cambiar_a_nivel(nivel_actual+3) #SALTAR DE UNA A NIVEL 4
		hud.visible = true
	else:
		print("\n¡HAS COMPLETADO TODOS LOS NIVELES!")
		print("¡NEMESIS HA SIDO DERROTADO!")

func activar_solo_core(numero: int):
	# Desactivar todos
	#banco.desactivar()
	hospital.desactivar() 
	
	# Activar el nivel solicitado
	match numero:
		1:
			if hospital.has_method("activar"):
				hospital.activar() 
			else:
				hospital.visible = true
		#2:
			#if banco:
				#if banco.has_method("activar"):
					#await get_tree().create_timer(3).timeout
					#banco.activar() 
				#else:
					#banco.visible = true
					#await get_tree().create_timer(3.5).timeout
					#get_tree().change_scene_to_file("res://escenas/niveles/nivel_2_safe_route.tscn")
			#else:
				#push_warning("No hay banco")	
