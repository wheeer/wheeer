extends Node2D

@export_file("*.tscn") var escena_destino
var puede_interactuar = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		puede_interactuar = true
		print("Presiona E para entrar/combatir")

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		puede_interactuar = false

func _process(_delta: float) -> void:
	if puede_interactuar and Input.is_action_just_pressed("interact"):
		iniciar_transicion()

func iniciar_transicion():
	if escena_destino:
		get_tree().call_deferred("change_scene_to_file", escena_destino)
