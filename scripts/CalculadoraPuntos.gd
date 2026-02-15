extends Node
class_name CalculadoraPuntos

var puntos_totales : int = 0
var racha_actual : int = 0
var racha_maxima : int = 0

# --- MEDIDORES ---
var carga_rafaga : float = 0.0     # Barra visual progresiva (0 a 100)
var usos_palabra : int = 0         # Acumulaciones (Máximo 3)
var progreso_palabra : float = 0.0 # Progreso hacia el siguiente uso
var usos_frase : int = 0           # Acumulaciones (Máximo 2)
var progreso_frase : float = 0.0   # Progreso hacia el siguiente uso

func registrar_acierto():
	racha_actual += 1
	if racha_actual > racha_maxima: racha_maxima = racha_actual
	
	# Ráfaga: Carga continua
	carga_rafaga = min(carga_rafaga + 2.0, 100.0)
	
	# Palabra: Si tiene menos de 3, carga. Si llega a 3, limpia el progreso.
	if usos_palabra < 3:
		progreso_palabra += 5.0 
		if progreso_palabra >= 100.0:
			usos_palabra += 1
			progreso_palabra = 0.0 # Se limpia al ganar el uso
			
	# Frase: Si tiene menos de 2, carga. Si llega a 2, limpia el progreso.
	if usos_frase < 2:
		progreso_frase += 2.0 
		if progreso_frase >= 100.0:
			usos_frase += 1
			progreso_frase = 0.0 # Se limpia al ganar el uso

func registrar_palabra_completada():
	puntos_totales += 50
	carga_rafaga = min(carga_rafaga + 5.0, 100.0)

func registrar_error():
	racha_actual = 0
	carga_rafaga = max(carga_rafaga - 10.0, 0.0)

func registrar_bloque_completado():
	puntos_totales += 200 
	carga_rafaga = min(carga_rafaga + 25.0, 100.0)
	# Al completar bloque, regalamos un uso de cada una si hay espacio
	if usos_palabra < 3: usos_palabra += 1
	if usos_frase < 2: usos_frase += 1

func obtener_porcentaje_combo() -> String:
	return str(min(racha_actual, 300)) + "%"

# PPM y estadísticas igual que antes...
func calcular_ppm_tiempo_real(total, inicio):
	var t = Time.get_unix_time_from_system() - inicio
	return int((float(total) / max(t, 1.0)) * 60.0)
