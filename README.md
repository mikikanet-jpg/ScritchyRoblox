# 01_idea_i_abast.md

## 1. Títol provisional del joc

Scratch Room

---

## 2. Tipus de microvideojoc escollit

Joc de gestió amb mecàniques d’atzar i progressió (roguelike simple)

---

## 3. Objectiu del joc

Guanyar diners i progressar desbloquejant tiquets de diferents nivells fins arribar a un tiquet final molt difícil d’aconseguir.

---

## 4. Rol del jugador

El jugador controla un personatge dins d’una habitació i es pot moure lliurement.

Pot:

* Moure’s per la sala
* Interactuar amb un ordinador per comprar tiquets
* Interactuar amb una taula per rascar tiquets

---

## 5. Regles bàsiques

* El joc es desenvolupa en una habitació amb dues zones:

  * PC (compra de tiquets)
  * Taula (rascar tiquets)

* Els tiquets es compren amb diners i es consumeixen en rascar-los.

* Els tiquets estan organitzats per nivells (tiers) i es desbloquegen progressivament.

* Cada tiquet pot donar:

  * Guanys de diners
  * Pèrdues
  * Jackpot

---

## 6. Condicions de victòria i derrota

* Victòria: arribar al tiquet final després de múltiples runs i millores.

* Derrota:

  * Aparició del tiquet de mort que finalitza la run.

* També es pot acabar la run manualment mitjançant el sistema de prestigi.

* A la primera run només es pot acabar mitjançant la mort.

---

## 7. Bucle principal del joc

Moure’s per l’habitació → anar al PC → comprar tiquets → anar a la taula → rascar tiquets → obtenir resultat → repetir → mort o prestigi → nova run

---

## 8. Repte principal i dificultat

El repte principal és maximitzar els guanys i avançar en els nivells de tiquets abans d’acabar la run.

La dificultat augmenta perquè:

* Els tiquets avançats són més cars
* El risc de perdre diners es manté
* Calen diverses runs per progressar

---

## 9. Limitacions explícites

* Gràfics simples (assets bàsics de Roblox)
* Escenari limitat a una sola habitació
* Sistema de tiquets simple
* Interfície d’usuari simple
* Sense multijugador

---

## 10. Riscos tècnics

1. Probabilitats mal balancejades
   Solució: ajustar i provar valors

2. Tickets infinits o compra incorrecta
   Solució: validar diners i limitar quantitat de tiquets

3. Errors en el reset del joc al fer prestigi
   Solució: reiniciar variables correctament i guardar millores

---

## 11. Exploració amb IA

Prompt 1:
"Cómo estructurar un sistema de tickets con diferentes niveles (tiers) en un videojuego"

Resposta resumida:
Organitzar els tiquets per nivells amb una progressió clara i augment gradual de recompenses.

---

Prompt 2:
"Cómo implementar un sistema de prestigio en un juego y qué variables mantener entre partidas"

Resposta resumida:
Guardar millores permanents entre runs i reiniciar només les variables de la partida actual.

---

## 12. Proposta final escollida

Desenvolupar un joc dins d’una habitació on el jugador compra i rasca tiquets amb un sistema d’atzar, progressió per nivells i mecànica de prestigi.

---

## 13. Justificació de viabilitat

El projecte és viable perquè:

* Té una estructura simple i clara
* Es basa en mecàniques fàcils d’implementar
* L’escenari és reduït
* Es pot completar dins del temps disponible (≤10 hores)

---

## 14. Mini pla de treball

1. Definir idea del joc i mecàniques
2. Dissenyar sistema (tiquets, prestigi, habitació)
3. Crear prototip en Roblox (moviment, compra, rascar)
4. Realitzar proves i detectar errors
5. Aplicar millores i optimitzar el sistema

---

## 15. Eines previstes i justificació

* Llenguatge: Lua → necessari per programar en Roblox
* Entorn: Roblox Studio → desenvolupament del joc
* Control de versions: GitHub amb Rojo → gestió del codi i versions
* IA: suport per idees, lògica i resolució de dubtes

---
