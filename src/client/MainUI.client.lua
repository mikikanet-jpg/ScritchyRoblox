--!strict
-- Interfaz principal de Scratch Room.
-- Sustituye a GameUI y TicketShopUI. Todo se crea por código, así que Rojo la sincroniza entera.
-- La lógica sigue en el servidor: aquí solo se muestra el estado y se envían los eventos.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui") :: PlayerGui
local data = player:WaitForChild("PlayerData")

local TicketData = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("TicketData")) :: any
local PetData = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("PetData")) :: any
local RoomData = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("RoomData")) :: any
local MissionData = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("MissionData")) :: any
local Lang = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Lang")) :: any

local remotes = {
	ShowMessage = ReplicatedStorage:WaitForChild("ShowMessage") :: RemoteEvent,
	OpenShop = ReplicatedStorage:WaitForChild("OpenShop") :: RemoteEvent,
	OpenScratch = ReplicatedStorage:WaitForChild("OpenScratch") :: RemoteEvent,
	BuyTicket = ReplicatedStorage:WaitForChild("BuyTicket") :: RemoteEvent,
	ScratchTicket = ReplicatedStorage:WaitForChild("ScratchTicket") :: RemoteEvent,
	BuyLuck = ReplicatedStorage:WaitForChild("BuyLuck") :: RemoteEvent,
	BuyAutoScratch = ReplicatedStorage:WaitForChild("BuyAutoScratch") :: RemoteEvent,
	UpgradeAutoSpeed = ReplicatedStorage:WaitForChild("UpgradeAutoSpeed") :: RemoteEvent,
	PrestigeEvent = ReplicatedStorage:WaitForChild("PrestigeEvent") :: RemoteEvent,
	ScratchStarted = ReplicatedStorage:WaitForChild("ScratchStarted") :: RemoteEvent,
	ScratchReveal = ReplicatedStorage:WaitForChild("ScratchReveal") :: RemoteEvent,
	JackpotAnnounced = ReplicatedStorage:WaitForChild("JackpotAnnounced") :: RemoteEvent,
}

-- Estos valores repiten los del servidor. Si cambian allí, hay que cambiarlos también aquí.
local AUTO_SCRATCH_PRICE = 3000
local AUTO_SPEED_PRICE = 2500
local AUTO_SPEED_MIN = 0.5
local PRESTIGE_LEVEL = 20

local Theme = {
	Bg = Color3.fromRGB(17, 18, 28),
	Surface = Color3.fromRGB(28, 30, 45),
	SurfaceHigh = Color3.fromRGB(40, 43, 63),
	Stroke = Color3.fromRGB(62, 66, 94),
	Text = Color3.fromRGB(244, 245, 252),
	Muted = Color3.fromRGB(160, 165, 190),
	Accent = Color3.fromRGB(124, 92, 255),
	AccentHigh = Color3.fromRGB(167, 139, 250),
	Green = Color3.fromRGB(52, 211, 153),
	Red = Color3.fromRGB(248, 113, 113),
	Amber = Color3.fromRGB(251, 191, 36),
	Disabled = Color3.fromRGB(58, 61, 80),
}

local Tiers = {
	{ id = "Basic", name = "Básico", letter = "B", plural = "Tickets Básicos", emoji = "🎟️", main = true, color = Color3.fromRGB(79, 173, 255), dark = Color3.fromRGB(37, 99, 235) },
	{ id = "Silver", name = "Plata", letter = "P", plural = "Tickets Plata", emoji = "🎟️", main = true, color = Color3.fromRGB(203, 213, 225), dark = Color3.fromRGB(100, 116, 139) },
	{ id = "Gold", name = "Oro", letter = "O", plural = "Tickets Oro", emoji = "🎟️", main = true, color = Color3.fromRGB(252, 211, 77), dark = Color3.fromRGB(217, 119, 6) },
	{ id = "Pizza", name = "Pizza", emoji = "🍕", color = Color3.fromRGB(251, 146, 60), dark = Color3.fromRGB(194, 65, 12) },
	{ id = "Space", name = "Espacio", emoji = "🚀", color = Color3.fromRGB(129, 140, 248), dark = Color3.fromRGB(49, 46, 129) },
	{ id = "Zombie", name = "Zombi", emoji = "🧟", color = Color3.fromRGB(132, 204, 22), dark = Color3.fromRGB(54, 83, 20) },
	{ id = "Final", name = "Final", emoji = "🏆", color = Color3.fromRGB(250, 204, 21), dark = Color3.fromRGB(113, 63, 18) },
}

local FONT = Enum.Font.GothamMedium
local FONT_BOLD = Enum.Font.GothamBold
local FONT_BLACK = Enum.Font.GothamBlack

---------------------------------------------------------------------
-- Utilidades
---------------------------------------------------------------------

local function make(className: string, props: { [string]: any }, children: { Instance }?): any
	local instance = Instance.new(className) :: any
	local parent = props.Parent
	for key, value in props do
		if key ~= "Parent" then
			instance[key] = value
		end
	end
	if children then
		for _, child in children do
			child.Parent = instance
		end
	end
	instance.Parent = parent
	return instance
end

local function corner(radius: number): UICorner
	return make("UICorner", { CornerRadius = UDim.new(0, radius) })
end

local function stroke(color: Color3, transparency: number?): UIStroke
	return make("UIStroke", {
		Color = color,
		Transparency = transparency or 0,
		Thickness = 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
end

local function padding(x: number, y: number): UIPadding
	return make("UIPadding", {
		PaddingLeft = UDim.new(0, x),
		PaddingRight = UDim.new(0, x),
		PaddingTop = UDim.new(0, y),
		PaddingBottom = UDim.new(0, y),
	})
end

local function label(props: { [string]: any }): TextLabel
	local defaults: { [string]: any } = {
		BackgroundTransparency = 1,
		Font = FONT,
		TextColor3 = Theme.Text,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}
	for key, value in props do
		defaults[key] = value
	end
	return make("TextLabel", defaults)
end

local function tween(instance: Instance, seconds: number, goal: { [string]: any }, style: Enum.EasingStyle?, direction: Enum.EasingDirection?)
	local info = TweenInfo.new(seconds, style or Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out)
	local t = TweenService:Create(instance, info, goal)
	t:Play()
	return t
end

-- 1234567 -> 1.234.567
local function formatNumber(value: number): string
	local text = tostring(math.floor(math.abs(value)))
	text = text:reverse():gsub("(%d%d%d)", "%1" .. Lang.thousands):reverse()
	if text:sub(1, 1) == Lang.thousands then
		text = text:sub(2)
	end
	return (value < 0 and "-" or "") .. text
end

local function money(value: number): string
	return "$" .. formatNumber(value)
end

local function stat(name: string): any
	return data:WaitForChild(name)
end

local stats = {
	Money = stat("Money"),
	Level = stat("TicketLevel"),
	XP = stat("TicketXP"),
	Luck = stat("Luck"),
	Prestige = stat("Prestige"),
	Auto = stat("AutoScratch"),
	Speed = stat("AutoScratchSpeed"),
	GameWon = stat("GameWon"),
}
for _, tier in Tiers do
	stats[tier.id] = stat(tier.id .. "Tickets")
end

local function tierUnlocked(tier: any): boolean
	local info = TicketData[tier.id]
	return stats.Level.Value >= info.UnlockLevel and stats.Prestige.Value >= (info.UnlockPrestige or 0)
end

local function tierRequirement(tier: any): string
	local info = TicketData[tier.id]
	if stats.Prestige.Value < (info.UnlockPrestige or 0) then
		return "Prestigio " .. info.UnlockPrestige
	end
	return "Nivel " .. info.UnlockLevel
end

---------------------------------------------------------------------
-- Botones
---------------------------------------------------------------------

local function button(props: { [string]: any }, onClick: () -> ()): (TextButton, (Color3) -> ())
	local baseColor: Color3 = props.BackgroundColor3 or Theme.Accent
	local scale = make("UIScale", { Scale = 1 })
	local gui = make("TextButton", {
		Size = props.Size,
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		Text = props.Text or "",
		TextColor3 = props.TextColor3 or Theme.Text,
		TextSize = props.TextSize or 14,
		Font = props.Font or FONT_BOLD,
		BackgroundColor3 = baseColor,
		AutoButtonColor = false,
		LayoutOrder = props.LayoutOrder,
		Parent = props.Parent,
	}, { corner(props.Radius or 10), scale })

	local function setColor(color: Color3)
		baseColor = color
		gui.BackgroundColor3 = color
	end

	gui.MouseEnter:Connect(function()
		tween(gui, 0.12, { BackgroundColor3 = baseColor:Lerp(Color3.new(1, 1, 1), 0.12) })
	end)
	gui.MouseLeave:Connect(function()
		tween(gui, 0.15, { BackgroundColor3 = baseColor })
		tween(scale, 0.15, { Scale = 1 })
	end)
	gui.MouseButton1Down:Connect(function()
		tween(scale, 0.07, { Scale = 0.95 })
	end)
	gui.MouseButton1Up:Connect(function()
		tween(scale, 0.18, { Scale = 1 }, Enum.EasingStyle.Back)
	end)
	gui.Activated:Connect(onClick)

	return gui, setColor
end

---------------------------------------------------------------------
-- Capas
---------------------------------------------------------------------

-- Quita la interfaz antigua si sigue en StarterGui.
local LEGACY_GUIS = { GameUI = true, TicketShopUI = true }
local function removeLegacy(child: Instance)
	if LEGACY_GUIS[child.Name] then
		child:Destroy()
	end
end
for _, child in playerGui:GetChildren() do
	removeLegacy(child)
end
playerGui.ChildAdded:Connect(function(child)
	task.defer(removeLegacy, child)
end)

local hudGui = make("ScreenGui", {
	Name = "ScratchHUD",
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	DisplayOrder = 5,
	Parent = playerGui,
})

local modalGui = make("ScreenGui", {
	Name = "ScratchMenus",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	DisplayOrder = 10,
	Parent = playerGui,
})

local toastGui = make("ScreenGui", {
	Name = "ScratchToasts",
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	DisplayOrder = 20,
	Parent = playerGui,
})

---------------------------------------------------------------------
-- Avisos
---------------------------------------------------------------------

local toastList = make("Frame", {
	AnchorPoint = Vector2.new(0.5, 1),
	Position = UDim2.new(0.5, 0, 1, -96),
	Size = UDim2.fromOffset(360, 240),
	BackgroundTransparency = 1,
	Parent = toastGui,
}, {
	make("UIListLayout", {
		Padding = UDim.new(0, 8),
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		SortOrder = Enum.SortOrder.LayoutOrder,
	}),
})

local MAX_TOASTS = 4
local toastCounter = 0

local function classify(message: string): (Color3, boolean)
	local lower = message:lower()
	if lower:find("jackpot", 1, true) then
		return Theme.Amber, true
	elseif lower:find("perdido", 1, true) then
		return Theme.Red, false
	elseif lower:find("necesitas", 1, true) or lower:find("no tienes", 1, true) or lower:find("te faltan", 1, true) or lower:find("ya tienes", 1, true) then
		return Theme.Muted, false
	elseif message:sub(1, 1) == "+" or message:sub(1, 5) == "[AUTO" then
		return Theme.Green, false
	end
	return Theme.AccentHigh, false
end

-- Mientras se rasca, los avisos esperan para no tapar el ticket.
local cardOpen = false
local toastQueue: { string } = {}

local function showToast(message: string)
	if cardOpen then
		table.insert(toastQueue, message)
		if #toastQueue > MAX_TOASTS then
			table.remove(toastQueue, 1)
		end
		return
	end

	local color, big = classify(message)
	toastCounter += 1

	local scale = make("UIScale", { Scale = 0.85 })
	local toast = make("Frame", {
		Size = UDim2.fromOffset(big and 340 or 280, big and 58 or 42),
		BackgroundColor3 = Theme.Bg,
		BackgroundTransparency = 0.05,
		LayoutOrder = toastCounter,
		Parent = toastList,
	}, {
		corner(12),
		stroke(color, 0.25),
		scale,
		make("Frame", {
			Size = UDim2.new(0, 4, 1, -16),
			Position = UDim2.fromOffset(8, 8),
			BackgroundColor3 = color,
			BorderSizePixel = 0,
		}, { corner(2) }),
		label({
			Size = UDim2.new(1, -32, 1, 0),
			Position = UDim2.fromOffset(22, 0),
			Text = message,
			Font = big and FONT_BLACK or FONT_BOLD,
			TextSize = big and 20 or 15,
			TextColor3 = big and color or Theme.Text,
		}),
	})

	tween(scale, 0.25, { Scale = 1 }, Enum.EasingStyle.Back)

	local toasts = {}
	for _, child in toastList:GetChildren() do
		if child:IsA("Frame") then
			table.insert(toasts, child)
		end
	end
	if #toasts > MAX_TOASTS then
		table.sort(toasts, function(a, b)
			return a.LayoutOrder < b.LayoutOrder
		end)
		toasts[1]:Destroy()
	end

	task.delay(big and 3.2 or 2.2, function()
		if toast.Parent then
			tween(scale, 0.16, { Scale = 0.85 })
			task.wait(0.16)
			toast:Destroy()
		end
	end)
end

---------------------------------------------------------------------
-- Paneles
---------------------------------------------------------------------

local backdrop
local scratchRequested = false
-- Se avisa aquí cuando cambia lo que hay abierto, para el mando.
local uiChanged: () -> () = function() end
local openPanelName: string? = nil
local panels: { [string]: { root: Frame, scale: UIScale } } = {}

local function closePanels()
	if cardOpen or not openPanelName then
		return
	end
	local name = openPanelName :: string
	local panel = panels[name]
	openPanelName = nil
	uiChanged()
	tween(backdrop, 0.18, { BackgroundTransparency = 1 })
	tween(panel.scale, 0.14, { Scale = 0.94 })
	task.delay(0.14, function()
		if openPanelName ~= name then
			panel.root.Visible = false
		end
		if openPanelName == nil then
			backdrop.Visible = false
		end
	end)
end

local function openPanel(name: string)
	if cardOpen then
		return
	end
	if openPanelName == name then
		closePanels()
		return
	end
	if openPanelName then
		panels[openPanelName :: string].root.Visible = false
	end
	openPanelName = name
	backdrop.Visible = true
	tween(backdrop, 0.2, { BackgroundTransparency = 0.45 })
	local panel = panels[name]
	panel.scale.Scale = 0.92
	panel.root.Visible = true
	tween(panel.scale, 0.28, { Scale = 1 }, Enum.EasingStyle.Back)
	uiChanged()
end

backdrop = make("TextButton", {
	Name = "Backdrop",
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = Color3.new(0, 0, 0),
	BackgroundTransparency = 1,
	Text = "",
	AutoButtonColor = false,
	Selectable = false,
	Visible = false,
	Parent = modalGui,
})
backdrop.Activated:Connect(closePanels)

local function createPanel(name: string, title: string, subtitle: string, maxHeight: number): ScrollingFrame
	local scale = make("UIScale", { Scale = 1 })
	local root = make("Frame", {
		Name = name,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.92, 0.88),
		BackgroundColor3 = Theme.Bg,
		Visible = false,
		ZIndex = 2,
		Active = true,
		Parent = modalGui,
	}, {
		make("UISizeConstraint", { MaxSize = Vector2.new(540, maxHeight) }),
		corner(18),
		stroke(Theme.Stroke, 0.2),
		scale,
	})

	label({
		Position = UDim2.fromOffset(22, 16),
		Size = UDim2.new(1, -80, 0, 28),
		Text = title,
		Font = FONT_BLACK,
		TextSize = 24,
		ZIndex = 3,
		Parent = root,
	})
	label({
		Position = UDim2.fromOffset(22, 44),
		Size = UDim2.new(1, -80, 0, 18),
		Text = subtitle,
		TextColor3 = Theme.Muted,
		TextSize = 13,
		ZIndex = 3,
		Parent = root,
	})

	local close = button({
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -16, 0, 16),
		Size = UDim2.fromOffset(36, 36),
		Text = "X",
		TextSize = 15,
		TextColor3 = Theme.Muted,
		BackgroundColor3 = Theme.SurfaceHigh,
		Parent = root,
	}, closePanels)
	close.ZIndex = 3

	local body = make("ScrollingFrame", {
		Position = UDim2.fromOffset(0, 74),
		Size = UDim2.new(1, 0, 1, -74),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = Theme.Stroke,
		ZIndex = 3,
		Parent = root,
	}, {
		make("UIPadding", {
			PaddingLeft = UDim.new(0, 16),
			PaddingRight = UDim.new(0, 16),
			PaddingBottom = UDim.new(0, 16),
		}),
		make("UIListLayout", {
			Padding = UDim.new(0, 10),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})

	panels[name] = { root = root, scale = scale }
	return body
end

-- Fila común: icono, título, detalle y botón.
type Row = {
	title: TextLabel,
	detail: TextLabel,
	icon: TextLabel,
	action: TextButton,
	setActionColor: (Color3) -> (),
}

local function createRow(parent: Instance, order: number, iconText: string, colorA: Color3, colorB: Color3, onClick: () -> ()): Row
	local frame = make("Frame", {
		Size = UDim2.new(1, 0, 0, 84),
		BackgroundColor3 = Theme.Surface,
		LayoutOrder = order,
		Parent = parent,
	}, { corner(14), stroke(Theme.Stroke, 0.55) })

	local iconFrame = make("Frame", {
		Position = UDim2.fromOffset(12, 12),
		Size = UDim2.fromOffset(60, 60),
		BackgroundColor3 = Color3.new(1, 1, 1),
		Parent = frame,
	}, {
		corner(12),
		make("UIGradient", {
			Color = ColorSequence.new(colorA, colorB),
			Rotation = 45,
		}),
	})
	local icon = label({
		Size = UDim2.fromScale(1, 1),
		Text = iconText,
		Font = FONT_BLACK,
		TextSize = 24,
		TextColor3 = Theme.Bg,
		TextXAlignment = Enum.TextXAlignment.Center,
		Parent = iconFrame,
	})

	local title = label({
		Position = UDim2.fromOffset(84, 15),
		Size = UDim2.new(1, -212, 0, 26),
		Font = FONT_BOLD,
		TextSize = 17,
		Parent = frame,
	})
	local detail = label({
		Position = UDim2.fromOffset(84, 41),
		Size = UDim2.new(1, -212, 0, 28),
		TextColor3 = Theme.Muted,
		TextSize = 13,
		TextWrapped = true,
		TextTruncate = Enum.TextTruncate.None,
		TextYAlignment = Enum.TextYAlignment.Top,
		Parent = frame,
	})

	local action, setActionColor = button({
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.fromOffset(112, 44),
		TextSize = 14,
		Parent = frame,
	}, onClick)

	return { title = title, detail = detail, icon = icon, action = action, setActionColor = setActionColor }
end

---------------------------------------------------------------------
-- Barra superior
---------------------------------------------------------------------

local HUD_WIDTH = 720
local hudScale = make("UIScale", { Scale = 1 })

local hud = make("Frame", {
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 8),
	Size = UDim2.fromOffset(HUD_WIDTH, 60),
	BackgroundColor3 = Theme.Bg,
	BackgroundTransparency = 0.08,
	Parent = hudGui,
}, { corner(16), stroke(Theme.Stroke, 0.35), hudScale })

local moneyLabel = label({
	Position = UDim2.fromOffset(16, 0),
	Size = UDim2.fromOffset(150, 60),
	Font = FONT_BLACK,
	TextSize = 22,
	TextColor3 = Theme.Green,
	Parent = hud,
})

local levelLabel = label({
	Position = UDim2.fromOffset(174, 10),
	Size = UDim2.fromOffset(100, 20),
	Font = FONT_BOLD,
	TextSize = 13,
	Parent = hud,
})
local xpLabel = label({
	Position = UDim2.fromOffset(274, 10),
	Size = UDim2.fromOffset(60, 20),
	TextSize = 12,
	TextColor3 = Theme.Muted,
	TextXAlignment = Enum.TextXAlignment.Right,
	Parent = hud,
})
local xpTrack = make("Frame", {
	Position = UDim2.fromOffset(174, 34),
	Size = UDim2.fromOffset(160, 8),
	BackgroundColor3 = Theme.SurfaceHigh,
	Parent = hud,
}, { corner(4) })
local xpFill = make("Frame", {
	Size = UDim2.fromScale(0, 1),
	BackgroundColor3 = Color3.new(1, 1, 1),
	Parent = xpTrack,
}, {
	corner(4),
	make("UIGradient", { Color = ColorSequence.new(Theme.Accent, Theme.AccentHigh) }),
})

-- Texto que aparece al pasar el ratón por encima de la barra.
local hudTooltip = make("TextLabel", {
	AnchorPoint = Vector2.new(0.5, 0),
	AutomaticSize = Enum.AutomaticSize.X,
	Size = UDim2.fromOffset(0, 26),
	BackgroundColor3 = Theme.Bg,
	Font = FONT_BOLD,
	TextSize = 13,
	TextColor3 = Theme.Text,
	Visible = false,
	ZIndex = 5,
	Parent = hud,
}, { corner(8), stroke(Theme.Stroke, 0.3), padding(10, 0) })

local function addTooltip(target: any, text: string)
	target.MouseEnter:Connect(function()
		hudTooltip.Text = text
		hudTooltip.Position = UDim2.fromOffset(target.AbsolutePosition.X - hud.AbsolutePosition.X + target.AbsoluteSize.X / 2, 66)
		hudTooltip.Visible = true
	end)
	target.MouseLeave:Connect(function()
		hudTooltip.Visible = false
	end)
end

addTooltip(moneyLabel, "Tu dinero")
addTooltip(levelLabel, "Nivel: desbloquea tickets y el prestigio")
addTooltip(xpLabel, "XP: rasca tickets a mano para subir de nivel")

-- Icono pequeño con forma de ticket.
local function ticketIcon(tier: any, parent: Instance)
	local icon = make("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 6, 0.5, 0),
		Size = UDim2.fromOffset(19, 14),
		BackgroundColor3 = tier.color,
		Parent = parent,
	}, {
		corner(3),
		label({
			Size = UDim2.fromScale(1, 1),
			Text = tier.letter,
			Font = FONT_BLACK,
			TextSize = 10,
			TextColor3 = Theme.Bg,
			TextXAlignment = Enum.TextXAlignment.Center,
		}),
	})
	for _, x in { 0, 1 } do
		make("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(x, 0.5),
			Size = UDim2.fromOffset(5, 5),
			BackgroundColor3 = Theme.Surface,
			Parent = icon,
		}, { corner(3) })
	end
end

local hudTicketLabels: { [string]: TextLabel } = {}
for index, tier in Tiers do
	if not tier.main then
		continue
	end
	local chip = make("Frame", {
		Position = UDim2.fromOffset(346 + (index - 1) * 58, 14),
		Size = UDim2.fromOffset(54, 32),
		BackgroundColor3 = Theme.Surface,
		Parent = hud,
	}, { corner(9) })
	ticketIcon(tier, chip)
	addTooltip(chip, tier.plural)
	hudTicketLabels[tier.id] = label({
		Position = UDim2.fromOffset(28, 0),
		Size = UDim2.new(1, -30, 1, 0),
		Font = FONT_BOLD,
		TextSize = 13,
		Parent = chip,
	})
end

-- Los tickets temáticos y el final comparten un contador.
local specialChip = make("Frame", {
	Position = UDim2.fromOffset(346 + 3 * 58, 14),
	Size = UDim2.fromOffset(54, 32),
	BackgroundColor3 = Theme.Surface,
	Parent = hud,
}, { corner(9) })
label({
	Position = UDim2.fromOffset(4, 0),
	Size = UDim2.fromOffset(24, 32),
	Text = "🍕",
	TextSize = 15,
	TextXAlignment = Enum.TextXAlignment.Center,
	Parent = specialChip,
})
addTooltip(specialChip, "Tickets especiales: Pizza, Espacio, Zombi y Final")
local hudSpecialLabel = label({
	Position = UDim2.fromOffset(28, 0),
	Size = UDim2.new(1, -30, 1, 0),
	Font = FONT_BOLD,
	TextSize = 13,
	Parent = specialChip,
})

local upgradesButton = button({
	AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.new(1, -10, 0.5, 0),
	Size = UDim2.fromOffset(120, 40),
	Text = "Mejoras",
	TextSize = 15,
	Parent = hud,
}, function()
	openPanel("Upgrades")
end)

local prestigeDot = make("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.new(1, -4, 0, 4),
	Size = UDim2.fromOffset(12, 12),
	BackgroundColor3 = Theme.Amber,
	Visible = false,
	Parent = upgradesButton,
}, { corner(6) })

-- En pantallas estrechas se reduce la barra para que quepa entera.
local function fitHud()
	local camera = Workspace.CurrentCamera
	if camera then
		hudScale.Scale = math.min(1, (camera.ViewportSize.X - 16) / HUD_WIDTH)
	end
end
fitHud()
local function watchCamera()
	local camera = Workspace.CurrentCamera
	if camera then
		camera:GetPropertyChangedSignal("ViewportSize"):Connect(fitHud)
	end
	fitHud()
end
watchCamera()
Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(watchCamera)

---------------------------------------------------------------------
-- Tienda
---------------------------------------------------------------------

local shopBody = createPanel("Shop", "Tienda de tickets", "Compra tickets y llévalos a la mesa para rascarlos", 620)
local shopRows: { [string]: Row } = {}

for index, tier in Tiers do
	local info = TicketData[tier.id]
	shopRows[tier.id] = createRow(shopBody, index, tier.emoji, tier.color, tier.dark, function()
		if info.IsFinal and (stats.GameWon.Value or stats.Final.Value > 0) then
			return
		elseif not tierUnlocked(tier) then
			showToast("Necesitas " .. tierRequirement(tier))
		elseif stats.Money.Value < info.Price then
			showToast("Te faltan " .. money(info.Price - stats.Money.Value))
		else
			remotes.BuyTicket:FireServer(tier.id)
		end
	end)
end

---------------------------------------------------------------------
-- Mesa de rascar
---------------------------------------------------------------------

local scratchBody = createPanel("Scratch", "Mesa de rascar", "Elige qué ticket quieres rascar", 620)

local resultCard = make("Frame", {
	Size = UDim2.new(1, 0, 0, 62),
	BackgroundColor3 = Theme.Surface,
	LayoutOrder = 0,
	Parent = scratchBody,
}, { corner(14) })
local resultStroke = stroke(Theme.Stroke, 0.55)
resultStroke.Parent = resultCard
local resultScale = make("UIScale", { Scale = 1, Parent = resultCard })
local resultLabel = label({
	Size = UDim2.fromScale(1, 1),
	Text = "¡Suerte!",
	Font = FONT_BLACK,
	TextSize = 22,
	TextColor3 = Theme.Muted,
	TextXAlignment = Enum.TextXAlignment.Center,
	Parent = resultCard,
})

local scratchRows: { [string]: Row } = {}

for index, tier in Tiers do
	scratchRows[tier.id] = createRow(scratchBody, index, tier.emoji, tier.color, tier.dark, function()
		if stats[tier.id].Value <= 0 then
			showToast("No tienes tickets " .. tier.name)
		elseif not scratchRequested then
			scratchRequested = true
			task.delay(3, function()
				scratchRequested = false
			end)
			remotes.ScratchTicket:FireServer(tier.id)
		end
	end)
end

---------------------------------------------------------------------
-- Mejoras y prestigio
---------------------------------------------------------------------

local upgradesBody = createPanel("Upgrades", "Mejoras", "Invierte tu dinero para avanzar más rápido", 458)

local prestigeArmedUntil = 0
local refreshPrestige: () -> ()

local luckRow = createRow(upgradesBody, 1, "🍀", Color3.fromRGB(110, 231, 183), Color3.fromRGB(5, 150, 105), function()
	local price = stats.Luck.Value * 1000
	if stats.Luck.Value >= TicketData.MaxLuck then
		return
	end
	if stats.Money.Value < price then
		showToast("Te faltan " .. money(price - stats.Money.Value))
	else
		remotes.BuyLuck:FireServer()
	end
end)

local autoRow = createRow(upgradesBody, 2, "🤖", Color3.fromRGB(125, 211, 252), Color3.fromRGB(2, 132, 199), function()
	if stats.Auto.Value then
		return
	elseif stats.Money.Value < AUTO_SCRATCH_PRICE then
		showToast("Te faltan " .. money(AUTO_SCRATCH_PRICE - stats.Money.Value))
	else
		remotes.BuyAutoScratch:FireServer()
	end
end)

local speedRow = createRow(upgradesBody, 3, "⚡", Color3.fromRGB(196, 181, 253), Color3.fromRGB(109, 40, 217), function()
	if not stats.Auto.Value then
		showToast("Necesitas Auto Scratch")
	elseif stats.Speed.Value <= AUTO_SPEED_MIN then
		return
	elseif stats.Money.Value < AUTO_SPEED_PRICE then
		showToast("Te faltan " .. money(AUTO_SPEED_PRICE - stats.Money.Value))
	else
		remotes.UpgradeAutoSpeed:FireServer()
	end
end)

local prestigeRow = createRow(upgradesBody, 4, "👑", Color3.fromRGB(253, 224, 71), Color3.fromRGB(217, 119, 6), function()
	if stats.Level.Value < PRESTIGE_LEVEL then
		showToast("Necesitas nivel " .. PRESTIGE_LEVEL)
		return
	end
	-- El prestigio borra el progreso, así que pide un segundo clic.
	if os.clock() > prestigeArmedUntil then
		prestigeArmedUntil = os.clock() + 3
		refreshPrestige()
		task.delay(3.05, refreshPrestige)
	else
		prestigeArmedUntil = 0
		remotes.PrestigeEvent:FireServer()
		refreshPrestige()
		closePanels()
	end
end)

---------------------------------------------------------------------
-- Ayuda
---------------------------------------------------------------------

-- Botones redondos: columna abajo a la izquierda en PC y fila bajo la barra en móvil,
-- donde la pantalla es más baja y abajo están los controles táctiles.
local isTouch = UserInputService.TouchEnabled
local TOUCH_ROW_Y = 76

local function roundButtonLayout(order: number): (Vector2, UDim2, UDim2)
	if isTouch then
		return Vector2.new(0, 0), UDim2.fromOffset(16 + order * 50, TOUCH_ROW_Y), UDim2.fromOffset(42, 42)
	end
	-- Las teles pueden recortar los bordes, así que en consola se deja más margen.
	local margin = GuiService:IsTenFootInterface() and 48 or 16
	return Vector2.new(0, 1), UDim2.new(0, margin, 1, -margin - order * 56), UDim2.fromOffset(46, 46)
end

-- Explica lo que hace el servidor. Si cambian las reglas, hay que actualizar estos textos.
local helpBody = createPanel("Help", "Cómo funciona", "Qué hace cada cosa del juego", 620)

local function helpCard(order: number, title: string, lines: { string })
	local card = make("Frame", {
		Size = UDim2.new(1, -6, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.Surface,
		LayoutOrder = order,
		Parent = helpBody,
	}, {
		corner(14),
		padding(14, 12),
		make("UIListLayout", {
			Padding = UDim.new(0, 5),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})
	label({
		Size = UDim2.new(1, 0, 0, 24),
		Text = title,
		Font = FONT_BOLD,
		TextSize = 17,
		LayoutOrder = 0,
		Parent = card,
	})
	for index, line in lines do
		label({
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Text = line,
			TextSize = 14,
			TextColor3 = Theme.Muted,
			TextWrapped = true,
			TextTruncate = Enum.TextTruncate.None,
			TextYAlignment = Enum.TextYAlignment.Top,
			LayoutOrder = index,
			Parent = card,
		})
	end
end

local ticketLines = {}
for _, tier in Tiers do
	local info = TicketData[tier.id]
	if not info.IsFinal then
		local line = tier.name .. " (" .. money(info.Price) .. ", nivel " .. info.UnlockLevel .. "): "
			.. info.Lose .. "% nada · " .. (info.Win - info.Lose) .. "% " .. money(info.Reward)
			.. " · " .. (100 - info.Win) .. "% " .. money(info.Jackpot)
		if info.JackpotGift then
			line ..= ". El jackpot regala " .. info.JackpotGift.text
		end
		table.insert(ticketLines, line)
	end
end
table.insert(ticketLines, "Compra en el ordenador del dormitorio y rasca en la mesa del salón arrastrando el ratón o el dedo.")

helpCard(1, "🎟️ Tickets", ticketLines)
helpCard(2, "⭐ Nivel y XP", {
	"Cada ticket rascado a mano da XP, y con Auto Scratch la mitad. Para subir de nivel necesitas " .. TicketData.XPPerLevel .. " XP por cada nivel que tienes.",
	"El nivel 5 desbloquea Plata, el 15 desbloquea Oro y el 20 permite hacer prestigio. No cambia las probabilidades.",
})
helpCard(3, "🍀 Suerte", {
	"Cada nivel por encima del 1 quita 1 punto a la probabilidad de no ganar nada y lo pasa a premio normal.",
	"Llega hasta el nivel " .. TicketData.MaxLuck .. " (15 puntos menos). Cada nivel cuesta $1.000 más que el anterior. También sube con cada prestigio.",
})
helpCard(4, "🤖 Auto Scratch", {
	"Rasca un ticket cada pocos segundos, empezando por el mejor que tengas, con las mismas probabilidades y premios que a mano.",
	"Da la mitad de XP, no suelta mascotas y no rasca el tiquet final.",
})
helpCard(5, "⚡ Velocidad", {
	"Cada mejora quita 0,5 s de espera, desde 5 s hasta un mínimo de 0,5 s.",
})
local dropTexts = {}
for _, tier in Tiers do
	local chance = PetData.DropChance[tier.id]
	if chance then
		table.insert(dropTexts, math.round(chance * 100) .. "% con " .. tier.name)
	end
end
local petLines = {
	"Al rascar a mano puede salir una mascota: " .. table.concat(dropTexts, ", ") .. ". Si ya la tienes, no pasa nada.",
	"Equipa una en el botón del perrito: te sigue y sube los premios de los tickets, también con Auto Scratch. El prestigio no te la quita.",
}
for _, rarityName in { "Common", "Rare", "Epic", "Legendary" } do
	local names = {}
	for _, pet in PetData.Pets do
		if pet.rarity == rarityName then
			table.insert(names, pet.name .. " +" .. math.round(pet.bonus * 100) .. "%")
		end
	end
	local rarity = PetData.Rarities[rarityName]
	table.insert(petLines, rarity.label .. " (" .. rarity.weight .. "% de las que salen): " .. table.concat(names, ", "))
end
helpCard(7, "🐶 Mascotas", petLines)
local roomLines = {
	"Abre el botón de la casa para comprar decoración y mejorar la mesa. Todo se queda aunque hagas prestigio. Con otros jugadores, cada uno ve solo su propia decoración.",
}
for level, info in RoomData.TableLevels do
	table.insert(roomLines, "Mesa " .. level .. " (" .. money(info.price) .. "): " .. info.name .. ", +" .. math.round(info.bonus * 100) .. "% de premios")
end
table.insert(roomLines, "El bonus de la mesa se suma al de la mascota.")
helpCard(8, "🏠 Habitación", roomLines)
local finalInfo = TicketData.Final
helpCard(9, "🏆 Tiquet Final", {
	"Es el objetivo del juego. Cuesta " .. money(finalInfo.Price) .. " y pide nivel " .. finalInfo.UnlockLevel .. " y al menos " .. finalInfo.UnlockPrestige .. " prestigio.",
	"Siempre se gana y solo se completa una vez: recibes " .. money(finalInfo.Reward) .. ", el Fénix dorado y un 🏆 junto a tu nivel. Auto Scratch no lo rasca.",
})
helpCard(10, "🎯 Misiones y logros", {
	"Abre el botón de la diana. Cuando completes una, pulsa Reclamar para cobrar el premio: un punto naranja te avisa.",
	"Las misiones de hoy se renuevan cada día y su premio crece con tu nivel. Si un día no juegas, no pierdes nada.",
	"Los logros se cobran una sola vez. Los tickets de Auto Scratch no cuentan como rascados, pero su dinero sí cuenta como ganado.",
})
helpCard(11, "🎮 Mando y consolas", {
	"Y abre las mejoras. La cruceta abre misiones (arriba), habitación (derecha), mascotas (izquierda) y ayuda (abajo).",
	"En los menús, muévete con la cruceta o el stick izquierdo, confirma con A y cierra con B (en PlayStation, X y círculo).",
	"Rasca moviendo el stick derecho o pulsa A para revelar. Para comprar o rascar, acércate y usa el botón que indica el aviso.",
})
helpCard(6, "👑 Prestigio", {
	"Disponible en el nivel 20. Vuelves al nivel 1 con $100 y sin tickets.",
	"A cambio, ganas +1 de suerte y duplicas la XP con cada prestigio. Conservas la suerte, Auto Scratch y su velocidad.",
})

local infoButton = button({
	AnchorPoint = (roundButtonLayout(0)),
	Position = select(2, roundButtonLayout(0)),
	Size = select(3, roundButtonLayout(0)),
	Text = "?",
	TextSize = 22,
	Font = FONT_BLACK,
	BackgroundColor3 = Theme.Bg,
	Radius = 23,
	Parent = hudGui,
}, function()
	openPanel("Help")
end)
stroke(Theme.Stroke, 0.2).Parent = infoButton

---------------------------------------------------------------------
-- Ticket para rascar
---------------------------------------------------------------------

local SOUND_IDS = {
	Scratch = "rbxassetid://9118768772",
	Lose = "rbxassetid://1846251194",
	Win = "rbxassetid://9117246569",
	Jackpot = "rbxassetid://1846251212",
}

local CARD_W, CARD_H = 440, 332
local ZONE_W, ZONE_H = 400, 190
local COLUMNS, ROWS = 30, 14
local CELL_W, CELL_H = ZONE_W / COLUMNS, ZONE_H / ROWS
local BRUSH_RADIUS = 24
local REVEAL_AT = 0.6

local tiersById: { [string]: any } = {}
for _, tier in Tiers do
	tiersById[tier.id] = tier
end

local cardGui = make("ScreenGui", {
	Name = "ScratchCard",
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	DisplayOrder = 15,
	Enabled = false,
	Parent = playerGui,
})

make("TextButton", {
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	Text = "",
	AutoButtonColor = false,
	Selectable = false,
	Parent = cardGui,
})

local cardScale = make("UIScale", { Scale = 1 })
local cardCenter = UDim2.fromScale(0.5, 0.5)
local card = make("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = cardCenter,
	Size = UDim2.fromOffset(CARD_W, CARD_H),
	BackgroundColor3 = Theme.Bg,
	ZIndex = 2,
	Parent = cardGui,
}, { corner(18), cardScale })
local cardStroke = stroke(Theme.Stroke)
cardStroke.Thickness = 2
cardStroke.Parent = card

local cardTitle = label({
	Position = UDim2.fromOffset(20, 12),
	Size = UDim2.new(1, -40, 0, 34),
	Font = FONT_BLACK,
	TextSize = 24,
	TextXAlignment = Enum.TextXAlignment.Center,
	ZIndex = 2,
	Parent = card,
})

local zone = make("Frame", {
	Position = UDim2.fromOffset(20, 54),
	Size = UDim2.fromOffset(ZONE_W, ZONE_H),
	BackgroundColor3 = Theme.Surface,
	ClipsDescendants = true,
	ZIndex = 2,
	Parent = card,
}, { corner(12) })

local prizeScale = make("UIScale", { Scale = 1 })
local prizeLabel = label({
	Size = UDim2.new(1, -20, 0, 76),
	Position = UDim2.fromOffset(10, 44),
	Font = FONT_BLACK,
	TextSize = 44,
	TextXAlignment = Enum.TextXAlignment.Center,
	ZIndex = 2,
	Parent = zone,
})
prizeScale.Parent = prizeLabel
local prizeSubLabel = label({
	Size = UDim2.new(1, -20, 0, 30),
	Position = UDim2.fromOffset(10, 118),
	Font = FONT_BOLD,
	TextSize = 18,
	TextColor3 = Theme.Muted,
	TextXAlignment = Enum.TextXAlignment.Center,
	ZIndex = 2,
	Parent = zone,
})

local foilCells: { Frame } = {}
for row = 0, ROWS - 1 do
	for column = 0, COLUMNS - 1 do
		table.insert(foilCells, make("Frame", {
			Position = UDim2.fromOffset(column * CELL_W, row * CELL_H),
			Size = UDim2.fromOffset(math.ceil(CELL_W) + 1, math.ceil(CELL_H) + 1),
			BorderSizePixel = 0,
			ZIndex = 3,
			Parent = zone,
		}))
	end
end

local foilHint = label({
	Size = UDim2.fromScale(1, 1),
	Text = "RASCA AQUÍ",
	Font = FONT_BLACK,
	TextSize = 30,
	TextColor3 = Theme.Bg,
	TextTransparency = 0.25,
	TextXAlignment = Enum.TextXAlignment.Center,
	ZIndex = 4,
	Parent = zone,
})

-- Captura el ratón o el dedo por encima de la capa.
local scratchInput = make("Frame", {
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	Active = true,
	ZIndex = 5,
	Parent = zone,
})

local activeTier: any = nil
local activeKind = "lose"
local cellsLeft = 0
local revealed = false
local scratching = false
local lastPoint: Vector2? = nil
local lastScratchSound = 0
local finishScratchCard: () -> ()

local scratchLoop = make("Sound", { SoundId = SOUND_IDS.Scratch, Looped = true, Volume = 0.5, Parent = cardGui })

local function playSound(name: string)
	local id = (SOUND_IDS :: any)[name]
	local sound = make("Sound", { SoundId = id, Parent = cardGui })
	sound.Ended:Once(function()
		sound:Destroy()
	end)
	sound:Play()
end

local function spawnChip(position: UDim2, color: Color3)
	local chip = make("Frame", {
		Position = position,
		Size = UDim2.fromOffset(math.random(3, 6), math.random(3, 6)),
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		ZIndex = 6,
		Parent = card,
	})
	local fall = tween(chip, 0.5, {
		Position = position + UDim2.fromOffset(math.random(-24, 24), math.random(30, 70)),
		BackgroundTransparency = 1,
		Rotation = math.random(-180, 180),
	}, Enum.EasingStyle.Quad)
	fall.Completed:Once(function()
		chip:Destroy()
	end)
end

local function scratchPoint(x: number, y: number)
	local firstColumn = math.max(0, math.floor((x - BRUSH_RADIUS) / CELL_W))
	local lastColumn = math.min(COLUMNS - 1, math.floor((x + BRUSH_RADIUS) / CELL_W))
	local firstRow = math.max(0, math.floor((y - BRUSH_RADIUS) / CELL_H))
	local lastRow = math.min(ROWS - 1, math.floor((y + BRUSH_RADIUS) / CELL_H))
	for row = firstRow, lastRow do
		for column = firstColumn, lastColumn do
			local cell = foilCells[row * COLUMNS + column + 1]
			local dx = (column + 0.5) * CELL_W - x
			local dy = (row + 0.5) * CELL_H - y
			if cell.Visible and dx * dx + dy * dy <= BRUSH_RADIUS * BRUSH_RADIUS then
				cell.Visible = false
				cellsLeft -= 1
				if math.random() < 0.3 then
					spawnChip(UDim2.fromOffset(20 + column * CELL_W, 54 + row * CELL_H), cell.BackgroundColor3)
				end
			end
		end
	end
end

local function scratchTo(point: Vector2)
	if revealed then
		return
	end
	foilHint.Visible = false

	local origin = zone.AbsolutePosition
	local size = zone.AbsoluteSize
	local current = Vector2.new((point.X - origin.X) / size.X * ZONE_W, (point.Y - origin.Y) / size.Y * ZONE_H)
	local previous = lastPoint or current
	local distance = (current - previous).Magnitude
	local steps = math.max(1, math.ceil(distance / (BRUSH_RADIUS / 2)))
	for step = 1, steps do
		local at = previous:Lerp(current, step / steps)
		scratchPoint(at.X, at.Y)
	end
	lastPoint = current

	if distance > 2 then
		lastScratchSound = os.clock()
		if not scratchLoop.IsPlaying then
			scratchLoop:Play()
			-- Se calla poco después de dejar de mover el ratón o el dedo.
			task.spawn(function()
				while os.clock() - lastScratchSound < 0.15 and not revealed do
					task.wait(0.05)
				end
				scratchLoop:Stop()
			end)
		end
	end
	if cellsLeft <= #foilCells * (1 - REVEAL_AT) then
		finishScratchCard()
	end
end

scratchInput.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		scratching = true
		lastPoint = nil
		scratchTo(Vector2.new(input.Position.X, input.Position.Y))
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if scratching and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		scratchTo(Vector2.new(input.Position.X, input.Position.Y))
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		scratching = false
	end
end)

local announceJackpot: (string, string, number, boolean?) -> ()
local announceQueue: { { any } } = {}

local function closeCard()
	cardGui.Enabled = false
	cardOpen = false
	local waitingToasts = toastQueue
	toastQueue = {}
	for _, message in waitingToasts do
		showToast(message)
	end
	local lastAnnounce = announceQueue[#announceQueue]
	announceQueue = {}
	if lastAnnounce then
		announceJackpot(lastAnnounce[1], lastAnnounce[2], lastAnnounce[3], lastAnnounce[4])
	end
	if openPanelName == "Scratch" then
		panels.Scratch.root.Visible = true
	end
	uiChanged()
end

local revealButton = button({
	Position = UDim2.fromOffset(20, 258),
	Size = UDim2.fromOffset(ZONE_W, 56),
	Text = "Revelar sin rascar",
	TextSize = 16,
	BackgroundColor3 = Theme.SurfaceHigh,
	Parent = card,
}, function()
	finishScratchCard()
end)
revealButton.ZIndex = 2

local againButton, setAgainColor = button({
	Position = UDim2.fromOffset(20, 258),
	Size = UDim2.fromOffset(240, 56),
	TextSize = 16,
	Parent = card,
}, function()
	if not activeTier or not revealed or scratchRequested then
		return
	end
	if stats[activeTier.id].Value <= 0 then
		showToast("No tienes tickets " .. activeTier.name)
		return
	end
	scratchRequested = true
	task.delay(3, function()
		scratchRequested = false
	end)
	remotes.ScratchTicket:FireServer(activeTier.id)
end)
againButton.ZIndex = 2

local closeButton = button({
	Position = UDim2.fromOffset(270, 258),
	Size = UDim2.fromOffset(150, 56),
	Text = "Cerrar",
	TextSize = 16,
	BackgroundColor3 = Theme.SurfaceHigh,
	Parent = card,
}, closeCard)
closeButton.ZIndex = 2

local function confetti(amount: number)
	local colors = { Theme.Amber, Theme.Green, Theme.AccentHigh, Theme.Red, Color3.fromRGB(79, 173, 255) }
	for _ = 1, amount do
		local piece = make("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, math.random(-40, 40), 0.42, math.random(-20, 20)),
			Size = UDim2.fromOffset(math.random(6, 11), math.random(8, 15)),
			BackgroundColor3 = colors[math.random(1, #colors)],
			BorderSizePixel = 0,
			ZIndex = 7,
			Parent = cardGui,
		})
		local seconds = 0.9 + math.random() * 0.8
		local flight = tween(piece, seconds, {
			Position = UDim2.new(0.5 + (math.random() - 0.5) * 0.9, 0, 0.42 + (math.random() - 0.2) * 0.8, 0),
			Rotation = math.random(-540, 540),
			BackgroundTransparency = 1,
		}, Enum.EasingStyle.Quad)
		flight.Completed:Once(function()
			piece:Destroy()
		end)
	end
end

local function shakeCard()
	task.spawn(function()
		for _ = 1, 10 do
			card.Position = cardCenter + UDim2.fromOffset(math.random(-9, 9), math.random(-7, 7))
			task.wait(0.03)
		end
		card.Position = cardCenter
	end)
end

finishScratchCard = function()
	if revealed then
		return
	end
	revealed = true
	scratching = false
	foilHint.Visible = false

	for _, cell in foilCells do
		if cell.Visible then
			tween(cell, 0.25, { BackgroundTransparency = 1 })
		end
	end
	task.delay(0.26, function()
		if revealed then
			for _, cell in foilCells do
				cell.Visible = false
			end
		end
	end)

	remotes.ScratchReveal:FireServer()

	prizeScale.Scale = 0.6
	tween(prizeScale, 0.4, { Scale = 1 }, Enum.EasingStyle.Back)

	if activeKind == "jackpot" or activeKind == "final" then
		playSound("Jackpot")
		tween(cardStroke, 0.2, { Color = Theme.Amber })
		confetti(70)
		shakeCard()
	elseif activeKind == "win" then
		playSound("Win")
		tween(cardStroke, 0.2, { Color = Theme.Green })
		confetti(22)
	else
		playSound("Lose")
	end

	revealButton.Visible = false
	againButton.Visible = true
	closeButton.Visible = true
	uiChanged()
	task.defer(function()
		local left = activeTier and stats[activeTier.id].Value or 0
		againButton.Text = "Rascar otro (" .. formatNumber(left) .. ")"
		setAgainColor(left > 0 and Theme.Accent or Theme.Disabled)
	end)
end

local function openCard(ticketType: string, kind: string, reward: number)
	local tier = tiersById[ticketType]
	if not tier then
		return
	end

	activeTier = tier
	activeKind = kind
	revealed = false
	scratching = false
	lastPoint = nil
	cellsLeft = #foilCells

	cardTitle.Text = tier.emoji .. " Ticket " .. tier.name
	cardTitle.TextColor3 = tier.color
	cardStroke.Color = tier.color
	card.Position = cardCenter

	for _, cell in foilCells do
		cell.Visible = true
		cell.BackgroundTransparency = 0
		cell.BackgroundColor3 = tier.color:Lerp(tier.dark, math.random() * 0.35)
	end
	foilHint.Visible = true

	if kind == "final" then
		prizeLabel.Text = "¡HAS GANADO!"
		prizeLabel.TextColor3 = Theme.Amber
		prizeSubLabel.Text = "+" .. money(reward) .. " y el Fénix dorado"
		prizeSubLabel.TextColor3 = Theme.Amber
	elseif kind == "jackpot" then
		prizeLabel.Text = "¡JACKPOT!"
		prizeLabel.TextColor3 = Theme.Amber
		prizeSubLabel.Text = "+" .. money(reward)
		prizeSubLabel.TextColor3 = Theme.Amber
	elseif kind == "win" then
		prizeLabel.Text = "+" .. money(reward)
		prizeLabel.TextColor3 = Theme.Green
		prizeSubLabel.Text = "¡Premio!"
		prizeSubLabel.TextColor3 = Theme.Muted
	else
		prizeLabel.Text = "Sin premio"
		prizeLabel.TextColor3 = Theme.Muted
		prizeSubLabel.Text = "Otra vez será"
		prizeSubLabel.TextColor3 = Theme.Muted
	end

	revealButton.Visible = true
	againButton.Visible = false
	closeButton.Visible = false

	local camera = Workspace.CurrentCamera
	if camera then
		local viewport = camera.ViewportSize
		cardScale.Scale = math.min(1, (viewport.X - 24) / CARD_W, (viewport.Y - 90) / CARD_H)
	end

	cardOpen = true
	if openPanelName == "Scratch" then
		panels.Scratch.root.Visible = false
	end
	cardGui.Enabled = true
	uiChanged()
end

remotes.ScratchStarted.OnClientEvent:Connect(function(ticketType: string, kind: string, reward: number)
	scratchRequested = false
	openCard(ticketType, kind, reward)
end)

---------------------------------------------------------------------
-- Inicio guiado y anuncios
---------------------------------------------------------------------

local guideBanner = make("Frame", {
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, isTouch and 126 or 76),
	Size = UDim2.new(0.9, 0, 0, 44),
	BackgroundColor3 = Theme.Accent,
	Visible = false,
	Parent = hudGui,
}, {
	make("UISizeConstraint", { MaxSize = Vector2.new(460, 44) }),
	corner(12),
})
local guideLabel = label({
	Size = UDim2.fromScale(1, 1),
	Font = FONT_BOLD,
	TextSize = 15,
	TextXAlignment = Enum.TextXAlignment.Center,
	Parent = guideBanner,
})

local guideBeam: Beam? = nil
local guideMarker: BillboardGui? = nil
local guideStart: Attachment? = nil
local guideEnd: Attachment? = nil

local function clearGuide()
	for _, item: any in { guideBeam, guideMarker, guideStart, guideEnd } do
		item:Destroy()
	end
	guideBeam, guideMarker, guideStart, guideEnd = nil, nil, nil, nil
end

local function pointGuideAt(target: BasePart)
	clearGuide()

	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")

	local marker = make("BillboardGui", {
		Size = UDim2.fromOffset(60, 60),
		StudsOffset = Vector3.new(0, 3, 0),
		AlwaysOnTop = true,
		Adornee = target,
		ResetOnSpawn = false,
		Parent = playerGui,
	})
	local arrow = label({
		Size = UDim2.fromScale(1, 1),
		Text = "⬇️",
		TextSize = 44,
		TextTruncate = Enum.TextTruncate.None,
		TextXAlignment = Enum.TextXAlignment.Center,
		Parent = marker,
	})
	TweenService:Create(
		arrow,
		TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
		{ Position = UDim2.fromOffset(0, -12) }
	):Play()
	guideMarker = marker

	if root then
		local startAttachment = make("Attachment", { Parent = root })
		local endAttachment = make("Attachment", { Parent = target })
		guideBeam = make("Beam", {
			Attachment0 = startAttachment,
			Attachment1 = endAttachment,
			Color = ColorSequence.new(Theme.Amber),
			Transparency = NumberSequence.new(0.15),
			LightEmission = 0.8,
			FaceCamera = true,
			Width0 = 1.2,
			Width1 = 1.2,
			Parent = root,
		})
		guideStart, guideEnd = startAttachment, endAttachment
	end
end

local tutorialDone = stat("TutorialDone")
local pcTarget = Workspace:WaitForChild("PC_Interact") :: BasePart
local tableTarget = Workspace:WaitForChild("TicketTable_Interact") :: BasePart

local function refreshGuide()
	if tutorialDone.Value then
		guideBanner.Visible = false
		clearGuide()
		return
	end
	guideBanner.Visible = true
	if stats.Basic.Value > 0 then
		guideLabel.Text = "Paso 2 de 2: ve a la mesa del salón y rasca tu ticket"
		pointGuideAt(tableTarget)
	else
		guideLabel.Text = "Paso 1 de 2: compra un ticket en el ordenador del dormitorio"
		pointGuideAt(pcTarget)
	end
end

tutorialDone.Changed:Connect(function(done: boolean)
	refreshGuide()
	if done then
		showToast("¡Ya sabes jugar!")
	end
end)
stats.Basic.Changed:Connect(function()
	if not tutorialDone.Value then
		refreshGuide()
	end
end)
local function guideCharacter(character: Model)
	character:WaitForChild("HumanoidRootPart", 10)
	if not tutorialDone.Value then
		refreshGuide()
	end
end
player.CharacterAdded:Connect(guideCharacter)
refreshGuide()
if player.Character then
	task.spawn(guideCharacter, player.Character)
end

local announceScale = make("UIScale", { Scale = 0.8 })
local announceBanner = make("Frame", {
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, isTouch and 176 or 126),
	Size = UDim2.new(0.9, 0, 0, 50),
	BackgroundColor3 = Theme.Bg,
	Visible = false,
	Parent = toastGui,
}, {
	make("UISizeConstraint", { MaxSize = Vector2.new(520, 50) }),
	corner(14),
	stroke(Theme.Amber),
	announceScale,
})
local announceLabel = label({
	Size = UDim2.new(1, -20, 1, 0),
	Position = UDim2.fromOffset(10, 0),
	Font = FONT_BLACK,
	TextSize = 17,
	TextColor3 = Theme.Amber,
	TextXAlignment = Enum.TextXAlignment.Center,
	Parent = announceBanner,
})
local announceId = 0

announceJackpot = function(name: string, ticket: string, amount: number, isFinal: boolean?)
	announceId += 1
	local id = announceId
	if isFinal then
		announceLabel.Text = "🏆 ¡" .. name .. " ha completado el juego!"
	else
		announceLabel.Text = "🎉 " .. name .. " ha sacado JACKPOT " .. ticket .. ": " .. money(amount)
	end
	announceBanner.Visible = true
	announceScale.Scale = 0.8
	tween(announceScale, 0.3, { Scale = 1 }, Enum.EasingStyle.Back)
	task.delay(5, function()
		if id == announceId then
			announceBanner.Visible = false
		end
	end)
end

remotes.JackpotAnnounced.OnClientEvent:Connect(function(name: string, ticket: string, amount: number, isFinal: boolean?)
	if not cardOpen then
		announceJackpot(name, ticket, amount, isFinal)
	elseif name ~= player.DisplayName then
		-- El tuyo ya se ve en el ticket.
		table.insert(announceQueue, { name, ticket, amount, isFinal })
	end
end)

---------------------------------------------------------------------
-- Actualizar la interfaz
---------------------------------------------------------------------

local function setButton(row: Row, text: string, enabled: boolean, color: Color3?)
	row.action.Text = text
	row.setActionColor(enabled and (color or Theme.Accent) or Theme.Disabled)
	row.action.TextColor3 = enabled and Theme.Text or Theme.Muted
end

---------------------------------------------------------------------
-- Mascotas
---------------------------------------------------------------------

local ownedPets = stat("OwnedPets")
local equippedPet = stat("EquippedPet")
local equipPetRemote = ReplicatedStorage:WaitForChild("EquipPet") :: RemoteEvent

local petsBody = createPanel("Pets", "Mascotas", "Pueden salir al rascar a mano. Equipa una para ganar más", 620)
local petRows: { [string]: Row } = {}

for index, pet in PetData.Pets do
	local rarity = PetData.Rarities[pet.rarity]
	petRows[pet.id] = createRow(petsBody, index, pet.emoji, rarity.color, rarity.dark, function()
		if not PetData.owns(ownedPets.Value, pet.id) then
			showToast("Aún no tienes esta mascota")
		elseif equippedPet.Value == pet.id then
			equipPetRemote:FireServer("")
		else
			equipPetRemote:FireServer(pet.id)
		end
	end)
end

local function refreshPets()
	for _, pet in PetData.Pets do
		local row = petRows[pet.id]
		local rarity = PetData.Rarities[pet.rarity]
		local bonusText = "+" .. math.round(pet.bonus * 100) .. "% de premios"
		if PetData.owns(ownedPets.Value, pet.id) then
			row.title.Text = pet.name
			row.detail.Text = rarity.label .. " · " .. bonusText
			if equippedPet.Value == pet.id then
				setButton(row, "Quitar", true, Theme.Green)
				row.action.TextColor3 = Theme.Bg
			else
				setButton(row, "Equipar", true)
			end
		else
			row.title.Text = "???"
			row.detail.Text = rarity.label .. " · " .. bonusText .. string.format(" · %.1f%%", PetData.share(pet))
			setButton(row, "Bloqueada", false)
		end
	end
end

ownedPets.Changed:Connect(refreshPets)
equippedPet.Changed:Connect(refreshPets)
refreshPets()

local petsButton = button({
	AnchorPoint = (roundButtonLayout(1)),
	Position = select(2, roundButtonLayout(1)),
	Size = select(3, roundButtonLayout(1)),
	Text = "🐶",
	TextSize = 22,
	BackgroundColor3 = Theme.Bg,
	Radius = 23,
	Parent = hudGui,
}, function()
	openPanel("Pets")
end)
stroke(Theme.Stroke, 0.2).Parent = petsButton

---------------------------------------------------------------------
-- Habitación
---------------------------------------------------------------------

local roomItems = stat("RoomItems")
local tableLevel = stat("TableLevel")
local buyRoomItem = ReplicatedStorage:WaitForChild("BuyRoomItem") :: RemoteEvent
local upgradeTable = ReplicatedStorage:WaitForChild("UpgradeTable") :: RemoteEvent

local roomBody = createPanel("Room", "Tu habitación", "Decora la sala y mejora la mesa para ganar más", 620)

local tableRow = createRow(roomBody, 0, "🎲", Color3.fromRGB(252, 211, 77), Color3.fromRGB(217, 119, 6), function()
	local nextLevel = RoomData.TableLevels[tableLevel.Value + 1]
	if not nextLevel then
		return
	elseif stats.Money.Value < nextLevel.price then
		showToast("Te faltan " .. money(nextLevel.price - stats.Money.Value))
	else
		upgradeTable:FireServer()
	end
end)

local roomRows: { [string]: Row } = {}
for index, item in RoomData.Items do
	roomRows[item.id] = createRow(roomBody, index, item.emoji, Color3.fromRGB(167, 139, 250), Color3.fromRGB(91, 33, 182), function()
		if RoomData.owns(roomItems.Value, item.id) then
			return
		elseif stats.Money.Value < item.price then
			showToast("Te faltan " .. money(item.price - stats.Money.Value))
		else
			buyRoomItem:FireServer(item.id)
		end
	end)
end

local function refreshRoom()
	local current = RoomData.TableLevels[tableLevel.Value]
	local nextLevel = RoomData.TableLevels[tableLevel.Value + 1]
	tableRow.title.Text = "Mesa: " .. (current and current.name or "normal")
	if nextLevel then
		tableRow.detail.Text = "Siguiente: +" .. math.round(nextLevel.bonus * 100) .. "% de premios"
		setButton(tableRow, money(nextLevel.price), stats.Money.Value >= nextLevel.price)
	else
		tableRow.detail.Text = "+" .. math.round(current.bonus * 100) .. "% de premios"
		setButton(tableRow, "Máxima", false)
	end

	for _, item in RoomData.Items do
		local row = roomRows[item.id]
		row.title.Text = item.name
		row.detail.Text = item.description
		if RoomData.owns(roomItems.Value, item.id) then
			setButton(row, "Comprado", false)
			row.action.TextColor3 = Theme.Green
		else
			setButton(row, money(item.price), stats.Money.Value >= item.price)
		end
	end
end

roomItems.Changed:Connect(refreshRoom)
tableLevel.Changed:Connect(refreshRoom)
stats.Money.Changed:Connect(refreshRoom)
refreshRoom()

local roomButton = button({
	AnchorPoint = (roundButtonLayout(2)),
	Position = select(2, roundButtonLayout(2)),
	Size = select(3, roundButtonLayout(2)),
	Text = "🏠",
	TextSize = 22,
	BackgroundColor3 = Theme.Bg,
	Radius = 23,
	Parent = hudGui,
}, function()
	openPanel("Room")
end)
stroke(Theme.Stroke, 0.2).Parent = roomButton

---------------------------------------------------------------------
-- Misiones y logros
---------------------------------------------------------------------

local claimMission = ReplicatedStorage:WaitForChild("ClaimMission") :: RemoteEvent
local missionsBody = createPanel("Missions", "Misiones", "Las de hoy se renuevan cada día. Los logros son para siempre", 620)

type MissionRow = { mission: any, isDaily: boolean, row: Row }
local missionRows: { MissionRow } = {}

local function addMissionRow(mission: any, isDaily: boolean)
	local colorA = isDaily and Color3.fromRGB(125, 211, 252) or Color3.fromRGB(252, 211, 77)
	local colorB = isDaily and Color3.fromRGB(2, 132, 199) or Color3.fromRGB(217, 119, 6)
	local row = createRow(missionsBody, #missionRows + 1, mission.emoji, colorA, colorB, function()
		if MissionData.progress(mission, data, isDaily) >= mission.target and not MissionData.isClaimed(mission, data, isDaily) then
			claimMission:FireServer(mission.id)
		end
	end)
	table.insert(missionRows, { mission = mission, isDaily = isDaily, row = row })
end

for _, mission in MissionData.Daily do
	addMissionRow(mission, true)
end
for _, mission in MissionData.Achievements do
	addMissionRow(mission, false)
end

local missionsButton = button({
	AnchorPoint = (roundButtonLayout(3)),
	Position = select(2, roundButtonLayout(3)),
	Size = select(3, roundButtonLayout(3)),
	Text = "🎯",
	TextSize = 22,
	BackgroundColor3 = Theme.Bg,
	Radius = 23,
	Parent = hudGui,
}, function()
	openPanel("Missions")
end)
stroke(Theme.Stroke, 0.2).Parent = missionsButton

local missionsDot = make("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.new(1, -4, 0, 6),
	Size = UDim2.fromOffset(12, 12),
	BackgroundColor3 = Theme.Amber,
	Visible = false,
	Parent = missionsButton,
}, { corner(6) })

local readyMissions: { [string]: boolean } = {}
local missionsStarted = false

local function refreshMissions()
	local anyReady = false
	for _, entry in missionRows do
		local mission, row, isDaily = entry.mission, entry.row, entry.isDaily
		local progress = MissionData.progress(mission, data, isDaily)
		local reward = MissionData.reward(mission, data)
		local claimed = MissionData.isClaimed(mission, data, isDaily)
		local ready = progress >= mission.target and not claimed

		row.title.Text = (isDaily and "Hoy: " or "") .. mission.name
		row.detail.Text = "Premio: " .. money(reward)
		if claimed then
			setButton(row, "Hecho", false)
			row.action.TextColor3 = Theme.Green
		elseif ready then
			setButton(row, "Reclamar", true, Theme.Green)
			row.action.TextColor3 = Theme.Bg
			anyReady = true
		else
			setButton(row, formatNumber(progress) .. "/" .. formatNumber(mission.target), false)
		end

		if ready and missionsStarted and not readyMissions[mission.id] then
			showToast("¡Misión lista! Reclámala en 🎯")
		end
		readyMissions[mission.id] = ready
	end
	missionsDot.Visible = anyReady
	missionsStarted = true
end

for _, name in MissionData.WatchedStats do
	stat(name).Changed:Connect(refreshMissions)
end
refreshMissions()

local function refreshTickets()
	for _, tier in Tiers do
		local owned = stats[tier.id].Value
		local info = TicketData[tier.id]
		local unlocked = tierUnlocked(tier)

		if tier.main then
			hudTicketLabels[tier.id].Text = owned > 999 and "999+" or tostring(owned)
		end

		local shopRow = shopRows[tier.id]
		shopRow.title.Text = "Ticket " .. tier.name
		if unlocked then
			shopRow.detail.Text = "Tienes " .. formatNumber(owned)
			setButton(shopRow, money(info.Price), stats.Money.Value >= info.Price)
		else
			shopRow.detail.Text = "Se desbloquea con " .. string.lower(tierRequirement(tier))
			setButton(shopRow, tierRequirement(tier), false)
		end

		if info.IsFinal and (stats.GameWon.Value or owned > 0) then
			shopRow.detail.Text = stats.GameWon.Value and "¡Juego completado!" or "Ráscalo en la mesa del salón"
			setButton(shopRow, stats.GameWon.Value and "Completado" or "Comprado", false)
		end

		local scratchRow = scratchRows[tier.id]
		scratchRow.title.Text = "Ticket " .. tier.name
		scratchRow.detail.Text = owned == 1 and "Te queda 1" or ("Te quedan " .. formatNumber(owned))
		setButton(scratchRow, "Rascar", owned > 0)
	end
end

local function refreshSpecialCount()
	local total = 0
	for _, tier in Tiers do
		if not tier.main then
			total += stats[tier.id].Value
		end
	end
	hudSpecialLabel.Text = total > 999 and "999+" or tostring(total)
end

local function refreshUpgrades()
	local luckPrice = stats.Luck.Value * 1000
	luckRow.title.Text = "Suerte"
	local luckBonus = math.min(stats.Luck.Value - 1, TicketData.MaxLuck - 1)
	luckRow.detail.Text = "Nivel " .. stats.Luck.Value .. ": " .. luckBonus .. " puntos menos de no ganar nada"
	if stats.Luck.Value >= TicketData.MaxLuck then
		setButton(luckRow, "Máxima", false)
	else
		setButton(luckRow, money(luckPrice), stats.Money.Value >= luckPrice)
	end

	autoRow.title.Text = "Auto Scratch"
	if stats.Auto.Value then
		autoRow.detail.Text = "Rasca tus tickets automáticamente"
		setButton(autoRow, "Activo", false)
		autoRow.action.TextColor3 = Theme.Green
	else
		autoRow.detail.Text = "Rasca tus tickets automáticamente"
		setButton(autoRow, money(AUTO_SCRATCH_PRICE), stats.Money.Value >= AUTO_SCRATCH_PRICE)
	end

	speedRow.title.Text = "Velocidad"
	speedRow.detail.Text = string.format("Un ticket cada %.1f s", stats.Speed.Value)
	if stats.Speed.Value <= AUTO_SPEED_MIN then
		setButton(speedRow, "Máxima", false)
	else
		setButton(speedRow, money(AUTO_SPEED_PRICE), stats.Auto.Value and stats.Money.Value >= AUTO_SPEED_PRICE)
	end
end

refreshPrestige = function()
	local ready = stats.Level.Value >= PRESTIGE_LEVEL
	local armed = os.clock() <= prestigeArmedUntil
	prestigeRow.title.Text = "Prestigio " .. stats.Prestige.Value
	if armed and ready then
		prestigeRow.detail.Text = "Pierdes dinero, nivel y tickets"
		setButton(prestigeRow, "Confirmar", true, Theme.Red)
	else
		prestigeRow.detail.Text = ready and "Reinicia tu partida a cambio de más XP" or ("Disponible en el nivel " .. PRESTIGE_LEVEL)
		setButton(prestigeRow, ready and "Prestigiar" or ("Nivel " .. PRESTIGE_LEVEL), ready, Theme.Amber)
		if ready then
			prestigeRow.action.TextColor3 = Theme.Bg
		end
	end
	prestigeDot.Visible = ready
end

local function refreshLevel()
	local required = stats.Level.Value * TicketData.XPPerLevel
	levelLabel.Text = "Nivel " .. stats.Level.Value .. (stats.Prestige.Value > 0 and ("  👑" .. stats.Prestige.Value) or "") .. (stats.GameWon.Value and " 🏆" or "")
	xpLabel.Text = stats.XP.Value .. "/" .. required
	tween(xpFill, 0.3, { Size = UDim2.fromScale(math.clamp(stats.XP.Value / required, 0, 1), 1) })
end

-- El dinero sube o baja poco a poco en vez de saltar.
local shownMoney = make("NumberValue", { Value = stats.Money.Value, Parent = hudGui })
shownMoney.Changed:Connect(function(value: number)
	moneyLabel.Text = money(math.round(value))
end)
moneyLabel.Text = money(stats.Money.Value)

stats.Money.Changed:Connect(function(value: number)
	tween(shownMoney, 0.4, { Value = value })
	refreshTickets()
	refreshUpgrades()
end)

for _, tier in Tiers do
	stats[tier.id].Changed:Connect(refreshTickets)
	stats[tier.id].Changed:Connect(refreshSpecialCount)
end
stats.Level.Changed:Connect(function()
	refreshLevel()
	refreshTickets()
	refreshPrestige()
end)
stats.XP.Changed:Connect(refreshLevel)
stats.Prestige.Changed:Connect(function()
	refreshLevel()
	refreshPrestige()
end)
stats.Luck.Changed:Connect(refreshUpgrades)
stats.Auto.Changed:Connect(refreshUpgrades)
stats.Speed.Changed:Connect(refreshUpgrades)

stats.GameWon.Changed:Connect(function()
	refreshLevel()
	refreshTickets()
end)
stats.Prestige.Changed:Connect(refreshTickets)

refreshTickets()
refreshSpecialCount()
refreshUpgrades()
refreshPrestige()
refreshLevel()

---------------------------------------------------------------------
-- Mando y consolas
---------------------------------------------------------------------

local isConsole = GuiService:IsTenFootInterface()
local SELECTION_GROUP = "ScratchMenus"

local GAMEPAD_INPUTS = {
	[Enum.UserInputType.Gamepad1] = true,
	[Enum.UserInputType.Gamepad2] = true,
	[Enum.UserInputType.Gamepad3] = true,
	[Enum.UserInputType.Gamepad4] = true,
}

local function usingGamepad(): boolean
	return isConsole or GAMEPAD_INPUTS[UserInputService:GetLastInputType()] == true
end

if isConsole then
	pcall(function()
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
	end)
end

-- Barra de atajos con los iconos del mando que se esté usando.
local hintBar = make("Frame", {
	AnchorPoint = Vector2.new(0.5, 1),
	Position = UDim2.new(0.5, 0, 1, isConsole and -40 or -12),
	Size = UDim2.fromOffset(0, 40),
	AutomaticSize = Enum.AutomaticSize.X,
	BackgroundColor3 = Theme.Bg,
	BackgroundTransparency = 0.1,
	Visible = false,
	Parent = hudGui,
}, {
	corner(12),
	padding(10, 0),
	make("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}),
})

local SHORTCUTS = {
	{ key = Enum.KeyCode.ButtonY, panel = "Upgrades", text = "Mejoras" },
	{ key = Enum.KeyCode.DPadUp, panel = "Missions", text = "Misiones" },
	{ key = Enum.KeyCode.DPadRight, panel = "Room", text = "Habitación" },
	{ key = Enum.KeyCode.DPadLeft, panel = "Pets", text = "Mascotas" },
	{ key = Enum.KeyCode.DPadDown, panel = "Help", text = "Ayuda" },
}

for index, shortcut in SHORTCUTS do
	make("ImageLabel", {
		Size = UDim2.fromOffset(24, 24),
		BackgroundTransparency = 1,
		Image = UserInputService:GetImageForKeyCode(shortcut.key),
		LayoutOrder = index * 2,
		Parent = hintBar,
	})
	label({
		Size = UDim2.fromOffset(0, 24),
		AutomaticSize = Enum.AutomaticSize.X,
		Text = shortcut.text,
		Font = FONT_BOLD,
		TextSize = 14,
		TextTruncate = Enum.TextTruncate.None,
		LayoutOrder = index * 2 + 1,
		Parent = hintBar,
	})
end

-- Punto de rascado que se mueve con el stick derecho.
local stickCursor = make("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Size = UDim2.fromOffset(BRUSH_RADIUS * 2, BRUSH_RADIUS * 2),
	BackgroundTransparency = 1,
	Visible = false,
	ZIndex = 6,
	Parent = zone,
}, { corner(BRUSH_RADIUS), stroke(Color3.new(1, 1, 1)) })

local stickInput = Vector2.zero
local cursorPoint = Vector2.new(ZONE_W / 2, ZONE_H / 2)

local function firstButtonIn(root: Instance): GuiObject?
	local best = nil
	for _, descendant in root:GetDescendants() do
		if descendant:IsA("TextButton") and descendant:FindFirstAncestorOfClass("ScrollingFrame") then
			if not best or descendant.AbsolutePosition.Y < best.AbsolutePosition.Y then
				best = descendant
			end
		end
	end
	return best
end

local function stickAction(_, inputState: Enum.UserInputState, input: InputObject)
	if inputState == Enum.UserInputState.Cancel or inputState == Enum.UserInputState.End then
		stickInput = Vector2.zero
	else
		stickInput = Vector2.new(input.Position.X, input.Position.Y)
	end
	return Enum.ContextActionResult.Sink
end

local stickBound = false

uiChanged = function()
	local scratching = cardOpen and not revealed
	if scratching and not stickBound then
		stickBound = true
		ContextActionService:BindActionAtPriority("ScratchStick", stickAction, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.Thumbstick2)
	elseif not scratching and stickBound then
		stickBound = false
		stickInput = Vector2.zero
		ContextActionService:UnbindAction("ScratchStick")
	end

	local gamepad = usingGamepad()
	hintBar.Visible = gamepad and not cardOpen and openPanelName == nil
	stickCursor.Visible = gamepad and scratching
	if scratching then
		foilHint.Text = gamepad and "RASCA CON EL STICK DERECHO" or "RASCA AQUÍ"
		foilHint.TextSize = gamepad and 20 or 30
		cursorPoint = Vector2.new(ZONE_W / 2, ZONE_H / 2)
		stickCursor.Position = UDim2.fromOffset(cursorPoint.X, cursorPoint.Y)
	end

	GuiService:RemoveSelectionGroup(SELECTION_GROUP)
	if not gamepad then
		if GuiService.SelectedObject and (GuiService.SelectedObject:IsDescendantOf(modalGui) or GuiService.SelectedObject:IsDescendantOf(cardGui)) then
			GuiService.SelectedObject = nil
		end
		return
	end

	local target: GuiObject? = nil
	if cardOpen then
		GuiService:AddSelectionParent(SELECTION_GROUP, card)
		if not revealed then
			target = revealButton
		elseif activeTier and stats[activeTier.id].Value > 0 then
			target = againButton
		else
			target = closeButton
		end
	elseif openPanelName then
		local root = panels[openPanelName :: string].root
		GuiService:AddSelectionParent(SELECTION_GROUP, root)
		target = firstButtonIn(root)
	end
	GuiService.SelectedObject = target
end

UserInputService.LastInputTypeChanged:Connect(uiChanged)

RunService.RenderStepped:Connect(function(deltaTime: number)
	if not (cardOpen and not revealed and stickInput.Magnitude > 0.2) then
		return
	end
	-- En el stick, arriba es positivo; en pantalla, abajo.
	local movement = Vector2.new(stickInput.X, -stickInput.Y) * 320 * deltaTime
	cursorPoint = Vector2.new(
		math.clamp(cursorPoint.X + movement.X, 0, ZONE_W),
		math.clamp(cursorPoint.Y + movement.Y, 0, ZONE_H)
	)
	stickCursor.Position = UDim2.fromOffset(cursorPoint.X, cursorPoint.Y)
	scratchTo(zone.AbsolutePosition + Vector2.new(cursorPoint.X / ZONE_W, cursorPoint.Y / ZONE_H) * zone.AbsoluteSize)
end)

local function menuAction(_, inputState: Enum.UserInputState, input: InputObject)
	if inputState ~= Enum.UserInputState.Begin then
		return Enum.ContextActionResult.Pass
	end

	if input.KeyCode == Enum.KeyCode.ButtonB then
		if cardOpen then
			if revealed then
				closeCard()
			end
			return Enum.ContextActionResult.Sink
		elseif openPanelName then
			closePanels()
			return Enum.ContextActionResult.Sink
		end
		return Enum.ContextActionResult.Pass
	end

	-- Con un menú abierto, la cruceta se usa para moverse por él.
	if cardOpen or openPanelName then
		return Enum.ContextActionResult.Pass
	end
	for _, shortcut in SHORTCUTS do
		if shortcut.key == input.KeyCode then
			openPanel(shortcut.panel)
			return Enum.ContextActionResult.Sink
		end
	end
	return Enum.ContextActionResult.Pass
end

local menuKeys = { Enum.KeyCode.ButtonB }
for _, shortcut in SHORTCUTS do
	table.insert(menuKeys, shortcut.key)
end
ContextActionService:BindAction("ScratchMenuKeys", menuAction, false, table.unpack(menuKeys))

uiChanged()

---------------------------------------------------------------------
-- Idioma
---------------------------------------------------------------------

-- Traduce cualquier texto de la interfaz en el momento en que se muestra.
local function localizeLabel(object: Instance)
	if not object:IsA("TextLabel") and not object:IsA("TextButton") then
		return
	end
	local textObject = object :: any
	local function apply()
		local translated = Lang.t(textObject.Text)
		if translated ~= textObject.Text then
			textObject.Text = translated
		end
	end
	textObject:GetPropertyChangedSignal("Text"):Connect(apply)
	apply()
end

if Lang.current ~= "es" then
	for _, gui in { hudGui, modalGui, toastGui, cardGui } do
		gui.DescendantAdded:Connect(localizeLabel)
		for _, descendant in gui:GetDescendants() do
			localizeLabel(descendant)
		end
	end
	for _, target in { pcTarget, tableTarget } do
		local prompt = target:FindFirstChildOfClass("ProximityPrompt")
		if prompt then
			prompt.ActionText = Lang.t(prompt.ActionText)
			prompt.ObjectText = Lang.t(prompt.ObjectText)
		end
	end
end

---------------------------------------------------------------------
-- Eventos del servidor
---------------------------------------------------------------------

if player:GetAttribute("DataLoadFailed") then
	showToast("No se pudo cargar tu progreso: esta partida no se guardará")
end

remotes.OpenShop.OnClientEvent:Connect(function()
	openPanel("Shop")
end)

remotes.OpenScratch.OnClientEvent:Connect(function()
	openPanel("Scratch")
end)

remotes.ShowMessage.OnClientEvent:Connect(function(message: string)
	-- Los resultados manuales también se muestran en grande en la mesa.
	local isAuto = message:sub(1, 5) == "[AUTO"
	local isResult = message:sub(1, 1) == "+" and message ~= "+1 Luck"
	isResult = isResult or message:lower():find("jackpot", 1, true) ~= nil or message:lower():find("perdido", 1, true) ~= nil
	-- Con el ticket abierto, el resultado ya se ve en él.
	if not (cardOpen and isResult and not isAuto) then
		showToast(message)
	end

	if isResult and not isAuto then
		local color = classify(message)
		resultLabel.Text = message
		resultLabel.TextColor3 = color
		resultStroke.Color = color
		resultStroke.Transparency = 0.2
		resultScale.Scale = 0.92
		tween(resultScale, 0.3, { Scale = 1 }, Enum.EasingStyle.Back)
	end
end)
