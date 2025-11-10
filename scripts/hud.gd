extends CanvasLayer
@onready var dfs = $Button_dfs
@onready var bfs = $Button_bfs
func _on_button_bfs_pressed() -> void:
	GameManager.iniciar_juego("BFS")
	desactivar()

func _on_button_dfs_pressed() -> void:
	GameManager.iniciar_juego("DFS")
	desactivar()
	
func desactivar():
	bfs.hide()
	dfs.hide()
