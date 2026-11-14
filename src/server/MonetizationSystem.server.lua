-- Comprueba los pases de cada jugador y da lo que incluyen.
-- Roblox guarda quién tiene cada pase, así que no hace falta guardarlo en el DataStore.
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Monetization = require(Shared:WaitForChild("Monetization"))
local PetData = require(Shared:WaitForChild("PetData"))
local RoomData = require(Shared:WaitForChild("RoomData"))
local showMessage = ReplicatedStorage:WaitForChild("ShowMessage")

local GOLD = Color3.fromRGB(253, 224, 71)

local function addToList(value, id)
	if not RoomData.owns(value.Value, id) then
		value.Value = value.Value == "" and id or (value.Value .. "," .. id)
	end
end

-- Nombre dorado con corona encima del personaje.
local function addVipTag(player, character)
	local head = character:WaitForChild("Head", 10)
	local humanoid = character:WaitForChild("Humanoid", 10)
	if not head or not humanoid or head:FindFirstChild("VipTag") then
		return
	end
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

	local tag = Instance.new("BillboardGui")
	tag.Name = "VipTag"
	tag.Size = UDim2.fromOffset(220, 40)
	tag.StudsOffset = Vector3.new(0, 2.6, 0)
	tag.MaxDistance = 80
	tag.Parent = head

	local text = Instance.new("TextLabel")
	text.BackgroundTransparency = 1
	text.Size = UDim2.fromScale(1, 1)
	text.Font = Enum.Font.GothamBlack
	text.TextScaled = true
	text.TextColor3 = GOLD
	text.TextStrokeTransparency = 0.3
	text.Text = "👑 " .. player.DisplayName
	text.Parent = tag
end

local function grant(player, pass)
	if Monetization.owns(player, pass.key) then
		return
	end
	player:SetAttribute("Pass" .. pass.key, true)

	local playerData = player:WaitForChild("PlayerData", 60)
	if not playerData then
		return
	end
	if pass.key == "Turbo" then
		playerData.AutoScratch.Value = true
	elseif pass.key == "Unicorn" then
		for _, pet in PetData.Pets do
			if pet.pass == pass.key then
				addToList(playerData.OwnedPets, pet.id)
			end
		end
	elseif pass.key == "VIP" then
		for _, item in RoomData.Items do
			if item.vip then
				addToList(playerData.RoomItems, item.id)
			end
		end
		if player.Character then
			task.spawn(addVipTag, player, player.Character)
		end
	end
end

local function checkPasses(player)
	-- En Studio se pueden probar con el atributo TestPasses de ReplicatedStorage, por ejemplo "Turbo,VIP,Unicorn".
	local testPasses = RunService:IsStudio() and ReplicatedStorage:GetAttribute("TestPasses")
	for _, pass in Monetization.Passes do
		if typeof(testPasses) == "string" and table.find(string.split(testPasses, ","), pass.key) then
			task.spawn(grant, player, pass)
		elseif pass.id ~= 0 then
			task.spawn(function()
				local ok, owns = pcall(function()
					return MarketplaceService:UserOwnsGamePassAsync(player.UserId, pass.id)
				end)
				if ok and owns then
					grant(player, pass)
				end
			end)
		end
	end
end

local function onPlayer(player)
	player.CharacterAdded:Connect(function(character)
		if Monetization.owns(player, "VIP") then
			addVipTag(player, character)
		end
	end)
	checkPasses(player)
end

Players.PlayerAdded:Connect(onPlayer)
for _, player in Players:GetPlayers() do
	task.spawn(onPlayer, player)
end

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, passId, purchased)
	local pass = purchased and Monetization.byId(passId)
	if pass then
		grant(player, pass)
		showMessage:FireClient(player, "¡Gracias por tu compra! " .. pass.name .. " activado")
	end
end)
