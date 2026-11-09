--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local TrailConfigurations = require(Modules:WaitForChild("TrailConfigurations"))

local eventsFolder = ReplicatedStorage:FindFirstChild("Events")
if not eventsFolder then
	eventsFolder = Instance.new("Folder")
	eventsFolder.Name = "Events"
	eventsFolder.Parent = ReplicatedStorage
end

local trailEvent = eventsFolder:FindFirstChild("TrailAction")
if not trailEvent then
	trailEvent = Instance.new("RemoteEvent")
	trailEvent.Name = "TrailAction"
	trailEvent.Parent = eventsFolder
end

local RemotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
if not RemotesFolder then
	RemotesFolder = Instance.new("Folder")
	RemotesFolder.Name = "Remotes"
	RemotesFolder.Parent = ReplicatedStorage
end

local NotifyRemote = RemotesFolder:FindFirstChild("Notify")
if not NotifyRemote then
	NotifyRemote = Instance.new("RemoteEvent")
	NotifyRemote.Name = "Notify"
	NotifyRemote.Parent = RemotesFolder
end

local function Notify(Player: Player, Text: string, Color: Color3?, Duration: number?)
	if NotifyRemote then
		NotifyRemote:FireClient(Player, Text, Color or Color3.fromRGB(255, 255, 255), Duration or 3)
	end
end

local ActionDebounce = {}

local function GetTrailsFolder(Player: Player): Folder
	local f = Player:FindFirstChild("Trails") :: Folder?
	if not f then
		f = Instance.new("Folder")
		f.Name = "Trails"
		f.Parent = Player
	end
	return f
end

local function GetEquippedTrailVal(Player: Player): StringValue
	local folder = GetTrailsFolder(Player)
	local eq = folder:FindFirstChild("Equipped") :: StringValue?
	if not eq then
		eq = Instance.new("StringValue")
		eq.Name = "Equipped"
		eq.Value = ""
		eq.Parent = folder
	end
	return eq
end

local function OwnsTrail(Player: Player, TrailID: string): boolean
	local Trails = GetTrailsFolder(Player)
	return Trails and Trails:FindFirstChild(TrailID) ~= nil
end

local function RemovePhysicalTrail(Character: Model?)
	if not Character then return end
	local oldTrail = Character:FindFirstChild("ActivePlayerTrail", true)
	if oldTrail then oldTrail:Destroy() end
	local a0 = Character:FindFirstChild("TrailAtt0", true)
	if a0 then a0:Destroy() end
	local a1 = Character:FindFirstChild("TrailAtt1", true)
	if a1 then a1:Destroy() end
end

local function ApplyPhysicalTrail(Character: Model?, TrailID: string)
	if not Character or TrailID == "" then return end
	RemovePhysicalTrail(Character)

	local Info = TrailConfigurations.GetTrailById(TrailID)
	if not Info then return end

	local Torso = Character:FindFirstChild("UpperTorso") or Character:FindFirstChild("Torso") or Character:FindFirstChild("HumanoidRootPart")
	if not Torso or not Torso:IsA("BasePart") then return end

	local att0 = Instance.new("Attachment")
	att0.Name = "TrailAtt0"
	att0.Position = Vector3.new(0, 0.8, 0)
	att0.Parent = Torso

	local att1 = Instance.new("Attachment")
	att1.Name = "TrailAtt1"
	att1.Position = Vector3.new(0, -0.8, 0)
	att1.Parent = Torso

	local trail = Instance.new("Trail")
	trail.Name = "ActivePlayerTrail"
	trail.Attachment0 = att0
	trail.Attachment1 = att1
	trail.Color = Info.Color
	trail.Lifetime = 0.55
	trail.MinLength = 0.1
	trail.LightEmission = 0.85
	trail.LightInfluence = 0
	trail.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.1),
		NumberSequenceKeypoint.new(1, 1),
	})
	trail.Parent = Torso
end

local function UpdatePlayerSpeedFromTrail(Player: Player)
	local char = Player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not hum then return end

	local ls = Player:FindFirstChild("leaderstats")
	local speedVal = ls and ls:FindFirstChild("Speed")
	local rawSpeed = speedVal and speedVal.Value or 0

	local eqVal = GetEquippedTrailVal(Player).Value
	local info = TrailConfigurations.GetTrailById(eqVal)
	local mult = info and info.SpeedMultiplier or 1.0

	local isCarrying = (char:GetAttribute("IsStealing") == true)
	local carryFactor = isCarrying and 0.75 or 1.0

	hum.WalkSpeed = (16 + rawSpeed * 0.15) * mult * carryFactor
end

local function BuyTrailWithMoney(Player: Player, TrailID: string)
	local Info = TrailConfigurations.GetTrailById(TrailID)
	if not Info then return end
	if OwnsTrail(Player, TrailID) then
		Notify(Player, "¡Ya posees este rastro!", Color3.fromRGB(240, 200, 60))
		return
	end

	local Leaderstats = Player:FindFirstChild("leaderstats")
	local Money = Leaderstats and Leaderstats:FindFirstChild("Money") :: IntValue?
	if not Money then return end

	local Cost = Info.MoneyCost or 0
	if Money.Value < Cost then
		Notify(Player, string.format("¡Monedas insuficientes! Cuesta $%d", Cost), Color3.fromRGB(220, 70, 70))
		return
	end

	Money.Value -= Cost

	local Trails = GetTrailsFolder(Player)
	local Owned = Instance.new("BoolValue")
	Owned.Name = TrailID
	Owned.Value = true
	Owned.Parent = Trails

	-- Auto-equip upon purchase
	local eq = GetEquippedTrailVal(Player)
	eq.Value = TrailID
	ApplyPhysicalTrail(Player.Character, TrailID)
	UpdatePlayerSpeedFromTrail(Player)

	Notify(Player, string.format("¡Compraste y equipaste: %s! (x%.1f Velocidad)", Info.Name, Info.SpeedMultiplier), Color3.fromRGB(80, 240, 120))
end

local function EquipTrail(Player: Player, TrailID: string)
	if not OwnsTrail(Player, TrailID) then
		Notify(Player, "¡No posees este rastro!", Color3.fromRGB(220, 70, 70))
		return
	end

	local eq = GetEquippedTrailVal(Player)
	eq.Value = TrailID
	ApplyPhysicalTrail(Player.Character, TrailID)
	UpdatePlayerSpeedFromTrail(Player)

	local Info = TrailConfigurations.GetTrailById(TrailID)
	Notify(Player, string.format("Rastro equipado: %s", Info and Info.Name or TrailID), Color3.fromRGB(80, 220, 255))
end

local function UnequipTrail(Player: Player, TrailID: string)
	local eq = GetEquippedTrailVal(Player)
	if eq.Value == TrailID or TrailID == "" then
		eq.Value = ""
		RemovePhysicalTrail(Player.Character)
		UpdatePlayerSpeedFromTrail(Player)
		Notify(Player, "Rastro desequipado.", Color3.fromRGB(200, 200, 200))
	end
end

trailEvent.OnServerEvent:Connect(function(Player: Player, Action: string, TrailID: string)
	if typeof(Action) ~= "string" or typeof(TrailID) ~= "string" then return end
	if ActionDebounce[Player] then return end
	ActionDebounce[Player] = true

	if Action == "BuyMoney" or Action == "Buy" then
		BuyTrailWithMoney(Player, TrailID)
	elseif Action == "Equip" then
		EquipTrail(Player, TrailID)
	elseif Action == "Unequip" then
		UnequipTrail(Player, TrailID)
	end

	task.delay(0.2, function()
		ActionDebounce[Player] = nil
	end)
end)

local function SetupPlayer(Player: Player)
	local eq = GetEquippedTrailVal(Player)

	Player.CharacterAdded:Connect(function(Character)
		task.wait(0.5)
		if eq.Value ~= "" then
			ApplyPhysicalTrail(Character, eq.Value)
			UpdatePlayerSpeedFromTrail(Player)
		end
	end)

	if Player.Character then
		task.defer(function()
			if eq.Value ~= "" then
				ApplyPhysicalTrail(Player.Character, eq.Value)
				UpdatePlayerSpeedFromTrail(Player)
			end
		end)
	end
end

Players.PlayerAdded:Connect(SetupPlayer)
for _, p in ipairs(Players:GetPlayers()) do
	SetupPlayer(p)
end

Players.PlayerRemoving:Connect(function(Player)
	ActionDebounce[Player] = nil
end)
