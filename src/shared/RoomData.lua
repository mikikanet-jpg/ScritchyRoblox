local RoomData = {}

-- Zona nueva de la habitación, al este de la sala original.
RoomData.Annex = { x0 = -97.4, x1 = -61.4, z0 = 142.48, z1 = 177.65, floor = 72.556, top = 83.43 }

-- La mesa de rascar queda en el centro del salón.
RoomData.TableTopCenter = Vector3.new(-79.4, 75.86, 160.06)

-- bonus: premio extra de los tickets con este nivel de mesa.
RoomData.TableLevels = {
	{ name = "Tapete azul", price = 2000, bonus = 0.05, color = Color3.fromRGB(59, 130, 246) },
	{ name = "Tapete morado", price = 10000, bonus = 0.1, color = Color3.fromRGB(139, 92, 246) },
	{ name = "Tapete dorado", price = 50000, bonus = 0.2, color = Color3.fromRGB(245, 180, 40) },
}

RoomData.Items = {
	{ id = "rug", name = "Alfombra", emoji = "🟪", price = 500, description = "Una alfombra grande para la sala" },
	{ id = "plants", name = "Plantas", emoji = "🌿", price = 800, description = "Dos plantas para las esquinas" },
	{ id = "posters", name = "Pósters", emoji = "🖼️", price = 1500, description = "Cuatro pósters en la pared" },
	{ id = "sofa", name = "Sofá", emoji = "🛋️", price = 3000, description = "Un sofá grande junto a la pared" },
	{ id = "neon", name = "Luces de neón", emoji = "💡", price = 5000, description = "Neón alrededor del techo" },
	{ id = "arcade", name = "Máquina arcade", emoji = "🕹️", price = 15000, description = "Una máquina arcade con pantalla" },
	{ id = "trophy", name = "Trofeo dorado", emoji = "🏆", price = 50000, description = "Para que se vea quién manda" },
	-- Vienen con el pase VIP, no se compran con dinero del juego.
	{ id = "vip_throne", name = "Trono VIP", emoji = "👑", price = 0, vip = true, description = "Un trono dorado en la esquina" },
	{ id = "vip_carpet", name = "Alfombra roja VIP", emoji = "🟥", price = 0, vip = true, description = "Alfombra roja desde la puerta" },
	{ id = "vip_coins", name = "Montaña de monedas VIP", emoji = "💰", price = 0, vip = true, description = "Monedas de oro que brillan" },
}

function RoomData.getItem(id)
	for _, item in RoomData.Items do
		if item.id == id then
			return item
		end
	end
	return nil
end

function RoomData.tableBonus(level)
	local info = RoomData.TableLevels[level]
	return info and info.bonus or 0
end

-- Cuántos objetos se pueden comprar con dinero del juego, sin los VIP.
function RoomData.countFree(ownedText)
	local count = 0
	for _, item in RoomData.Items do
		if not item.vip and (ownedText == nil or RoomData.owns(ownedText, item.id)) then
			count += 1
		end
	end
	return count
end

-- Los objetos de cada jugador se guardan como "rug,sofa".
function RoomData.owns(ownedText, id)
	return table.find(string.split(ownedText, ","), id) ~= nil
end

return RoomData
