extends Label3D

# Referencia a la cámara
@onready var camera: Camera3D

func _ready():
	# Buscar la cámara automáticamente
	camera = get_viewport().get_camera_3d()
	
	# Si prefieres asignarla manualmente en el Inspector:
	# @export var camera: Camera3D

func _process(_delta):
	if camera:
		# Hacer que la label siempre mire hacia la cámara
		look_at(camera.global_position, Vector3.UP)
		
		# IMPORTANTE: Rotar 180 grados para que el texto no esté al revés
		rotate_object_local(Vector3.UP, PI)
		
