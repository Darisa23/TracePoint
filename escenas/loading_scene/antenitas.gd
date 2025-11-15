extends TextureRect

func _ready():
	pivot_offset = size / 2  # centra el pivote para girar desde el medio

func _process(delta):
	rotation += deg_to_rad(90) * delta  # gira 90 grados por segundo
