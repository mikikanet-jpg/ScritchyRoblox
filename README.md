01_idea_i_abast.md
--------------------------
1. Idea del joc
Objectiu

L’objectiu del joc és guanyar diners i progressar desbloquejant tiquets de diferents nivells fins arribar a un tiquet final molt difícil d’aconseguir.

Rol del jugador

El jugador controla un personatge dins d’una habitació i es pot moure lliurement.

Pot:

Moure’s per la sala
Interactuar amb un ordinador per comprar tiquets
Interactuar amb una taula per rascar tiquets
Regles i condicions
El joc es desenvolupa en una habitació amb dues zones:
PC (compra de tiquets)
Taula (rascar tiquets)
Els tiquets es compren amb diners i es consumeixen en rascar-los.
Els tiquets estan organitzats per nivells (tiers) i es van desbloquejant progressivament.
Cada tiquet pot donar:
Guanys de diners
Pèrdues
Jackpot
Existeix un tiquet de mort que finalitza la run.
La run pot acabar de dues formes:
Amb el tiquet de mort
Activant el botó de prestigi
A la primera run només es pot acabar mitjançant la mort.
Bucle de joc

Moure’s per l’habitació → anar al PC → comprar tiquets → anar a la taula → rascar tiquets → obtenir resultat → repetir → mort o prestigi → nova run

Estats del joc
Diners del jugador
Nombre de tiquets disponibles
Nivell de tiquets (tiers)
Nivell de sort
Millores de prestigi
Bonus i multiplicadors

Durant la partida:

Augmenta el nivell de tiquets
Augmenta la sort
Varia el diner

Entre runs:

Es mantenen millores, bonus i multiplicadors
Repte i dificultat

El repte és maximitzar els guanys abans d’acabar la run i progressar fins als tiquets més avançats.

La dificultat augmenta perquè:

Els tiquets millors són més cars
El risc de perdre diners continua present
El progrés requereix múltiples runs
Limitacions
Gràfics simples (assets bàsics de Roblox)
Escenari limitat a una sola habitació
Sistema de tiquets simple
Interfície d’usuari simple
Sense multijugador
----------------------------------------
2. Riscos tècnics
Probabilitats mal balancejades
Solució: ajustar i provar valors
Tickets infinits o compra incorrecta
Solució: validar diners i limitar quantitat de tiquets
Errors en el reset del joc al fer prestigi
Solució: reiniciar variables correctament i guardar millores
----------------------------------------
3. Exploració amb IA

Prompt 1:
"Cómo estructurar un sistema de tickets con diferentes niveles (tiers) en un videojuego"

Aportació:
Permet definir la progressió i organitzar els diferents nivells de tiquets

Prompt 2:
"Cómo implementar un sistema de prestigio en un juego y qué variables mantener entre partidas"

Aportació:
Ajuda a definir quines dades es mantenen entre runs i com gestionar el progrés

----------------------------------------
4. Proposta final i viabilitat

El projecte és viable perquè:

Té una lògica clara i estructurada
Es basa en sistemes simples (compra, aleatorietat, progressió)
L’escenari és reduït
Es pot implementar dins del temps disponible
----------------------------------------
5. Pla de treball
Definir idea del joc i mecàniques
Dissenyar sistema (tiquets, prestigi, habitació)
Crear prototip en Roblox (moviment, compra, rascar)
Realitzar proves i detectar errors
Aplicar millores i optimitzar el sistema
----------------------------------------
6. Eines i tecnologies
Llenguatge: Lua
Entorn: Roblox Studio
Control de versions: GitHub amb Rojo
IA: suport per idees, lògica i resolució de dubtes
-----------------------------------------