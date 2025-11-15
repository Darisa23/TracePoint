extends AnimatedSprite2D

var tiempo_acumulado = 0.0
const VELOCIDAD_PULSACION = 4.0  # Controla la velocidad con la que pulsa
const ESCALA_MIN = 1.9 # El tamaño más pequeño (95%)
const ESCALA_MAX = 2.3 # El tamaño más grande (105%)
const ESCALA_BASE = 0.5 # Asume un tamaño inicial de tu sprite si no lo has escalado ya

func _ready():
	# 1. Inicia la animación (como ya lo tenías)
	play("new_animation")

	# 2. Establece la escala base de tu AnimatedSprite2D
	# Usa el valor que necesites para que tu sprite se vea del tamaño correcto en la pantalla
	self.scale = Vector2(ESCALA_BASE, ESCALA_BASE)

func _process(delta):
	# 1. Acumular el tiempo para alimentar la función senoidal
	tiempo_acumulado += delta * VELOCIDAD_PULSACION
	
	# 2. Calcular el valor de la pulsación (va de -1 a 1)
	var sin_valor = sin(tiempo_acumulado)
	
	# 3. Mapear el valor senoidal al rango deseado (de 0.95 a 1.05)
	var rango_escala = ESCALA_MAX - ESCALA_MIN
	# 'remap' de Godot (o la fórmula que usamos antes) mapea [-1, 1] a [ESCALA_MIN, ESCALA_MAX]
	var factor_pulsacion = ESCALA_MIN + ((sin_valor + 1.0) / 2.0) * rango_escala
	
	# 4. Aplicar la nueva escala combinando la escala base y el factor de pulsación
	var nueva_escala_x = ESCALA_BASE * factor_pulsacion
	var nueva_escala_y = ESCALA_BASE * factor_pulsacion
	
	self.scale = Vector2(nueva_escala_x, nueva_escala_y)
