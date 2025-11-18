extends Control

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
	
	$AnimationPlayer.play("Title")
