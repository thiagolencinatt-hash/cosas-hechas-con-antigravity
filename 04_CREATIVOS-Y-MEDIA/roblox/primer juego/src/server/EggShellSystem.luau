--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local Map = workspace:WaitForChild("Map")
local EggsFolder = Map:WaitForChild("Eggs")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local EggModule = require(Modules:WaitForChild("EggModule"))
local OpeningToolsConfig = require(Modules:WaitForChild("OpeningToolsConfig"))

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local NotifyRemote = Remotes:FindFirstChild("Notify") :: RemoteEvent?
local DamageRemote = Remotes:WaitForChild("DamageEggShell") :: RemoteEvent
local HitFX = Remotes:FindFirstChild("EggHitFX") :: RemoteEvent?
if not HitFX then
	HitFX = Instance.new("RemoteEvent")
	HitFX.Name = "EggHitFX"
	HitFX.Parent = Remotes
end

local function Notify(Player: Player, Text: string, Color: Color3?)
	if NotifyRemote then
		NotifyRemote:FireClient(Player, Text, Color or Color3.fromRGB(255, 255, 255), 2.5)
	end
end

local function GetPlayerEquippedWeapon(Player: Player): (string, number)
	local char = Player.Character
	if char then
		for _, item in ipairs(char:GetChildren()) do
			if item:IsA("Tool") and item:GetAttribute("IsWeapon") == true then
				local bp = item:GetAttribute("BreakPower") or 1
				return item.Name, tonumber(bp) or 1
			end
		end
	end
	local bp = Player:FindFirstChild("Backpack")
	if bp then
		for _, item in ipairs(bp:GetChildren()) do
			if item:IsA("Tool") and item:GetAttribute("IsWeapon") == true then
				local p = item:GetAttribute("BreakPower") or 1
				return item.Name, tonumber(p) or 1
			end
		end
	end
	return "Mazo de Madera", 1
end

local function CreateEggHealthBar(EggModel: Model, MaxHP: number)
	local primary = EggModel.PrimaryPart or EggModel:FindFirstChildWhichIsA("BasePart", true)
	if not primary then return end

	local existing = primary:FindFirstChild("ShellHealthGui")
	if existing then existing:Destroy() end

	local bb = Instance.new("BillboardGui")
	bb.Name = "ShellHealthGui"
	bb.Size = UDim2.new(0, 180, 0, 56)
	bb.StudsOffset = Vector3.new(0, 3.2, 0)
	bb.AlwaysOnTop = false
	bb.MaxDistance = 45
	bb.Parent = primary

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, 0, 0.40, 0)
	title.BackgroundTransparency = 1
	title.Text = "🛡️ BLINDAJE DE SEGURIDAD"
	title.TextColor3 = Color3.fromRGB(255, 230, 80)
	title.Font = Enum.Font.FredokaOne
	title.TextScaled = true
	title.Parent = bb

	local bg = Instance.new("Frame")
	bg.Name = "BarBackground"
	bg.Size = UDim2.new(0.9, 0, 0.32, 0)
	bg.Position = UDim2.new(0.05, 0, 0.44, 0)
	bg.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
	bg.BorderSizePixel = 0
	bg.Parent = bb

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = bg

	local fill = Instance.new("Frame")
	fill.Name = "BarFill"
	fill.Size = UDim2.new(1, 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(60, 220, 90)
	fill.BorderSizePixel = 0
	fill.Parent = bg

	local fCorner = Instance.new("UICorner")
	fCorner.CornerRadius = UDim.new(0, 6)
	fCorner.Parent = fill

	local hpLabel = Instance.new("TextLabel")
	hpLabel.Name = "HpLabel"
	hpLabel.Size = UDim2.new(1, 0, 1, 0)
	hpLabel.BackgroundTransparency = 1
	hpLabel.Text = string.format("%d / %d HP", MaxHP, MaxHP)
	hpLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	hpLabel.Font = Enum.Font.GothamBold
	hpLabel.TextSize = 10
	hpLabel.Parent = bg
end

local function UpdateHealthBar(EggModel: Model, CurrentHP: number, MaxHP: number)
	local primary = EggModel.PrimaryPart or EggModel:FindFirstChildWhichIsA("BasePart", true)
	if not primary then return end
	local bb = primary:FindFirstChild("ShellHealthGui") :: BillboardGui?
	if not bb then return end

	local bg = bb:FindFirstChild("BarBackground")
	local fill = bg and bg:FindFirstChild("BarFill") :: Frame?
	local lbl = bg and bg:FindFirstChild("HpLabel") :: TextLabel?

	local ratio = math.clamp(CurrentHP / math.max(MaxHP, 1), 0, 1)
	if fill then
		fill.Size = UDim2.new(ratio, 0, 1, 0)
		if ratio > 0.5 then
			fill.BackgroundColor3 = Color3.fromRGB(60, 220, 90)
		elseif ratio > 0.25 then
			fill.BackgroundColor3 = Color3.fromRGB(240, 180, 40)
		else
			fill.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
		end
	end
	if lbl then
		lbl.Text = string.format("%d / %d HP", math.max(0, CurrentHP), MaxHP)
	end
end

local function SetupEggShell(EggModel: Model, EggType: string)
	local existingMax = EggModel:GetAttribute("MaxShellHealth") :: number?
	local maxHP = existingMax or 5
	if not existingMax then
		local data = EggModule[EggType]
		maxHP = (data and (data.BaseHealth or data.ShellHealth)) or 5
		EggModel:SetAttribute("MaxShellHealth", maxHP)
		EggModel:SetAttribute("ShellHealth", maxHP)
		EggModel:SetAttribute("EggLocked", true)
		CreateEggHealthBar(EggModel, maxHP)
	else
		EggModel:SetAttribute("ShellHealth", maxHP)
		EggModel:SetAttribute("EggLocked", true)
		UpdateHealthBar(EggModel, maxHP, maxHP)
	end
end

local HitDebounces: { [Player]: number } = {}

local function HitEgg(Player: Player, EggModel: Model)
	if not EggModel or not EggModel.Parent then return end
	local primary = EggModel.PrimaryPart or EggModel:FindFirstChildWhichIsA("BasePart", true)
	if not primary then return end

	local char = Player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local dist = (hrp.Position - primary.Position).Magnitude
	if dist > 25 then return end

	local now = os.clock()
	local lastHit = HitDebounces[Player] or 0
	if now - lastHit < 0.20 then return end
	HitDebounces[Player] = now

	local weaponName, breakPower = GetPlayerEquippedWeapon(Player)
	local currentHP = (EggModel:GetAttribute("ShellHealth") :: number?) or 1
	local maxHP = (EggModel:GetAttribute("MaxShellHealth") :: number?) or 5

	currentHP = math.max(0, currentHP - breakPower)
	EggModel:SetAttribute("ShellHealth", currentHP)
	UpdateHealthBar(EggModel, currentHP, maxHP)

	-- Visual & Sound Impact Feedback
	local hitSound = Instance.new("Sound")
	hitSound.SoundId = "rbxassetid://138090596"
	hitSound.Volume = 0.8
	hitSound.Parent = primary
	hitSound:Play()
	Debris:AddItem(hitSound, 1)

	local spark = Instance.new("ParticleEmitter")
	spark.Color = ColorSequence.new(Color3.fromRGB(255, 230, 100), Color3.fromRGB(255, 100, 30))
	spark.Size = NumberSequence.new(0.5, 0)
	spark.Speed = NumberRange.new(8, 16)
	spark.Lifetime = NumberRange.new(0.3, 0.6)
	spark.Rate = 80
	spark.Parent = primary
	spark:Emit(12)
	Debris:AddItem(spark, 0.8)

	-- Fire Client Damage Numbers & Squash Animation
	if HitFX then
		HitFX:FireAllClients(EggModel, breakPower, currentHP <= 0)
	end

	if currentHP <= 0 then
		-- SAFE VAULT CRACKED!
		local reward = (EggModel:GetAttribute("Reward") :: number?) or 25
		local tier = (EggModel:GetAttribute("Tier") :: string?) or "Normal"
		
		-- Payout Cash Reward
		local leaderstats = Player:FindFirstChild("leaderstats")
		local money = leaderstats and leaderstats:FindFirstChild("Money") :: IntValue?
		if money then
			money.Value += reward
		end

		Notify(Player, string.format("💥 ¡BLINDAJE DESTRUIDO! ¡Botín de $%d asegurado! ¡Huye con la caja!", reward), Color3.fromRGB(255, 220, 60))
		EggModel:SetAttribute("EggLocked", false)

		-- Explosive door blast tween & gold particle shower
		local door = EggModel:FindFirstChild("VaultDoor") :: BasePart?
		if door then
			door.Transparency = 0.3
			local blast = TweenService:Create(door, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				CFrame = door.CFrame * CFrame.new(0, 0, 3.5) * CFrame.Angles(0, math.rad(65), 0)
			})
			blast:Play()
		end

		local burst = Instance.new("ParticleEmitter")
		burst.Color = ColorSequence.new(Color3.fromRGB(255, 220, 60), Color3.fromRGB(255, 180, 0))
		burst.Size = NumberSequence.new(0.8, 0)
		burst.Speed = NumberRange.new(12, 22)
		burst.SpreadAngle = Vector2.new(180, 180)
		burst.Lifetime = NumberRange.new(0.5, 1.2)
		burst.Rate = 200
		burst.Parent = primary
		burst:Emit(35)
		Debris:AddItem(burst, 1.5)

		local bb = primary:FindFirstChild("ShellHealthGui")
		if bb then bb:Destroy() end

		local claimEvent = Remotes:FindFirstChild("ClaimEggShell") :: BindableEvent?
		if claimEvent then
			claimEvent:Fire(Player, EggModel)
		end
	else
		Notify(Player, string.format("🔨 ¡Golpeando caja con %s! (-%d HP). Restan %d HP", weaponName, breakPower, currentHP), Color3.fromRGB(120, 220, 255))
	end
end

DamageRemote.OnServerEvent:Connect(function(Player: Player, TargetEgg: any)
	if typeof(TargetEgg) == "Instance" and TargetEgg:IsA("Model") then
		HitEgg(Player, TargetEgg)
	end
end)

-- Initialize all eggs and safes in workspace.Map.Eggs
local function InitAllEggs()
	for _, eggFolder in ipairs(EggsFolder:GetChildren()) do
		local eggType = eggFolder.Name
		for _, child in ipairs(eggFolder:GetChildren()) do
			if child:IsA("Model") and (child.Name == "Egg" or string.find(child.Name, "Egg") or string.find(child.Name, "Safe")) then
				SetupEggShell(child, eggType)

				local prompt = child:FindFirstChildWhichIsA("ProximityPrompt", true)
				if prompt then
					prompt.Triggered:Connect(function(triggeredPlayer)
						if child:GetAttribute("ShellHealth") and (child:GetAttribute("ShellHealth") :: number) > 0 then
							HitEgg(triggeredPlayer, child)
						end
					end)
				end
			end
		end
	end
end

InitAllEggs()
EggsFolder.DescendantAdded:Connect(function(desc)
	if desc:IsA("Model") and (string.find(desc.Name, "Egg") or string.find(desc.Name, "Safe")) then
		local folder = desc:FindFirstAncestorOfClass("Folder")
		if folder and folder.Parent == EggsFolder then
			task.wait(0.2)
			SetupEggShell(desc, folder.Name)
		end
	end
end)
