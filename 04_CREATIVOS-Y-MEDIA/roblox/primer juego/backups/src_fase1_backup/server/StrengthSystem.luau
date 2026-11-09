--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local Map = workspace:WaitForChild("Map")
local PlotsFolder = Map:WaitForChild("Plots")

local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
if not Remotes then
	Remotes = Instance.new("Folder")
	Remotes.Name = "Remotes"
	Remotes.Parent = ReplicatedStorage
end

local NotifyRemote = Remotes:FindFirstChild("Notify")

local function Notify(Player: Player, Text: string, Color: Color3?, Duration: number?)
	if not Player or not NotifyRemote then return end
	(NotifyRemote :: RemoteEvent):FireClient(Player, Text, Color or Color3.fromRGB(255, 255, 255), Duration or 2)
end

-- Strength Levels Configuration
local STRENGTH_LEVELS = {
	[1] = { Gain = 1, UpgradeCost = 1500, Title = "Banco Novato" },
	[2] = { Gain = 2, UpgradeCost = 8000, Title = "Banco de Hierro" },
	[3] = { Gain = 4, UpgradeCost = 35000, Title = "Banco Olímpico" },
	[4] = { Gain = 8, UpgradeCost = 150000, Title = "Banco Titánico" },
	[5] = { Gain = 16, UpgradeCost = 0, Title = "Banco Legendario" }, -- Max Level
}

local MAX_STRENGTH_LEVEL = 5
local COOLDOWN_WORKOUT = 0.45
local MAX_WORKOUT_DISTANCE = 14

local PlayerCooldowns: { [Player]: number } = {}
local UpgradeDebounces: { [Player]: boolean } = {}

local function OwnsPlot(Player: Player, Plot: Instance): boolean
	return Plot:GetAttribute("OwnerUserId") == Player.UserId
end

local function GetLeaderstat(Player: Player, StatName: string): ValueBase?
	local Leaderstats = Player:FindFirstChild("leaderstats")
	if not Leaderstats then return nil end
	return Leaderstats:FindFirstChild(StatName)
end

-- Floating "+X 💪" effect above player
local function CreateFloatingFeedback(Character: Model, Text: string, Color: Color3)
	local Head = Character:FindFirstChild("Head") or Character:FindFirstChild("HumanoidRootPart")
	if not Head or not Head:IsA("BasePart") then return end

	local Part = Instance.new("Part")
	Part.Name = "StrengthFeedback"
	Part.Size = Vector3.new(0.1, 0.1, 0.1)
	Part.Transparency = 1
	Part.CanCollide = false
	Part.Anchored = true
	Part.CFrame = Head.CFrame + Vector3.new(math.random(-10, 10) * 0.1, 2.5, math.random(-10, 10) * 0.1)
	Part.Parent = workspace

	local BB = Instance.new("BillboardGui")
	BB.Size = UDim2.new(0, 140, 0, 45)
	BB.StudsOffset = Vector3.new(0, 0, 0)
	BB.AlwaysOnTop = true
	BB.Parent = Part

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1, 0, 1, 0)
	Label.BackgroundTransparency = 1
	Label.Text = Text
	Label.TextColor3 = Color
	Label.Font = Enum.Font.FredokaOne
	Label.TextScaled = true
	Label.TextStrokeTransparency = 0.2
	Label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	Label.Parent = BB

	local Tween = TweenService:Create(Part, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		CFrame = Part.CFrame + Vector3.new(0, 3.5, 0)
	})
	local TextFade = TweenService:Create(Label, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		TextTransparency = 1,
		TextStrokeTransparency = 1
	})

	Tween:Play()
	TextFade:Play()
	Debris:AddItem(Part, 0.75)
end

local function UpdatePlotStrengthDisplay(Plot: Instance)
	local Level = (Plot:GetAttribute("StrengthLevel") :: number?) or 1
	local LevelData = STRENGTH_LEVELS[Level] or STRENGTH_LEVELS[1]

	-- Update StrengthStation Billboard
	local Station = Plot:FindFirstChild("StrengthStation")
	if Station then
		local Bar = Station:FindFirstChild("Barbell")
		local BB = Bar and Bar:FindFirstChild("StationBillboard")
		if BB then
			local SubLabel = BB:FindFirstChild("SubLabel") :: TextLabel?
			if SubLabel then
				SubLabel.Text = string.format("Nivel %d • +%d Fuerza/rep", Level, LevelData.Gain)
			end
		end
	end

	-- Update StrengthUpgradePart Billboard & Prompt
	local UpgPart = Plot:FindFirstChild("StrengthUpgradePart")
	if UpgPart then
		local UpgBB = UpgPart:FindFirstChild("UpgradeBillboard")
		local Prompt = UpgPart:FindFirstChild("UpgradePrompt") :: ProximityPrompt?

		if Level >= MAX_STRENGTH_LEVEL then
			if UpgBB then
				local UpgCost = UpgBB:FindFirstChild("UpgradeCost") :: TextLabel?
				if UpgCost then
					UpgCost.Text = "¡NIVEL MÁXIMO!"
					UpgCost.TextColor3 = Color3.fromRGB(255, 215, 0)
				end
			end
			if Prompt then
				Prompt.Enabled = false
			end
		else
			local NextData = STRENGTH_LEVELS[Level + 1]
			local CostStr = string.format("$%s", string.gsub(string.format("%d", NextData.UpgradeCost), "^(-?%d+)(%d%d%d)", "%1,%2"))
			if UpgBB then
				local UpgCost = UpgBB:FindFirstChild("UpgradeCost") :: TextLabel?
				if UpgCost then
					UpgCost.Text = string.format("Nivel %d: %s (+%d/rep)", Level + 1, CostStr, NextData.Gain)
					UpgCost.TextColor3 = Color3.fromRGB(120, 255, 120)
				end
			end
			if Prompt then
				Prompt.Enabled = true
				Prompt.ActionText = string.format("Mejorar a Nivel %d (%s)", Level + 1, CostStr)
			end
		end
	end
end

local function HandleWorkout(Player: Player, Plot: Instance)
	local Now = os.clock()
	local LastTime = PlayerCooldowns[Player] or 0
	if Now - LastTime < COOLDOWN_WORKOUT then return end
	PlayerCooldowns[Player] = Now

	if not OwnsPlot(Player, Plot) then
		Notify(Player, "¡Esta estación de pesas no pertenece a tu base!", Color3.fromRGB(255, 100, 100), 2)
		return
	end

	local Character = Player.Character
	local Root = Character and Character:FindFirstChild("HumanoidRootPart") :: BasePart?
	local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
	if not Character or not Root or not Humanoid or Humanoid.Health <= 0 then return end

	local Station = Plot:FindFirstChild("StrengthStation")
	local Mat = Station and Station:FindFirstChild("Mat") :: BasePart?
	if not Mat then return end

	-- Distance validation
	if (Root.Position - Mat.Position).Magnitude > MAX_WORKOUT_DISTANCE then
		return
	end

	local StrengthStat = GetLeaderstat(Player, "Strength") :: IntValue?
	if not StrengthStat then return end

	local Level = (Player:GetAttribute("StrengthLevel") :: number?) or 1
	local LevelData = STRENGTH_LEVELS[Level] or STRENGTH_LEVELS[1]
	local Gain = LevelData.Gain

	StrengthStat.Value += Gain

	-- Visual Feedback
	CreateFloatingFeedback(Character, string.format("+%d 💪", Gain), Color3.fromRGB(255, 215, 0))

	-- Lift animation / slight character pulse
	local OldOffset = Humanoid.CameraOffset
	Humanoid.CameraOffset = Vector3.new(0, 0.4, 0)
	task.delay(0.12, function()
		if Humanoid and Humanoid.Parent then
			Humanoid.CameraOffset = OldOffset
		end
	end)
end

local function HandleUpgrade(Player: Player, Plot: Instance)
	if UpgradeDebounces[Player] then return end
	UpgradeDebounces[Player] = true

	task.delay(0.5, function()
		UpgradeDebounces[Player] = nil
	end)

	if not OwnsPlot(Player, Plot) then
		Notify(Player, "¡Solo el dueño de la base puede mejorar esta estación!", Color3.fromRGB(255, 100, 100), 2)
		return
	end

	local Character = Player.Character
	local Root = Character and Character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not Root then return end

	local UpgPart = Plot:FindFirstChild("StrengthUpgradePart") :: BasePart?
	if not UpgPart or (Root.Position - UpgPart.Position).Magnitude > MAX_WORKOUT_DISTANCE then
		return
	end

	local CurrentLevel = (Player:GetAttribute("StrengthLevel") :: number?) or 1
	if CurrentLevel >= MAX_STRENGTH_LEVEL then
		Notify(Player, "¡Tu banco de pesas ya está al nivel máximo!", Color3.fromRGB(255, 215, 0), 2)
		return
	end

	local NextData = STRENGTH_LEVELS[CurrentLevel + 1]
	if not NextData then return end

	local MoneyStat = GetLeaderstat(Player, "Money") :: IntValue?
	if not MoneyStat or MoneyStat.Value < NextData.UpgradeCost then
		Notify(Player, string.format("¡Dinero insuficiente! Cuesta $%d", NextData.UpgradeCost), Color3.fromRGB(255, 80, 80), 2.5)
		return
	end

	-- Deduct cost and upgrade
	MoneyStat.Value -= NextData.UpgradeCost
	local NewLevel = CurrentLevel + 1
	Player:SetAttribute("StrengthLevel", NewLevel)
	Plot:SetAttribute("StrengthLevel", NewLevel)

	UpdatePlotStrengthDisplay(Plot)
	Notify(Player, string.format("¡Pesas mejoradas a Nivel %d (%s)! +%d Fuerza/rep", NewLevel, NextData.Title, NextData.Gain), Color3.fromRGB(100, 255, 120), 3)
end

local function SetupPlot(Plot: Instance)
	local Station = Plot:WaitForChild("StrengthStation", 5)
	local PromptPart = Station and Station:WaitForChild("PromptPart", 5)
	local WorkoutPrompt = PromptPart and PromptPart:WaitForChild("WorkoutPrompt", 5) :: ProximityPrompt?

	if WorkoutPrompt then
		WorkoutPrompt.Triggered:Connect(function(Player: Player)
			HandleWorkout(Player, Plot)
		end)
	end

	local UpgPart = Plot:WaitForChild("StrengthUpgradePart", 5)
	local UpgPrompt = UpgPart and UpgPart:WaitForChild("UpgradePrompt", 5) :: ProximityPrompt?

	if UpgPrompt then
		UpgPrompt.Triggered:Connect(function(Player: Player)
			HandleUpgrade(Player, Plot)
		end)
	end

	Plot:GetAttributeChangedSignal("OwnerUserId"):Connect(function()
		local OwnerId = Plot:GetAttribute("OwnerUserId") :: number?
		if OwnerId then
			local Player = Players:GetPlayerByUserId(OwnerId)
			if Player then
				local PLevel = (Player:GetAttribute("StrengthLevel") :: number?) or 1
				Plot:SetAttribute("StrengthLevel", PLevel)
			end
		end
		UpdatePlotStrengthDisplay(Plot)
	end)

	Plot:GetAttributeChangedSignal("StrengthLevel"):Connect(function()
		UpdatePlotStrengthDisplay(Plot)
	end)

	UpdatePlotStrengthDisplay(Plot)
end

for _, Plot in ipairs(PlotsFolder:GetChildren()) do
	task.spawn(SetupPlot, Plot)
end

PlotsFolder.ChildAdded:Connect(function(Plot)
	task.spawn(SetupPlot, Plot)
end)

Players.PlayerRemoving:Connect(function(Player)
	PlayerCooldowns[Player] = nil
	UpgradeDebounces[Player] = nil
end)
