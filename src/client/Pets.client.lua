-- Dibuja la mascota equipada de cada jugador. Solo es visual, los bonus están en el servidor.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local PetData = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("PetData"))

local FOLLOW_OFFSET = CFrame.new(3, 0.2, 2.5)
local FOLLOW_SPEED = 7

local folder = Instance.new("Folder")
folder.Name = "PetVisuals"
folder.Parent = Workspace

local function addPart(model, shape, size, color, offset)
	local part = Instance.new(shape == "Wedge" and "WedgePart" or "Part")
	if shape == "Ball" then
		part.Shape = Enum.PartType.Ball
	end
	part.Size = size
	part.Color = color
	part.Material = Enum.Material.SmoothPlastic
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.CFrame = offset
	part.Parent = model
	return part
end

local function addMirrored(model, shape, size, color, x, y, z, angles)
	for _, side in { -1, 1 } do
		addPart(model, shape, size, color, CFrame.new(side * x, y, z) * CFrame.Angles(angles.X, side * angles.Y, side * angles.Z))
	end
end

local function buildPet(pet)
	local model = Instance.new("Model")
	model.Name = pet.id

	local body = addPart(model, "Ball", Vector3.new(1.7, 1.7, 1.7), pet.color, CFrame.new())
	model.PrimaryPart = body

	addMirrored(model, "Ball", Vector3.new(0.34, 0.34, 0.34), Color3.new(0.05, 0.05, 0.08), 0.34, 0.15, -0.72, Vector3.zero)
	addPart(model, "Ball", Vector3.new(0.22, 0.18, 0.18), pet.accent, CFrame.new(0, -0.15, -0.82))

	if pet.style == "cat" then
		addMirrored(model, "Wedge", Vector3.new(0.18, 0.55, 0.5), pet.color, 0.48, 0.92, 0, Vector3.new(0, math.pi / 2, -0.25))
	elseif pet.style == "dog" then
		addMirrored(model, "Block", Vector3.new(0.3, 0.8, 0.45), pet.accent, 0.9, 0.2, 0, Vector3.new(0, 0, 0.2))
	elseif pet.style == "bunny" then
		addMirrored(model, "Block", Vector3.new(0.3, 1.2, 0.18), pet.color, 0.32, 1.25, 0, Vector3.new(0, 0, -0.12))
		addMirrored(model, "Block", Vector3.new(0.14, 0.9, 0.2), pet.accent, 0.32, 1.25, -0.02, Vector3.new(0, 0, -0.12))
	elseif pet.style == "round" then
		addMirrored(model, "Ball", Vector3.new(0.65, 0.65, 0.65), pet.accent, 0.62, 0.72, 0, Vector3.zero)
		addMirrored(model, "Ball", Vector3.new(0.5, 0.56, 0.2), pet.accent, 0.34, 0.15, -0.66, Vector3.zero)
		addMirrored(model, "Ball", Vector3.new(0.2, 0.2, 0.2), Color3.new(1, 1, 1), 0.34, 0.18, -0.78, Vector3.zero)
	elseif pet.style == "wings" then
		addMirrored(model, "Wedge", Vector3.new(0.14, 0.9, 1.3), pet.accent, 1.05, 0.25, 0.3, Vector3.new(0, 0, -0.7))
		addMirrored(model, "Wedge", Vector3.new(0.18, 0.5, 0.4), pet.accent, 0.42, 0.9, 0, Vector3.new(0, math.pi / 2, -0.2))
	elseif pet.style == "antenna" then
		addMirrored(model, "Block", Vector3.new(0.08, 0.7, 0.08), pet.accent, 0.32, 1.05, 0, Vector3.new(0, 0, -0.25))
		addMirrored(model, "Ball", Vector3.new(0.25, 0.25, 0.25), pet.accent, 0.42, 1.42, 0, Vector3.zero)
	end

	if pet.glow then
		local light = Instance.new("PointLight")
		light.Color = pet.color
		light.Range = 10
		light.Brightness = 1.5
		light.Parent = body
		local sparks = Instance.new("ParticleEmitter")
		sparks.Color = ColorSequence.new(pet.color, pet.accent)
		sparks.LightEmission = 0.7
		sparks.Size = NumberSequence.new(0.3, 0)
		sparks.Lifetime = NumberRange.new(0.6, 1)
		sparks.Speed = NumberRange.new(1, 3)
		sparks.Rate = 12
		sparks.Parent = body
	end

	return model
end

local active = {}

local function removePet(player)
	local entry = active[player]
	if entry then
		entry.model:Destroy()
		active[player] = nil
	end
end

local function trackPlayer(player)
	local playerData = player:WaitForChild("PlayerData", 60)
	if not playerData then
		return
	end
	local equipped = playerData:WaitForChild("EquippedPet")

	local function refresh()
		removePet(player)
		local pet = PetData.get(equipped.Value)
		if pet then
			local model = buildPet(pet)
			model.Parent = folder
			active[player] = { model = model, seed = math.random() * 10 }
		end
	end

	equipped.Changed:Connect(refresh)
	refresh()
end

Players.PlayerAdded:Connect(trackPlayer)
Players.PlayerRemoving:Connect(removePet)
for _, player in Players:GetPlayers() do
	task.spawn(trackPlayer, player)
end

RunService.RenderStepped:Connect(function(deltaTime)
	local alpha = 1 - math.exp(-FOLLOW_SPEED * deltaTime)
	for player, entry in active do
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if root then
			local bob = math.sin(os.clock() * 3 + entry.seed) * 0.25
			local target = root.CFrame * FOLLOW_OFFSET * CFrame.new(0, bob, 0)
			if not entry.position then
				entry.position = target
			end
			entry.position = entry.position:Lerp(target, alpha)
			entry.model:PivotTo(entry.position)
		end
	end
end)
