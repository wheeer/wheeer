extends StaticBody2D

var mago_esta_cerca = false

# Se activa cuando el jugador entra al círculo grande
func _on_zona_interaccion_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		mago_esta_cerca = true
		print("Cerca del Altar. Presiona E para compilar.")

# Se activa cuando el jugador se aleja
func _on_zona_interaccion_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		mago_esta_cerca = false

func _process(_delta: float) -> void:
	# Verifica si está cerca y si presionó la tecla de acción (E)
	if mago_esta_cerca and Input.is_action_just_pressed("interact"):
		if GameManager.tiene_todo():
			print("¡PROYECTO COMPILADO! jugador ha pasado de Mago a Programador.")
		else:
			print("Aún te faltan Grimorios. Revisa los semestres.")
