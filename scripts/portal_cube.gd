extends Node3D


@export var next_scene: PackedScene
@export var rotation_speed = 1.0
@export var float_speed = 1.5
@export var float_amplitude = 0.5
@export var light_pulse_speed = 2.0
@export var light_min_energy = 2.0
@export var light_max_energy = 4.0

var time = 0.0
var initial_position: Vector3

@onready var cube = $MeshInstance3D
@onready var light = $OmniLight3D

func _ready():
	initial_position = cube.position

func _process(delta):
	time += delta
	
	# Rotación constante
	cube.rotation.y += rotation_speed * delta
	cube.rotation.x += rotation_speed * 0.5 * delta
	
	# Movimiento flotante (arriba y abajo)
	cube.position.y = initial_position.y + sin(time * float_speed) * float_amplitude
	
	# Pulsación de la luz
	var pulse = (sin(time * light_pulse_speed) + 1.0) / 2.0
	light.light_energy = light_min_energy + pulse * (light_max_energy - light_min_energy)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "Player3DTemplate":  
		if next_scene:
			
			await get_tree().create_timer(1).timeout
			get_tree().change_scene_to_packed(next_scene)
		else:
			push_warning("No asignaste una escena en 'next_scene'")
