extends Area2D

var velocidad = 600
var letra = ""
var es_correcta = true
var ha_chocado = false

func _ready():
	$Label.text = letra
	# Color normal para todas al inicio
	$Label.modulate = Color.WHITE 

func _process(delta):
	if not ha_chocado:
		# Todas vuelan hacia arriba inicialmente
		position.y -= velocidad * delta
		
		# Simulamos el "choque" con el muro
		if position.y <= 150: 
			llegar_al_muro()
	else:
		# Solo si es errónea, hace el glitch y cae después de chocar
		if not es_correcta:
			position.y += (velocidad / 2.0) * delta
			position.x += randf_range(-10, 10)

func llegar_al_muro():
	ha_chocado = true
	if not es_correcta:
		$Label.modulate = Color.RED # Se vuelve roja al fallar en el muro
	else:
		# Si es correcta, simplemente desaparece (se "encaja" en la muralla)
		queue_free()
