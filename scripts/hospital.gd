extends Node3D

@onready var anim = $AnimationPlayer
@export var activo: bool = true 
func _ready():
	
	# Si el nivel no está activo, desactivarlo
	if not activo:
		visible = false
		process_mode = Node.PROCESS_MODE_DISABLED
		return

	await get_tree().process_frame
	await get_tree().process_frame

func start() -> void:	
	anim.play("Intro")
	await get_tree().create_timer(13.5).timeout
	cycle_animations()

func activar():
	self.activo = true
	visible = true
	process_mode = Node.PROCESS_MODE_INHERIT
	await get_tree().create_timer(0.2).timeout
	start()
func cycle_animations():
		var i := 1
		while true:
			var name := "%s%d" % ["Notification_", i]
			if not anim.has_animation(name):
				break
			anim.play(name)
			await anim.animation_finished
			await get_tree().create_timer(1.0).timeout
			i += 1

func desactivar():
	self.activo = false
	visible = false
	process_mode = Node.PROCESS_MODE_DISABLED
