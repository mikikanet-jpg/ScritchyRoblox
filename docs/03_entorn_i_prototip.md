# 03_entorn_i_prototip.md

# 1. Entorn de desenvolupament

## IDE utilitzat

Per al desenvolupament del projecte s’han utilitzat les següents eines:

* Roblox Studio → desenvolupament del joc i proves
* Visual Studio Code → edició del codi
* Rojo → sincronització entre Roblox Studio i el codi local
* GitHub → control de versions del projecte

---

## Configuració bàsica

S’ha configurat un repositori GitHub amb l’estructura inicial del projecte.

També s’ha configurat Rojo per permetre treballar el codi des de Visual Studio Code i sincronitzar-lo amb Roblox Studio.

El projecte inclou:

* carpeta docs
* carpeta img
* carpeta src
* fitxers de configuració de Rojo

---

# 2. Decisions inicials d’implementació

Per facilitar el desenvolupament i mantenir el projecte viable dins del temps disponible, s’han pres les següents decisions:

* Utilitzar una sola habitació com a escenari principal
* Utilitzar gràfics simples i assets bàsics de Roblox
* Separar el joc en diferents sistemes:

  * compra de tiquets
  * sistema de tiquets
  * prestigi
  * dades del jugador
* Implementar les interaccions mitjançant ProximityPrompt

Aquestes decisions permeten mantenir una estructura clara i fàcil d’ampliar.

---

# 3. Estat actual del prototip

Actualment el prototip inclou:

* Habitació funcional
* Zona d’ordinador
* Zona de taula per rascar tiquets
* Moviment del jugador
* Primera interacció amb el PC
* Sistema inicial amb tecla E mitjançant ProximityPrompt

---

# 4. Evidències del treball realitzat

## Habitació inicial del joc

Inserir captura de pantalla:

![alt text](/img/image.png)

Breu explicació:
S’ha creat una habitació simple amb diferents zones interactives per al jugador.

---

## Sistema d’interacció amb el PC

Inserir captura de pantalla:

![alt text](image3.png)

Breu explicació:
S’ha implementat un sistema d’interacció amb el PC utilitzant ProximityPrompt i la tecla E.

---

## Configuració del projecte

Inserir captura de pantalla:

![alt text](/img/diagrama_classes.pngimage-1.png)

Breu explicació:
Es mostra l’estructura inicial del repositori i la configuració del projecte amb Rojo.

---

# 5. Implementació inicial

La primera funcionalitat implementada permet:

* Detectar quan el jugador s’apropa al PC
* Mostrar una interacció amb la tecla E
* Executar un script inicial quan el jugador interactua

Aquest sistema servirà de base per implementar la compra de tiquets.

---

# 6. Condicions mínimes assolides

Actualment el projecte compleix les següents condicions mínimes:

* Entorn configurat correctament
* Repositori funcional
* Prototip inicial jugable
* Sistema bàsic d’interacció implementat
* Estructura preparada per continuar el desenvolupament

---
