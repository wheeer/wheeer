extends Area2D

var velocidad = 600
var letra = ""
var es_correcta = true
var ha_chocado = false
var y_objetivo = 0 # Nueva variable para la altura de choque personalizada

func _ready():
	$Label.text = letra
	$Label.modulate = Color.WHITE 

func _process(delta):
	if not ha_chocado:
		position.y -= velocidad * delta
		
		# Ahora comparamos con la altura dinámica que le pasamos
		if position.y <= y_objetivo: 
			llegar_al_muro()
	else:
		if not es_correcta:
			position.y += (velocidad / 2.0) * delta
			position.x += randf_range(-10, 10)

func llegar_al_muro():
	ha_chocado = true
	if not es_correcta:
		$Label.modulate = Color.RED
	else:
		queue_free()
