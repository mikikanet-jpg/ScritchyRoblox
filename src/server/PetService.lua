local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PetData = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("PetData"))

local PetService = {}

-- Suma el bonus de la mascota equipada a un premio.
function PetService.applyBonus(playerData, reward)
	local pet = PetData.get(playerData.EquippedPet.Value)
	if pet then
		return math.floor(reward * (1 + pet.bonus))
	end
	return reward
end

local function pickPet()
	local roll = math.random() * 100
	local rarity = "Common"
	for name, info in PetData.Rarities do
		if roll < info.weight then
			rarity = name
			break
		end
		roll -= info.weight
	end

	local options = {}
	for _, pet in PetData.Pets do
		if pet.rarity == rarity then
			table.insert(options, pet)
		end
	end
	return options[math.random(1, #options)]
end

-- Devuelve la mascota nueva si ha salido una que el jugador no tenía.
function PetService.rollDrop(playerData, ticketType)
	local chance = PetData.DropChance[ticketType]
	if not chance or math.random() >= chance then
		return nil
	end

	local pet = pickPet()
	local owned = playerData.OwnedPets
	if PetData.owns(owned.Value, pet.id) then
		return nil
	end

	owned.Value = owned.Value == "" and pet.id or (owned.Value .. "," .. pet.id)
	return pet
end

return PetService
