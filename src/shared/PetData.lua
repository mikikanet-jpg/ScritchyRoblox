local PetData = {}

-- Probabilidad de que salga una mascota al rascar a mano cada ticket.
PetData.DropChance = { Basic = 0.05, Silver = 0.1, Gold = 0.15, Pizza = 0.2, Space = 0.25, Zombie = 0.3 }

-- El peso reparte las mascotas que salen entre las rarezas (suma 100).
PetData.Rarities = {
	Common = { label = "Común", weight = 70, color = Color3.fromRGB(148, 163, 184), dark = Color3.fromRGB(71, 85, 105) },
	Rare = { label = "Rara", weight = 22, color = Color3.fromRGB(96, 165, 250), dark = Color3.fromRGB(29, 78, 216) },
	Epic = { label = "Épica", weight = 7, color = Color3.fromRGB(192, 132, 252), dark = Color3.fromRGB(109, 40, 217) },
	Legendary = { label = "Legendaria", weight = 1, color = Color3.fromRGB(252, 211, 77), dark = Color3.fromRGB(217, 119, 6) },
}

-- bonus: premio extra de los tickets mientras la mascota está equipada.
PetData.Pets = {
	{ id = "cat", name = "Gatito", emoji = "🐱", rarity = "Common", bonus = 0.05, style = "cat", color = Color3.fromRGB(251, 146, 60), accent = Color3.fromRGB(255, 237, 213) },
	{ id = "dog", name = "Perrito", emoji = "🐶", rarity = "Common", bonus = 0.05, style = "dog", color = Color3.fromRGB(180, 130, 90), accent = Color3.fromRGB(92, 60, 38) },
	{ id = "bunny", name = "Conejo", emoji = "🐰", rarity = "Common", bonus = 0.08, style = "bunny", color = Color3.fromRGB(241, 245, 249), accent = Color3.fromRGB(251, 182, 206) },
	{ id = "fox", name = "Zorro", emoji = "🦊", rarity = "Rare", bonus = 0.12, style = "cat", color = Color3.fromRGB(234, 88, 12), accent = Color3.fromRGB(255, 255, 255) },
	{ id = "panda", name = "Panda", emoji = "🐼", rarity = "Rare", bonus = 0.15, style = "round", color = Color3.fromRGB(245, 245, 245), accent = Color3.fromRGB(30, 30, 30) },
	{ id = "dragon", name = "Dragón", emoji = "🐲", rarity = "Epic", bonus = 0.25, style = "wings", color = Color3.fromRGB(34, 197, 94), accent = Color3.fromRGB(21, 94, 52) },
	{ id = "alien", name = "Alien", emoji = "👽", rarity = "Epic", bonus = 0.3, style = "antenna", color = Color3.fromRGB(163, 230, 53), accent = Color3.fromRGB(77, 124, 15) },
	{ id = "phoenix", name = "Fénix dorado", emoji = "🔥", rarity = "Legendary", bonus = 0.5, style = "wings", color = Color3.fromRGB(251, 191, 36), accent = Color3.fromRGB(239, 68, 68), glow = true },
}

function PetData.get(id)
	for _, pet in PetData.Pets do
		if pet.id == id then
			return pet
		end
	end
	return nil
end

-- Probabilidad, entre las mascotas que salen, de que sea esta.
function PetData.share(pet)
	local sameRarity = 0
	for _, other in PetData.Pets do
		if other.rarity == pet.rarity then
			sameRarity += 1
		end
	end
	return PetData.Rarities[pet.rarity].weight / sameRarity
end

-- Las mascotas de cada jugador se guardan como "cat,fox,dragon".
function PetData.owns(ownedText, id)
	return table.find(string.split(ownedText, ","), id) ~= nil
end

return PetData
