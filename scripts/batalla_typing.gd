extends Node2D

@onready var muro_codigo = $InterfazBatalla/RichTextLabel
@onready var mago = $MagoBatalla
@onready var panel_consola = $InterfazBatalla/PanelConsola
@onready var log_texto = $InterfazBatalla/PanelConsola/LogTexto
@onready var boton_compilar = $InterfazBatalla/BotonCompilar

var fase_final_activa = false 
var codigo_objetivo = "" 
var indice_caracter_actual = 0 
var escena_bala = preload("res://scenes/proyectil_letra.tscn")

# Variable que guardará el ejercicio actual sacado del JSON
var script_actual_data = {}
# Progresión
var scripts_totales_muro = 3 
var scripts_actuales = 0


# Estadísticas
var tiempo_inicio = 0.0
var total_pulsaciones = 0
var errores = 0

func _ready():
	muro_codigo.bbcode_enabled = true
	panel_consola.hide() # Empezamos con consola oculta
	preparar_siguiente_script() # Cargamos el primer script

func _input(event):
	if event is InputEventKey and event.pressed:
		# --- CONECTOR CRÍTICO ---
		# Si el botón de compilar está visible, el Enter debe activar la consola
		if fase_final_activa:
			if event.keycode == KEY_ENTER:
				iniciar_secuencia_compilacion()
			return # No procesamos más teclas si estamos en fase final

		# --- LÓGICA DE TIPEO ---
		if indice_caracter_actual >= codigo_objetivo.length():
			return

		total_pulsaciones += 1
		var letra_presionada = ""
		var caracter_objetivo = codigo_objetivo[indice_caracter_actual]
		
		if event.keycode == KEY_ENTER: letra_presionada = "\n"
		elif event.keycode == KEY_TAB: letra_presionada = "\t"
		elif event.keycode == KEY_SPACE: letra_presionada = " "
		else: letra_presionada = char(event.unicode)

		if event.unicode == 0 and letra_presionada not in ["\n", "\t", " "]:
			return

		if letra_presionada == caracter_objetivo:
			indice_caracter_actual += 1
			actualizar_texto_visual()
			disparar_proyectil(letra_presionada, true)
			ajustar_posicion_mago_dinamica()
			
			if indice_caracter_actual >= codigo_objetivo.length():
				victoria_batalla()
		else:
			errores += 1
			disparar_proyectil(letra_presionada, false)

func actualizar_texto_visual():
	var parte_escrita = codigo_objetivo.left(indice_caracter_actual)
	var resto = codigo_objetivo.substr(indice_caracter_actual)
	var ayuda = ""
	var salto_caracter = 0
	
	if resto.length() > 0:
		var siguiente = resto[0]
		if siguiente == "\n": 
			ayuda = "[color=#ff00ff][font_size=16] ENTER↵ [/font_size][/color]\n"
			salto_caracter = 1
		elif siguiente == "\t": 
			ayuda = "[color=#ff00ff][font_size=16] TAB→ [/font_size][/color]"
			salto_caracter = 1
		elif siguiente == " ": 
			ayuda = "[color=#ff00ff][font_size=16] ESPACIO [/font_size][/color]"
			salto_caracter = 1
	
	var parte_restante_visible = resto.substr(salto_caracter)
	muro_codigo.text = "[color=#ffffff]" + parte_escrita + "[/color]" + ayuda + "[color=#4b4b4b]" + parte_restante_visible + "[/color]"

func ajustar_posicion_mago_dinamica():
	var texto_hasta_ahora = codigo_objetivo.left(indice_caracter_actual)
	var lineas = texto_hasta_ahora.split("\n")
	var caracteres_en_linea_actual = lineas[-1].length()
	var ancho_caracter = 14 
	var objetivo_x = muro_codigo.global_position.x + (caracteres_en_linea_actual * ancho_caracter)
	var tween = create_tween()
	tween.tween_property(mago, "global_position:x", objetivo_x, 0.15)

func disparar_proyectil(letra_a_lanzar, es_correcta):
	var nueva_bala = escena_bala.instantiate()
	var texto_hasta_ahora = codigo_objetivo.left(indice_caracter_actual)
	var numero_de_lineas = texto_hasta_ahora.split("\n").size()
	var altura_base = 10 
	var espacio_entre_lineas = 26 
	nueva_bala.y_objetivo = altura_base + ((numero_de_lineas - 1) * espacio_entre_lineas)
	
	var texto_bala = letra_a_lanzar
	if letra_a_lanzar == "\n": texto_bala = "ENTER"
	elif letra_a_lanzar == "\t": texto_bala = "TAB"
	elif letra_a_lanzar == " ": texto_bala = "SPC"
	
	nueva_bala.letra = texto_bala
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
	
	var lineas = [
		"*** Ejecución Iniciada. ***",
		"> " + script_actual_data["titulo"],
		script_actual_data["salida"], # Muestra la salida definida en tu JSON
		"*** Ejecución Finalizada con éxito. ***"
	]
	
	for linea in lineas:
		log_texto.add_text(linea + "\n")
		await get_tree().create_timer(0.4).timeout
	
	scripts_actuales += 1
	
	if scripts_actuales < scripts_totales_muro:
		await get_tree().create_timer(1.0).timeout
		preparar_siguiente_script()
	else:
		finalizar_muro_completo()

func preparar_siguiente_script():
	# Accedemos directamente a la base de datos del GameManager
	var biblioteca = GameManager.base_de_scripts["facil"]
	
	# Guardamos el diccionario del ejercicio que toca
	script_actual_data = biblioteca[scripts_actuales]
	
	# Extraemos el código
	codigo_objetivo = script_actual_data["codigo"]
	
	# Reset de interfaz
	indice_caracter_actual = 0
	fase_final_activa = false
	panel_consola.hide()
	actualizar_texto_visual()
	mago.global_position.x = muro_codigo.global_position.x
	
func finalizar_muro_completo():
	var tiempo_final = Time.get_unix_time_from_system()
	var duracion_total = tiempo_final - tiempo_inicio
	var precision = 0.0
	if total_pulsaciones > 0:
		precision = (float(total_pulsaciones - errores) / total_pulsaciones) * 100.0
	var kpm = 0.0
	if duracion_total > 0:
		kpm = (total_pulsaciones / duracion_total) * 60.0
	
	log_texto.add_text("\n=== INFORME DE RENDIMIENTO ===\n")
	log_texto.add_text("Precisión: " + str(snapped(precision, 0.1)) + "%\n")
	log_texto.add_text("Velocidad: " + str(snapped(kpm, 1)) + " KPM\n")
	log_texto.add_text("Errores: " + str(errores) + "\n")
	log_texto.add_text("==============================\n")
	
	await get_tree().create_timer(4.0).timeout
	GameManager.muro_semestre1_derrotado = true
	get_tree().change_scene_to_file("res://scenes/semestre1.tscn")
