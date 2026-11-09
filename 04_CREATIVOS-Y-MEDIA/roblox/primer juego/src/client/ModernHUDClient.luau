--!strict
-- ModernHUDClient.luau
-- Drives all real-time HUD counters: Health Bar, WalkSpeed, Money, Loot Status, Police Pursuit Alert, and Side Menu Buttons.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local MoneyGui = script.Parent :: ScreenGui
local MoneyFrame = MoneyGui:WaitForChild("MoneyFrame") :: Frame
local MoneyText = MoneyFrame:WaitForChild("MoneyText") :: TextLabel

local SpeedFrame = MoneyGui:WaitForChild("SpeedFrame") :: Frame
local SpeedText = SpeedFrame:WaitForChild("SpeedText") :: TextLabel

local HealthFrame = MoneyGui:WaitForChild("HealthFrame") :: Frame
local HeartIcon = HealthFrame:WaitForChild("HeartIcon") :: TextLabel
local BarBg = HealthFrame:WaitForChild("BarBg") :: Frame
local BarFill = BarBg:WaitForChild("Fill") :: Frame
local HpText = BarBg:WaitForChild("HpText") :: TextLabel

local LootStatusFrame = MoneyGui:WaitForChild("LootStatusFrame") :: Frame
local LootLabel = LootStatusFrame:WaitForChild("LootLabel") :: TextLabel

local PoliceAlertBanner = MoneyGui:WaitForChild("PoliceAlertBanner") :: Frame
local AlertText = PoliceAlertBanner:WaitForChild("AlertText") :: TextLabel

local LeftMenuButtons = MoneyGui:WaitForChild("LeftMenuButtons") :: Frame
local ShopBtn = LeftMenuButtons:WaitForChild("ShopBtn") :: TextButton
local IndexBtn = LeftMenuButtons:WaitForChild("IndexBtn") :: TextButton
local SlowModeBtn = LeftMenuButtons:WaitForChild("SlowModeBtn") :: TextButton

-- Initial visibility
LootStatusFrame.Visible = false
PoliceAlertBanner.Visible = false

-- Number formatting
local function formatNumber(n: number): string
	local formatted = tostring(math.floor(n))
	while true do
		local result, count = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
		formatted = result
		if count == 0 then break end
	end
	return formatted
end

-- ==================== 1. HEALTH BAR ====================
local function setupHealth(character: Model)
	local humanoid = character:WaitForChild("Humanoid") :: Humanoid

	local function updateHealth()
		local hp = math.max(0, humanoid.Health)
		local maxHp = math.max(1, humanoid.MaxHealth)
		local ratio = math.clamp(hp / maxHp, 0, 1)

		local fillTween = TweenService:Create(BarFill, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(ratio, 0, 1, 0)
		})
		fillTween:Play()

		if ratio > 0.5 then
			BarFill.BackgroundColor3 = Color3.fromRGB(60, 220, 90)
		elseif ratio > 0.25 then
			BarFill.BackgroundColor3 = Color3.fromRGB(240, 180, 40)
		else
			BarFill.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
		end

		HpText.Text = string.format("%d / %d HP", math.floor(hp), math.floor(maxHp))
	end

	humanoid.HealthChanged:Connect(updateHealth)
	humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(updateHealth)
	updateHealth()
end

if Player.Character then
	setupHealth(Player.Character)
end
Player.CharacterAdded:Connect(setupHealth)

-- Heart pulsing animation
task.spawn(function()
	while true do
		local pulseUp = TweenService:Create(HeartIcon, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			TextSize = 22
		})
		pulseUp:Play()
		task.wait(0.4)
		local pulseDown = TweenService:Create(HeartIcon, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
			TextSize = 18
		})
		pulseDown:Play()
		task.wait(0.4)
	end
end)

-- ==================== 2. WALKSPEED ====================
local isSlowMode = false
local defaultWalkSpeed = 24

local function setupSpeed(character: Model)
	local humanoid = character:WaitForChild("Humanoid") :: Humanoid

	local function updateSpeed()
		local ws = humanoid.WalkSpeed
		SpeedText.RichText = true
		SpeedText.Text = string.format("<i>%d (x1)</i>", math.floor(ws))
	end

	humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(updateSpeed)
	updateSpeed()
end

if Player.Character then
	setupSpeed(Player.Character)
end
Player.CharacterAdded:Connect(setupSpeed)

-- ==================== 3. MONEY ====================
task.spawn(function()
	local leaderstats = Player:WaitForChild("leaderstats", 15) :: Folder?
	if not leaderstats then return end
	local money = leaderstats:WaitForChild("Money", 10) :: IntValue?
	if not money then return end

	local function updateMoney()
		MoneyText.RichText = true
		MoneyText.Text = string.format("<i>$%s</i>", formatNumber(money.Value))
	end

	money:GetPropertyChangedSignal("Value"):Connect(updateMoney)
	updateMoney()
end)

-- ==================== 4. LOOT STATUS & POLICE PURSUIT ====================
local sirenRunning = false
local currentStealLight: PointLight? = nil
local currentStealParticles: ParticleEmitter? = nil

local function updateStealVisuals(character: Model?, isStealing: boolean)
	local hrp = character and character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not hrp then return end

	if isStealing then
		if not currentStealLight then
			local light = Instance.new("PointLight")
			light.Name = "PoliceStrobeLight"
			light.Range = 18
			light.Brightness = 3.5
			light.Color = Color3.fromRGB(255, 30, 30)
			light.Parent = hrp
			currentStealLight = light

			task.spawn(function()
				while currentStealLight and currentStealLight.Parent do
					light.Color = Color3.fromRGB(255, 30, 30)
					task.wait(0.2)
					if not currentStealLight or not currentStealLight.Parent then break end
					light.Color = Color3.fromRGB(30, 100, 255)
					task.wait(0.2)
				end
			end)
		end

		if not currentStealParticles then
			local trail = Instance.new("ParticleEmitter")
			trail.Name = "EscapeDust"
			trail.Color = ColorSequence.new(Color3.fromRGB(255, 230, 150), Color3.fromRGB(200, 200, 200))
			trail.Size = NumberSequence.new(0.6, 0)
			trail.Speed = NumberRange.new(3, 7)
			trail.Rate = 30
			trail.Lifetime = NumberRange.new(0.3, 0.6)
			trail.Parent = hrp
			currentStealParticles = trail
		end
	else
		if currentStealLight then
			currentStealLight:Destroy()
			currentStealLight = nil
		end
		if currentStealParticles then
			currentStealParticles:Destroy()
			currentStealParticles = nil
		end
	end
end

local function startPoliceSiren()
	if sirenRunning then return end
	sirenRunning = true
	PoliceAlertBanner.Visible = true

	task.spawn(function()
		local stroke = PoliceAlertBanner:FindFirstChildOfClass("UIStroke")
		while sirenRunning and PoliceAlertBanner.Visible do
			-- Red Flash
			PoliceAlertBanner.BackgroundColor3 = Color3.fromRGB(220, 30, 30)
			if stroke then stroke.Color = Color3.fromRGB(255, 230, 0) end
			task.wait(0.28)
			-- Blue Flash
			PoliceAlertBanner.BackgroundColor3 = Color3.fromRGB(20, 80, 240)
			if stroke then stroke.Color = Color3.fromRGB(255, 255, 255) end
			task.wait(0.28)
		end
	end)
end

local function stopPoliceSiren()
	sirenRunning = false
	PoliceAlertBanner.Visible = false
end

local carryAnimConnection: RBXScriptConnection? = nil

local function updateCarryAnimation(character: Model?, isStealing: boolean)
	if carryAnimConnection then
		carryAnimConnection:Disconnect()
		carryAnimConnection = nil
	end

	if not isStealing or not character then return end

	carryAnimConnection = RunService.Stepped:Connect(function()
		if not character or not character.Parent then
			if carryAnimConnection then
				carryAnimConnection:Disconnect()
				carryAnimConnection = nil
			end
			return
		end

		-- R15 support
		local rightUpperArm = character:FindFirstChild("RightUpperArm")
		local leftUpperArm = character:FindFirstChild("LeftUpperArm")
		local rightShoulder = rightUpperArm and rightUpperArm:FindFirstChild("RightShoulder") :: Motor6D?
		local leftShoulder = leftUpperArm and leftUpperArm:FindFirstChild("LeftShoulder") :: Motor6D?

		if rightShoulder and leftShoulder then
			rightShoulder.Transform = CFrame.Angles(math.rad(155), math.rad(-15), math.rad(25))
			leftShoulder.Transform = CFrame.Angles(math.rad(155), math.rad(15), math.rad(-25))
			return
		end

		-- R6 support
		local torso = character:FindFirstChild("Torso")
		if torso then
			local r6Right = torso:FindFirstChild("Right Shoulder") :: Motor6D?
			local r6Left = torso:FindFirstChild("Left Shoulder") :: Motor6D?
			if r6Right and r6Left then
				r6Right.Transform = CFrame.Angles(math.rad(155), math.rad(-15), math.rad(25))
				r6Left.Transform = CFrame.Angles(math.rad(155), math.rad(15), math.rad(-25))
			end
		end
	end)
end

local function updateStealingStatus()
	local isStealing = Player:GetAttribute("IsStealing") == true
	local char = Player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
	local inSafeZone = hrp and hrp.Position.Z <= -645

	if isStealing then
		LootStatusFrame.Visible = true
		updateCarryAnimation(Player.Character, true)
		if inSafeZone then
			stopPoliceSiren()
			updateStealVisuals(Player.Character, false)
			LootLabel.Text = "🛡️ ZONA SEGURA • Colocá la caja en tu base"
		else
			local lootValue = Player:GetAttribute("LootValue")
			if typeof(lootValue) == "number" and lootValue > 0 then
				LootLabel.Text = string.format("📦 BOTÍN $%s • ¡Huye a Base!", formatNumber(lootValue))
			else
				LootLabel.Text = "📦 BOTÍN EN MANO • ¡Huye a Base!"
			end
			startPoliceSiren()
			updateStealVisuals(Player.Character, true)
		end
	else
		LootStatusFrame.Visible = false
		stopPoliceSiren()
		updateStealVisuals(Player.Character, false)
		updateCarryAnimation(Player.Character, false)
	end
end

-- Monitor continuo en tiempo real: el instante exacto en que se cruza a la zona verde cesa toda alerta policial
RunService.Heartbeat:Connect(function()
	local isStealing = Player:GetAttribute("IsStealing") == true
	local char = Player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not hrp then return end

	local inSafeZone = hrp.Position.Z <= -645
	if inSafeZone then
		stopPoliceSiren()
		if currentStealLight then
			currentStealLight:Destroy()
			currentStealLight = nil
		end
		if isStealing then
			LootStatusFrame.Visible = true
			local lootValue = Player:GetAttribute("LootValue")
			if typeof(lootValue) == "number" and lootValue > 0 then
				LootLabel.Text = string.format("🛡️ ZONA SEGURA • Botín $%s asegurado", formatNumber(lootValue))
			else
				LootLabel.Text = "🛡️ ZONA SEGURA • Dejá la caja en tu base"
			end
		end
	elseif isStealing and not sirenRunning then
		startPoliceSiren()
		updateStealVisuals(char, true)
	end
end)

Player.CharacterRemoving:Connect(function()
	if carryAnimConnection then
		carryAnimConnection:Disconnect()
		carryAnimConnection = nil
	end
end)

Player:GetAttributeChangedSignal("IsStealing"):Connect(updateStealingStatus)
updateStealingStatus()

-- ==================== 5. MENU BUTTONS ====================
ShopBtn.MouseButton1Click:Connect(function()
	if typeof(_G.ToggleShop) == "function" then
		_G.ToggleShop("Armas")
		return
	end
	local frame = PlayerGui:FindFirstChild("OpeningToolsFrame", true) :: Frame?
	if frame then
		frame.Visible = not frame.Visible
		if frame.Visible then
			local sc = frame:FindFirstChildOfClass("UIScale")
			if sc then sc.Scale = 1 end
		end
	end
end)

IndexBtn.MouseButton1Click:Connect(function()
	local petsGui = PlayerGui:FindFirstChild("Pets")
	if petsGui then
		local indexFrame = petsGui:FindFirstChild("Index")
		if indexFrame then
			indexFrame.Visible = not indexFrame.Visible
		end
	end
end)

SlowModeBtn.MouseButton1Click:Connect(function()
	local char = Player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not hum then return end

	isSlowMode = not isSlowMode
	if isSlowMode then
		hum.WalkSpeed = 16
		SlowModeBtn.BackgroundColor3 = Color3.fromRGB(80, 200, 100)
		SlowModeBtn.Text = "Modo lento: ON"
	else
		hum.WalkSpeed = defaultWalkSpeed
		SlowModeBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
		SlowModeBtn.Text = "Modo lento: OFF"
	end
end)
