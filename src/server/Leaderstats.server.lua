local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local STORE_NAME = "ScratchRoomData_v1"
local AUTOSAVE_SECONDS = 60
local MAX_ATTEMPTS = 3

-- Cada estadística que existe y se guarda, con su valor inicial.
local STATS = {
	{ name = "Money", class = "IntValue", default = 100 },
	{ name = "BasicTickets", class = "IntValue", default = 0 },
	{ name = "SilverTickets", class = "IntValue", default = 0 },
	{ name = "GoldTickets", class = "IntValue", default = 0 },
	{ name = "Luck", class = "IntValue", default = 1 },
	{ name = "TicketLevel", class = "IntValue", default = 1 },
	{ name = "TicketXP", class = "IntValue", default = 0 },
	{ name = "Jackpots", class = "IntValue", default = 0 },
	{ name = "Prestige", class = "IntValue", default = 0 },
	{ name = "AutoScratch", class = "BoolValue", default = false },
	{ name = "AutoScratchSpeed", class = "NumberValue", default = 5 },
	{ name = "TutorialDone", class = "BoolValue", default = false },
}

local store
local storeOk, storeError = pcall(function()
	store = DataStoreService:GetDataStore(STORE_NAME)
end)
if not storeOk then
	warn("DataStore no disponible, el progreso no se guardará: " .. tostring(storeError))
end

-- Solo se guarda a quien cargó bien, para no pisar sus datos con los iniciales.
local canSave = {}

local function retry(action)
	local ok, result
	for attempt = 1, MAX_ATTEMPTS do
		ok, result = pcall(action)
		if ok then
			return true, result
		end
		warn("Error de DataStore (intento " .. attempt .. "): " .. tostring(result))
		if attempt < MAX_ATTEMPTS then
			task.wait(attempt * 2)
		end
	end
	return false, result
end

local function keyFor(userId)
	return "player_" .. userId
end

local function savePlayer(player, playerData)
	if not store or not canSave[player] then
		return true
	end

	local snapshot = {}
	for _, stat in STATS do
		local value = playerData:FindFirstChild(stat.name)
		if value then
			snapshot[stat.name] = value.Value
		end
	end

	local ok = retry(function()
		store:SetAsync(keyFor(player.UserId), snapshot, { player.UserId })
	end)
	return ok
end

local function setupPlayer(player)
	if player:FindFirstChild("PlayerData") then
		return
	end

	local playerData = Instance.new("Folder")
	playerData.Name = "PlayerData"

	local saved
	if store then
		local ok, result = retry(function()
			return store:GetAsync(keyFor(player.UserId))
		end)
		if ok then
			saved = result
			canSave[player] = true
		else
			player:SetAttribute("DataLoadFailed", true)
		end
	else
		player:SetAttribute("DataLoadFailed", true)
	end

	-- El jugador pudo salir mientras cargaban sus datos.
	if not player:IsDescendantOf(Players) then
		canSave[player] = nil
		return
	end

	for _, stat in STATS do
		local value = Instance.new(stat.class)
		value.Name = stat.name
		value.Value = stat.default
		local savedValue = type(saved) == "table" and saved[stat.name]
		if savedValue ~= nil and typeof(savedValue) == typeof(stat.default) then
			value.Value = savedValue
		end
		value.Parent = playerData
	end

	-- Se añade al final: los demás scripts esperan a que exista.
	playerData.Parent = player
end

Players.PlayerAdded:Connect(setupPlayer)
for _, player in Players:GetPlayers() do
	task.spawn(setupPlayer, player)
end

Players.PlayerRemoving:Connect(function(player)
	local playerData = player:FindFirstChild("PlayerData")
	if playerData then
		savePlayer(player, playerData)
	end
	canSave[player] = nil
end)

task.spawn(function()
	while true do
		task.wait(AUTOSAVE_SECONDS)
		for _, player in Players:GetPlayers() do
			local playerData = player:FindFirstChild("PlayerData")
			if playerData then
				task.spawn(savePlayer, player, playerData)
			end
		end
	end
end)

-- Guarda a todos antes de que se cierre el servidor.
game:BindToClose(function()
	local waiting = 0
	for _, player in Players:GetPlayers() do
		local playerData = player:FindFirstChild("PlayerData")
		if playerData then
			waiting += 1
			task.spawn(function()
				savePlayer(player, playerData)
				waiting -= 1
			end)
		end
	end
	local started = os.clock()
	while waiting > 0 and os.clock() - started < 25 do
		task.wait(0.1)
	end
	if RunService:IsStudio() then
		task.wait(1)
	end
end)
