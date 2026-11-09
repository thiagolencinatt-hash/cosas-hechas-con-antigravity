--!strict
-- WeaponCombatController.luau
-- Manages weapon swinging, click/tap targeting, real-time safe damage, and tactile hit feedback.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local DamageEggShellRemote = Remotes:WaitForChild("DamageEggShell") :: RemoteEvent

local Map = workspace:WaitForChild("Map")
local EggsFolder = Map:WaitForChild("Eggs")

local SWING_COOLDOWN = 0.25
local MAX_REACH = 20
local lastSwingTime = 0

-- Sounds
local SWING_SOUND_ID = "rbxassetid://6534947589"
local HIT_SOUND_ID = "rbxassetid://138090596"

local function playLocalSound(soundId: string, volume: number, pitchRange: {number}?)
	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Volume = volume or 0.6
	if pitchRange then
		sound.PlaybackSpeed = pitchRange[1] + math.random() * (pitchRange[2] - pitchRange[1])
	end
	sound.Parent = Camera
	sound:Play()
	Debris:AddItem(sound, 1.2)
end

-- Camera micro-shake on hit
local function playCameraShake(intensity: number)
	if not Camera then return end
	local origOffset = Vector3.zero
	local char = Player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not hum then return end

	local shakeOffset = Vector3.new(
		(math.random() - 0.5) * intensity,
		(math.random() - 0.5) * intensity,
		(math.random() - 0.5) * intensity
	)
	hum.CameraOffset = shakeOffset
	local tween = TweenService:Create(hum, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		CameraOffset = origOffset
	})
	tween:Play()
end

-- Procedural weapon swing
local function animateWeaponSwing(tool: Tool)
	local handle = tool:FindFirstChild("Handle") :: BasePart?
	if not handle then return end

	local originalGrip = tool.Grip
	local swingGrip = originalGrip * CFrame.Angles(math.rad(-45), math.rad(25), math.rad(-30)) * CFrame.new(0, -0.4, -0.5)
	tool.Grip = swingGrip

	task.delay(0.08, function()
		if tool and tool.Parent == Player.Character then
			local recoverTween = TweenService:Create(tool, TweenInfo.new(0.14, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {})
			tool.Grip = originalGrip
		end
	end)
end

-- Find safe under mouse or directly in front of player
local function findTargetSafe(): Model?
	local char = Player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not hrp then return nil end

	-- 1. Try Mouse raycast
	local mousePos = UserInputService:GetMouseLocation()
	local ray = Camera:ViewportPointToRay(mousePos.X, mousePos.Y)
	
	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Include
	rayParams.FilterDescendantsInstances = { EggsFolder }
	
	local hitResult = workspace:Raycast(ray.Origin, ray.Direction * 150, rayParams)
	if hitResult and hitResult.Instance then
		local model = hitResult.Instance:FindFirstAncestorOfClass("Model")
		while model and model.Parent ~= EggsFolder and model.Parent and model.Parent.Parent ~= EggsFolder do
			model = model.Parent :: Model?
		end
		if model and (hrp.Position - hitResult.Position).Magnitude <= MAX_REACH then
			return model
		end
	end

	-- 2. Fallback: Closest safe in front within reach
	local bestSafe: Model? = nil
	local bestDist = MAX_REACH

	for _, eggFolder in ipairs(EggsFolder:GetChildren()) do
		for _, child in ipairs(eggFolder:GetChildren()) do
			if child:IsA("Model") and (string.find(child.Name, "Egg") or string.find(child.Name, "Safe")) then
				local primary = child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart", true)
				if primary then
					local offset = primary.Position - hrp.Position
					local dist = offset.Magnitude
					if dist <= MAX_REACH then
						-- Check forward angle
						local dot = hrp.CFrame.LookVector:Dot(offset.Unit)
						if dot > 0.15 and dist < bestDist then
							bestDist = dist
							bestSafe = child
						end
					end
				end
			end
		end
	end

	return bestSafe
end

-- Trigger swing and hit
local function performAttack()
	local now = os.clock()
	if now - lastSwingTime < SWING_COOLDOWN then return end
	lastSwingTime = now

	local char = Player.Character
	if not char then return end

	local tool = char:FindFirstChildOfClass("Tool")
	if tool then
		animateWeaponSwing(tool)
	end

	playLocalSound(SWING_SOUND_ID, 0.45, {0.95, 1.1})

	local targetSafe = findTargetSafe()
	if targetSafe then
		playLocalSound(HIT_SOUND_ID, 0.7, {0.9, 1.15})
		playCameraShake(0.35)
		DamageEggShellRemote:FireServer(targetSafe)
	end
end

-- Connect tool activation
local function setupTool(tool: Tool)
	tool.Activated:Connect(function()
		performAttack()
	end)
end

local function onCharacterAdded(char: Model)
	char.ChildAdded:Connect(function(child)
		if child:IsA("Tool") then
			setupTool(child)
		end
	end)
	for _, child in ipairs(char:GetChildren()) do
		if child:IsA("Tool") then
			setupTool(child)
		end
	end
end

if Player.Character then
	onCharacterAdded(Player.Character)
end
Player.CharacterAdded:Connect(onCharacterAdded)

-- Also handle direct click/tap on screen
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		local char = Player.Character
		local tool = char and char:FindFirstChildOfClass("Tool")
		if tool then
			performAttack()
		end
	end
end)
