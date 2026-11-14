-- Ranking mundial: los 10 jugadores con más dinero ganado y con más jackpots.
-- El resultado se publica en ReplicatedStorage.Leaderboards para que lo lean los clientes.
local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local REFRESH_SECONDS = 120
local TOP = 10

local BOARDS = {
	{ id = "Earned", stat = "TotalEarned", storeName = "ScritchyTop_Earned_v1" },
	{ id = "Jackpots", stat = "Jackpots", storeName = "ScritchyTop_Jackpots_v1" },
}

local folder = Instance.new("Folder")
folder.Name = "Leaderboards"
for _, board in BOARDS do
	local value = Instance.new("StringValue")
	value.Name = board.id
	value.Value = "[]"
	value.Parent = folder
	board.value = value
	local ok, store = pcall(function()
		return DataStoreService:GetOrderedDataStore(board.storeName)
	end)
	board.store = ok and store or nil
end
folder.Parent = ReplicatedStorage

-- Último valor enviado de cada jugador, para no escribir si no ha cambiado.
local sent = {}

local function writePlayer(player)
	local playerData = player:FindFirstChild("PlayerData")
	-- Si sus datos no cargaron, tiene ceros: no se pisa su puesto en el ranking.
	if not playerData or player:GetAttribute("DataLoadFailed") then
		return
	end
	sent[player] = sent[player] or {}
	for _, board in BOARDS do
		local amount = playerData[board.stat].Value
		if board.store and amount > 0 and sent[player][board.id] ~= amount then
			local ok = pcall(function()
				board.store:SetAsync(tostring(player.UserId), amount)
			end)
			if ok then
				sent[player][board.id] = amount
			end
		end
	end
end

local names = {}

local function nameFor(userId)
	if not names[userId] then
		local ok, name = pcall(function()
			return Players:GetNameFromUserIdAsync(userId)
		end)
		if not ok then
			return "?"
		end
		names[userId] = name
	end
	return names[userId]
end

local function refreshBoards()
	for _, board in BOARDS do
		if board.store then
			local ok, page = pcall(function()
				return board.store:GetSortedAsync(false, TOP):GetCurrentPage()
			end)
			if ok then
				local list = {}
				for _, entry in page do
					local userId = tonumber(entry.key)
					if userId then
						table.insert(list, { id = userId, name = nameFor(userId), value = entry.value })
					end
				end
				board.value.Value = HttpService:JSONEncode(list)
			end
		end
	end
end

Players.PlayerRemoving:Connect(function(player)
	writePlayer(player)
	sent[player] = nil
end)

while true do
	for _, player in Players:GetPlayers() do
		writePlayer(player)
	end
	refreshBoards()
	task.wait(REFRESH_SECONDS)
end
