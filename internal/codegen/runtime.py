def ligar(namedevice):
    print(namedevice + " ligado!\n")
    return 1

def desligar(namedevice):
    print(namedevice + " desligado!\n")
    return 0

def verificar(namedevice):
    print(namedevice + "verificado!\n")
    return 0

def alert(device, msg, val=None):
    if not val:
        print(f"[ALERT] {device}: {msg}")
    else:
        print(f"[ALERT] {device}: {msg} - {val}")
