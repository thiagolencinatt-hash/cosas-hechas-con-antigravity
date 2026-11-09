local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local petsGui = playerGui:WaitForChild("Pets")

local frameNames = {"EggFrame", "Index", "PetsFrame", "SellFrame", "TrailsFrame"}

local frames = {}
local scales = {}
local originalSizes = {}
local tweens = {}
local suppress = {}

local OPEN_TWEEN_INFO = TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local CLOSE_TWEEN_INFO = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

for _, name in ipairs(frameNames) do
	local frame = petsGui:WaitForChild(name, 3) :: Frame?
	if frame and frame:IsA("GuiObject") then
		frames[name] = frame
		originalSizes[name] = frame.Size

		local scale = frame:FindFirstChildOfClass("UIScale")
		if not scale then
			scale = Instance.new("UIScale")
			scale.Parent = frame
		end
		scale.Scale = 1
		scales[name] = scale
	end
end

local function closeFrame(name)
	local frame = frames[name]
	local scale = scales[name]

	if not frame.Visible then
		return
	end

	if tweens[name] then
		tweens[name]:Cancel()
	end

	local tween = TweenService:Create(scale, CLOSE_TWEEN_INFO, {Scale = 0})
	tweens[name] = tween

	tween.Completed:Connect(function(playbackState)
		if playbackState == Enum.PlaybackState.Completed then
			suppress[name] = true
			frame.Visible = false
			suppress[name] = false
		end
	end)

	tween:Play()
end

local function openFrame(name)
	local scale = scales[name]

	if tweens[name] then
		tweens[name]:Cancel()
		tweens[name] = nil
	end

	scale.Scale = 0

	local tween = TweenService:Create(scale, OPEN_TWEEN_INFO, {Scale = 1})
	tweens[name] = tween
	tween:Play()

	for _, otherName in ipairs(frameNames) do
		if otherName ~= name then
			closeFrame(otherName)
		end
	end
end

for _, name in ipairs(frameNames) do
	local frame = frames[name]
	if frame then
		frame:GetPropertyChangedSignal("Visible"):Connect(function()
			if suppress[name] then
				return
			end

			if frame.Visible then
				openFrame(name)
			end
		end)
	end
end
