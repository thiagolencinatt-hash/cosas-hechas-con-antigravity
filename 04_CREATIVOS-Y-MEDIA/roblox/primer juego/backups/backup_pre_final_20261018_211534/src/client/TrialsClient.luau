--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local PetsGui = script.Parent
local Frame = PetsGui:WaitForChild("TrialsFrame")
local CloseBtn = Frame:WaitForChild("Title"):WaitForChild("CloseBtn")
local Scroll = Frame:WaitForChild("TrialsScroll")
local Scale = Frame:FindFirstChildOfClass("UIScale") or Instance.new("UIScale", Frame)

local RaceHUD = PetsGui:WaitForChild("TrialHUD")
local TimerLabel = RaceHUD:WaitForChild("TimerLabel") :: TextLabel
local ProgressLabel = RaceHUD:WaitForChild("ProgressLabel") :: TextLabel
local CancelBtn = RaceHUD:WaitForChild("CancelBtn") :: TextButton

local Modules = ReplicatedStorage:WaitForChild("Modules")
local BiomesConfig = require(Modules:WaitForChild("BiomesConfig"))

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local TrialActionRemote = Remotes:WaitForChild("TrialAction") :: RemoteEvent
local TrialProgressRemote = Remotes:WaitForChild("TrialProgress") :: RemoteEvent

local HUD = PetsGui:WaitForChild("HUD")
local RightHUD = HUD:WaitForChild("Right")
local TrialsBtn = RightHUD:WaitForChild("TrialsButton") :: GuiButton

local isOpen = false
local activeRace = false
local raceStartTime = 0
local raceTargetTime = 25
local totalCheckpoints = 4
local currentCheckpoint = 0
local timerConn: RBXScriptConnection? = nil

local function setOpen(open: boolean)
	isOpen = open
	if open then
		Frame.Visible = true
		Scale.Scale = 0
		local tw = TweenService:Create(Scale, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1})
		tw:Play()
	else
		local tw = TweenService:Create(Scale, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Scale = 0})
		tw:Play()
		tw.Completed:Connect(function()
			if not isOpen then Frame.Visible = false end
		end)
	end
end

TrialsBtn.MouseButton1Click:Connect(function()
	setOpen(not isOpen)
end)

CloseBtn.MouseButton1Click:Connect(function()
	setOpen(false)
end)

CancelBtn.MouseButton1Click:Connect(function()
	TrialActionRemote:FireServer("Cancel", nil)
end)

local function populate()
	for _, child in ipairs(Scroll:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end

	for i, biome in ipairs(BiomesConfig.Biomes) do
		local trial = biome.Trial
		if trial then
			local card = Instance.new("Frame")
			card.Name = "TrialCard_" .. i
			card.Size = UDim2.new(1, 0, 0, 95)
			card.BackgroundColor3 = Color3.fromRGB(28, 34, 48)
			card.LayoutOrder = i
			card.Parent = Scroll

			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0, 10)
			corner.Parent = card

			local stroke = Instance.new("UIStroke")
			stroke.Color = biome.Color
			stroke.Thickness = 1.5
			stroke.Parent = card

			local titleLbl = Instance.new("TextLabel")
			titleLbl.Size = UDim2.new(0.65, 0, 0.35, 0)
			titleLbl.Position = UDim2.new(0.04, 0, 0.1, 0)
			titleLbl.BackgroundTransparency = 1
			titleLbl.Text = string.format("🚩 %s (%s)", trial.Name, biome.Name)
			titleLbl.TextColor3 = biome.Color
			titleLbl.Font = Enum.Font.FredokaOne
			titleLbl.TextScaled = true
			titleLbl.TextXAlignment = Enum.TextXAlignment.Left
			titleLbl.Parent = card

			local detailsLbl = Instance.new("TextLabel")
			detailsLbl.Size = UDim2.new(0.65, 0, 0.45, 0)
			detailsLbl.Position = UDim2.new(0.04, 0, 0.48, 0)
			detailsLbl.BackgroundTransparency = 1
			detailsLbl.Text = string.format("Meta: %ds • %d Checkpoints • Recompensa: +$%d Monedas", trial.TargetTime, trial.Checkpoints, trial.RewardCoins)
			detailsLbl.TextColor3 = Color3.fromRGB(220, 230, 245)
			detailsLbl.Font = Enum.Font.Gotham
			detailsLbl.TextSize = 12
			detailsLbl.TextWrapped = true
			detailsLbl.TextXAlignment = Enum.TextXAlignment.Left
			detailsLbl.Parent = card

			local startBtn = Instance.new("TextButton")
			startBtn.Size = UDim2.new(0.24, 0, 0.5, 0)
			startBtn.Position = UDim2.new(0.72, 0, 0.25, 0)
			startBtn.BackgroundColor3 = (biome.Status == "Active") and Color3.fromRGB(240, 160, 40) or Color3.fromRGB(80, 85, 95)
			startBtn.Text = (biome.Status == "Active") and "INICIAR" or "PROTOTIPO"
			startBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			startBtn.Font = Enum.Font.GothamBold
			startBtn.TextScaled = true
			startBtn.Parent = card

			local bCorner = Instance.new("UICorner")
			bCorner.CornerRadius = UDim.new(0, 8)
			bCorner.Parent = startBtn

			if biome.Status == "Active" then
				startBtn.MouseButton1Click:Connect(function()
					setOpen(false)
					TrialActionRemote:FireServer("Start", biome.Id)
				end)
			end
		end
	end
end

populate()

TrialProgressRemote.OnClientEvent:Connect(function(event: string, data: any)
	if event == "Start" then
		activeRace = true
		raceStartTime = os.clock()
		raceTargetTime = data.TargetTime or 25
		totalCheckpoints = data.TotalCheckpoints or 4
		currentCheckpoint = 0

		RaceHUD.Visible = true
		ProgressLabel.Text = string.format("🚩 CHECKPOINTS: 0 / %d", totalCheckpoints)

		if timerConn then timerConn:Disconnect() end
		timerConn = RunService.RenderStepped:Connect(function()
			if activeRace then
				local elapsed = os.clock() - raceStartTime
				local remaining = math.max(0, raceTargetTime - elapsed)
				TimerLabel.Text = string.format("⏳ TIEMPO: %.1fs / %.1fs", elapsed, raceTargetTime)
				if remaining <= 0 then
					TimerLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
				else
					TimerLabel.TextColor3 = Color3.fromRGB(255, 230, 80)
				end
			end
		end)

	elseif event == "Update" then
		currentCheckpoint = data.CurrentCheckpoint or currentCheckpoint
		ProgressLabel.Text = string.format("🚩 CHECKPOINTS: %d / %d", currentCheckpoint, totalCheckpoints)

	elseif event == "Complete" or event == "Fail" or event == "Cancel" then
		activeRace = false
		if timerConn then
			timerConn:Disconnect()
			timerConn = nil
		end
		task.delay(1.5, function()
			if not activeRace then RaceHUD.Visible = false end
		end)
	end
end)
