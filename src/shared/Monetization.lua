-- Pases que se compran con Robux. Ninguno es al azar: se sabe siempre lo que se compra.
-- id: número del pase en el Creator Hub. Con 0, el pase sale en la tienda como "Pronto".
local Monetization = {}

Monetization.Passes = {
	{
		key = "Turbo", id = 2089166645, emoji = "⚡", name = "Auto Scratch Turbo",
		description = "Auto Scratch incluido y el doble de rápido",
		colorA = Color3.fromRGB(34, 211, 238), colorB = Color3.fromRGB(37, 99, 235),
	},
	{
		key = "VIP", id = 2088428677, emoji = "👑", name = "VIP",
		description = "Nombre dorado, etiqueta en el chat y 3 muebles VIP",
		colorA = Color3.fromRGB(253, 224, 71), colorB = Color3.fromRGB(217, 119, 6),
	},
	{
		key = "Unicorn", id = 2088272668, emoji = "🦄", name = "Unicornio",
		description = "Mascota exclusiva: +20% de premios",
		colorA = Color3.fromRGB(249, 168, 212), colorB = Color3.fromRGB(168, 85, 247),
	},
}

function Monetization.get(key)
	for _, pass in Monetization.Passes do
		if pass.key == key then
			return pass
		end
	end
	return nil
end

function Monetization.byId(id)
	for _, pass in Monetization.Passes do
		if pass.id ~= 0 and pass.id == id then
			return pass
		end
	end
	return nil
end

-- El servidor marca al jugador con un atributo por cada pase que tiene.
function Monetization.owns(player, key)
	return player:GetAttribute("Pass" .. key) == true
end

return Monetization
