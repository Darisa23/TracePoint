extends CanvasLayer
@onready var dfs = $Button_dfs
@onready var bfs = $Button_bfs
@onready var hrtcont = $HBoxContainer

func _ready():
	GameManager.vida_perdida.connect(_on_vida_perdida)
	GameManager.mision_completada.connect(desactivar)
	
func _process(_delta):
	if GameManager.nivel_actual > 1:
		desactivar()
func _on_button_bfs_pressed() -> void:
	GameManager.iniciar_juego("BFS")
	desactivar()

func _on_button_dfs_pressed() -> void:
	GameManager.iniciar_juego("DFS")
	desactivar()
	
func desactivar():
	bfs.hide()
	dfs.hide()

func _on_vida_perdida():
	var hearts = hrtcont.get_children()
	for i in hearts:
		i.update(false)
	for i in range(GameManager.vidas_actuales,hearts.size()):
		hearts[i].update(true)
	
