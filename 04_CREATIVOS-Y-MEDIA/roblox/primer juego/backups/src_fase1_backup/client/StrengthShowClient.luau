local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local MoneyGui = script.Parent
local StrengthFrame = MoneyGui:WaitForChild("StrengthFrame")
local StrengthText = StrengthFrame:WaitForChild("StrengthText")

local Leaderstats = Player:WaitForChild("leaderstats")
local Strength = Leaderstats:WaitForChild("Strength")

local PreviousStrength = Strength.Value
local BounceGeneration = 0

local BounceScale = StrengthFrame:FindFirstChild("BounceScale")
if not BounceScale then
	BounceScale = Instance.new("UIScale")
	BounceScale.Name = "BounceScale"
	BounceScale.Scale = 1
	BounceScale.Parent = StrengthFrame
end

local GrowInfo = TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local ShrinkInfo = TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local NormalInfo = TweenInfo.new(0.06, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

local function FormatNumber(Number)
	local Formatted = tostring(math.floor(Number))
	while true do
		local Result, Count = string.gsub(Formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
		Formatted = Result
		if Count == 0 then break end
	end
	return Formatted
end

local function PlayBounce()
	BounceGeneration += 1
	local ThisGeneration = BounceGeneration

	task.spawn(function()
		local GrowTween = TweenService:Create(BounceScale, GrowInfo, { Scale = 1.18 })
		GrowTween:Play()
		GrowTween.Completed:Wait()

		if ThisGeneration ~= BounceGeneration then return end

		local ShrinkTween = TweenService:Create(BounceScale, ShrinkInfo, { Scale = 0.92 })
		ShrinkTween:Play()
		ShrinkTween.Completed:Wait()

		if ThisGeneration ~= BounceGeneration then return end

		local NormalTween = TweenService:Create(BounceScale, NormalInfo, { Scale = 1 })
		NormalTween:Play()
		NormalTween.Completed:Wait()

		if ThisGeneration == BounceGeneration then
			BounceScale.Scale = 1
		end
	end)
end

local function UpdateStrength()
	local CurrentStrength = Strength.Value
	local Difference = CurrentStrength - PreviousStrength

	StrengthText.Text = FormatNumber(CurrentStrength)
	PreviousStrength = CurrentStrength

	if Player:GetAttribute("DataLoaded") ~= true then
		return
	end

	if Difference > 0 then
		PlayBounce()
	end
end

Strength:GetPropertyChangedSignal("Value"):Connect(UpdateStrength)
StrengthText.Text = FormatNumber(Strength.Value)
