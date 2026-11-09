--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer

local Map = workspace:WaitForChild("Map")
local PlotsFolder = Map:WaitForChild("Plots")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local UpgradeModule = require(Modules:WaitForChild("UpgradeModule") :: ModuleScript) :: any

local TreadmillData = UpgradeModule.TreadmillUpgrade
local PlotUpgradeData = UpgradeModule.PlotUpgrade

local PurchaseRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("PurchaseUpgrade") :: RemoteEvent

local RED = Color3.fromRGB(220, 50, 50)
local GREEN = Color3.fromRGB(60, 220, 80)
local BLUE = Color3.fromRGB(50, 140, 255)
local GRAY = Color3.fromRGB(110, 110, 110)

local COUNTRIES = { "Argentina", "Brasil", "Estados Unidos", "JapÃ³n", "MÃ©xico", "EspaÃ±a", "Reino Unido", "Francia", "Egipto", "PaÃ­s NÃ³rdico" }
local FLAGS = { "ðŸ‡¦ðŸ‡·", "ðŸ‡§ðŸ‡·", "ðŸ‡ºðŸ‡¸", "ðŸ‡¯ðŸ‡µ", "ðŸ‡²ðŸ‡½", "ðŸ‡ªðŸ‡¸", "ðŸ‡¬ðŸ‡§", "ðŸ‡«ðŸ‡·", "ðŸ‡ªðŸ‡¬", "â„ï¸" }

local updateCallbacks: { () -> () } = {}

local function FormatCost(number: number): string
	if number >= 1e12 then
		local v = number / 1e12
		return string.format(v >= 100 and "%.0fT" or "%.1fT", v):gsub("%.0T", "T")
	elseif number >= 1e9 then
		local v = number / 1e9
		return string.format(v >= 100 and "%.0fB" or "%.1fB", v):gsub("%.0B", "B")
	elseif number >= 1e6 then
		local v = number / 1e6
		return string.format(v >= 100 and "%.0fM" or "%.1fM", v):gsub("%.0M", "M")
	elseif number >= 1e3 then
		local v = number / 1e3
		return string.format(v >= 100 and "%.0fK" or "%.1fK", v):gsub("%.0K", "K")
	else
		return tostring(math.floor(number))
	end
end

local function GetPlayerMoney(): number
	local leaderstats = Player:FindFirstChild("leaderstats")
	local money = leaderstats and leaderstats:FindFirstChild("Money")
	return (money and typeof(money.Value) == "number") and money.Value or 0
end

local function GetCost(data: any): number?
	if not data then return nil end
	if string.lower(tostring(data.Cost)) == "free" then return 0 end
	return tonumber(data.Cost)
end

local function SetButton(button: TextButton, text: string, color: Color3, enabled: boolean)
	button.Text = text
	button.BackgroundColor3 = color
	button.Active = enabled
	button.AutoButtonColor = enabled
end

local function UpdateMainPanel(Plot: Model, Button: TextButton, Title: TextLabel, Levels: TextLabel)
	local PlotLevel = Plot:GetAttribute("PlotLevel") or 1
	local currentMoney = GetPlayerMoney()

	Title.Text = "ðŸ  MEJORA DE BASE"
	Levels.Text = "Nivel " .. PlotLevel

	local nextData = PlotUpgradeData[PlotLevel + 1]
	if not nextData then
		SetButton(Button, "MÃXIMO", GRAY, false)
		return
	end

	local cost = GetCost(nextData) or 0
	SetButton(
		Button,
		cost == 0 and "MEJORAR GRATIS" or "MEJORAR $" .. FormatCost(cost),
		currentMoney >= cost and GREEN or RED,
		true
	)
end

local function UpdateTreadmillPanel(Plot: Model, Button: TextButton, Title: TextLabel, Levels: TextLabel)
	local Frame = Levels.Parent
	local NextInfo = Frame and Frame:FindFirstChild("NextInfo") :: TextLabel?
	local SpeedInfo = Frame and Frame:FindFirstChild("SpeedInfo") :: TextLabel?

	local CurrentLevel = math.max(1, Plot:GetAttribute("TreadmillLevel") or 1)
	local CurrentData = TreadmillData[CurrentLevel]
	local NextData = TreadmillData[CurrentLevel + 1]

	Title.Text = "ðŸƒ MEJORA DE CINTA"

	-- ProximityPrompt en el poste de madera de la valla
	local Tup = Plot:FindFirstChild("TreadmillUpgradePart")
	local Prompt = Tup and Tup:FindFirstChild("MejorarCintaPrompt") :: ProximityPrompt?

	if not NextData then
		Levels.Text = "Nivel " .. CurrentLevel .. " " .. (FLAGS[CurrentLevel] or "") .. " Â· MÃXIMO"
		if NextInfo then NextInfo.Text = "Â¡Cinta de " .. (COUNTRIES[CurrentLevel] or "?") .. " al mÃ¡ximo!" end
		if SpeedInfo then SpeedInfo.Text = "ðŸ‘Ÿ +" .. FormatCost(CurrentData and CurrentData.Speed or 0) .. " /Paso" end
		SetButton(Button, "MÃXIMO", GRAY, false)

		if Prompt then
			Prompt.Enabled = false
			Prompt.ActionText = "MÃXIMO"
		end
		return
	end

	Levels.Text = "Nivel " .. CurrentLevel .. " " .. (FLAGS[CurrentLevel] or "") .. " âžœ Nivel " .. (CurrentLevel + 1)
	if NextInfo then NextInfo.Text = "Siguiente: " .. (FLAGS[CurrentLevel + 1] or "") .. " " .. (COUNTRIES[CurrentLevel + 1] or "?") end
	if SpeedInfo then
		SpeedInfo.Text = "ðŸ‘Ÿ +" .. FormatCost(CurrentData and CurrentData.Speed or 0) .. " âžœ +" .. FormatCost(NextData.Speed or 0) .. " /Paso"
	end

	local currentMoney = GetPlayerMoney()
	local cost = GetCost(NextData) or 0
	local costText = "$" .. FormatCost(cost)

	-- Solo en este cartel de madera se muestra claramente el dinero requerido y se actualiza dinÃ¡micamente
	SetButton(
		Button,
		"MEJORAR (" .. costText .. ")",
		currentMoney >= cost and GREEN or RED,
		true
	)

	if Prompt then
		Prompt.Enabled = true
		Prompt.ActionText = "Mejorar (" .. costText .. ")"
		Prompt.ObjectText = "Cinta Nivel " .. (CurrentLevel + 1) .. " " .. (FLAGS[CurrentLevel + 1] or "")
	end

	-- Sincronizar tambien panel frontal si existe
	local panelFront = Tup and Tup:FindFirstChild("TreadmillUpgradePanel_Front") :: SurfaceGui?
	local frameFront = panelFront and panelFront:FindFirstChild("TreadmillUpgradedFrame") :: Frame?
	if frameFront then
		local btnFront = frameFront:FindFirstChild("UpgradedButton") :: TextButton?
		local titleFront = frameFront:FindFirstChild("Title") :: TextLabel?
		local levelsFront = frameFront:FindFirstChild("Levels") :: TextLabel?
		local nextFront = frameFront:FindFirstChild("NextInfo") :: TextLabel?
		local speedFront = frameFront:FindFirstChild("SpeedInfo") :: TextLabel?
		if titleFront then titleFront.Text = Title.Text end
		if levelsFront then levelsFront.Text = Levels.Text end
		if nextFront and NextInfo then nextFront.Text = NextInfo.Text end
		if speedFront and SpeedInfo then speedFront.Text = SpeedInfo.Text end
		if btnFront then
			SetButton(btnFront, Button.Text, Button.BackgroundColor3, Button.Active)
		end
	end
end

local function ConnectPlot(Plot: Instance)
	if not Plot:IsA("Model") then return end

	local PlotUpgradePart = Plot:WaitForChild("PlotUpgradePart", 15) :: BasePart?
	if not PlotUpgradePart then return end

	local PlotPanel = PlotUpgradePart:WaitForChild("PlotUpgradePanel", 15) :: SurfaceGui?
	if not PlotPanel then return end

	local PlotFrame = PlotPanel:WaitForChild("PlotUpgradedFrame", 15) :: Frame?
	if not PlotFrame then return end

	local MainButton = PlotFrame:WaitForChild("UpgradedButton") :: TextButton
	local MainTitle = PlotFrame:WaitForChild("Title") :: TextLabel
	local MainLevels = PlotFrame:WaitForChild("Levels") :: TextLabel

	local TreadmillUpgradePart = Plot:WaitForChild("TreadmillUpgradePart", 15) :: BasePart?
	if not TreadmillUpgradePart then return end

	local TreadmillPanel = TreadmillUpgradePart:WaitForChild("TreadmillUpgradePanel", 15) :: SurfaceGui?
	if not TreadmillPanel then return end

	local TreadmillFrame = TreadmillPanel:WaitForChild("TreadmillUpgradedFrame", 15) :: Frame?
	if not TreadmillFrame then return end

	local TreadmillButton = TreadmillFrame:WaitForChild("UpgradedButton") :: TextButton
	local TreadmillTitle = TreadmillFrame:WaitForChild("Title") :: TextLabel
	local TreadmillLevels = TreadmillFrame:WaitForChild("Levels") :: TextLabel

	local function Update()
		local isOwner = Plot:GetAttribute("OwnerUserId") == Player.UserId
		if not isOwner then
			MainButton.Active = false
			TreadmillButton.Active = false
			return
		end

		UpdateMainPanel(Plot, MainButton, MainTitle, MainLevels)
		UpdateTreadmillPanel(Plot, TreadmillButton, TreadmillTitle, TreadmillLevels)
	end

	table.insert(updateCallbacks, Update)

	MainButton.Activated:Connect(function()
		if Plot:GetAttribute("OwnerUserId") ~= Player.UserId then return end
		PurchaseRemote:FireServer(Plot, "Main")
	end)

	local function onTreadmillUpgrade()
		if Plot:GetAttribute("OwnerUserId") ~= Player.UserId then return end
		TweenService:Create(TreadmillButton, TweenInfo.new(0.08), { Size = UDim2.new(1, -24, 0, 48) }):Play()
		task.delay(0.1, function()
			TweenService:Create(TreadmillButton, TweenInfo.new(0.08), { Size = UDim2.new(1, -16, 0, 54) }):Play()
		end)
		PurchaseRemote:FireServer(Plot, "Treadmill")
	end

	TreadmillButton.Activated:Connect(onTreadmillUpgrade)

	local panelFront = TreadmillUpgradePart:FindFirstChild("TreadmillUpgradePanel_Front") :: SurfaceGui?
	local btnFront = panelFront and panelFront:FindFirstChild("UpgradedButton", true) :: TextButton?
	if btnFront then
		btnFront.Activated:Connect(onTreadmillUpgrade)
	end

	Plot:GetAttributeChangedSignal("OwnerUserId"):Connect(Update)
	Plot:GetAttributeChangedSignal("TreadmillLevel"):Connect(Update)
	Plot:GetAttributeChangedSignal("PlotLevel"):Connect(Update)

	Update()
end

-- Listener reactivo persistente de Dinero del jugador
task.spawn(function()
	local function bindMoney(moneyVal: NumberValue)
		moneyVal:GetPropertyChangedSignal("Value"):Connect(function()
			for _, cb in ipairs(updateCallbacks) do
				cb()
			end
		end)
		for _, cb in ipairs(updateCallbacks) do
			cb()
		end
	end

	local leaderstats = Player:WaitForChild("leaderstats", 20)
	if leaderstats then
		local money = leaderstats:FindFirstChild("Money") :: NumberValue?
		if money then
			bindMoney(money)
		else
			leaderstats.ChildAdded:Connect(function(ch)
				if ch.Name == "Money" and ch:IsA("NumberValue") then
					bindMoney(ch)
				end
			end)
		end
	end
end)

for _, Plot in ipairs(PlotsFolder:GetChildren()) do
	task.spawn(ConnectPlot, Plot)
end

PlotsFolder.ChildAdded:Connect(function(Plot)
	task.spawn(ConnectPlot, Plot)
end)
