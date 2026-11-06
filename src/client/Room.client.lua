-- Dibuja la decoración del jugador. Solo la ve él, porque la habitación es compartida.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local RoomData = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("RoomData"))

local playerData = Players.LocalPlayer:WaitForChild("PlayerData")
local roomItems = playerData:WaitForChild("RoomItems")
local tableLevel = playerData:WaitForChild("TableLevel")

local annex = RoomData.Annex
local centerX = (annex.x0 + annex.x1) / 2
local centerZ = (annex.z0 + annex.z1) / 2
local floorY = annex.floor

local folder = Instance.new("Folder")
folder.Name = "RoomDecor"
folder.Parent = Workspace

local function block(parent, size, position, color, material, shape)
	local part = Instance.new("Part")
	part.Anchored = true
	part.Size = size
	part.CFrame = typeof(position) == "CFrame" and position or CFrame.new(position)
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	if shape then
		part.Shape = shape
	end
	part.Parent = parent
	return part
end

local builders = {}

function builders.rug(parent)
	local outer = block(parent, Vector3.new(24, 0.1, 18), Vector3.new(centerX, floorY + 0.05, centerZ), Color3.fromRGB(76, 29, 149), Enum.Material.Fabric)
	local inner = block(parent, Vector3.new(20, 0.12, 14), Vector3.new(centerX, floorY + 0.06, centerZ), Color3.fromRGB(124, 92, 255), Enum.Material.Fabric)
	outer.CanCollide = false
	inner.CanCollide = false
end

function builders.plants(parent)
	for _, z in { annex.z0 + 3, annex.z1 - 3 } do
		local x = annex.x1 - 3
		block(parent, Vector3.new(2, 1.8, 2), Vector3.new(x, floorY + 0.9, z), Color3.fromRGB(120, 72, 48))
		block(parent, Vector3.new(0.4, 2.4, 0.4), Vector3.new(x, floorY + 3, z), Color3.fromRGB(92, 60, 38))
		for _, leaf in { Vector3.new(0, 4.6, 0), Vector3.new(1, 3.8, 0.4), Vector3.new(-1, 3.9, -0.3), Vector3.new(0.2, 3.9, -1) } do
			block(parent, Vector3.new(2.2, 2.2, 2.2), Vector3.new(x, floorY, z) + leaf, Color3.fromRGB(34, 150, 84), Enum.Material.Grass, Enum.PartType.Ball)
		end
	end
end

function builders.posters(parent)
	local designs = {
		{ text = "🎟️", caption = "RASCA", color = Color3.fromRGB(37, 99, 235) },
		{ text = "💰", caption = "JACKPOT", color = Color3.fromRGB(217, 119, 6) },
		{ text = "🍀", caption = "SUERTE", color = Color3.fromRGB(21, 128, 61) },
		{ text = "👑", caption = "PRESTIGIO", color = Color3.fromRGB(109, 40, 217) },
	}
	for index, design in designs do
		local x = annex.x0 + 5 + (index - 1) * 8.5
		local poster = block(parent, Vector3.new(5.2, 6.5, 0.1), Vector3.new(x, floorY + 6.6, annex.z1 - 0.7), design.color)
		poster.CanCollide = false

		local gui = Instance.new("SurfaceGui")
		gui.Face = Enum.NormalId.Front
		gui.CanvasSize = Vector2.new(240, 300)
		gui.Parent = poster

		local emoji = Instance.new("TextLabel")
		emoji.BackgroundTransparency = 1
		emoji.Size = UDim2.new(1, 0, 0.7, 0)
		emoji.Text = design.text
		emoji.TextSize = 120
		emoji.Parent = gui

		local caption = Instance.new("TextLabel")
		caption.BackgroundTransparency = 1
		caption.Position = UDim2.fromScale(0, 0.7)
		caption.Size = UDim2.fromScale(1, 0.25)
		caption.Text = design.caption
		caption.Font = Enum.Font.GothamBlack
		caption.TextSize = 34
		caption.TextColor3 = Color3.new(1, 1, 1)
		caption.Parent = gui
	end
end

function builders.sofa(parent)
	local color = Color3.fromRGB(67, 56, 120)
	local x, z = centerX, annex.z1 - 3.2
	block(parent, Vector3.new(14, 1.6, 4), Vector3.new(x, floorY + 0.8, z), color, Enum.Material.Fabric)
	block(parent, Vector3.new(14, 3.6, 1), Vector3.new(x, floorY + 2.4, z + 1.9), color, Enum.Material.Fabric)
	for _, side in { -1, 1 } do
		block(parent, Vector3.new(1, 2.6, 4), Vector3.new(x + side * 7, floorY + 1.3, z), color, Enum.Material.Fabric)
	end
end

function builders.neon(parent)
	local y = annex.top - 0.3
	local color = Color3.fromRGB(236, 72, 153)
	local width = annex.x1 - annex.x0
	local depth = annex.z1 - annex.z0
	local strips = {
		{ Vector3.new(width, 0.2, 0.2), Vector3.new(centerX, y, annex.z0 + 1) },
		{ Vector3.new(width, 0.2, 0.2), Vector3.new(centerX, y, annex.z1 - 1) },
		{ Vector3.new(0.2, 0.2, depth), Vector3.new(annex.x1 - 1, y, centerZ) },
	}
	for _, strip in strips do
		local part = block(parent, strip[1], strip[2], color, Enum.Material.Neon)
		part.CanCollide = false
	end
	local glow = Instance.new("PointLight")
	glow.Color = color
	glow.Range = 40
	glow.Brightness = 0.8
	glow.Parent = block(parent, Vector3.new(0.2, 0.2, 0.2), Vector3.new(centerX, y, centerZ), color, Enum.Material.Neon)
end

function builders.arcade(parent)
	local x, z = annex.x1 - 2.4, centerZ
	local body = Color3.fromRGB(30, 27, 75)
	block(parent, Vector3.new(3.2, 7.4, 3.6), Vector3.new(x, floorY + 3.7, z), body)
	block(parent, Vector3.new(0.1, 2.6, 2.8), Vector3.new(x - 1.65, floorY + 5, z), Color3.fromRGB(34, 211, 238), Enum.Material.Neon).CanCollide = false
	block(parent, Vector3.new(1, 0.3, 3), Vector3.new(x - 2, floorY + 3.3, z), Color3.fromRGB(67, 56, 120))
	for offset = -1, 1 do
		block(parent, Vector3.new(0.3, 0.2, 0.3), Vector3.new(x - 2.1, floorY + 3.5, z + offset * 0.8), Color3.fromRGB(248, 113, 113), Enum.Material.Neon).CanCollide = false
	end
	block(parent, Vector3.new(0.1, 0.7, 3.4), Vector3.new(x - 1.65, floorY + 7, z), Color3.fromRGB(236, 72, 153), Enum.Material.Neon).CanCollide = false
end

function builders.trophy(parent)
	local x, z = centerX, annex.z0 + 4
	local gold = Color3.fromRGB(250, 204, 21)
	block(parent, Vector3.new(3.4, 3.6, 3.4), Vector3.new(x, floorY + 1.8, z), Color3.fromRGB(241, 245, 249), Enum.Material.Marble)
	block(parent, Vector3.new(1.8, 0.4, 1.8), Vector3.new(x, floorY + 3.8, z), gold, Enum.Material.Metal)
	block(parent, Vector3.new(0.6, 1.2, 0.6), Vector3.new(x, floorY + 4.6, z), gold, Enum.Material.Metal)
	local cup = block(parent, Vector3.new(2.2, 2.2, 2.2), Vector3.new(x, floorY + 6, z), gold, Enum.Material.Metal, Enum.PartType.Ball)
	for _, side in { -1, 1 } do
		block(parent, Vector3.new(0.3, 1, 0.3), Vector3.new(x + side * 1.3, floorY + 6.1, z), gold, Enum.Material.Metal)
	end
	local light = Instance.new("PointLight")
	light.Color = gold
	light.Range = 14
	light.Parent = cup
end

local built = {}

local function refreshItems()
	for _, item in RoomData.Items do
		if RoomData.owns(roomItems.Value, item.id) and not built[item.id] then
			local model = Instance.new("Model")
			model.Name = item.id
			builders[item.id](model)
			model.Parent = folder
			built[item.id] = model
		end
	end
end

-- Tapete sobre la mesa, con el color del nivel.
local mat
local function refreshTable()
	local info = RoomData.TableLevels[tableLevel.Value]
	if mat then
		mat:Destroy()
		mat = nil
	end
	if info then
		mat = block(folder, Vector3.new(4.8, 0.06, 8.6), RoomData.TableTopCenter, info.color, Enum.Material.Fabric)
		mat.CanCollide = false
	end
end

roomItems.Changed:Connect(refreshItems)
tableLevel.Changed:Connect(refreshTable)
refreshItems()
refreshTable()
