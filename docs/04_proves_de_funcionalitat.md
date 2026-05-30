# Proves i errors

## Problemes trobats

### Error de sincronització amb Rojo
Durant el desenvolupament es va produir un problema amb la sincronització entre Roblox Studio i VS Code.

Es va detectar que existien dos ServerScriptService duplicats provocats per una mala configuració inicial dels fitxers `init.server.luau`.

### Errors amb WaitForChild
En diferents moments van aparèixer errors relacionats amb variables nil i objectes inexistents.

Es van solucionar revisant:
- noms de variables
- majúscules/minúscules
- sincronització del projecte

### Sistema d'Auto Scratch
El sistema automàtic inicialment no funcionava correctament perquè algunes estadístiques no existien dins de `PlayerData`.

Es va solucionar afegint correctament les noves variables al sistema de dades del jugador.

---

## Proves realitzades

- Compra de tiquets
- Sistema de rascat
- Sistema de jackpots
- Sistema de Luck
- Sistema de nivells
- Sistema de prestigi
- Sistema d'Auto Scratch
- Millora de velocitat