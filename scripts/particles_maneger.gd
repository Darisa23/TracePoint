extends Node3D
@onready var particles = $GPUParticles3D

func emitir_en(pos: Vector3):
	if not particles:
		print("NO HAY")
		return
	
	particles.global_position = pos+Vector3(0,1.5,0)
	particles.restart()
	particles.emitting = true
