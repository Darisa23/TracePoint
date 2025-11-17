extends Control

func _ready():
	Progress.cargar()
	# Nivel 1 siempre habilitado
	$Level_1.disabled = false

	# Nivel 2 depende del nivel 1
	$Level_2.disabled = not Progress.nivel_completado["nivel_1"]

	# Nivel 3 depende del nivel 2
	$Level_3.disabled = not Progress.nivel_completado["nivel_2"]

	# Nivel 4 depende del nivel 3
	$Level_4.disabled = not Progress.nivel_completado["nivel_3"]

	# Nivel 5 depende del nivel 4
	$Level_5.disabled = not Progress.nivel_completado["nivel_4"]
	
	for i in range(1, 5):
		if Progress.nivel_completado["nivel_"+str(i)]:
			var linea = get_node("Line2D%d" % i)
			linea.visible = true
		else:
			var linea = get_node("Line2D%d" % i)
			linea.visible = false
