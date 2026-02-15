extends Node
class_name GestorVisual

var batalla

func _init(referencia_batalla):
	batalla = referencia_batalla

# Corregido para aceptar racha, ráfaga, y los 2 tipos de acumulaciones
func actualizar_interfaz(_racha, _c_rafaga, _u_palabra, _u_frase):
	# 1. Combo
	var label_combo = batalla.get_node("InterfazBatalla/LabelCombo")
	label_combo.text = "Combo " + batalla.puntos_calculadora.obtener_porcentaje_combo()
	
	# 2. Barra de Ráfaga (La única visual progresiva)
	var barra = batalla.get_node("InterfazBatalla/BarraEnergia")
	barra.value = _c_rafaga

	# 3. Mostrar cuántos usos tienes (Feedback simple de texto por ahora)
	# Por ejemplo, un label que diga "Palabra: 2/3 | Frase: 1/2"
	# var label_cargas = batalla.get_node("InterfazBatalla/LabelCargas")
	# label_cargas.text = "P: %d | F: %d" % [u_palabra, u_frase]
