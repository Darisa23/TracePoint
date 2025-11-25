extends Control
@onready var anim = $AnimationPlayer
@onready var titles := {
	1: $Titulo1NetworkTracer,
	2: $Titulo2SafeRoute,
	3: $Titulo3RebuildNet,
	4: $Titulo4FlowControl
}

func _enter_tree():
	set_anchors_preset(Control.PRESET_FULL_RECT)

func _ready():
	await get_tree().process_frame
	set_anchors_preset(Control.PRESET_FULL_RECT)
	
	anim.play("Title")

func chou():
	visible =true
	anim.play("Title")
	await get_tree().create_timer(3).timeout
	ocultar_titulo()
	
func ocultar_titulo():
	anim.stop()
	visible = false
	
	
