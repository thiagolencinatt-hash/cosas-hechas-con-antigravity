--!strict
-- OpeningToolsClient.luau
-- Controlador Maestro de la Tienda: Maneja los 3 apartados (Armas de Asalto, Rastros de Velocidad y Mejoras).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local OpeningToolsConfig = require(Modules:WaitForChild("OpeningToolsConfig"))
local TrailConfigurations = require(Modules:WaitForChild("TrailConfigurations"))

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local ToolActionRemote = Remotes:WaitForChild("OpeningToolsAction") :: RemoteEvent
local PurchaseUpgradeRemote = Remotes:FindFirstChild("PurchaseUpgrade") :: RemoteEvent?

local EventsFolder = ReplicatedStorage:FindFirstChild("Events")
local TrailActionRemote = (EventsFolder and EventsFolder:FindFirstChild("TrailAction")) :: RemoteEvent?
if not TrailActionRemote then
	TrailActionRemote = Remotes:FindFirstChild("TrailAction") :: RemoteEvent?
end

local function formatNumber(n: number): string
	local formatted = tostring(math.floor(n))
	while true do
		local result, count = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
		formatted = result
		if count == 0 then break end
	end
	return formatted
end

local function style(inst: GuiObject, cornerRadius: number, strokeColor: Color3?, strokeWidth: number?)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, cornerRadius)
	c.Parent = inst
	if strokeColor then
		local s = Instance.new("UIStroke")
		s.Color = strokeColor
		s.Thickness = strokeWidth or 1.5
		s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		s.Parent = inst
	end
end

-- 1. Localizar o Crear la Ventana de la Tienda (Fail-safe)
local petsGui = PlayerGui:WaitForChild("Pets", 4)
local frame = (petsGui and petsGui:FindFirstChild("OpeningToolsFrame"))
	or PlayerGui:FindFirstChild("OpeningToolsFrame", true) :: Frame?

if not frame then
	local shopGui = Instance.new("ScreenGui")
	shopGui.Name = "ShopGui"
	shopGui.ResetOnSpawn = false
	shopGui.DisplayOrder = 50
	shopGui.Parent = PlayerGui

	frame = Instance.new("Frame")
	frame.Name = "OpeningToolsFrame"
	frame.Size = UDim2.new(0, 580, 0, 480)
	frame.Position = UDim2.new(0.5, -290, 0.5, -240)
	frame.BackgroundColor3 = Color3.fromRGB(24, 27, 38)
	frame.BorderSizePixel = 0
	frame.Visible = false
	frame.Parent = shopGui
	style(frame, 14, Color3.fromRGB(45, 55, 75), 2.5)

	local titleFrame = Instance.new("Frame")
	titleFrame.Name = "Title"
	titleFrame.Size = UDim2.new(1, 0, 0, 44)
	titleFrame.BackgroundColor3 = Color3.fromRGB(32, 38, 54)
	titleFrame.BorderSizePixel = 0
	titleFrame.Parent = frame
	style(titleFrame, 14, nil, nil)

	local titleLbl = Instance.new("TextLabel")
	titleLbl.Size = UDim2.new(1, -60, 1, 0)
	titleLbl.Position = UDim2.new(0, 16, 0, 0)
	titleLbl.BackgroundTransparency = 1
	titleLbl.Text = "🛒 TIENDA GENERAL DE ASALTO"
	titleLbl.TextColor3 = Color3.fromRGB(255, 215, 0)
	titleLbl.Font = Enum.Font.FredokaOne
	titleLbl.TextSize = 16
	titleLbl.TextXAlignment = Enum.TextXAlignment.Left
	titleLbl.Parent = titleFrame

	local closeBtn = Instance.new("TextButton")
	closeBtn.Name = "CloseBtn"
	closeBtn.Size = UDim2.new(0, 30, 0, 30)
	closeBtn.Position = UDim2.new(1, -38, 0.5, -15)
	closeBtn.BackgroundColor3 = Color3.fromRGB(230, 50, 50)
	closeBtn.Text = "✕"
	closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeBtn.Font = Enum.Font.FredokaOne
	closeBtn.TextSize = 14
	closeBtn.Parent = titleFrame
	style(closeBtn, 8, Color3.fromRGB(160, 30, 30), 1.5)

	local scroll = Instance.new("ScrollingFrame")
	scroll.Name = "ToolsScroll"
	scroll.Size = UDim2.new(1, -24, 1, -100)
	scroll.Position = UDim2.new(0, 12, 0, 90)
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.ScrollBarThickness = 6
	scroll.ScrollBarImageColor3 = Color3.fromRGB(255, 170, 0)
	scroll.Parent = frame

	local grid = Instance.new("UIGridLayout")
	grid.CellSize = UDim2.new(0, 170, 0, 230)
	grid.CellPadding = UDim2.new(0, 12, 0, 12)
	grid.Parent = scroll
end

local titleFrame = frame:FindFirstChild("Title") or frame
local closeBtn = titleFrame:FindFirstChild("CloseBtn") or titleFrame:FindFirstChild("Close") :: TextButton?
local scroll = (frame:FindFirstChild("ToolsScroll") or frame:FindFirstChild("Scrolling") or frame:FindFirstChildWhichIsA("ScrollingFrame", true)) :: ScrollingFrame

scroll.Position = UDim2.new(0, 12, 0, 90)
scroll.Size = UDim2.new(1, -24, 1, -100)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

local scale = frame:FindFirstChildOfClass("UIScale")
if not scale then
	scale = Instance.new("UIScale")
	scale.Scale = 1
	scale.Parent = frame
end

-- 2. Barra de Apartados (Tabs Navigation Bar)
local tabBar = frame:FindFirstChild("ShopTabBar") :: Frame?
if not tabBar then
	tabBar = Instance.new("Frame")
	tabBar.Name = "ShopTabBar"
	tabBar.Size = UDim2.new(1, -24, 0, 36)
	tabBar.Position = UDim2.new(0, 12, 0, 48)
	tabBar.BackgroundColor3 = Color3.fromRGB(18, 20, 30)
	tabBar.BorderSizePixel = 0
	tabBar.Parent = frame
	style(tabBar, 8, Color3.fromRGB(40, 48, 68), 1.5)

	local tLayout = Instance.new("UIListLayout")
	tLayout.FillDirection = Enum.FillDirection.Horizontal
	tLayout.Padding = UDim.new(0, 6)
	tLayout.Parent = tabBar
end

local currentTab = "Armas"
local tabButtons: { [string]: TextButton } = {}

local function createTabBtn(id: string, text: string)
	local b = tabBar:FindFirstChild("Tab_" .. id) :: TextButton?
	if not b then
		b = Instance.new("TextButton")
		b.Name = "Tab_" .. id
		b.Size = UDim2.new(0.333, -4, 1, 0)
		b.BackgroundColor3 = Color3.fromRGB(30, 36, 50)
		b.Text = text
		b.TextColor3 = Color3.fromRGB(200, 210, 230)
		b.Font = Enum.Font.FredokaOne
		b.TextSize = 13
		b.Parent = tabBar
		style(b, 6, nil, nil)
	end
	tabButtons[id] = b
end

createTabBtn("Armas", "🔨 ARMAS DE ASALTO")
createTabBtn("Rastros", "⚡ RASTROS DE VELOCIDAD")
createTabBtn("Mejoras", "🏃 MEJORAS DE CINTA")

-- Ensure grid in scroll
local grid = scroll:FindFirstChildOfClass("UIGridLayout")
if not grid then
	grid = Instance.new("UIGridLayout")
	grid.CellSize = UDim2.new(0, 170, 0, 230)
	grid.CellPadding = UDim2.new(0, 12, 0, 12)
	grid.Parent = scroll
end

local isOpen = false

local function setOpen(open: boolean, initialTab: string?)
	if initialTab then
		currentTab = initialTab
	end
	isOpen = open
	if open then
		frame.Visible = true
		scale.Scale = 1
		_G.PopulateCurrentShopTab()
	else
		frame.Visible = false
	end
end

if closeBtn then
	closeBtn.MouseButton1Click:Connect(function()
		setOpen(false)
	end)
end

local function getPlayerMoney(): number
	local ls = Player:FindFirstChild("leaderstats")
	local m = ls and ls:FindFirstChild("Money") :: IntValue?
	return m and m.Value or 0
end

-- Tool Emojis
local toolIcons = {
	MazoMadera = "🗝️",
	PicoRomperrocas = "⛏️",
	MartilloEscarcha = "🔨",
	MazoChicle = "🔩",
	HachaAcida = "🔥",
	TridenteAbisal = "⚡",
	EspadonMagma = "💻",
	GuadanaFloral = "❄️",
	EspadaLaserGalactica = "🔊",
	CanonDesintegradorAlien = "⚛️",
}

-- Render Apartado 1: ARMAS DE ASALTO
local function renderArmasTab()
	for _, child in ipairs(scroll:GetChildren()) do
		if child:IsA("GuiObject") and not child:IsA("UIGridLayout") and not child:IsA("UIPadding") then
			child:Destroy()
		end
	end

	local folder = Player:FindFirstChild("OpeningTools")
	local eqVal = folder and folder:FindFirstChild("EquippedTool") :: StringValue?
	local eqId = eqVal and eqVal.Value or "MazoMadera"
	local currentMoney = getPlayerMoney()

	for index, tool in ipairs(OpeningToolsConfig.Tools) do
		local isOwned = (tool.Id == "MazoMadera") or (folder and folder:FindFirstChild(tool.Id) ~= nil)
		local isEquipped = (eqId == tool.Id)

		local card = Instance.new("Frame")
		card.Name = tool.Id
		card.BackgroundColor3 = Color3.fromRGB(246, 248, 252)
		card.LayoutOrder = index
		card.Parent = scroll
		style(card, 10, Color3.fromRGB(30, 35, 45), 2)

		-- Name
		local nameLbl = Instance.new("TextLabel")
		nameLbl.Size = UDim2.new(0.92, 0, 0, 30)
		nameLbl.Position = UDim2.new(0.04, 0, 0.03, 0)
		nameLbl.BackgroundTransparency = 1
		nameLbl.Text = tool.Name
		nameLbl.TextColor3 = Color3.fromRGB(20, 25, 35)
		nameLbl.Font = Enum.Font.FredokaOne
		nameLbl.TextScaled = true
		nameLbl.Parent = card

		-- Rarity badge
		local rarityBadge = Instance.new("Frame")
		rarityBadge.Size = UDim2.new(0.68, 0, 0, 18)
		rarityBadge.Position = UDim2.new(0.16, 0, 0.18, 0)
		rarityBadge.BackgroundColor3 = Color3.fromRGB(230, 235, 245)
		rarityBadge.Parent = card
		style(rarityBadge, 9, nil, nil)

		local rarityText = Instance.new("TextLabel")
		rarityText.Size = UDim2.new(1, 0, 1, 0)
		rarityText.BackgroundTransparency = 1
		rarityText.Text = tool.Rarity
		rarityText.TextColor3 = tool.RarityColor or Color3.fromRGB(80, 80, 90)
		rarityText.Font = Enum.Font.FredokaOne
		rarityText.TextSize = 11
		rarityText.Parent = rarityBadge

		-- Icon
		local iconBg = Instance.new("Frame")
		iconBg.Size = UDim2.new(0, 64, 0, 64)
		iconBg.Position = UDim2.new(0.5, -32, 0.28, 0)
		iconBg.BackgroundColor3 = Color3.fromRGB(238, 242, 248)
		iconBg.Parent = card
		style(iconBg, 10, tool.Color, 1.5)

		local iconLbl = Instance.new("TextLabel")
		iconLbl.Size = UDim2.new(1, 0, 1, 0)
		iconLbl.BackgroundTransparency = 1
		iconLbl.Text = toolIcons[tool.Id] or "🔨"
		iconLbl.TextSize = 34
		iconLbl.Parent = iconBg

		-- Power Box
		local powerBox = Instance.new("Frame")
		powerBox.Size = UDim2.new(0.88, 0, 0, 22)
		powerBox.Position = UDim2.new(0.06, 0, 0.61, 0)
		powerBox.BackgroundColor3 = Color3.fromRGB(36, 42, 54)
		powerBox.Parent = card
		style(powerBox, 6, Color3.fromRGB(20, 24, 32), 1)

		local powerLbl = Instance.new("TextLabel")
		powerLbl.Size = UDim2.new(1, 0, 1, 0)
		powerLbl.BackgroundTransparency = 1
		powerLbl.Text = string.format("⚡ %s Poder", formatNumber(tool.BreakPower))
		powerLbl.TextColor3 = Color3.fromRGB(80, 220, 255)
		powerLbl.Font = Enum.Font.FredokaOne
		powerLbl.TextSize = 12
		powerLbl.Parent = powerBox

		-- Action Button
		local actionBtn = Instance.new("TextButton")
		actionBtn.Size = UDim2.new(0.88, 0, 0, 32)
		actionBtn.Position = UDim2.new(0.06, 0, 0.79, 0)
		actionBtn.Font = Enum.Font.FredokaOne
		actionBtn.TextSize = 13
		actionBtn.Parent = card

		if isEquipped then
			actionBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 70)
			actionBtn.Text = "✓ EQUIPADO"
			actionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			style(actionBtn, 8, Color3.fromRGB(30, 90, 40), 1.5)
		elseif isOwned then
			actionBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 230)
			actionBtn.Text = "EQUIPAR"
			actionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			style(actionBtn, 8, Color3.fromRGB(0, 110, 160), 1.5)
			actionBtn.MouseButton1Click:Connect(function()
				ToolActionRemote:FireServer("Equip", tool.Id)
			end)
		else
			local canAfford = currentMoney >= tool.Price
			actionBtn.BackgroundColor3 = canAfford and Color3.fromRGB(245, 155, 30) or Color3.fromRGB(200, 70, 60)
			actionBtn.Text = "🛒 $" .. formatNumber(tool.Price)
			actionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			style(actionBtn, 8, canAfford and Color3.fromRGB(170, 100, 15) or Color3.fromRGB(140, 40, 30), 1.5)
			actionBtn.MouseButton1Click:Connect(function()
				ToolActionRemote:FireServer("Buy", tool.Id)
			end)
		end
	end
	scroll.CanvasSize = UDim2.new(0, 0, 0, math.ceil(#OpeningToolsConfig.Tools / 3) * 242)
end

-- Render Apartado 2: RASTROS DE VELOCIDAD
local function renderRastrosTab()
	for _, child in ipairs(scroll:GetChildren()) do
		if child:IsA("GuiObject") and not child:IsA("UIGridLayout") and not child:IsA("UIPadding") then
			child:Destroy()
		end
	end

	local trails = Player:FindFirstChild("Trails")
	local eqVal = trails and trails:FindFirstChild("Equipped") :: StringValue?
	local eqId = eqVal and eqVal.Value or ""
	local currentMoney = getPlayerMoney()

	for index, trail in ipairs(TrailConfigurations.Trails) do
		local isOwned = trails and trails:FindFirstChild(trail.ID) ~= nil
		local isEquipped = (eqId == trail.ID)

		local card = Instance.new("Frame")
		card.Name = trail.ID
		card.BackgroundColor3 = Color3.fromRGB(246, 248, 252)
		card.LayoutOrder = index
		card.Parent = scroll
		style(card, 10, Color3.fromRGB(30, 35, 45), 2)

		-- Name
		local nameLbl = Instance.new("TextLabel")
		nameLbl.Size = UDim2.new(0.92, 0, 0, 30)
		nameLbl.Position = UDim2.new(0.04, 0, 0.03, 0)
		nameLbl.BackgroundTransparency = 1
		nameLbl.Text = trail.Name
		nameLbl.TextColor3 = Color3.fromRGB(20, 25, 35)
		nameLbl.Font = Enum.Font.FredokaOne
		nameLbl.TextScaled = true
		nameLbl.Parent = card

		-- Biome badge
		local biomeBadge = Instance.new("Frame")
		biomeBadge.Size = UDim2.new(0.72, 0, 0, 18)
		biomeBadge.Position = UDim2.new(0.14, 0, 0.18, 0)
		biomeBadge.BackgroundColor3 = Color3.fromRGB(230, 235, 245)
		biomeBadge.Parent = card
		style(biomeBadge, 9, nil, nil)

		local biomeText = Instance.new("TextLabel")
		biomeText.Size = UDim2.new(1, 0, 1, 0)
		biomeText.BackgroundTransparency = 1
		biomeText.Text = trail.Biome
		biomeText.TextColor3 = Color3.fromRGB(80, 80, 100)
		biomeText.Font = Enum.Font.FredokaOne
		biomeText.TextSize = 10
		biomeText.Parent = biomeBadge

		-- Trail visual color preview
		local previewBar = Instance.new("Frame")
		previewBar.Size = UDim2.new(0, 64, 0, 64)
		previewBar.Position = UDim2.new(0.5, -32, 0.28, 0)
		previewBar.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
		previewBar.Parent = card
		style(previewBar, 10, Color3.fromRGB(40, 50, 70), 1.5)

		local tIcon = Instance.new("TextLabel")
		tIcon.Size = UDim2.new(1, 0, 1, 0)
		tIcon.BackgroundTransparency = 1
		tIcon.Text = "⚡"
		tIcon.TextSize = 34
		tIcon.TextColor3 = trail.Color.Keypoints[1].Value
		tIcon.Parent = previewBar

		-- Speed Boost container
		local boostBox = Instance.new("Frame")
		boostBox.Size = UDim2.new(0.88, 0, 0, 22)
		boostBox.Position = UDim2.new(0.06, 0, 0.61, 0)
		boostBox.BackgroundColor3 = Color3.fromRGB(36, 42, 54)
		boostBox.Parent = card
		style(boostBox, 6, Color3.fromRGB(20, 24, 32), 1)

		local boostLbl = Instance.new("TextLabel")
		boostLbl.Size = UDim2.new(1, 0, 1, 0)
		boostLbl.BackgroundTransparency = 1
		boostLbl.Text = string.format("👟 +%d Vel (x%.1f)", trail.SpeedBoost, trail.SpeedMultiplier)
		boostLbl.TextColor3 = Color3.fromRGB(255, 215, 0)
		boostLbl.Font = Enum.Font.FredokaOne
		boostLbl.TextSize = 12
		boostLbl.Parent = boostBox

		-- Action Button
		local actionBtn = Instance.new("TextButton")
		actionBtn.Size = UDim2.new(0.88, 0, 0, 32)
		actionBtn.Position = UDim2.new(0.06, 0, 0.79, 0)
		actionBtn.Font = Enum.Font.FredokaOne
		actionBtn.TextSize = 13
		actionBtn.Parent = card

		if isEquipped then
			actionBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
			actionBtn.Text = "✕ DESEQUIPAR"
			actionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			style(actionBtn, 8, Color3.fromRGB(140, 30, 30), 1.5)
			actionBtn.MouseButton1Click:Connect(function()
				if TrailActionRemote then
					TrailActionRemote:FireServer("Unequip", trail.ID)
				end
			end)
		elseif isOwned then
			actionBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 230)
			actionBtn.Text = "EQUIPAR"
			actionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			style(actionBtn, 8, Color3.fromRGB(0, 110, 160), 1.5)
			actionBtn.MouseButton1Click:Connect(function()
				if TrailActionRemote then
					TrailActionRemote:FireServer("Equip", trail.ID)
				end
			end)
		else
			local canAfford = currentMoney >= trail.MoneyCost
			actionBtn.BackgroundColor3 = canAfford and Color3.fromRGB(245, 155, 30) or Color3.fromRGB(200, 70, 60)
			actionBtn.Text = "🛒 $" .. formatNumber(trail.MoneyCost)
			actionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			style(actionBtn, 8, canAfford and Color3.fromRGB(170, 100, 15) or Color3.fromRGB(140, 40, 30), 1.5)
			actionBtn.MouseButton1Click:Connect(function()
				if TrailActionRemote then
					TrailActionRemote:FireServer("BuyMoney", trail.ID)
				end
			end)
		end
	end
	scroll.CanvasSize = UDim2.new(0, 0, 0, math.ceil(#TrailConfigurations.Trails / 3) * 242)
end

-- Render Apartado 3: MEJORAS DE CINTA Y BASE
local function renderMejorasTab()
	for _, child in ipairs(scroll:GetChildren()) do
		if child:IsA("GuiObject") and not child:IsA("UIGridLayout") and not child:IsA("UIPadding") then
			child:Destroy()
		end
	end

	local UpgradeModule = require(Modules:WaitForChild("UpgradeModule") :: ModuleScript) :: any
	local TreadmillData = UpgradeModule.TreadmillUpgrade
	local PlotUpgradeData = UpgradeModule.PlotUpgrade

	local currentTreadmill = Player:GetAttribute("TreadmillLevel") or 1
	local currentPlot = Player:GetAttribute("PlotLevel") or 1
	local currentMoney = getPlayerMoney()

	local myPlot: Model? = nil
	local plots = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Plots")
	if plots then
		for _, p in ipairs(plots:GetChildren()) do
			if p:GetAttribute("OwnerUserId") == Player.UserId then
				myPlot = p
				break
			end
		end
	end

	-- Card 1: Cinta de Correr
	local tCard = Instance.new("Frame")
	tCard.Name = "TreadmillCard"
	tCard.BackgroundColor3 = Color3.fromRGB(246, 248, 252)
	tCard.Parent = scroll
	style(tCard, 10, Color3.fromRGB(30, 35, 45), 2)

	local tTitle = Instance.new("TextLabel")
	tTitle.Size = UDim2.new(0.92, 0, 0, 30)
	tTitle.Position = UDim2.new(0.04, 0, 0.04, 0)
	tTitle.BackgroundTransparency = 1
	tTitle.Text = "🏃 CINTA DE ENTRENAMIENTO"
	tTitle.TextColor3 = Color3.fromRGB(20, 25, 35)
	tTitle.Font = Enum.Font.FredokaOne
	tTitle.TextScaled = true
	tTitle.Parent = tCard

	local tIcon = Instance.new("TextLabel")
	tIcon.Size = UDim2.new(0, 64, 0, 64)
	tIcon.Position = UDim2.new(0.5, -32, 0.22, 0)
	tIcon.BackgroundTransparency = 1
	tIcon.Text = "🏃"
	tIcon.TextSize = 44
	tIcon.Parent = tCard

	local nextTreadData = TreadmillData[currentTreadmill + 1]
	local tCost = nextTreadData and tonumber(nextTreadData.Cost) or 0

	local tLevelLbl = Instance.new("TextLabel")
	tLevelLbl.Size = UDim2.new(0.92, 0, 0, 24)
	tLevelLbl.Position = UDim2.new(0.04, 0, 0.58, 0)
	tLevelLbl.BackgroundTransparency = 1
	tLevelLbl.Text = nextTreadData and ("Nivel " .. currentTreadmill .. " ➜ " .. (currentTreadmill + 1)) or ("Nivel " .. currentTreadmill .. " (MÁXIMO)")
	tLevelLbl.TextColor3 = Color3.fromRGB(40, 50, 70)
	tLevelLbl.Font = Enum.Font.FredokaOne
	tLevelLbl.TextSize = 13
	tLevelLbl.Parent = tCard

	local tBtn = Instance.new("TextButton")
	tBtn.Size = UDim2.new(0.88, 0, 0, 34)
	tBtn.Position = UDim2.new(0.06, 0, 0.78, 0)
	tBtn.Font = Enum.Font.FredokaOne
	tBtn.TextSize = 13
	tBtn.Parent = tCard

	if not nextTreadData then
		tBtn.BackgroundColor3 = Color3.fromRGB(110, 110, 110)
		tBtn.Text = "MÁXIMO ALCANZADO"
		tBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		style(tBtn, 8, nil, nil)
	else
		local canAfford = currentMoney >= tCost
		tBtn.BackgroundColor3 = canAfford and Color3.fromRGB(60, 200, 80) or Color3.fromRGB(220, 60, 60)
		tBtn.Text = "MEJORAR $" .. formatNumber(tCost)
		tBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		style(tBtn, 8, canAfford and Color3.fromRGB(30, 120, 40) or Color3.fromRGB(140, 30, 30), 1.5)
		tBtn.MouseButton1Click:Connect(function()
			if PurchaseUpgradeRemote and myPlot then
				PurchaseUpgradeRemote:FireServer(myPlot, "Treadmill")
			end
		end)
	end

	-- Card 2: Base / Parcela
	local pCard = Instance.new("Frame")
	pCard.Name = "PlotCard"
	pCard.BackgroundColor3 = Color3.fromRGB(246, 248, 252)
	pCard.Parent = scroll
	style(pCard, 10, Color3.fromRGB(30, 35, 45), 2)

	local pTitle = Instance.new("TextLabel")
	pTitle.Size = UDim2.new(0.92, 0, 0, 30)
	pTitle.Position = UDim2.new(0.04, 0, 0.04, 0)
	pTitle.BackgroundTransparency = 1
	pTitle.Text = "🏠 MEJORA DE BASE"
	pTitle.TextColor3 = Color3.fromRGB(20, 25, 35)
	pTitle.Font = Enum.Font.FredokaOne
	pTitle.TextScaled = true
	pTitle.Parent = pCard

	local pIcon = Instance.new("TextLabel")
	pIcon.Size = UDim2.new(0, 64, 0, 64)
	pIcon.Position = UDim2.new(0.5, -32, 0.22, 0)
	pIcon.BackgroundTransparency = 1
	pIcon.Text = "🏠"
	pIcon.TextSize = 44
	pIcon.Parent = pCard

	local nextPlotData = PlotUpgradeData[currentPlot + 1]
	local pCost = nextPlotData and tonumber(nextPlotData.Cost) or 0

	local pLevelLbl = Instance.new("TextLabel")
	pLevelLbl.Size = UDim2.new(0.92, 0, 0, 24)
	pLevelLbl.Position = UDim2.new(0.04, 0, 0.58, 0)
	pLevelLbl.BackgroundTransparency = 1
	pLevelLbl.Text = nextPlotData and ("Nivel " .. currentPlot .. " ➜ " .. (currentPlot + 1)) or ("Nivel " .. currentPlot .. " (MÁXIMO)")
	pLevelLbl.TextColor3 = Color3.fromRGB(40, 50, 70)
	pLevelLbl.Font = Enum.Font.FredokaOne
	pLevelLbl.TextSize = 13
	pLevelLbl.Parent = pCard

	local pBtn = Instance.new("TextButton")
	pBtn.Size = UDim2.new(0.88, 0, 0, 34)
	pBtn.Position = UDim2.new(0.06, 0, 0.78, 0)
	pBtn.Font = Enum.Font.FredokaOne
	pBtn.TextSize = 13
	pBtn.Parent = pCard

	if not nextPlotData then
		pBtn.BackgroundColor3 = Color3.fromRGB(110, 110, 110)
		pBtn.Text = "MÁXIMO ALCANZADO"
		pBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		style(pBtn, 8, nil, nil)
	else
		local canAfford = currentMoney >= pCost
		pBtn.BackgroundColor3 = canAfford and Color3.fromRGB(60, 200, 80) or Color3.fromRGB(220, 60, 60)
		pBtn.Text = "MEJORAR $" .. formatNumber(pCost)
		pBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		style(pBtn, 8, canAfford and Color3.fromRGB(30, 120, 40) or Color3.fromRGB(140, 30, 30), 1.5)
		pBtn.MouseButton1Click:Connect(function()
			if PurchaseUpgradeRemote and myPlot then
				PurchaseUpgradeRemote:FireServer(myPlot, "Main")
			end
		end)
	end

	scroll.CanvasSize = UDim2.new(0, 0, 0, 260)
end

local function updateTabsVisual()
	for id, btn in pairs(tabButtons) do
		if id == currentTab then
			btn.BackgroundColor3 = Color3.fromRGB(245, 155, 30)
			btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		else
			btn.BackgroundColor3 = Color3.fromRGB(30, 36, 50)
			btn.TextColor3 = Color3.fromRGB(180, 190, 210)
		end
	end
end

function _G.PopulateCurrentShopTab()
	updateTabsVisual()
	if currentTab == "Armas" then
		renderArmasTab()
	elseif currentTab == "Rastros" then
		renderRastrosTab()
	elseif currentTab == "Mejoras" then
		renderMejorasTab()
	end
end

for id, btn in pairs(tabButtons) do
	btn.MouseButton1Click:Connect(function()
		currentTab = id
		_G.PopulateCurrentShopTab()
	end)
end

-- Global helper to open / toggle from other scripts
function _G.ToggleShop(tabName: string?)
	if tabName then currentTab = tabName end
	setOpen(not frame.Visible, tabName)
end

function _G.OpenShop(tabName: string?)
	if tabName then currentTab = tabName end
	setOpen(true, tabName)
end

-- Keyboard shortcut [B] to toggle shop
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.B then
		setOpen(not frame.Visible)
	end
end)

-- Connect physical Lobby Stands
task.spawn(function()
	local function hookStand(standName: string, defaultTab: string)
		local function bind(stand: Instance)
			local pad = stand:FindFirstChild("InteractionPad", true) :: BasePart?
			if pad then
				local prompt = pad:FindFirstChildWhichIsA("ProximityPrompt", true)
				if prompt then
					prompt.Triggered:Connect(function()
						setOpen(true, defaultTab)
					end)
				end
				pad.Touched:Connect(function(hit)
					local char = hit:FindFirstAncestorOfClass("Model")
					if char and char == Player.Character and not frame.Visible then
						setOpen(true, defaultTab)
					end
				end)
			end
		end

		local stand = workspace:FindFirstChild(standName, true)
		if stand then
			bind(stand)
		end
		workspace.DescendantAdded:Connect(function(desc)
			if desc.Name == standName then
				bind(desc)
			end
		end)
	end

	hookStand("StandArmas", "Armas")
	hookStand("StandRastros", "Rastros")
end)

-- Synchronize with Data Updates
task.spawn(function()
	local folder = Player:WaitForChild("OpeningTools", 15)
	if folder then
		folder.ChildAdded:Connect(function() if frame.Visible then _G.PopulateCurrentShopTab() end end)
		local eq = folder:WaitForChild("EquippedTool", 10)
		if eq then
			eq.Changed:Connect(function() if frame.Visible then _G.PopulateCurrentShopTab() end end)
		end
	end

	local trails = Player:WaitForChild("Trails", 15)
	if trails then
		trails.ChildAdded:Connect(function() if frame.Visible then _G.PopulateCurrentShopTab() end end)
		local eq = trails:WaitForChild("Equipped", 10)
		if eq then
			eq.Changed:Connect(function() if frame.Visible then _G.PopulateCurrentShopTab() end end)
		end
	end

	local ls = Player:WaitForChild("leaderstats", 15)
	local m = ls and ls:WaitForChild("Money", 10)
	if m then
		m.Changed:Connect(function() if frame.Visible then _G.PopulateCurrentShopTab() end end)
	end
end)
