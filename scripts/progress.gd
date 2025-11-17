extends Node

var nivel_completado = {
	"nivel_1": false,
	"nivel_2": false,
	"nivel_3": false,
	"nivel_4": false,
	"nivel_5": false,
}

func guardar():
	var save := ConfigFile.new()
	for key in nivel_completado.keys():
		save.set_value("progreso", key, nivel_completado[key])
	save.save("user://save.cfg")

func cargar():
	var save := ConfigFile.new()
	if save.load("user://save.cfg") != OK:
		return  # No había archivo, usar valores por defecto
	
	for key in nivel_completado.keys():
		nivel_completado[key] = save.get_value("progreso", key, false)
