from datetime import date

def calcular_edad(fecha_nacimiento: date) -> int:
    """
    Calcula la edad en años basada en la fecha de nacimiento.
    Se actualiza automáticamente cuando la persona cumple años.
    """
    hoy = date.today()
    edad = hoy.year - fecha_nacimiento.year
    
    # Verificar si ya cumplió años este año
    if (hoy.month, hoy.day) < (fecha_nacimiento.month, fecha_nacimiento.day):
        edad -= 1
    
    return edad

def validar_fecha_nacimiento(fecha_nacimiento: date) -> bool:
    """
    Valida que la fecha de nacimiento sea razonable para un estudiante.
    Debe tener entre 5 y 25 años.
    """
    edad = calcular_edad(fecha_nacimiento)
    return 5 <= edad <= 25

def obtener_proximo_cumpleanos(fecha_nacimiento: date) -> date:
    """
    Obtiene la fecha del próximo cumpleaños.
    """
    hoy = date.today()
    cumpleanos_este_ano = date(hoy.year, fecha_nacimiento.month, fecha_nacimiento.day)
    
    if cumpleanos_este_ano <= hoy:
        # Ya pasó este año, será el próximo año
        return date(hoy.year + 1, fecha_nacimiento.month, fecha_nacimiento.day)
    else:
        # Aún no ha llegado este año
        return cumpleanos_este_ano

def dias_hasta_cumpleanos(fecha_nacimiento: date) -> int:
    """
    Calcula cuántos días faltan para el próximo cumpleaños.
    """
    proximo_cumpleanos = obtener_proximo_cumpleanos(fecha_nacimiento)
    hoy = date.today()
    return (proximo_cumpleanos - hoy).days
