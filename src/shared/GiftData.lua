-- Regalo diario: un ciclo de 7 regalos. Saltarse un día no reinicia nada.
local GiftData = {}

-- Dinero de cada regalo por cada nivel que tenga el jugador.
GiftData.PerLevel = { 50, 75, 100, 150, 200, 300, 1000 }

function GiftData.today()
	return math.floor(os.time() / 86400)
end

-- Qué regalo del ciclo toca ahora, del 1 al 7.
function GiftData.dayIndex(playerData)
	return playerData.GiftCount.Value % #GiftData.PerLevel + 1
end

function GiftData.reward(playerData)
	return GiftData.PerLevel[GiftData.dayIndex(playerData)] * playerData.TicketLevel.Value
end

function GiftData.ready(playerData)
	return playerData.GiftDay.Value ~= GiftData.today()
end

return GiftData
