extends StaticBody2D

@export var interfaz_batalla: CanvasLayer 
var mago_cerca = false

func _ready():
	if interfaz_batalla:
		interfaz_batalla.hide()

func _on_zona_deteccion_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		mago_cerca = true
		print("Mago frente al muro. Presiona E para descifrar.")

func _on_zona_deteccion_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		mago_cerca = false
		if interfaz_batalla:
			interfaz_batalla.hide()
			# Si el Mago se aleja, le devuelve el movimiento
			body.esta_en_batalla = false 

func _process(_delta: float) -> void:
	if GameManager.muro_semestre1_derrotado:
		queue_free()
	if mago_cerca and Input.is_action_just_pressed("interact"):
		# GUARDAR POSICIÓN: Busca al Player en la escena actual
		var player = get_tree().current_scene.get_node("Player") 
		if player:
			GameManager.posicion_mago_antes_de_batalla = player.global_position
		
		get_tree().change_scene_to_file("res://scenes/batalla_typing.tscn")
