extends Node

var grimorios = {
	"Semestre1": false,
	"Semestre2": false,
	"Semestre3": false,
	"Semestre4": false
}

var muro_semestre1_derrotado = false
var posicion_mago_antes_de_batalla = Vector2.ZERO
var base_de_scripts = {}

func _ready():
	cargar_scripts_desde_json()

func cargar_scripts_desde_json():
	var ruta = "res://resources/scripts_biblioteca.json"
	if FileAccess.file_exists(ruta):
		var archivo = FileAccess.open(ruta, FileAccess.READ)
		var contenido = archivo.get_as_text()
		archivo.close()
	
		var json = JSON.new()
		var error = json.parse(contenido)
		if error == OK:
			base_de_scripts = json.data
			print("JSON de scripts cargado con éxito.")
		else:
			print("Error al parsear JSON: ", json.get_error_message())
	else:
		print("Error: No se encontró el archivo JSON en ", ruta)

func tiene_todo():
	# Versión simplificada
	for valor in grimorios.values():
		if valor == false:
			return false
	return true
