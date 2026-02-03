extends Node2D

@onready var muro_codigo = $InterfazBatalla/RichTextLabel
@onready var mago = $MagoBatalla
@onready var panel_consola = $InterfazBatalla/PanelConsola
@onready var log_texto = $InterfazBatalla/PanelConsola/LogTexto
@onready var boton_compilar = $InterfazBatalla/BotonCompilar

# --- CAPAS DE SERVICIO (Delegación) ---
var puntos_calculadora = CalculadoraPuntos.new()
@onready var habilidades = GestorHabilidades.new(self)

# --- VARIABLES DE ESTADO ---
var fase_final_activa = false 
var esperando_salida = false
var codigo_objetivo = "" 
var indice_caracter_actual = 0 
var escena_bala = preload("res://scenes/proyectil_letra.tscn")

var script_actual_data = {}
var scripts_totales_muro = 3 
var scripts_actuales = 0

# Estadísticas base
var tiempo_inicio = 0.0
var total_pulsaciones = 0
var errores = 0

func _ready():
	muro_codigo.bbcode_enabled = true
	panel_consola.hide()
	preparar_siguiente_script()

func _input(event):
	if not (event is InputEventKey and event.pressed): return

	if esperando_salida:
		_gestionar_salida()
		return

	if fase_final_activa:
		_gestionar_confirmacion_compilacion(event)
		return

	_gestionar_escritura_y_habilidades(event)


# --- ENRUTADOR DE INPUT ---
func _gestionar_escritura_y_habilidades(event):
	# Habilidad: Control (Ráfaga) - KEY_CTRL es universal en Godot
	if event.keycode == KEY_CTRL:
		habilidades.habilidad_rafaga()
		return
	
	# Habilidad: Borrar (Completar Palabra)
	if event.keycode == KEY_BACKSPACE:
		habilidades.habilidad_palabra()
		return
		
	_procesar_tecla_manual(event)

func _procesar_tecla_manual(event):
	if indice_caracter_actual >= codigo_objetivo.length(): return
	
	var letra_presionada = _obtener_tecla_string(event)
	if letra_presionada == "": return

	total_pulsaciones += 1
	if letra_presionada == codigo_objetivo[indice_caracter_actual]:
		_simular_tecla_correcta(letra_presionada)
	else:
		_simular_tecla_error(letra_presionada)

# --- EJECUCIÓN DE ACIERTO/ERROR (Llamadas a servicios) ---
func _simular_tecla_correcta(letra):
	indice_caracter_actual += 1
	puntos_calculadora.registrar_acierto()
	
	actualizar_texto_visual()
	disparar_proyectil(letra, true)
	ajustar_posicion_mago_dinamica()
	
	if letra == " " or letra == "\n": 
		puntos_calculadora.registrar_palabra_completada()
	
	# --- FEEDBACK VISUAL Y CONSOLA ---
	_actualizar_feedback_visual()

	if indice_caracter_actual >= codigo_objetivo.length():
		puntos_calculadora.registrar_bloque_completado()
		victoria_batalla()

func _actualizar_feedback_visual():
	var racha = puntos_calculadora.racha_actual
	
	
	if racha == 10:
		panel_consola.show()
		log_texto.add_text("\n[SISTEMA]: Autocompletado (Borrar) LISTO\n")
		mago.modulate = Color(1, 1, 0) # Amarillo
	elif racha == 15:
		log_texto.add_text("\n[SISTEMA]: Ráfaga (CTRL) LISTA\n")
		mago.modulate = Color(0, 1, 1) # Cian
	elif racha == 0:
		mago.modulate = Color(1, 1, 1) # Blanco
	
func _simular_tecla_error(letra):
	errores += 1
	puntos_calculadora.registrar_error()
	disparar_proyectil(letra, false)

# --- FUNCIONES VISUALES Y DE FLUJO ---
func actualizar_texto_visual():
	var parte_escrita = codigo_objetivo.left(indice_caracter_actual)
	var resto = codigo_objetivo.substr(indice_caracter_actual)
	var ayuda = ""
	var salto = 0
	
	if resto.length() > 0:
		if resto[0] == "\n": ayuda = "[color=#ff00ff] ENTER↵ [/color]\n"; salto = 1
		elif resto[0] == "\t": ayuda = "[color=#ff00ff] TAB→ [/color]"; salto = 1
		elif resto[0] == " ": ayuda = "[color=#ff00ff] ESPACIO [/color]"; salto = 1
	
	muro_codigo.text = "[color=#ffffff]" + parte_escrita + "[/color]" + ayuda + "[color=#4b4b4b]" + resto.substr(salto) + "[/color]"

func disparar_proyectil(letra, es_correcta):
	var nueva_bala = escena_bala.instantiate()
	var lineas = codigo_objetivo.left(indice_caracter_actual).split("\n").size()
	nueva_bala.y_objetivo = 10 + ((lineas - 1) * 26)
	nueva_bala.letra = "ENTER" if letra == "\n" else ("TAB" if letra == "\t" else ("SPC" if letra == " " else letra))
	nueva_bala.es_correcta = es_correcta
	nueva_bala.global_position = $MagoBatalla/PuntoDisparo.global_position
	add_child(nueva_bala)

func victoria_batalla():
	fase_final_activa = true 
	boton_compilar.show()
	if tiempo_inicio == 0: 
		tiempo_inicio = Time.get_unix_time_from_system()

func iniciar_secuencia_compilacion():
	fase_final_activa = false
	boton_compilar.hide()
	panel_consola.show()
	log_texto.clear()
	
	var lineas = ["*** Iniciando ***", "> " + script_actual_data["titulo"], script_actual_data["salida"], "*** Éxito ***"]
	for l in lineas:
		log_texto.add_text(l + "\n")
		await get_tree().create_timer(0.4).timeout
	
	scripts_actuales += 1
	if scripts_actuales < scripts_totales_muro:
		await get_tree().create_timer(1.0).timeout
		preparar_siguiente_script()
	else:
		finalizar_muro_completo()

func preparar_siguiente_script():
	script_actual_data = GameManager.base_de_scripts["facil"][scripts_actuales]
	codigo_objetivo = script_actual_data["codigo"]
	indice_caracter_actual = 0
	fase_final_activa = false
	panel_consola.hide()
	actualizar_texto_visual()
	mago.global_position.x = muro_codigo.global_position.x

func finalizar_muro_completo():
	var tiempo_total = Time.get_unix_time_from_system() - tiempo_inicio
	var precision = puntos_calculadora.calcular_precision(total_pulsaciones, errores)
	var ppm = puntos_calculadora.calcular_ppm(total_pulsaciones, tiempo_total)
	
	log_texto.add_text("\n=== ESTADÍSTICAS DE BATALLA ===\n")
	log_texto.add_text("PUNTOS TOTALES: " + str(puntos_calculadora.puntos_totales) + "\n")
	log_texto.add_text("PRECISIÓN: " + str(snapped(precision, 0.1)) + "%\n")
	log_texto.add_text("VELOCIDAD: " + str(ppm) + " PPM\n")
	log_texto.add_text("RACHA MÁXIMA: " + str(puntos_calculadora.racha_maxima) + "\n")
	log_texto.add_text("\n===============================\n")
	log_texto.add_text("PULSA CUALQUIER TECLA PARA VOLVER...")
	
	esperando_salida = true
func _gestionar_salida():
	GameManager.muro_semestre1_derrotado = true
	get_tree().change_scene_to_file("res://scenes/semestre1.tscn")

func _gestionar_confirmacion_compilacion(event):
	if event.keycode == KEY_ENTER: iniciar_secuencia_compilacion()

func _obtener_tecla_string(event) -> String:
	if event.keycode == KEY_ENTER: return "\n"
	if event.keycode == KEY_TAB: return "\t"
	if event.keycode == KEY_SPACE: return " "
	if event.unicode != 0: return char(event.unicode)
	return ""

func ajustar_posicion_mago_dinamica():
	var characters = codigo_objetivo.left(indice_caracter_actual).split("\n")[-1].length()
	var tween = create_tween()
	tween.tween_property(mago, "global_position:x", muro_codigo.global_position.x + (characters * 14), 0.15)
