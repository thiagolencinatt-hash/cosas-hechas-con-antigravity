--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local AdminRemote = Remotes:WaitForChild("AdminCommand") :: RemoteEvent
local AdminVerify = Remotes:WaitForChild("AdminVerify") :: RemoteFunction

-- Authorization Check
local isAuth = false
local success, res = pcall(function()
	return AdminVerify:InvokeServer()
end)
if success and res == true then
	isAuth = true
end
if not isAuth then
	return
end

-- Ensure AdminGui exists in PlayerGui
local adminGui = PlayerGui:FindFirstChild("AdminGui") :: ScreenGui?
if not adminGui then
	adminGui = Instance.new("ScreenGui")
	adminGui.Name = "AdminGui"
	adminGui.ResetOnSpawn = false
	adminGui.DisplayOrder = 999
	adminGui.Parent = PlayerGui
end

-- Helper to create rounded corners & strokes
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

-- 1. Floating Toggle Button (Top-Right)
local toggleBtn = adminGui:FindFirstChild("AdminToggleBtn") :: TextButton?
if not toggleBtn then
	toggleBtn = Instance.new("TextButton")
	toggleBtn.Name = "AdminToggleBtn"
	toggleBtn.Size = UDim2.new(0, 115, 0, 36)
	toggleBtn.Position = UDim2.new(1, -125, 0, 12)
	toggleBtn.BackgroundColor3 = Color3.fromRGB(25, 28, 42)
	toggleBtn.Text = "🛡️ ADMIN [F2]"
	toggleBtn.TextColor3 = Color3.fromRGB(0, 220, 255)
	toggleBtn.Font = Enum.Font.FredokaOne
	toggleBtn.TextSize = 13
	toggleBtn.Parent = adminGui
	style(toggleBtn, 8, Color3.fromRGB(0, 180, 255), 2)
end

-- 2. Admin Window Frame
local window = adminGui:FindFirstChild("AdminWindow") :: Frame?
if not window then
	window = Instance.new("Frame")
	window.Name = "AdminWindow"
	window.Size = UDim2.new(0, 480, 0, 560)
	window.Position = UDim2.new(0.5, -240, 0.5, -280)
	window.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
	window.BorderSizePixel = 0
	window.Visible = false
	window.Parent = adminGui
	style(window, 14, Color3.fromRGB(0, 200, 255), 2.5)

	-- Header with Draggable Support
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, 42)
	header.BackgroundColor3 = Color3.fromRGB(24, 28, 40)
	header.BorderSizePixel = 0
	header.Parent = window
	style(header, 14, nil, nil)

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -50, 1, 0)
	title.Position = UDim2.new(0, 14, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = "🛡️ PANEL DE ADMINISTRADOR"
	title.TextColor3 = Color3.fromRGB(0, 230, 255)
	title.Font = Enum.Font.FredokaOne
	title.TextSize = 15
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = header

	local closeBtn = Instance.new("TextButton")
	closeBtn.Name = "CloseBtn"
	closeBtn.Size = UDim2.new(0, 30, 0, 30)
	closeBtn.Position = UDim2.new(1, -36, 0.5, -15)
	closeBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
	closeBtn.Text = "✕"
	closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeBtn.Font = Enum.Font.FredokaOne
	closeBtn.TextSize = 14
	closeBtn.Parent = header
	style(closeBtn, 8, Color3.fromRGB(150, 30, 30), 1.5)

	-- Scroll Area
	local scroll = Instance.new("ScrollingFrame")
	scroll.Name = "ScrollContent"
	scroll.Size = UDim2.new(1, -20, 1, -52)
	scroll.Position = UDim2.new(0, 10, 0, 46)
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.ScrollBarThickness = 6
	scroll.ScrollBarImageColor3 = Color3.fromRGB(0, 180, 255)
	scroll.CanvasSize = UDim2.new(0, 0, 0, 840)
	scroll.Parent = window

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 12)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = scroll

	local function addSection(titleText: string, order: number): (Frame, UIListLayout)
		local sec = Instance.new("Frame")
		sec.Size = UDim2.new(1, 0, 0, 0)
		sec.AutomaticSize = Enum.AutomaticSize.Y
		sec.BackgroundColor3 = Color3.fromRGB(25, 29, 42)
		sec.LayoutOrder = order
		sec.Parent = scroll
		style(sec, 10, Color3.fromRGB(45, 52, 75), 1.5)

		local pad = Instance.new("UIPadding")
		pad.PaddingTop = UDim.new(0, 8)
		pad.PaddingBottom = UDim.new(0, 10)
		pad.PaddingLeft = UDim.new(0, 10)
		pad.PaddingRight = UDim.new(0, 10)
		pad.Parent = sec

		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, 0, 0, 22)
		lbl.BackgroundTransparency = 1
		lbl.Text = titleText
		lbl.TextColor3 = Color3.fromRGB(255, 215, 0)
		lbl.Font = Enum.Font.FredokaOne
		lbl.TextSize = 14
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Parent = sec

		local sLayout = Instance.new("UIListLayout")
		sLayout.Padding = UDim.new(0, 8)
		sLayout.SortOrder = Enum.SortOrder.LayoutOrder
		sLayout.Parent = sec

		return sec, sLayout
	end

	-- ===== SECTION 1: DINERO (Custom Money) =====
	local secMoney = addSection("💰 MODIFICAR DINERO (CASH)", 1)
	local moneyRow = Instance.new("Frame")
	moneyRow.Size = UDim2.new(1, 0, 0, 36)
	moneyRow.BackgroundTransparency = 1
	moneyRow.Parent = secMoney

	local moneyInput = Instance.new("TextBox")
	moneyInput.Name = "MoneyInput"
	moneyInput.Size = UDim2.new(0.50, -6, 1, 0)
	moneyInput.BackgroundColor3 = Color3.fromRGB(15, 18, 26)
	moneyInput.PlaceholderText = "Ingresa cantidad de $"
	moneyInput.PlaceholderColor3 = Color3.fromRGB(130, 140, 160)
	moneyInput.Text = ""
	moneyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
	moneyInput.Font = Enum.Font.FredokaOne
	moneyInput.TextSize = 13
	moneyInput.ClearTextOnFocus = false
	moneyInput.Parent = moneyRow
	style(moneyInput, 6, Color3.fromRGB(50, 60, 85), 1)

	local setMoneyBtn = Instance.new("TextButton")
	setMoneyBtn.Size = UDim2.new(0.25, -4, 1, 0)
	setMoneyBtn.Position = UDim2.new(0.50, 2, 0, 0)
	setMoneyBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 80)
	setMoneyBtn.Text = "FIJAR $"
	setMoneyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	setMoneyBtn.Font = Enum.Font.FredokaOne
	setMoneyBtn.TextSize = 12
	setMoneyBtn.Parent = moneyRow
	style(setMoneyBtn, 6, Color3.fromRGB(20, 100, 50), 1)

	local addMoneyBtn = Instance.new("TextButton")
	addMoneyBtn.Size = UDim2.new(0.25, -4, 1, 0)
	addMoneyBtn.Position = UDim2.new(0.75, 4, 0, 0)
	addMoneyBtn.BackgroundColor3 = Color3.fromRGB(30, 120, 200)
	addMoneyBtn.Text = "SUMAR +"
	addMoneyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	addMoneyBtn.Font = Enum.Font.FredokaOne
	addMoneyBtn.TextSize = 12
	addMoneyBtn.Parent = moneyRow
	style(addMoneyBtn, 6, Color3.fromRGB(20, 80, 140), 1)

	setMoneyBtn.MouseButton1Click:Connect(function()
		local val = tonumber(moneyInput.Text)
		if val then AdminRemote:FireServer("SetMoney", val) end
	end)
	addMoneyBtn.MouseButton1Click:Connect(function()
		local val = tonumber(moneyInput.Text)
		if val then AdminRemote:FireServer("AddMoney", val) end
	end)

	local mPresets = Instance.new("Frame")
	mPresets.Size = UDim2.new(1, 0, 0, 28)
	mPresets.BackgroundTransparency = 1
	mPresets.Parent = secMoney
	local mPLayout = Instance.new("UIListLayout")
	mPLayout.FillDirection = Enum.FillDirection.Horizontal
	mPLayout.Padding = UDim.new(0, 6)
	mPLayout.Parent = mPresets

	local presetMoneyValues = { { "+$50K", 50000 }, { "+$500K", 500000 }, { "+$5M", 5000000 }, { "+$50M", 50000000 }, { "$1B (MAX)", 1000000000 } }
	for _, pm in ipairs(presetMoneyValues) do
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(0.20, -5, 1, 0)
		b.BackgroundColor3 = Color3.fromRGB(35, 40, 60)
		b.Text = pm[1]
		b.TextColor3 = Color3.fromRGB(255, 215, 0)
		b.Font = Enum.Font.FredokaOne
		b.TextSize = 11
		b.Parent = mPresets
		style(b, 6, Color3.fromRGB(60, 70, 95), 1)
		b.MouseButton1Click:Connect(function()
			AdminRemote:FireServer("AddMoney", pm[2])
		end)
	end

	-- ===== SECTION 2: VELOCIDAD (Custom Speed) =====
	local secSpeed = addSection("⚡ MODIFICAR VELOCIDAD (WALKSPEED & STAT)", 2)
	local speedRow = Instance.new("Frame")
	speedRow.Size = UDim2.new(1, 0, 0, 36)
	speedRow.BackgroundTransparency = 1
	speedRow.Parent = secSpeed

	local speedInput = Instance.new("TextBox")
	speedInput.Name = "SpeedInput"
	speedInput.Size = UDim2.new(0.50, -6, 1, 0)
	speedInput.BackgroundColor3 = Color3.fromRGB(15, 18, 26)
	speedInput.PlaceholderText = "Ingresa velocidad (ej: 100)"
	speedInput.PlaceholderColor3 = Color3.fromRGB(130, 140, 160)
	speedInput.Text = ""
	speedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
	speedInput.Font = Enum.Font.FredokaOne
	speedInput.TextSize = 13
	speedInput.ClearTextOnFocus = false
	speedInput.Parent = speedRow
	style(speedInput, 6, Color3.fromRGB(50, 60, 85), 1)

	local setWsBtn = Instance.new("TextButton")
	setWsBtn.Size = UDim2.new(0.25, -4, 1, 0)
	setWsBtn.Position = UDim2.new(0.50, 2, 0, 0)
	setWsBtn.BackgroundColor3 = Color3.fromRGB(0, 160, 220)
	setWsBtn.Text = "FIJAR WS"
	setWsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	setWsBtn.Font = Enum.Font.FredokaOne
	setWsBtn.TextSize = 12
	setWsBtn.Parent = speedRow
	style(setWsBtn, 6, Color3.fromRGB(0, 100, 150), 1)

	local setStatBtn = Instance.new("TextButton")
	setStatBtn.Size = UDim2.new(0.25, -4, 1, 0)
	setStatBtn.Position = UDim2.new(0.75, 4, 0, 0)
	setStatBtn.BackgroundColor3 = Color3.fromRGB(120, 60, 220)
	setStatBtn.Text = "FIJAR STAT"
	setStatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	setStatBtn.Font = Enum.Font.FredokaOne
	setStatBtn.TextSize = 12
	setStatBtn.Parent = speedRow
	style(setStatBtn, 6, Color3.fromRGB(70, 30, 140), 1)

	setWsBtn.MouseButton1Click:Connect(function()
		local val = tonumber(speedInput.Text)
		if val then AdminRemote:FireServer("SetWalkSpeed", val) end
	end)
	setStatBtn.MouseButton1Click:Connect(function()
		local val = tonumber(speedInput.Text)
		if val then AdminRemote:FireServer("SetSpeedStat", val) end
	end)

	local sPresets = Instance.new("Frame")
	sPresets.Size = UDim2.new(1, 0, 0, 28)
	sPresets.BackgroundTransparency = 1
	sPresets.Parent = secSpeed
	local sPLayout = Instance.new("UIListLayout")
	sPLayout.FillDirection = Enum.FillDirection.Horizontal
	sPLayout.Padding = UDim.new(0, 6)
	sPLayout.Parent = sPresets

	local presetSpeedValues = { { "16 Normal", 16 }, { "50 Rápido", 50 }, { "100 Sónico", 100 }, { "250 Flash", 250 }, { "500 Dios", 500 } }
	for _, ps in ipairs(presetSpeedValues) do
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(0.20, -5, 1, 0)
		b.BackgroundColor3 = Color3.fromRGB(35, 40, 60)
		b.Text = ps[1]
		b.TextColor3 = Color3.fromRGB(80, 220, 255)
		b.Font = Enum.Font.FredokaOne
		b.TextSize = 11
		b.Parent = sPresets
		style(b, 6, Color3.fromRGB(60, 70, 95), 1)
		b.MouseButton1Click:Connect(function()
			AdminRemote:FireServer("SetWalkSpeed", ps[2])
		end)
	end

	-- ===== SECTION 3: MODO DIOS & UTILIDADES =====
	local secUtils = addSection("🛡️ MODO DIOS & UTILIDADES", 3)
	local utilRow = Instance.new("Frame")
	utilRow.Size = UDim2.new(1, 0, 0, 32)
	utilRow.BackgroundTransparency = 1
	utilRow.Parent = secUtils
	local uLayout = Instance.new("UIListLayout")
	uLayout.FillDirection = Enum.FillDirection.Horizontal
	uLayout.Padding = UDim.new(0, 8)
	uLayout.Parent = utilRow

	local godBtn = Instance.new("TextButton")
	godBtn.Size = UDim2.new(0.33, -6, 1, 0)
	godBtn.BackgroundColor3 = Color3.fromRGB(220, 160, 30)
	godBtn.Text = "🛡️ MODO DIOS"
	godBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	godBtn.Font = Enum.Font.FredokaOne
	godBtn.TextSize = 12
	godBtn.Parent = utilRow
	style(godBtn, 6, Color3.fromRGB(150, 100, 10), 1)
	godBtn.MouseButton1Click:Connect(function()
		AdminRemote:FireServer("ToggleGodMode", nil)
	end)

	local breakBtn = Instance.new("TextButton")
	breakBtn.Size = UDim2.new(0.33, -6, 1, 0)
	breakBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 40)
	breakBtn.Text = "💥 ROMPER CAJA"
	breakBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	breakBtn.Font = Enum.Font.FredokaOne
	breakBtn.TextSize = 12
	breakBtn.Parent = utilRow
	style(breakBtn, 6, Color3.fromRGB(140, 30, 20), 1)
	breakBtn.MouseButton1Click:Connect(function()
		AdminRemote:FireServer("BreakNearbyVault", nil)
	end)

	local resetBtn = Instance.new("TextButton")
	resetBtn.Size = UDim2.new(0.34, -4, 1, 0)
	resetBtn.BackgroundColor3 = Color3.fromRGB(70, 75, 95)
	resetBtn.Text = "🔄 REINICIAR"
	resetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	resetBtn.Font = Enum.Font.FredokaOne
	resetBtn.TextSize = 12
	resetBtn.Parent = utilRow
	style(resetBtn, 6, Color3.fromRGB(45, 50, 65), 1)
	resetBtn.MouseButton1Click:Connect(function()
		AdminRemote:FireServer("ResetCharacterStats", nil)
	end)

	-- ===== SECTION 4: DESBLOQUEAR TODO =====
	local secUnlocks = addSection("📦 DESBLOQUEAR EQUIPAMIENTO", 4)
	local unlRow = Instance.new("Frame")
	unlRow.Size = UDim2.new(1, 0, 0, 32)
	unlRow.BackgroundTransparency = 1
	unlRow.Parent = secUnlocks
	local unlLayout = Instance.new("UIListLayout")
	unlLayout.FillDirection = Enum.FillDirection.Horizontal
	unlLayout.Padding = UDim.new(0, 8)
	unlLayout.Parent = unlRow

	local allToolsBtn = Instance.new("TextButton")
	allToolsBtn.Size = UDim2.new(0.5, -4, 1, 0)
	allToolsBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 100)
	allToolsBtn.Text = "🗡️ TODAS LAS ARMAS"
	allToolsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	allToolsBtn.Font = Enum.Font.FredokaOne
	allToolsBtn.TextSize = 12
	allToolsBtn.Parent = unlRow
	style(allToolsBtn, 6, Color3.fromRGB(30, 110, 60), 1)
	allToolsBtn.MouseButton1Click:Connect(function()
		AdminRemote:FireServer("UnlockAllTools", nil)
	end)

	local allTrailsBtn = Instance.new("TextButton")
	allTrailsBtn.Size = UDim2.new(0.5, -4, 1, 0)
	allTrailsBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 200)
	allTrailsBtn.Text = "⚡ TODOS LOS RASTROS"
	allTrailsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	allTrailsBtn.Font = Enum.Font.FredokaOne
	allTrailsBtn.TextSize = 12
	allTrailsBtn.Parent = unlRow
	style(allTrailsBtn, 6, Color3.fromRGB(110, 30, 130), 1)
	allTrailsBtn.MouseButton1Click:Connect(function()
		AdminRemote:FireServer("UnlockAllTrails", nil)
	end)

	-- ===== SECTION 5: TELETRANSPORTES (10 PAÍSES & BASES) =====
	local secTp = addSection("📍 TELETRANSPORTES A LOS 10 PAÍSES", 5)
	local tpGrid = Instance.new("Frame")
	tpGrid.Size = UDim2.new(1, 0, 0, 160)
	tpGrid.BackgroundTransparency = 1
	tpGrid.Parent = secTp
	local gridLayout = Instance.new("UIGridLayout")
	gridLayout.CellSize = UDim2.new(0.31, 0, 0, 32)
	gridLayout.CellPadding = UDim2.new(0.035, 0, 0, 8)
	gridLayout.Parent = tpGrid

	local tps = {
		{ "🏠 Parcelas", "Plots" },
		{ "🛡️ SafeZone", "SafeZone" },
		{ "🇦🇷 Argentina", "Argentina" },
		{ "🇧🇷 Brasil", "Brasil" },
		{ "🇺🇸 USA", "USA" },
		{ "🇯🇵 Japón", "Japon" },
		{ "🇲🇽 México", "Mexico" },
		{ "🇪🇸 España", "Espana" },
		{ "🇬🇧 Reino Unido", "ReinoUnido" },
		{ "🇫🇷 Francia", "Francia" },
		{ "🇪🇬 Egipto", "Egipto" },
		{ "❄️ Nórdico", "PaisNordico" },
	}
	for _, tp in ipairs(tps) do
		local tb = Instance.new("TextButton")
		tb.BackgroundColor3 = Color3.fromRGB(35, 42, 62)
		tb.Text = tp[1]
		tb.TextColor3 = Color3.fromRGB(240, 245, 255)
		tb.Font = Enum.Font.FredokaOne
		tb.TextSize = 11
		tb.Parent = tpGrid
		style(tb, 6, Color3.fromRGB(60, 75, 105), 1)
		tb.MouseButton1Click:Connect(function()
			AdminRemote:FireServer("Teleport", tp[2])
		end)
	end

	closeBtn.MouseButton1Click:Connect(function()
		window.Visible = false
	end)
end

-- Toggle function
local function toggleAdmin()
	window.Visible = not window.Visible
end

toggleBtn.MouseButton1Click:Connect(toggleAdmin)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.F2 then
		toggleAdmin()
	end
end)