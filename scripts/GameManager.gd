extends Node

# Diccionario que guarda el progreso de los 4 semestres
var grimorios = {
	"Semestre1": false,
	"Semestre2": false,
	"Semestre3": false,
	"Semestre4": false
}
var posicion_mago_antes_de_batalla = Vector2.ZERO
var muro_semestre1_derrotado = false

# Función para verificar si el Mago ya es un Programador Real
func tiene_todo():
	return grimorios["Semestre1"] and grimorios["Semestre2"] and grimorios["Semestre3"] and grimorios["Semestre4"]
