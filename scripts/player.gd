extends CharacterBody2D
var escena_proyectil = preload("res://scenes/proyectil_letra.tscn")
const SPEED = 500.0
var esta_en_batalla = false

func _physics_process(_delta: float) -> void:
	# Si está en batalla, no procesa el movimiento ni el input de dirección
	if esta_en_batalla:
		velocity = Vector2.ZERO
		move_and_slide()
		return # Detiene la ejecución de lo que sigue abajo
	var input_direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if input_direction != Vector2.ZERO:

		velocity = input_direction.normalized() * SPEED
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)

	move_and_slide()
	
	if Input.is_action_just_pressed("interact"):
		_on_interact()

func _unhandled_input(event: InputEvent) -> void:
	# Solo dispara si el Mago está en batalla y se presiona una tecla
	if esta_en_batalla and event is InputEventKey and event.pressed:
		var tecla = char(event.unicode)
		
		# Evita disparar con teclas invisibles (como Shift o Ctrl)
		if tecla != "":
			disparar_letra(tecla)

func disparar_letra(letra_a_lanzar):
	var nuevo_proyectil = escena_proyectil.instantiate()
	nuevo_proyectil.letra = letra_a_lanzar
	
	# Lo posiciona donde está el Marker2D
	nuevo_proyectil.global_position = $PuntoDisparo.global_position
	
	# Lo añade a la escena principal
	get_tree().get_root().add_child(nuevo_proyectil)
	print("Mago lanza: ", letra_a_lanzar)
	
func _on_interact():
	print("Syntax Sorcerer, lanza un pulso de lógica.")
	pass
