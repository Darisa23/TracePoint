extends TextureButton

func _ready():
	pressed.connect(_on_pressed)

func _on_pressed():
	# Llamar a la función de reinicio del GameManager
	GameManager.reiniciar_nivel()
