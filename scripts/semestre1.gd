extends Node2D 

func _ready():
	# Si existe una posición guardada, el Mago aparece ahí
	if GameManager.posicion_mago_antes_de_batalla != Vector2.ZERO:
		$Player.global_position = GameManager.posicion_mago_antes_de_batalla
