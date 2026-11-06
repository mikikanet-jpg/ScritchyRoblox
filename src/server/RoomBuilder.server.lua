-- Convierte la habitación en una casa al arrancar: la sala original queda como dormitorio
-- con baño, y al otro lado de una puerta se construye el salón con la mesa de rascar.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RoomData = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("RoomData"))

local hotel = workspace:WaitForChild("Hotel room")
local annex = RoomData.Annex
local width = annex.x1 - annex.x0
local centerX = (annex.x0 + annex.x1) / 2
local centerZ = (annex.z0 + annex.z1) / 2
local depth = annex.z1 - annex.z0

local function findPart(name, x, y, z)
	for _, child in hotel:GetChildren() do
		if child.Name == name and child:IsA("BasePart") then
			local p = child.Position
			if math.abs(p.X - x) < 0.1 and math.abs(p.Y - y) < 0.1 and math.abs(p.Z - z) < 0.1 then
				return child
			end
		end
	end
	error("No se encuentra la pieza " .. name)
end

local folder = Instance.new("Folder")
folder.Name = "RoomExpansion"
folder.Parent = workspace

-- Copia una pieza con sus texturas, conservando su giro.
local function copy(template, size, position)
	local part = template:Clone()
	part.Size = size
	part.CFrame = CFrame.new(position) * template.CFrame.Rotation
	part.Parent = folder
	return part
end

local floor = findPart("Floor", -109.8436, 72.2361, 160.0636)
local under = findPart("Ceiling", -109.8436, 71.5967, 160.0636)
local eastLower = findPart("Wall Part", -97.5186, 77.3518, 160.3834)
local eastUpper = findPart("Wall Part", -97.6939, 82.7872, 160.3834)
local southBase = findPart("Wall Part", -109.8436, 73.8348, 142.7983)
local southTop = findPart("Wall Part", -109.8436, 82.7872, 142.7983)
local southPost = findPart("Wall Part", -98.9728, 78.6307, 142.7983)
local window = findPart("Window", -111.7619, 78.6294, 142.748)

copy(floor, Vector3.new(width, floor.Size.Y, depth), Vector3.new(centerX, floor.Position.Y, centerZ))
copy(under, Vector3.new(width, under.Size.Y, depth), Vector3.new(centerX, under.Position.Y, centerZ))

copy(eastLower, eastLower.Size, Vector3.new(annex.x1, eastLower.Position.Y, eastLower.Position.Z))
copy(eastUpper, eastUpper.Size, Vector3.new(annex.x1, eastUpper.Position.Y, eastUpper.Position.Z))

copy(southPost, Vector3.new(width, 9.5919, southPost.Size.Z), Vector3.new(centerX, 77.3518, annex.z1 - 0.3))
copy(southTop, Vector3.new(width, southTop.Size.Y, southTop.Size.Z), Vector3.new(centerX, southTop.Position.Y, annex.z1 - 0.3))

copy(southBase, Vector3.new(width, southBase.Size.Y, southBase.Size.Z), Vector3.new(centerX, southBase.Position.Y, southBase.Position.Z))
copy(southTop, Vector3.new(width, southTop.Size.Y, southTop.Size.Z), Vector3.new(centerX, southTop.Position.Y, southTop.Position.Z))

local POST = 2.4
local postY, postZ = southPost.Position.Y, southPost.Position.Z
local postSize = Vector3.new(POST, southPost.Size.Y, southPost.Size.Z)
copy(southPost, postSize, Vector3.new(annex.x1 - POST / 2, postY, postZ))
copy(southPost, postSize, Vector3.new(centerX, postY, postZ))

local leftPane = width / 2 - POST / 2
local rightPane = width / 2 - POST * 1.5
local paneY, paneZ = window.Position.Y, window.Position.Z
copy(window, Vector3.new(leftPane, window.Size.Y, window.Size.Z), Vector3.new(annex.x0 + leftPane / 2, paneY, paneZ))
copy(window, Vector3.new(rightPane, window.Size.Y, window.Size.Z), Vector3.new(centerX + POST / 2 + rightPane / 2, paneY, paneZ))

local ceiling = Instance.new("Part")
ceiling.Name = "AnnexCeiling"
ceiling.Anchored = true
ceiling.Size = Vector3.new(width, 0.6, depth)
ceiling.CFrame = CFrame.new(centerX, annex.top + 0.3, centerZ)
ceiling.Material = Enum.Material.WoodPlanks
ceiling.Color = Color3.fromRGB(143, 76, 42)
ceiling.Parent = folder

-- Mismas lámparas que la sala original.
local lightTemplate
for _, child in workspace:GetChildren() do
	if child.Name == "Light" and child:IsA("Model") then
		lightTemplate = child
		break
	end
end
if lightTemplate then
	local pivotY = lightTemplate:GetPivot().Y
	for _, offset in { Vector2.new(-9, -8), Vector2.new(9, -8), Vector2.new(-9, 8), Vector2.new(9, 8) } do
		local light = lightTemplate:Clone()
		light:PivotTo(CFrame.new(centerX + offset.X, pivotY, centerZ + offset.Y))
		light.Parent = folder
	end
end

-- Puerta entre el dormitorio y el salón. El resto de la pared sigue cerrando el baño.
local DOOR_Z0, DOOR_Z1 = 151, 157
local DOOR_TOP = 80.2
local wallX, wallY, wallZ = eastLower.Position.X, eastLower.Position.Y, eastLower.Position.Z
local wallStart = wallZ - eastLower.Size.X / 2
local wallEnd = wallZ + eastLower.Size.X / 2
local wallThick = eastLower.Size.Z
local wallHeight = eastLower.Size.Y
local wallTop = wallY + wallHeight / 2

copy(eastLower, Vector3.new(DOOR_Z0 - wallStart, wallHeight, wallThick), Vector3.new(wallX, wallY, (wallStart + DOOR_Z0) / 2))
copy(eastLower, Vector3.new(wallEnd - DOOR_Z1, wallHeight, wallThick), Vector3.new(wallX, wallY, (wallEnd + DOOR_Z1) / 2))
copy(eastLower, Vector3.new(DOOR_Z1 - DOOR_Z0, wallTop - DOOR_TOP, wallThick), Vector3.new(wallX, (wallTop + DOOR_TOP) / 2, (DOOR_Z0 + DOOR_Z1) / 2))
eastLower:Destroy()

local function frame(size, position)
	local part = Instance.new("Part")
	part.Name = "DoorFrame"
	part.Anchored = true
	part.Size = size
	part.CFrame = CFrame.new(position)
	part.Material = Enum.Material.Wood
	part.Color = Color3.fromRGB(92, 60, 38)
	part.Parent = folder
end
local doorMidY = (annex.floor + DOOR_TOP) / 2
local doorHeight = DOOR_TOP - annex.floor
frame(Vector3.new(0.9, doorHeight, 0.3), Vector3.new(wallX, doorMidY, DOOR_Z0 + 0.15))
frame(Vector3.new(0.9, doorHeight, 0.3), Vector3.new(wallX, doorMidY, DOOR_Z1 - 0.15))
frame(Vector3.new(0.9, 0.3, DOOR_Z1 - DOOR_Z0), Vector3.new(wallX, DOOR_TOP - 0.15, (DOOR_Z0 + DOOR_Z1) / 2))

-- La mesa de rascar y su silla pasan al centro del salón.
local tableTop = workspace:WaitForChild("table")
local chair = workspace:WaitForChild("Chair")
local tableInteract = workspace:WaitForChild("TicketTable_Interact")
local tableOffset = Vector3.new(RoomData.TableTopCenter.X + 101.0282, 0, RoomData.TableTopCenter.Z - 155.6514)
tableTop:PivotTo(tableTop:GetPivot() + tableOffset)
chair:PivotTo(chair:GetPivot() + tableOffset)
tableInteract.CFrame = tableInteract.CFrame + tableOffset

-- Se aparece en el salón, no en el baño.
local spawnLocation = workspace:FindFirstChildOfClass("SpawnLocation")
if spawnLocation then
	for _, child in spawnLocation:GetChildren() do
		if child:IsA("Decal") then
			child:Destroy()
		end
	end
	spawnLocation.Transparency = 1
	spawnLocation.CanCollide = false
	spawnLocation.CFrame = CFrame.new(annex.x0 + 5, annex.floor + 0.3, annex.z1 - 7)
end
