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


temperatura = 0
umidade = 0
luminosidade = 0
pressao = 0
potVentilador = 0
potLampada = 0
potUmidificador = 0
potAquecedor = 0
temperatura = 25
umidade = 60
luminosidade = 300
pressao = 1013
potVentilador = 0
potLampada = 0
potUmidificador = 0
potAquecedor = 0
if temperatura > 30:
	ligar('ventilador')
	potVentilador = 100
	if temperatura > 40:
		alert('Monitor', 'Temperatura critica')
		alert('celular', 'Temperatura critica')
		alert('Central', 'Temperatura critica')

		ligar('alarme')
	else:
		alert('temperatura', 'Temperatura alta', 'Monitor')
else:
	if temperatura < 15:
		ligar('aquecedor')
		potAquecedor = 100
if umidade < 40:
	ligar('umidificador')
	potUmidificador = 80
	if verificar('umidificador') == 0:
		alert('Monitor', 'Umidificador falhou')
		alert('celular', 'Umidificador falhou')
else:
	if umidade > 70:
		alert('umidade', 'Umidade muito alta', 'Central')
if luminosidade < 100:
	ligar('lampada')
	potLampada = 100
else:
	desligar('lampada')
if temperatura > 30 and umidade > 70:
	alert('Monitor', 'Calor e umidade altos')
	alert('celular', 'Calor e umidade altos')
	alert('Central', 'Calor e umidade altos')
	alert('alarme', 'Calor e umidade altos')
if temperatura < 20 and umidade < 30 and luminosidade < 50:
	ligar('aquecedor')
	ligar('umidificador')
	ligar('lampada')
if pressao < 1000:
	alert('Monitor', 'Pressao baixa, tempestade', 'pressao')
	alert('Central', 'Pressao baixa, tempestade', 'pressao')

	if temperatura > 25:
		if umidade > 60:
			alert('Central', 'Risco de chuva forte')
if verificar('ventilador') == 1:
	estadoVent = verificar('ventilador')
	if estadoVent == 1:
		desligar('ventilador')
alert('Monitor', 'Sistema verificado')
alert('celular', 'Sistema verificado')
alert('Central', 'Sistema verificado')

desligar('alarme')
ligar('Monitor')

