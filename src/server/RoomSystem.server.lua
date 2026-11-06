local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RoomData = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("RoomData"))
local showMessage = ReplicatedStorage:WaitForChild("ShowMessage")

local function newRemote(name)
	local remote = Instance.new("RemoteEvent")
	remote.Name = name
	remote.Parent = ReplicatedStorage
	return remote
end

local buyRoomItem = newRemote("BuyRoomItem")
local upgradeTable = newRemote("UpgradeTable")

buyRoomItem.OnServerEvent:Connect(function(player, itemId)
	local playerData = player:FindFirstChild("PlayerData")
	local item = typeof(itemId) == "string" and RoomData.getItem(itemId)
	if not playerData or not item then
		return
	end

	local owned = playerData.RoomItems
	if RoomData.owns(owned.Value, item.id) or playerData.Money.Value < item.price then
		return
	end

	playerData.Money.Value -= item.price
	owned.Value = owned.Value == "" and item.id or (owned.Value .. "," .. item.id)
	showMessage:FireClient(player, "¡Comprado: " .. item.name .. "!")
end)

upgradeTable.OnServerEvent:Connect(function(player)
	local playerData = player:FindFirstChild("PlayerData")
	if not playerData then
		return
	end

	local nextLevel = RoomData.TableLevels[playerData.TableLevel.Value + 1]
	if not nextLevel or playerData.Money.Value < nextLevel.price then
		return
	end

	playerData.Money.Value -= nextLevel.price
	playerData.TableLevel.Value += 1
	showMessage:FireClient(player, "¡Mesa mejorada: " .. nextLevel.name .. "!")
end)
