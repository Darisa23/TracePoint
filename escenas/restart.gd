extends TextureButton

func _ready():
	pressed.connect(_on_pressed)

func _on_pressed():
	var n = GameManager.nivel_actual
	match n:
		1: 
			get_tree().change_scene_to_file("res://escenas/hospital.tscn")
		2:
			get_tree().change_scene_to_file("res://escenas/tristeza_v_2.tscn")
		3:
			get_tree().change_scene_to_file("res://3dmodels/plantaelectrica.tscn")
