extends Node
class_name GestorHabilidades

var batalla 

func _init(referencia_batalla):
	batalla = referencia_batalla

# --- HABILIDADES ---
func habilidad_rafaga():
	if batalla.puntos_calculadora.racha_actual < 15 or batalla.fase_final_activa: return
	
	batalla.fase_final_activa = true
	for i in range(5):
		if batalla.indice_caracter_actual >= batalla.codigo_objetivo.length(): break
		
		batalla._simular_tecla_correcta(batalla.codigo_objetivo[batalla.indice_caracter_actual])
		
		# Espera breve para feedback visual de disparo
		if batalla.indice_caracter_actual < batalla.codigo_objetivo.length():
			await batalla.get_tree().create_timer(0.04).timeout
	
	_limpiar_estado_habilidad()

func habilidad_palabra():
	if batalla.puntos_calculadora.racha_actual < 10 or batalla.fase_final_activa: return
	
	batalla.fase_final_activa = true
	var resto = batalla.codigo_objetivo.substr(batalla.indice_caracter_actual)
	
	# Buscar final de palabra
	var e_pos = resto.find(" ")
	var n_pos = resto.find("\n")
	var limite = -1
	
	if e_pos != -1 and n_pos != -1: limite = min(e_pos, n_pos)
	elif e_pos != -1: limite = e_pos
	else: limite = n_pos

	var chars = (limite + 1) if limite != -1 else resto.length()

	for i in range(chars):
		if batalla.indice_caracter_actual >= batalla.codigo_objetivo.length(): break
		batalla._simular_tecla_correcta(batalla.codigo_objetivo[batalla.indice_caracter_actual])
		
		if batalla.indice_caracter_actual < batalla.codigo_objetivo.length():
			await batalla.get_tree().create_timer(0.03).timeout
	
	_limpiar_estado_habilidad()

# --- SEGURIDAD ---
func _limpiar_estado_habilidad():
	if batalla.indice_caracter_actual < batalla.codigo_objetivo.length():
		batalla.fase_final_activa = false
	else:
		batalla.fase_final_activa = true

func habilidad_especial():
	pass
