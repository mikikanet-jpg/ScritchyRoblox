local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PetService = require(script.Parent:WaitForChild("PetService"))
local MissionService = require(script.Parent:WaitForChild("MissionService"))
local TicketRules = require(script.Parent:WaitForChild("TicketRules"))
local TicketData = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("TicketData"))

local interactPart = workspace:WaitForChild("TicketTable_Interact")
local prompt = interactPart:WaitForChild("ProximityPrompt")

local showMessage = ReplicatedStorage:WaitForChild("ShowMessage")
local openScratch = ReplicatedStorage:WaitForChild("OpenScratch")
local scratchTicket = ReplicatedStorage:WaitForChild("ScratchTicket")

local function getRemote(name)
	local remote = ReplicatedStorage:FindFirstChild(name)
	if not remote then
		remote = Instance.new("RemoteEvent")
		remote.Name = name
		remote.Parent = ReplicatedStorage
	end
	return remote
end

-- El servidor decide el premio al empezar y lo paga al terminar de rascar.
local scratchStarted = getRemote("ScratchStarted")
local scratchReveal = getRemote("ScratchReveal")
local jackpotAnnounced = getRemote("JackpotAnnounced")

local AUTO_REVEAL_SECONDS = 120

local pending = {}

-- Efecto dorado alrededor del jugador, visible para todos.
local function celebrateJackpot(player)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end
	local emitter = Instance.new("ParticleEmitter")
	emitter.Color = ColorSequence.new(Color3.fromRGB(252, 211, 77))
	emitter.LightEmission = 0.6
	emitter.Size = NumberSequence.new(0.5, 0)
	emitter.Lifetime = NumberRange.new(1, 1.6)
	emitter.Speed = NumberRange.new(6, 12)
	emitter.SpreadAngle = Vector2.new(180, 180)
	emitter.Rate = 0
	emitter.Parent = root
	emitter:Emit(120)
	Debris:AddItem(emitter, 3)
end

prompt.Triggered:Connect(function(player)
	openScratch:FireClient(player)
end)

local function finishScratch(player, scratch)
	if pending[player] ~= scratch then
		return
	end
	pending[player] = nil

	local playerData = player:FindFirstChild("PlayerData")
	if not playerData then
		return
	end

	playerData.TutorialDone.Value = true

	MissionService.recordScratch(playerData)
	if scratch.reward > 0 then
		MissionService.recordEarned(playerData, scratch.reward)
	end
	if scratch.kind == "jackpot" then
		MissionService.recordJackpot(playerData)
	end

	local newPet = PetService.rollDrop(playerData, scratch.ticketType)
	if newPet then
		showMessage:FireClient(player, "¡Mascota nueva: " .. newPet.name .. "!")
	end

	TicketRules.addXP(player, playerData, TicketRules.xpPerScratch(playerData))

	if scratch.kind == "final" then
		playerData.Money.Value += scratch.reward
		playerData.GameWon.Value = true
		if not string.find(playerData.OwnedPets.Value, "phoenix", 1, true) then
			local owned = playerData.OwnedPets.Value
			playerData.OwnedPets.Value = owned == "" and "phoenix" or (owned .. ",phoenix")
		end
		showMessage:FireClient(player, "¡JUEGO COMPLETADO!")
		celebrateJackpot(player)
		jackpotAnnounced:FireAllClients(player.DisplayName, "FINAL", scratch.reward, true)
	elseif scratch.kind == "lose" then
		showMessage:FireClient(player, "Has perdido")
	elseif scratch.kind == "win" then
		playerData.Money.Value += scratch.reward
		showMessage:FireClient(player, "+" .. scratch.reward .. "$")
	else
		playerData.Money.Value += scratch.reward
		playerData.Jackpots.Value += 1
		local gift = scratch.gift
		if gift then
			playerData[gift.stat].Value += gift.amount
			showMessage:FireClient(player, "¡Y además " .. gift.text .. "!")
		end
		showMessage:FireClient(player, scratch.text .. scratch.reward .. "$")
		celebrateJackpot(player)
		jackpotAnnounced:FireAllClients(player.DisplayName, TicketData[scratch.ticketType].Label, scratch.reward)
	end
end

scratchTicket.OnServerEvent:Connect(function(player, ticketType)
	local outcome = table.find(TicketData.Order, ticketType) and TicketData[ticketType]
	if not outcome or pending[player] then
		return
	end

	local playerData = player:FindFirstChild("PlayerData")
	local tickets = playerData and playerData:FindFirstChild(ticketType .. "Tickets")
	if not tickets then
		return
	end

	if tickets.Value <= 0 then
		showMessage:FireClient(player, "No tienes tickets")
		return
	end

	tickets.Value -= 1

	local scratch
	if outcome.IsFinal then
		scratch = { kind = "final", reward = outcome.Reward, ticketType = ticketType }
	elseif not playerData.TutorialDone.Value then
		-- El primer ticket de cada jugador siempre tiene premio.
		scratch = { kind = "win", reward = PetService.applyBonus(playerData, outcome.Reward), ticketType = ticketType }
	else
		scratch = TicketRules.roll(playerData, ticketType)
	end

	pending[player] = scratch
	scratchStarted:FireClient(player, ticketType, scratch.kind, scratch.reward)

	-- Si el jugador nunca termina, no pierde el premio.
	task.delay(AUTO_REVEAL_SECONDS, finishScratch, player, scratch)
end)

scratchReveal.OnServerEvent:Connect(function(player)
	local scratch = pending[player]
	if scratch then
		finishScratch(player, scratch)
	end
end)

Players.PlayerRemoving:Connect(function(player)
	pending[player] = nil
end)
