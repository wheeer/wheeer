extends Node
class_name GestorHabilidades

var batalla 

func _init(referencia_batalla):
	batalla = referencia_batalla

func habilidad_rafaga():
	var carga = batalla.puntos_calculadora.carga_rafaga
	if carga < 25.0 or batalla.fase_final_activa: return
	
	var letras = 5
	var color = Color(1, 1, 1)

	if carga >= 100.0:
		letras = 20
		color = Color(0, 2, 2)
		batalla.puntos_calculadora.carga_rafaga = 0
	elif carga >= 50.0:
		letras = 10
		color = Color(0.5, 0.5, 2)
		batalla.puntos_calculadora.carga_rafaga -= 50
	else:
		letras = 5
		batalla.puntos_calculadora.carga_rafaga -= 25

	if batalla.visual.has_method("crear_rayo_escritura"):
		batalla.visual.crear_rayo_escritura(color)
	
	_ejecutar_autocompletado(letras, 0.02)

func habilidad_palabra():
	# Solo necesita tener al menos 1 uso acumulado
	if batalla.puntos_calculadora.usos_palabra <= 0 or batalla.fase_final_activa: return
	
	batalla.puntos_calculadora.usos_palabra -= 1
	var resto = batalla.codigo_objetivo.substr(batalla.indice_caracter_actual)
	var e_pos = resto.find(" ")
	var n_pos = resto.find("\n")
	var limite = min(e_pos if e_pos != -1 else 999, n_pos if n_pos != -1 else 999)
	if limite == 999: limite = resto.length()
	
	_ejecutar_autocompletado(limite + 1, 0.03)

func habilidad_especial():
	# Habilidad de Frase (Suprimir)
	if batalla.puntos_calculadora.usos_frase <= 0 or batalla.fase_final_activa: return
	
	batalla.puntos_calculadora.usos_frase -= 1
	var resto = batalla.codigo_objetivo.substr(batalla.indice_caracter_actual)
	var n_pos = resto.find("\n")
	var chars = (n_pos + 1) if n_pos != -1 else resto.length()
	
	_ejecutar_autocompletado(chars, 0.01)

func _ejecutar_autocompletado(cantidad, delay):
	batalla.fase_final_activa = true
	for i in range(cantidad):
		if batalla.indice_caracter_actual >= batalla.codigo_objetivo.length(): 
			break
		batalla._simular_tecla_correcta(batalla.codigo_objetivo[batalla.indice_caracter_actual])
		await batalla.get_tree().create_timer(delay).timeout
	
	# Verificación de estado final
	if batalla.indice_caracter_actual >= batalla.codigo_objetivo.length():
		batalla.victoria_batalla()
	else:
		batalla.fase_final_activa = false
