def ligar(namedevice):
    print(namedevice + "ligado!")
    return 1

def desligar(namedevice):
    print(namedevice + "desligado!")
    return 0

def verificar(namedevice):
    print(namedevice + "verificado!")
    return 0

def alert(device, msg, val=None):
    if not val:
        print(f"[ALERT] {device}: {msg}")
    else:
        print(f"[ALERT] {device}: {msg} - {val}")


potencia = 100

ligar('lampada')


