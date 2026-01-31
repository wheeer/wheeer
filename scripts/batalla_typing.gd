extends Node2D

@onready var muro_codigo = $InterfazBatalla/RichTextLabel
@onready var mago = $MagoBatalla

var codigo_objetivo = "Algoritmo Saludo\n\tEscribir \"Hola Mundo\"\nFinAlgoritmo"
var indice_caracter_actual = 0 
var escena_bala = preload("res://scenes/proyectil_letra.tscn")

func _ready():
	# alineación a la izquierda
	muro_codigo.bbcode_enabled = true
	actualizar_texto_visual()
	# El mago empieza al inicio del bloque de texto
	mago.global_position.x = muro_codigo.global_position.x

func _input(event):
	if indice_caracter_actual >= codigo_objetivo.length():
		return

	if event is InputEventKey and event.pressed:
		var letra_presionada = ""
		var caracter_objetivo = codigo_objetivo[indice_caracter_actual]
		
		# Detección estricta de teclas
		if event.keycode == KEY_ENTER:
			letra_presionada = "\n"
		elif event.keycode == KEY_TAB:
			letra_presionada = "\t"
		elif event.keycode == KEY_SPACE:
			letra_presionada = " "
		else:
			letra_presionada = char(event.unicode)

		# Ignorar teclas que no generan caracteres (como Shift solo)
		if letra_presionada == "": return

		if letra_presionada == caracter_objetivo:
			# ACIERTO
			indice_caracter_actual += 1
			actualizar_texto_visual()
			disparar_proyectil(letra_presionada, true)
			ajustar_posicion_mago_dinamica()
			
			if indice_caracter_actual >= codigo_objetivo.length():
				victoria_batalla()
		else:
			# ERROR
			disparar_proyectil(letra_presionada, false)

func actualizar_texto_visual():
	var parte_escrita = codigo_objetivo.left(indice_caracter_actual)
	var resto = codigo_objetivo.substr(indice_caracter_actual)
	
	var ayuda = ""
	var salto_caracter = 0
	
	if resto.length() > 0:
		var siguiente = resto[0]
		if siguiente == "\n": 
			# \n al final de la ayuda para que el texto NO suba
			ayuda = "[color=#ff00ff][font_size=16] ENTER↵ [/font_size][/color]\n"
			salto_caracter = 1
		elif siguiente == "\t": 
			ayuda = "[color=#ff00ff][font_size=16] TAB→ [/font_size][/color]"
			salto_caracter = 1
		elif siguiente == " ": 
			ayuda = "[color=#ff00ff][font_size=16] ESPACIO [/font_size][/color]"
			salto_caracter = 1
	
	var parte_restante_visible = resto.substr(salto_caracter)
	
	# Actualizar texto.
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
	
	# Traducitor de símbolos invisibles para el proyectil
	var texto_bala = letra_a_lanzar
	if letra_a_lanzar == "\n": texto_bala = "ENTER"
	elif letra_a_lanzar == "\t": texto_bala = "TAB"
	elif letra_a_lanzar == " ": texto_bala = "SPC"
	
	nueva_bala.letra = texto_bala
	nueva_bala.es_correcta = es_correcta
	nueva_bala.global_position = $MagoBatalla/PuntoDisparo.global_position
	add_child(nueva_bala)

func victoria_batalla():
	GameManager.muro_semestre1_derrotado = true
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://scenes/semestre1.tscn")
