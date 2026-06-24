estados = {}
def ligar(namedevice):
    print(namedevice + " ligado!\n")
    estados[namedevice] = True
    return 1

def desligar(namedevice):
    print(namedevice + " desligado!\n")
    estados[namedevice] = False
    return 0

def verificar(namedevice):
    if estados.get(namedevice):
        print(namedevice + " está ligado")
        return 1
    else:
        print(namedevice + " está desligado")
        return 0


def alert(device, msg, val=None):
    if not val:
        print(f"[ALERT] {device}: {msg}")
    else:
        print(f"[ALERT] {device}: {msg} - {val}")


umidade = 0
potenciaUmidificador = 0
potenciaUmidificador = 100
if umidade < 40:
	alert('Monitor', 'Ar seco detectado')
	if verificar('umidificador') == 0:
		ligar('umidificador')
	potenciaUmidificador = 100

