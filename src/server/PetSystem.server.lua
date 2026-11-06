local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PetData = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("PetData"))

local equipPet = Instance.new("RemoteEvent")
equipPet.Name = "EquipPet"
equipPet.Parent = ReplicatedStorage

-- Un texto vacío quita la mascota equipada.
equipPet.OnServerEvent:Connect(function(player, petId)
	local playerData = player:FindFirstChild("PlayerData")
	if not playerData or typeof(petId) ~= "string" then
		return
	end
	if petId == "" or PetData.owns(playerData.OwnedPets.Value, petId) then
		playerData.EquippedPet.Value = petId
	end
end)
