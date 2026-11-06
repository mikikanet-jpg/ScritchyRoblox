-- Traducción al inglés. El juego está escrito en español: los jugadores con Roblox en español
-- lo ven tal cual y al resto se les traducen los textos justo antes de mostrarlos.
-- Si añades un texto nuevo, añádelo también aquí.
local LocalizationService = game:GetService("LocalizationService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Lang = {}

-- El atributo ForceLang de ReplicatedStorage sirve para probar un idioma en Studio.
local function detect()
	local forced = ReplicatedStorage:GetAttribute("ForceLang")
	if forced then
		return forced
	end
	local ok, locale = pcall(function()
		return LocalizationService.RobloxLocaleId
	end)
	if ok and string.sub(string.lower(locale), 1, 2) == "es" then
		return "es"
	end
	return "en"
end

Lang.current = detect()
Lang.thousands = Lang.current == "es" and "." or ","

local EXACT = {
	["Ya tienes Auto Scratch"] = "You already have Auto Scratch",
	["AUTO SCRATCH DESBLOQUEADO"] = "AUTO SCRATCH UNLOCKED",
	["Has perdido"] = "No prize",
	["Velocidad máxima alcanzada"] = "Maximum speed reached",
	["Auto Scratch mejorado"] = "Auto Scratch upgraded",
	["No tienes suficiente dinero"] = "You don't have enough money",
	["Tu suerte ya está al máximo"] = "Your luck is already at maximum",
	["+1 Luck"] = "+1 Luck",
	["Tickets Básicos"] = "Basic Tickets",
	["Tickets Plata"] = "Silver Tickets",
	["Tickets Oro"] = "Gold Tickets",
	["Tu dinero"] = "Your money",
	["Nivel: desbloquea tickets y el prestigio"] = "Level: unlocks tickets and prestige",
	["XP: rasca tickets a mano para subir de nivel"] = "XP: scratch tickets by hand to level up",
	["Tickets especiales: Pizza, Espacio, Zombi y Final"] = "Special tickets: Pizza, Space, Zombie and Final",
	["Mejoras"] = "Upgrades",
	["Tienda de tickets"] = "Ticket Shop",
	["Compra tickets y llévalos a la mesa para rascarlos"] = "Buy tickets and take them to the table to scratch",
	["Mesa de rascar"] = "Scratch Table",
	["Elige qué ticket quieres rascar"] = "Choose a ticket to scratch",
	["¡Suerte!"] = "Good luck!",
	["Invierte tu dinero para avanzar más rápido"] = "Spend your money to progress faster",
	["Cómo funciona"] = "How it works",
	["Qué hace cada cosa del juego"] = "What everything in the game does",
	["Compra en el ordenador del dormitorio y rasca en la mesa del salón arrastrando el ratón o el dedo."] = "Buy at the bedroom computer and scratch at the living room table by dragging your mouse or finger.",
	["🎟️ Tickets"] = "🎟️ Tickets",
	["⭐ Nivel y XP"] = "⭐ Level and XP",
	["El nivel 5 desbloquea Plata, el 15 desbloquea Oro y el 20 permite hacer prestigio. No cambia las probabilidades."] = "Level 5 unlocks Silver, level 15 unlocks Gold and level 20 lets you prestige. Levels don't change your odds.",
	["🍀 Suerte"] = "🍀 Luck",
	["Cada nivel por encima del 1 quita 1 punto a la probabilidad de no ganar nada y lo pasa a premio normal."] = "Each level above 1 takes 1 point from the chance of winning nothing and moves it to a normal prize.",
	["🤖 Auto Scratch"] = "🤖 Auto Scratch",
	["Rasca un ticket cada pocos segundos, empezando por el mejor que tengas, con las mismas probabilidades y premios que a mano."] = "Scratches a ticket every few seconds, starting with your best one, with the same odds and prizes as by hand.",
	["Da la mitad de XP, no suelta mascotas y no rasca el tiquet final."] = "It gives half the XP, drops no pets and doesn't scratch the Final Ticket.",
	["⚡ Velocidad"] = "⚡ Speed",
	["Cada mejora quita 0,5 s de espera, desde 5 s hasta un mínimo de 0,5 s."] = "Each upgrade removes 0.5 s of waiting, from 5 s down to a minimum of 0.5 s.",
	["Equipa una en el botón del perrito: te sigue y sube los premios de los tickets, también con Auto Scratch. El prestigio no te la quita."] = "Equip one with the puppy button: it follows you and raises ticket prizes, including Auto Scratch. Prestige doesn't take it away.",
	["🐶 Mascotas"] = "🐶 Pets",
	["Abre el botón de la casa para comprar decoración y mejorar la mesa. Todo se queda aunque hagas prestigio. Con otros jugadores, cada uno ve solo su propia decoración."] = "Use the house button to buy decorations and upgrade the table. You keep everything when you prestige. With other players, each one only sees their own decorations.",
	["El bonus de la mesa se suma al de la mascota."] = "The table bonus adds to your pet's bonus.",
	["🏠 Habitación"] = "🏠 Room",
	["🏆 Tiquet Final"] = "🏆 Final Ticket",
	["🎯 Misiones y logros"] = "🎯 Missions and achievements",
	["Abre el botón de la diana. Cuando completes una, pulsa Reclamar para cobrar el premio: un punto naranja te avisa."] = "Use the target button. When you finish one, press Claim to collect the prize: an orange dot lets you know.",
	["Las misiones de hoy se renuevan cada día y su premio crece con tu nivel. Si un día no juegas, no pierdes nada."] = "Today's missions renew every day and their prize grows with your level. You lose nothing if you skip a day.",
	["Los logros se cobran una sola vez. Los tickets de Auto Scratch no cuentan como rascados, pero su dinero sí cuenta como ganado."] = "Achievements pay out only once. Auto Scratch tickets don't count as scratched, but their money counts as earned.",
	["👑 Prestigio"] = "👑 Prestige",
	["Disponible en el nivel 20. Vuelves al nivel 1 con $100 y sin tickets."] = "Available at level 20. You go back to level 1 with $100 and no tickets.",
	["A cambio, ganas +1 de suerte y duplicas la XP con cada prestigio. Conservas la suerte, Auto Scratch y su velocidad."] = "In return you get +1 luck and double your XP with each prestige. You keep your luck, Auto Scratch and its speed.",
	["RASCA AQUÍ"] = "SCRATCH HERE",
	["Revelar sin rascar"] = "Reveal without scratching",
	["Cerrar"] = "Close",
	["¡HAS GANADO!"] = "YOU WON!",
	["¡JACKPOT!"] = "JACKPOT!",
	["¡Premio!"] = "Prize!",
	["Sin premio"] = "No prize",
	["Otra vez será"] = "Maybe next time",
	["Paso 2 de 2: ve a la mesa del salón y rasca tu ticket"] = "Step 2 of 2: go to the living room table and scratch your ticket",
	["Paso 1 de 2: compra un ticket en el ordenador del dormitorio"] = "Step 1 of 2: buy a ticket at the bedroom computer",
	["¡Ya sabes jugar!"] = "Now you know how to play!",
	["Mascotas"] = "Pets",
	["Pueden salir al rascar a mano. Equipa una para ganar más"] = "They can appear when scratching by hand. Equip one to earn more",
	["Aún no tienes esta mascota"] = "You don't have this pet yet",
	["Quitar"] = "Remove",
	["Equipar"] = "Equip",
	["Bloqueada"] = "Locked",
	["Tu habitación"] = "Your Room",
	["Decora la sala y mejora la mesa para ganar más"] = "Decorate the room and upgrade the table to earn more",
	["Máxima"] = "Maxed",
	["Comprado"] = "Owned",
	["Misiones"] = "Missions",
	["Las de hoy se renuevan cada día. Los logros son para siempre"] = "Today's renew every day. Achievements are forever",
	["Hecho"] = "Done",
	["Reclamar"] = "Claim",
	["¡Misión lista! Reclámala en 🎯"] = "Mission complete! Claim it at 🎯",
	["¡Juego completado!"] = "Game completed!",
	["Ráscalo en la mesa del salón"] = "Scratch it at the living room table",
	["Te queda 1"] = "1 left",
	["Rascar"] = "Scratch",
	["Suerte"] = "Luck",
	["Rasca tus tickets automáticamente"] = "Scratches your tickets automatically",
	["Activo"] = "Active",
	["Velocidad"] = "Speed",
	["Pierdes dinero, nivel y tickets"] = "You lose money, level and tickets",
	["Confirmar"] = "Confirm",
	["Reinicia tu partida a cambio de más XP"] = "Restart your game in exchange for more XP",
	["Prestigiar"] = "Prestige",
	["No se pudo cargar tu progreso: esta partida no se guardará"] = "Your progress couldn't load: this session won't be saved",
	["Rasca 20 tickets"] = "Scratch 20 tickets",
	["Gana $1.000"] = "Earn $1,000",
	["Saca un jackpot"] = "Hit a jackpot",
	["Primer rasca"] = "First scratch",
	["Rasca 50 tickets"] = "Scratch 50 tickets",
	["Rasca 500 tickets"] = "Scratch 500 tickets",
	["Rasca 2.000 tickets"] = "Scratch 2,000 tickets",
	["Gana $10.000 en total"] = "Earn $10,000 in total",
	["Gana $1.000.000 en total"] = "Earn $1,000,000 in total",
	["Gana $100.000.000 en total"] = "Earn $100,000,000 in total",
	["Tu primer jackpot"] = "Your first jackpot",
	["Saca 25 jackpots"] = "Hit 25 jackpots",
	["Consigue 3 mascotas"] = "Get 3 pets",
	["Consigue todas las mascotas"] = "Get every pet",
	["Compra toda la decoración"] = "Buy every decoration",
	["Haz tu primer prestigio"] = "Do your first prestige",
	["Completa el tiquet final"] = "Complete the Final Ticket",
	["¡PRESTIGIO COMPLETADO!"] = "PRESTIGE COMPLETE!",
	["Necesitas llegar al nivel 20"] = "You need to reach level 20",
	["Necesitas Auto Scratch"] = "You need Auto Scratch",
	["Alfombra"] = "Rug",
	["Una alfombra grande para la sala"] = "A big rug for the room",
	["Plantas"] = "Plants",
	["Dos plantas para las esquinas"] = "Two plants for the corners",
	["Pósters"] = "Posters",
	["Cuatro pósters en la pared"] = "Four posters on the wall",
	["Sofá"] = "Sofa",
	["Un sofá grande junto a la pared"] = "A big sofa by the wall",
	["Luces de neón"] = "Neon lights",
	["Neón alrededor del techo"] = "Neon around the ceiling",
	["Máquina arcade"] = "Arcade machine",
	["Una máquina arcade con pantalla"] = "An arcade machine with a screen",
	["Trofeo dorado"] = "Golden trophy",
	["Para que se vea quién manda"] = "To show who's in charge",
	["Te regalamos un ticket para seguir jugando"] = "Here's a free ticket to keep playing",
	["¡JUEGO COMPLETADO!"] = "GAME COMPLETED!",
	["No tienes tickets"] = "You have no tickets",
	["RASCA"] = "SCRATCH",
	["SUERTE"] = "LUCK",
	["PRESTIGIO"] = "PRESTIGE",
	["Comprar Tickets"] = "Buy Tickets",
	["Ordenador"] = "Computer",
	["Rascar Ticket"] = "Scratch Ticket",
	["Mesa"] = "Table",
}

-- Nombres que aparecen dentro de textos con números.
local NAMES = {
	{ "Fénix dorado", "Golden Phoenix" },
	{ "Tapete azul", "Blue Mat" }, { "Tapete morado", "Purple Mat" }, { "Tapete dorado", "Golden Mat" },
	{ "Básico", "Basic" }, { "BÁSICO", "BASIC" }, { "Plata", "Silver" }, { "PLATA", "SILVER" },
	{ "Oro", "Gold" }, { "ORO", "GOLD" }, { "Espacio", "Space" }, { "ESPACIO", "SPACE" },
	{ "%f[%a]Zombi%f[%A]", "Zombie" }, { "%f[%a]ZOMBI%f[%A]", "ZOMBIE" },
	{ "Común", "Common" }, { "Rara", "Rare" }, { "Épica", "Epic" }, { "Legendaria", "Legendary" },
	{ "Gatito", "Kitten" }, { "Perrito", "Puppy" }, { "Conejo", "Bunny" }, { "Zorro", "Fox" },
	{ "Dragón", "Dragon" },
}

local function names(text)
	for _, pair in NAMES do
		text = string.gsub(text, pair[1], pair[2])
	end
	return text
end

-- Convierte los importes de 1.000 a 1,000.
local function numbers(text)
	return (string.gsub(text, "(%d)%.(%d%d%d)", "%1,%2"))
end

local PATTERNS = {
	{ "^Nivel (%d+): (%d+) puntos menos de no ganar nada$", "Level %1: %2 points less of winning nothing" },
	{ "^Mesa (%d+) %((.+)%): (.+), (.+) de premios$", "Table %1 (%2): %3, %4 prizes" },
	{ "^Nivel (%d+)(.*)$", "Level %1%2" },
	{ "^Prestigio (%d+)$", "Prestige %1" },
	{ "^Necesitas [Nn]ivel (%d+)$", "You need level %1" },
	{ "^Necesitas Prestigio (%d+)$", "You need Prestige %1" },
	{ "^Necesitas (%d+)%$$", "You need $%1" },
	{ "^Se desbloquea con nivel (%d+)$", "Unlocks at level %1" },
	{ "^Se desbloquea con prestigio (%d+)$", "Unlocks at Prestige %1" },
	{ "^Te faltan (.+)$", "You need %1 more" },
	{ "^No tienes tickets (.+)$", "You have no %1 tickets" },
	{ "^Tienes (.+)$", "You have %1" },
	{ "^Te quedan (.+)$", "%1 left" },
	{ "^Un ticket cada (.+) s$", "One ticket every %1 s" },
	{ "^Disponible en el nivel (%d+)$", "Available at level %1" },
	{ "^Mesa: normal$", "Table: normal" },
	{ "^Mesa: (.+)$", "Table: %1" },
	{ "^Siguiente: (.+) de premios$", "Next: %1 prizes" },
	{ "^(.+) de premios$", "%1 prizes" },
	{ "^(.+) · (.+) de premios · (.+)$", "%1 · %2 prizes · %3" },
	{ "^(.+) · (.+) de premios$", "%1 · %2 prizes" },
	{ "^Premio: (.+)$", "Prize: %1" },
	{ "^Rascar otro %((.+)%)$", "Scratch another (%1)" },
	{ "^(.-) Ticket (.+)$", "%1 %2 Ticket" },
	{ "^Ticket (.+)$", "%1 Ticket" },
	{ "^%[AUTO (.-)%] Has perdido$", "[AUTO %1] No prize" },
	{ "^%[AUTO (.-)%] JACKPOT %+(%d+)%$$", "[AUTO %1] JACKPOT +$%2" },
	{ "^%[AUTO (.-)%] %+(%d+)%$$", "[AUTO %1] +$%2" },
	{ "^¡Mascota nueva: (.+)!$", "New pet: %1!" },
	{ "^¡Comprado: (.+)!$", "Bought: %1!" },
	{ "^¡Mesa mejorada: (.+)!$", "Table upgraded: %1!" },
	{ "^¡Y además (%d+) tickets (.+) gratis!$", "And %1 free %2 tickets!" },
	{ "^¡Premio cobrado: (%d+)%$!$", "Prize collected: $%1!" },
	{ "^SUBES A NIVEL (%d+)$", "LEVEL UP: %1" },
	{ "^%+(%d+)%$$", "+$%1" },
	{ "^JACKPOT (.-)! %+(%d+)%$$", "%1 JACKPOT! +$%2" },
	{ "^JACKPOT! %+(%d+)%$$", "JACKPOT! +$%1" },
	{ "^🎉 (.+) ha sacado JACKPOT (.+): (.+)$", "🎉 %1 hit a %2 JACKPOT: %3" },
	{ "^🏆 ¡(.+) ha completado el juego!$", "🏆 %1 completed the game!" },
	{ "^%+(.+) y el Fénix dorado$", "+%1 and the Golden Phoenix" },
	{ "^(.+) %((.+), nivel (%d+)%): (%d+)%% nada · (.+)%. El jackpot regala (%d+) tickets (.+) gratis$", "%1 (%2, level %3): %4%% nothing · %5. The jackpot gives %6 free %7 tickets" },
	{ "^(.+) %((.+), nivel (%d+)%): (%d+)%% nada · (.+)$", "%1 (%2, level %3): %4%% nothing · %5" },
	{ "^Cada ticket rascado a mano da XP, y con Auto Scratch la mitad%. Para subir de nivel necesitas (%d+) XP por cada nivel que tienes%.$", "Each ticket scratched by hand gives XP, and half with Auto Scratch. To level up you need %1 XP per level you have." },
	{ "^Llega hasta el nivel (%d+) %(15 puntos menos%)%. Cada nivel cuesta %$1%.000 más que el anterior%. También sube con cada prestigio%.$", "Goes up to level %1 (15 points less). Each level costs $1,000 more than the last. It also rises with each prestige." },
	{ "^Al rascar a mano puede salir una mascota: (.+)%. Si ya la tienes, no pasa nada%.$", "Scratching by hand can drop a pet: %1. Nothing happens if you already have it." },
	{ "^(.+) %((%d+)%% de las que salen%): (.+)$", "%1 (%2%% of drops): %3" },
	{ "^Es el objetivo del juego%. Cuesta (.+) y pide nivel (%d+) y al menos (%d+) prestigio%.$", "This is the goal of the game. It costs %1 and needs level %2 and at least %3 prestige." },
	{ "^Siempre se gana y solo se completa una vez: recibes (.+), el Fénix dorado y un 🏆 junto a tu nivel%. Auto Scratch no lo rasca%.$", "It always wins and can be completed once: you get %1, the Golden Phoenix and a 🏆 next to your level. Auto Scratch won't scratch it." },
}

local function finish(text)
	-- "5% con Básico" dentro de la ayuda de mascotas.
	text = string.gsub(text, "(%d+%%) con ", "%1 with ")
	return numbers(names(text))
end

function Lang.t(text)
	if Lang.current == "es" or text == "" then
		return text
	end
	local exact = EXACT[text]
	if exact then
		return exact
	end
	-- Las misiones diarias llevan delante "Hoy: ".
	local daily = string.match(text, "^Hoy: (.+)$")
	if daily then
		return "Today: " .. Lang.t(daily)
	end
	for _, rule in PATTERNS do
		if string.find(text, rule[1]) then
			return finish((string.gsub(text, rule[1], rule[2])))
		end
	end
	return finish(text)
end

return Lang
