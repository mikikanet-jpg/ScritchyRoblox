local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PetService = require(script.Parent:WaitForChild("PetService"))

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

-- lose y win son el límite superior de una tirada del 1 al 100.
local OUTCOMES = {
	Basic = { lose = 35, win = 90, reward = 30, jackpot = 100, jackpotText = "JACKPOT! +" },
	Silver = { lose = 25, win = 85, reward = 500, jackpot = 1500, jackpotText = "JACKPOT PLATA! +" },
	Gold = { lose = 15, win = 75, reward = 25000, jackpot = 50000, jackpotText = "JACKPOT ORO! +" },
}

local TICKET_NAMES = { Basic = "BÁSICO", Silver = "PLATA", Gold = "ORO" }

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

	local newPet = PetService.rollDrop(playerData, scratch.ticketType)
	if newPet then
		showMessage:FireClient(player, "¡Mascota nueva: " .. newPet.name .. "!")
	end

	local ticketXP = playerData.TicketXP
	local ticketLevel = playerData.TicketLevel

	ticketXP.Value += 2 ^ playerData.Prestige.Value

	local requiredXP = ticketLevel.Value * 10
	if ticketXP.Value >= requiredXP then
		ticketXP.Value = 0
		ticketLevel.Value += 1
		showMessage:FireClient(player, "SUBES A NIVEL " .. ticketLevel.Value)
	end

	if scratch.kind == "lose" then
		showMessage:FireClient(player, "Has perdido")
	elseif scratch.kind == "win" then
		playerData.Money.Value += scratch.reward
		showMessage:FireClient(player, "+" .. scratch.reward .. "$")
	else
		playerData.Money.Value += scratch.reward
		playerData.Jackpots.Value += 1
		showMessage:FireClient(player, scratch.text .. scratch.reward .. "$")
		celebrateJackpot(player)
		jackpotAnnounced:FireAllClients(player.DisplayName, TICKET_NAMES[scratch.ticketType], scratch.reward)
	end
end

scratchTicket.OnServerEvent:Connect(function(player, ticketType)
	local outcome = typeof(ticketType) == "string" and OUTCOMES[ticketType]
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

	local roll = math.random(1, 100)
	local scratch
	if not playerData.TutorialDone.Value then
		-- El primer ticket de cada jugador siempre tiene premio.
		scratch = { kind = "win", reward = PetService.applyBonus(playerData, outcome.reward), ticketType = ticketType }
	elseif roll <= outcome.lose then
		scratch = { kind = "lose", reward = 0, ticketType = ticketType }
	elseif roll <= outcome.win then
		scratch = { kind = "win", reward = PetService.applyBonus(playerData, outcome.reward), ticketType = ticketType }
	else
		scratch = { kind = "jackpot", reward = PetService.applyBonus(playerData, outcome.jackpot), text = outcome.jackpotText, ticketType = ticketType }
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
