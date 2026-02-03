extends Node
class_name CalculadoraPuntos

# --- VARIABLES DE ESTADO ---
var puntos_totales : int = 0
var racha_actual : int = 0
var racha_maxima : int = 0

# --- MULTIPLICADORES (Ajustables para equilibrio) ---
var valor_letra = 10
var bono_palabra = 50
var bono_bloque = 200

func registrar_acierto():
	racha_actual += 1
	if racha_actual > racha_maxima:
		racha_maxima = racha_actual
	
	# El multiplicador crece con la racha, pero le ponemos un tope (cap)
	# Ejemplo: racha de 10 = x1.1, racha de 50 = x1.5
	var multiplicador = 1.0 + (min(racha_actual, 100) * 0.01)
	puntos_totales += int(valor_letra * multiplicador)

func registrar_error():
	racha_actual = 0 # La racha se corta al fallar

func registrar_palabra_completada():
	puntos_totales += bono_palabra

func registrar_bloque_completado():
	puntos_totales += bono_bloque

func obtener_puntos_texto() -> String:
	# Formatea el número con puntos de miles para que sea legible
	return str(puntos_totales)


func calcular_precision(total_pulsaciones: int, errores: int) -> float:
	if total_pulsaciones == 0: return 0.0
	# La precisión es: (Aciertos / Total) * 100
	var aciertos = total_pulsaciones - errores
	return (float(aciertos) / float(total_pulsaciones)) * 100.0

func calcular_ppm(total_pulsaciones: int, tiempo_segundos: float) -> int:
	if tiempo_segundos <= 0: return 0
	# PPM = (Total pulsaciones / tiempo en segundos) * 60
	return int((float(total_pulsaciones) / tiempo_segundos) * 60.0)
