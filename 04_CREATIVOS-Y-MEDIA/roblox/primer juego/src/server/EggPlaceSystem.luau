local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local PhysicsService = game:GetService("PhysicsService")
local TweenService = game:GetService("TweenService")

local RestorePlacedData = ServerStorage:WaitForChild("RestorePlacedData")
local MAX_PLACED_PETS = 7

local Map = workspace:WaitForChild("Map")
local PlotsFolder = Map:WaitForChild("Plots")
local WorldEggsFolder = Map:WaitForChild("Eggs")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local EggModule = require(Modules:WaitForChild("EggModule"))
local PetsModule = require(Modules:WaitForChild("PetsModule"))
local RarityModule = require(Modules:WaitForChild("RarityModule"))

local Assets = ServerStorage:WaitForChild("Assets")
local BoardsFolder = Assets:WaitForChild("Boards")
local PetRigFolder = Assets:WaitForChild("PetRig")

local TimerBoardTemplate = BoardsFolder:WaitForChild("TimerBoard")
local InfoBoardTemplate = BoardsFolder:WaitForChild("InfoBoard")
local MoneyBoardTemplate = BoardsFolder:WaitForChild("MoneyBoard")

local ToolGenerator = require(ServerStorage:WaitForChild("ToolGenerator"))
local _, PetsToolFolder = ToolGenerator.EnsureGenerated()

local STARTING_SCALE = 0.3
local EGG_FINAL_SCALE = 1.6
local MAX_DISTANCE = 25
local PET_MARGIN = 2
local PET_WALK_SPEED = 7
local PET_IDLE_MIN = 1
local PET_IDLE_MAX = 3

local PET_WEIGHT_NORMAL_KG = 4
local PET_WEIGHT_MIN_KG = 2
local PET_WEIGHT_MAX_KG = 10

local PlayerDebounces = {}
local PickupDebounces = {}

local PET_COLLISION_GROUP = "Pets"
if not PhysicsService:IsCollisionGroupRegistered(PET_COLLISION_GROUP) then
	PhysicsService:RegisterCollisionGroup(PET_COLLISION_GROUP)
end
PhysicsService:CollisionGroupSetCollidable(PET_COLLISION_GROUP, PET_COLLISION_GROUP, false)

local RemotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
if not RemotesFolder then
	RemotesFolder = Instance.new("Folder")
	RemotesFolder.Name = "Remotes"
	RemotesFolder.Parent = ReplicatedStorage
end

local function GetOrCreateRemote(Name, ClassName)
	local Remote = RemotesFolder:FindFirstChild(Name)
	if not Remote then
		Remote = Instance.new(ClassName or "RemoteEvent")
		Remote.Name = Name
		Remote.Parent = RemotesFolder
	end
	return Remote
end

local PetDiscoveredBindable = ServerStorage:FindFirstChild("PetDiscovered")
if not PetDiscoveredBindable then
	PetDiscoveredBindable = Instance.new("BindableEvent")
	PetDiscoveredBindable.Name = "PetDiscovered"
	PetDiscoveredBindable.Parent = ServerStorage
end

local PlaceEggRemote = GetOrCreateRemote("PlaceEgg")
local PlacePetRemote = GetOrCreateRemote("PlacePet")
local PickupPetRemote = GetOrCreateRemote("PickupPet")
local HatchEggRemote = GetOrCreateRemote("HatchEgg")
local NotifyRemote = GetOrCreateRemote("Notify")

local function Notify(Player, Text, Color, Duration)
	if not Player then return end
	NotifyRemote:FireClient(Player, Text, Color, Duration)
end

local EggTemplates = ServerStorage:FindFirstChild("EggTemplates")
if not EggTemplates then
	EggTemplates = Instance.new("Folder")
	EggTemplates.Name = "EggTemplates"
	EggTemplates.Parent = ServerStorage
end

local function SaveEggTemplates()
	for EggType in pairs(EggModule) do
		if EggTemplates:FindFirstChild(EggType) then continue end
		local EggFolder = WorldEggsFolder:FindFirstChild(EggType)
		if not EggFolder then
			warn("[SaveEggTemplates] Map.Eggs." .. EggType .. " does not exist")
			continue
		end
		local Original = EggFolder:FindFirstChildWhichIsA("Model", true)
		if not Original then
			warn("[SaveEggTemplates] " .. EggType .. " does not contain a Model")
			continue
		end
		local Template = Original:Clone()
		Template.Name = EggType
		for _, Object in ipairs(Template:GetDescendants()) do
			if Object:IsA("ProximityPrompt") or Object:IsA("Script") or Object:IsA("LocalScript") then
				Object:Destroy()
			end
		end
		Template.Parent = EggTemplates
	end
end

local function GetPlotFromPlace(Place)
	local Current = Place
	while Current and Current.Parent ~= PlotsFolder do
		Current = Current.Parent
	end
	if Current and Current.Parent == PlotsFolder then
		return Current
	end
	return nil
end

local function OwnsPlot(Player, Plot)
	return Plot:GetAttribute("OwnerUserId") == Player.UserId
end

local function ValidDistance(Player, Position)
	local Character = Player.Character
	local RootPart = Character and Character:FindFirstChild("HumanoidRootPart")
	if not RootPart then return false end
	return (RootPart.Position - Position).Magnitude <= MAX_DISTANCE
end

local function GetEquippedTool(Player, ToolType)
	local Character = Player.Character
	if not Character then return nil end
	for _, Object in ipairs(Character:GetChildren()) do
		if not Object:IsA("Tool") then continue end
		if ToolType == "Egg" and EggModule[Object.Name] then
			return Object
		end
		if ToolType == "Pet" and Object:GetAttribute("IsPetTool") == true then
			return Object
		end
	end
	return nil
end

local function GetSurfacePosition(Place, WorldPosition, Height, Margin)
	Margin = Margin or 0
	local LocalPosition = Place.CFrame:PointToObjectSpace(WorldPosition)
	local HalfX = math.max(0, Place.Size.X / 2 - Margin)
	local HalfZ = math.max(0, Place.Size.Z / 2 - Margin)
	local X = math.clamp(LocalPosition.X, -HalfX, HalfX)
	local Z = math.clamp(LocalPosition.Z, -HalfZ, HalfZ)
	return Place.CFrame:PointToWorldSpace(Vector3.new(X, Place.Size.Y / 2 + Height, Z))
end

local function PrepareEgg(Egg)
	if not Egg.PrimaryPart then
		Egg.PrimaryPart = Egg:FindFirstChildWhichIsA("BasePart", true)
	end
	if not Egg.PrimaryPart then return false end
	for _, Object in ipairs(Egg:GetDescendants()) do
		if Object:IsA("BasePart") then
			Object.Anchored = true
			Object.CanCollide = false
			Object.CanTouch = false
		end
	end
	return true
end

local function PositionEgg(Egg, Place, ClickPosition)
	local _, EggSize = Egg:GetBoundingBox()
	local Position = GetSurfacePosition(Place, ClickPosition, EggSize.Y / 2, 0)
	Egg:PivotTo(CFrame.new(Position) * Place.CFrame.Rotation)
end

local function RollWeight()
	return PET_WEIGHT_MIN_KG + math.random() * (PET_WEIGHT_MAX_KG - PET_WEIGHT_MIN_KG)
end

local function CreateTimerBoard(Egg, EggData)
	local Board = TimerBoardTemplate:Clone()
	Board.Name = "EggTimerBoard"
	if Board:IsA("BillboardGui") then
		Board.Adornee = Egg.PrimaryPart
		Board.AlwaysOnTop = true
	end
	Board.Parent = Egg.PrimaryPart

	pcall(function()
		local EggName = Board:FindFirstChild("EggName", true)
		if EggName and EggName:IsA("TextLabel") then
			EggName.Text = EggData.EggName
		end
	end)
	pcall(function()
		local TimerBar = Board:FindFirstChild("TimerBar", true)
		local Bar = TimerBar and TimerBar:FindFirstChild("Bar")
		local TimeLabel = TimerBar and TimerBar:FindFirstChild("Time")
		if Bar and Bar:IsA("GuiObject") then
			Bar.Size = UDim2.new(0, 0, 1, 0)
		end
		if TimeLabel and TimeLabel:IsA("TextLabel") then
			TimeLabel.Text = string.format("%.1fs", EggData.EggTimer)
		end
	end)
	return Board
end

local function ChooseReward(Rewards)
	local TotalChance = 0
	for _, RewardData in pairs(Rewards) do
		TotalChance += RewardData.Chance or 0
	end
	if TotalChance <= 0 then return nil, nil end
	local RandomNumber = math.random() * TotalChance
	local CurrentChance = 0
	for RigName, RewardData in pairs(Rewards) do
		CurrentChance += RewardData.Chance or 0
		if RandomNumber <= CurrentChance then
			return RigName, RewardData
		end
	end
	return nil, nil
end

local function GiveSpecificReward(Player, EggType, RigName, RewardData, Weight)
	local EggToolsFolder = PetsToolFolder:FindFirstChild(EggType)
	local ToolTemplate = EggToolsFolder and EggToolsFolder:FindFirstChild(RigName)
	if not ToolTemplate or not ToolTemplate:IsA("Tool") then
		warn("[GiveSpecificReward] PetsTool missing: " .. tostring(EggType) .. "." .. tostring(RigName))
		return false
	end
	local Backpack = Player:FindFirstChild("Backpack")
	if not Backpack then
		warn("[GiveSpecificReward] Backpack missing for", Player.Name)
		return false
	end
	local PetData = PetsModule[RigName] or RewardData
	local BaseMoney = PetData.MoneyPerSecond or 0
	local BaseKG = PET_WEIGHT_NORMAL_KG
	local WeightMultiplier = Weight and (Weight / BaseKG) or 1
	local Tool = ToolTemplate:Clone()
	Tool:SetAttribute("IsPetTool", true)
	Tool:SetAttribute("EggType", EggType)
	Tool:SetAttribute("PetRigName", RigName)
	Tool:SetAttribute("Weight", Weight or BaseKG)
	Tool:SetAttribute("MoneyPerSecond", math.floor(BaseMoney * WeightMultiplier + 0.5))
	Tool.Parent = Backpack
	return true
end

local function RevealPet(Player, Egg, EggType, RigName)
	local EggPetFolder = PetRigFolder:FindFirstChild(EggType)
	local PetTemplate = EggPetFolder and EggPetFolder:FindFirstChild(RigName)
	if not PetTemplate or not PetTemplate:IsA("Model") then
		warn("[RevealPet] PetRig missing: " .. tostring(EggType) .. "." .. tostring(RigName))
		return false
	end
	local Character = Player.Character
	local PlayerRoot = Character and Character:FindFirstChild("HumanoidRootPart")
	if not PlayerRoot then return false end

	local RevealedPet = PetTemplate:Clone()
	RevealedPet.Name = "HatchedPet"
	if not RevealedPet.PrimaryPart then
		RevealedPet.PrimaryPart = RevealedPet:FindFirstChild("HumanoidRootPart") or RevealedPet:FindFirstChildWhichIsA("BasePart", true)
	end
	if not RevealedPet.PrimaryPart then
		RevealedPet:Destroy()
		return false
	end
	for _, Object in ipairs(RevealedPet:GetDescendants()) do
		if Object:IsA("BasePart") then
			Object.Anchored = true
			Object.CanCollide = false
			Object.CanTouch = false
			Object.CanQuery = false
			Object:GetPropertyChangedSignal("CanCollide"):Connect(function()
				if Object.CanCollide then Object.CanCollide = false end
			end)
		end
		if Object:IsA("BillboardGui") or Object:IsA("Script") or Object:IsA("LocalScript") then
			Object:Destroy()
		end
	end
	RevealedPet.Parent = workspace
	local StartCFrame = Egg:GetPivot() * CFrame.new(0, 2, 0)
	RevealedPet:PivotTo(StartCFrame)
	task.wait(0.7)
	if not RevealedPet.Parent or not PlayerRoot.Parent then
		if RevealedPet.Parent then RevealedPet:Destroy() end
		return false
	end
	local BounceValue = Instance.new("CFrameValue")
	BounceValue.Value = RevealedPet:GetPivot()
	local PivotConnection = BounceValue:GetPropertyChangedSignal("Value"):Connect(function()
		if RevealedPet.Parent then RevealedPet:PivotTo(BounceValue.Value) end
	end)
	local BounceUpCFrame = StartCFrame * CFrame.new(0, 1, 0)
	local BounceUpTween = TweenService:Create(BounceValue, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Value = BounceUpCFrame })
	BounceUpTween:Play()
	BounceUpTween.Completed:Wait()
	if not RevealedPet.Parent or not PlayerRoot.Parent then
		PivotConnection:Disconnect()
		BounceValue:Destroy()
		if RevealedPet.Parent then RevealedPet:Destroy() end
		return false
	end
	local TargetCFrame = PlayerRoot.CFrame * CFrame.new(0, 1, -2)
	local PlayerTween = TweenService:Create(BounceValue, TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Value = TargetCFrame })
	PlayerTween:Play()
	PlayerTween.Completed:Wait()
	PivotConnection:Disconnect()
	BounceValue:Destroy()
	if RevealedPet.Parent then RevealedPet:Destroy() end
	return true
end

local function AnimateEggHatchAway(Egg)
	if not Egg.Parent then return end
	local Duration = 0.35
	for _, Object in ipairs(Egg:GetDescendants()) do
		if Object:IsA("BasePart") then
			Object.Material = Enum.Material.Neon
			TweenService:Create(Object, TweenInfo.new(Duration, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Transparency = 1 }):Play()
		end
	end
	local StartScale = Egg:GetScale()
	local StartClock = os.clock()
	while Egg.Parent and os.clock() - StartClock < Duration do
		local Progress = math.clamp((os.clock() - StartClock) / Duration, 0, 1)
		Egg:ScaleTo(math.max(StartScale * (1 - Progress), 0.001))
		task.wait()
	end
	if Egg.Parent then Egg:Destroy() end
end

local function HatchPlacedEgg(Player, Egg)
	if typeof(Egg) ~= "Instance" or not Egg:IsA("Model") or not Egg.Parent then return end
	if Egg:GetAttribute("OwnerUserId") ~= Player.UserId then return end
	if Egg:GetAttribute("Ready") ~= true then return end
	if Egg:GetAttribute("Hatching") == true then return end
	local EggType = Egg:GetAttribute("EggType") or Egg.Name
	local RigName = Egg:GetAttribute("RewardRig")
	local EggData = EggModule[EggType]
	if not EggData or not RigName then
		warn("[HatchPlacedEgg] Egg missing reward")
		return
	end
	local RewardData = EggData.Rewards and EggData.Rewards[RigName] or PetsModule[RigName]
	if not RewardData then return end
	local PetWeight = RollWeight()
	Egg:SetAttribute("Hatching", true)
	local Prompt = Egg:FindFirstChild("HatchPrompt", true)
	if Prompt and Prompt:IsA("ProximityPrompt") then Prompt.Enabled = false end
	local Board = Egg:FindFirstChild("EggTimerBoard", true)
	if Board and Board:IsA("BillboardGui") then Board.Enabled = false end
	task.spawn(function()
		local Revealed = RevealPet(Player, Egg, EggType, RigName)
		if not Revealed then return end
		if not Egg.Parent then return end
		local Delivered = GiveSpecificReward(Player, EggType, RigName, RewardData, PetWeight)
		if Delivered then
			PetDiscoveredBindable:Fire(Player, EggType, RigName)
			Notify(Player, EggData.EggName .. " hatched!", Color3.fromRGB(80, 220, 120), 3)
			AnimateEggHatchAway(Egg)
			return
		end
		Egg:SetAttribute("Hatching", false)
		if Prompt and Prompt.Parent then Prompt.Enabled = true end
		if Board and Board.Parent then Board.Enabled = true end
		warn("[HatchPlacedEgg] Could not deliver PetsTool: " .. tostring(EggType) .. "." .. tostring(RigName))
	end)
end

local function MakeEggReady(Player, Egg, EggType, EggData, Board)
	if not Egg.Parent or not Egg.PrimaryPart then return end
	if not EggData.Rewards then return end
	local RigName = Egg:GetAttribute("RewardRig")
	if not RigName then
		local RewardData
		RigName, RewardData = ChooseReward(EggData.Rewards)
		if not RigName then return end
		Egg:SetAttribute("RewardRig", RigName)
	end
	Egg:SetAttribute("Ready", true)
	Egg:SetAttribute("Hatching", false)
	if Board then
		pcall(function()
			local TimeLabel = Board:FindFirstChild("Time", true)
			if TimeLabel and TimeLabel:IsA("TextLabel") then
				TimeLabel.Text = "READY!"
			end
			local TimerBar = Board:FindFirstChild("TimerBar", true)
			local Bar = TimerBar and TimerBar:FindFirstChild("Bar")
			if Bar and Bar:IsA("GuiObject") then
				Bar.Size = UDim2.new(1, 0, 1, 0)
			end
		end)
	end
	local ExistingPrompt = Egg:FindFirstChild("HatchPrompt", true)
	if ExistingPrompt then return end
	local Prompt = Instance.new("ProximityPrompt")
	Prompt.Name = "HatchPrompt"
	Prompt.ActionText = "Hatch"
	Prompt.ObjectText = EggData.EggName or EggType
	Prompt.HoldDuration = 0
	Prompt.Style = Enum.ProximityPromptStyle.Custom
	Prompt.MaxActivationDistance = 10
	Prompt.RequiresLineOfSight = false
	Prompt.Parent = Egg.PrimaryPart
	Prompt.Triggered:Connect(function(TriggeredPlayer)
		HatchPlacedEgg(TriggeredPlayer, Egg)
	end)
end

local function RunEggGrowth(Player, EggType, Egg, Place, ClickPosition, Board, EggData, StartClock)
	local TimerBar = Board:FindFirstChild("TimerBar", true)
	local Bar = TimerBar and TimerBar:FindFirstChild("Bar")
	local TimeLabel = TimerBar and TimerBar:FindFirstChild("Time")
	local TotalTime = EggData.EggTimer
	while Egg.Parent do
		local Elapsed = math.clamp(os.clock() - StartClock, 0, TotalTime)
		local Progress = TotalTime > 0 and (Elapsed / TotalTime) or 1
		if Bar and Bar:IsA("GuiObject") then
			Bar.Size = UDim2.new(Progress, 0, 1, 0)
		end
		if TimeLabel and TimeLabel:IsA("TextLabel") then
			local Remaining = TotalTime - Elapsed
			if Remaining <= 0 then
				TimeLabel.Text = "Ready!"
			else
				TimeLabel.Text = string.format("%.1fs", Remaining)
			end
		end
		local CurrentScale = STARTING_SCALE + (EGG_FINAL_SCALE - STARTING_SCALE) * Progress
		Egg:ScaleTo(CurrentScale)
		if Place and ClickPosition then
			PositionEgg(Egg, Place, ClickPosition)
		end
		if Progress >= 1 then break end
		task.wait()
	end
	if not Egg.Parent then return end
	MakeEggReady(Player, Egg, EggType, EggData, Board)
end

local function PlaceEgg(Player, Place, ClickPosition)
	if PlayerDebounces[Player] then return end
	local Plot = GetPlotFromPlace(Place)
	if not Plot or not OwnsPlot(Player, Plot) then
		Notify(Player, "You can't place here", Color3.fromRGB(220, 70, 70), 3)
		return
	end
	local EggTool = GetEquippedTool(Player, "Egg")
	if not EggTool then return end
	local EggType = EggTool.Name
	local EggData = EggModule[EggType]
	local Template = EggTemplates:FindFirstChild(EggType)
	if not EggData or not Template or not Template:IsA("Model") then
		warn("[PlaceEgg] Missing template for", EggType)
		return
	end
	PlayerDebounces[Player] = true
	local PlacedEggs = Plot:FindFirstChild("PlacedEggs")
	if not PlacedEggs then
		PlacedEggs = Instance.new("Folder")
		PlacedEggs.Name = "PlacedEggs"
		PlacedEggs.Parent = Plot
	end
	local Egg = Template:Clone()
	Egg.Name = EggType
	Egg:SetAttribute("OwnerUserId", Player.UserId)
	Egg.Parent = PlacedEggs
	if not PrepareEgg(Egg) then
		Egg:Destroy()
		PlayerDebounces[Player] = nil
		return
	end
	local Board = CreateTimerBoard(Egg, EggData)
	Egg:ScaleTo(STARTING_SCALE)
	PositionEgg(Egg, Place, ClickPosition)
	EggTool:Destroy()
	local StartClock = os.clock()
	local EndTime = os.time() + math.ceil(EggData.EggTimer)
	Egg:SetAttribute("EggType", EggType)
	Egg:SetAttribute("EndTime", EndTime)
	Egg:SetAttribute("Ready", false)
	Notify(Player, EggData.EggName .. " placed", Color3.fromRGB(255, 255, 255), 3)
	task.spawn(function()
		RunEggGrowth(Player, EggType, Egg, Place, ClickPosition, Board, EggData, StartClock)
	end)
	task.delay(0.5, function()
		PlayerDebounces[Player] = nil
	end)
end

local function GetPetTemplate(EggType, RigName)
	local EggFolder = PetRigFolder:FindFirstChild(EggType)
	local Template = EggFolder and EggFolder:FindFirstChild(RigName)
	if Template and Template:IsA("Model") then return Template end
	return nil
end

local function PreparePet(Pet)
	if not Pet.PrimaryPart then
		Pet.PrimaryPart = Pet:FindFirstChild("HumanoidRootPart") or Pet:FindFirstChildWhichIsA("BasePart", true)
	end
	if not Pet.PrimaryPart then
		warn("[PreparePet] Missing PrimaryPart/Root for", Pet.Name)
		return false
	end
	for _, Object in ipairs(Pet:GetDescendants()) do
		if Object:IsA("BasePart") then
			Object.Anchored = true
			Object.CanCollide = true
			Object.CanTouch = false
			Object.CollisionGroup = PET_COLLISION_GROUP
		end
	end
	Pet.DescendantAdded:Connect(function(Object)
		if Object:IsA("BasePart") then
			Object.Anchored = true
			Object.CanCollide = true
			Object.CollisionGroup = PET_COLLISION_GROUP
		end
	end)
	return true
end

local function CreatePetInfoBoard(Pet, RigName, PetData, Weight)
	local Torso = Pet:FindFirstChild("Torso") or Pet:FindFirstChild("UpperTorso") or Pet.PrimaryPart
	if not Torso then return end
	local Board = InfoBoardTemplate:Clone()
	Board.Name = "PetInfoBoard"
	if Board:IsA("BillboardGui") then
		Board.Adornee = Torso
	end
	Board.Parent = Torso
	pcall(function()
		local PetName = Board:FindFirstChild("PetName", true)
		if PetName and PetName:IsA("TextLabel") then PetName.Text = RigName end
	end)
	pcall(function()
		local RarityName = PetData.Rarity or "Common"
		local RarityData = RarityModule[RarityName]
		local PetRarity = Board:FindFirstChild("PetRarity", true)
		if PetRarity and PetRarity:IsA("TextLabel") then
			PetRarity.Text = RarityName
			if RarityData and RarityData.Color then
				PetRarity.TextColor3 = RarityData.Color
			end
		end
	end)
	pcall(function()
		local PetMoney = Board:FindFirstChild("PetMoney", true)
		if PetMoney and PetMoney:IsA("TextLabel") then
			PetMoney.Text = "$" .. tostring(PetData.MoneyPerSecond or 0) .. "/s"
		end
	end)
	pcall(function()
		local PetWeight = Board:FindFirstChild("Weight", true)
		if PetWeight and (PetWeight:IsA("TextLabel") or PetWeight:IsA("TextButton")) then
			PetWeight.Text = string.format("%.2f", Weight or PET_WEIGHT_NORMAL_KG) .. " kg"
		end
	end)
end

local function ShowPetMoneyPopup(Pet, Amount)
	if Amount <= 0 or not Pet.Parent then return end
	local Torso = Pet:FindFirstChild("Torso") or Pet:FindFirstChild("UpperTorso") or Pet.PrimaryPart
	if not Torso or not Torso:IsA("BasePart") then return end
	local Board = MoneyBoardTemplate:Clone()
	Board.Name = "MoneyPopup"
	local Generated = Board:FindFirstChild("Generated", true)
	if Generated and Generated:IsA("TextLabel") then
		Generated.Text = "+" .. tostring(Amount)
	end
	if Board:IsA("BillboardGui") then
		Board.Adornee = Torso
		local StartingOffset = Board.StudsOffset
		local EndingOffset = StartingOffset + Vector3.new(0, 1.5, 0)
		Board.Parent = Torso
		TweenService:Create(Board, TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { StudsOffset = EndingOffset }):Play()
	else
		Board.Parent = Torso
	end
	task.delay(0.6, function()
		if not Board.Parent then return end
		for _, Object in ipairs(Board:GetDescendants()) do
			if Object:IsA("TextLabel") or Object:IsA("TextButton") then
				TweenService:Create(Object, TweenInfo.new(0.6), { TextTransparency = 1, TextStrokeTransparency = 1, BackgroundTransparency = 1 }):Play()
			elseif Object:IsA("UIStroke") then
				TweenService:Create(Object, TweenInfo.new(0.6), { Transparency = 1 }):Play()
			elseif Object:IsA("ImageLabel") or Object:IsA("ImageButton") then
				TweenService:Create(Object, TweenInfo.new(0.6), { ImageTransparency = 1, BackgroundTransparency = 1 }):Play()
			end
		end
	end)
	task.delay(1.2, function()
		if Board.Parent then Board:Destroy() end
	end)
end

local function StartPetIncome(Player, Pet, PetData)
	local Amount = PetData.MoneyPerSecond or 0
	task.spawn(function()
		while Pet.Parent and Player.Parent do
			task.wait(1)
			if not Pet.Parent or not Player.Parent then break end
			local Leaderstats = Player:FindFirstChild("leaderstats")
			local Money = Leaderstats and Leaderstats:FindFirstChild("Money")
			if Money then
				Money.Value += Amount
				ShowPetMoneyPopup(Pet, Amount)
			end
		end
	end)
end

local function RandomPetPosition(Place, Height)
	local HalfX = math.max(0, Place.Size.X / 2 - PET_MARGIN)
	local HalfZ = math.max(0, Place.Size.Z / 2 - PET_MARGIN)
	local X = (math.random() * 2 - 1) * HalfX
	local Z = (math.random() * 2 - 1) * HalfZ
	return Place.CFrame:PointToWorldSpace(Vector3.new(X, Place.Size.Y / 2 + Height, Z))
end

local function StartPetMovement(Pet, Place)
	local Root = Pet.PrimaryPart
	task.spawn(function()
		local PivotValue = Instance.new("CFrameValue")
		PivotValue.Value = Pet:GetPivot()
		local PivotConnection = PivotValue:GetPropertyChangedSignal("Value"):Connect(function()
			if Pet.Parent then
				Pet:PivotTo(PivotValue.Value)
			end
		end)
		while Pet.Parent and Root.Parent do
			local CurrentPosition = Pet:GetPivot().Position
			local Target = RandomPetPosition(Place, Root.Size.Y / 2)
			local Distance = (Target - CurrentPosition).Magnitude
			if Distance > 0.1 then
				local FacingRotation = CFrame.lookAt(CurrentPosition, Target).Rotation
				PivotValue.Value = CFrame.new(CurrentPosition) * FacingRotation
				local TargetCFrame = CFrame.new(Target) * FacingRotation
				local Duration = math.max(Distance / PET_WALK_SPEED, 0.3)
				local MoveTween = TweenService:Create(PivotValue, TweenInfo.new(Duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Value = TargetCFrame })
				MoveTween:Play()
				MoveTween.Completed:Wait()
			end
			if not Pet.Parent then break end
			task.wait(math.random(PET_IDLE_MIN, PET_IDLE_MAX))
		end
		PivotConnection:Disconnect()
		PivotValue:Destroy()
	end)
end

local function GetPlacedPetCount(Plot)
	local PlacedPets = Plot:FindFirstChild("PlacedPets")
	if not PlacedPets then return 0 end
	local Count = 0
	for _, Pet in ipairs(PlacedPets:GetChildren()) do
		if Pet:IsA("Model") and Pet:GetAttribute("IsPlacedPet") == true then
			Count += 1
		end
	end
	return Count
end

local function PlacePet(Player, Place, ClickPosition)
	if PlayerDebounces[Player] then return end
	local Plot = GetPlotFromPlace(Place)
	if not Plot or not OwnsPlot(Player, Plot) then
		Notify(Player, "You can't place here", Color3.fromRGB(220, 70, 70), 3)
		return
	end
	if GetPlacedPetCount(Plot) >= MAX_PLACED_PETS then
		Notify(Player, "Plot is full", Color3.fromRGB(220, 70, 70), 3)
		return
	end
	local PetTool = GetEquippedTool(Player, "Pet")
	if not PetTool then return end
	local EggType = PetTool:GetAttribute("EggType")
	local RigName = PetTool:GetAttribute("PetRigName")
	if not EggType or not RigName then return end
	local PetData = PetsModule[RigName]
	local Template = GetPetTemplate(EggType, RigName)
	if not PetData or not Template then
		warn("[PlacePet] Missing template for", EggType, RigName)
		return
	end
	PlayerDebounces[Player] = true
	local PlacedPets = Plot:FindFirstChild("PlacedPets")
	if not PlacedPets then
		PlacedPets = Instance.new("Folder")
		PlacedPets.Name = "PlacedPets"
		PlacedPets.Parent = Plot
	end
	local Pet = Template:Clone()
	Pet.Name = RigName
	local Weight = PetTool:GetAttribute("Weight") or PET_WEIGHT_NORMAL_KG
	local BaseKG = PET_WEIGHT_NORMAL_KG
	local SizeMultiplier = Weight / BaseKG
	local ToolMoney = PetTool:GetAttribute("MoneyPerSecond")
	Pet:SetAttribute("IsPlacedPet", true)
	Pet:SetAttribute("OwnerUserId", Player.UserId)
	Pet:SetAttribute("EggType", EggType)
	Pet:SetAttribute("PetRigName", RigName)
	Pet:SetAttribute("Weight", Weight)
	Pet:SetAttribute("Rarity", PetData.Rarity or "Common")
	Pet:SetAttribute("MoneyPerSecond", ToolMoney or PetData.MoneyPerSecond or 0)
	Pet.Parent = PlacedPets
	if not PreparePet(Pet) then
		Pet:Destroy()
		PlayerDebounces[Player] = nil
		return
	end
	pcall(function() Pet:ScaleTo(SizeMultiplier) end)
	local _, PetSize = Pet:GetBoundingBox()
	local Position = GetSurfacePosition(Place, ClickPosition, PetSize.Y / 2, PET_MARGIN)
	Pet:PivotTo(CFrame.new(Position) * Place.CFrame.Rotation)
	local EffectivePetData = {
		Rarity = PetData.Rarity,
		MoneyPerSecond = ToolMoney or PetData.MoneyPerSecond or 0,
	}
	CreatePetInfoBoard(Pet, RigName, EffectivePetData, Weight)
	StartPetIncome(Player, Pet, EffectivePetData)
	PetTool:Destroy()
	StartPetMovement(Pet, Place)
	task.delay(0.5, function()
		PlayerDebounces[Player] = nil
	end)
end

local function PickupPet(Player, Pet)
	if PickupDebounces[Player] then return end
	if typeof(Pet) ~= "Instance" or not Pet:IsA("Model") or Pet:GetAttribute("IsPlacedPet") ~= true or Pet:GetAttribute("OwnerUserId") ~= Player.UserId then
		return
	end
	if not Pet:IsDescendantOf(PlotsFolder) then return end
	local Character = Player.Character
	local PlayerRoot = Character and Character:FindFirstChild("HumanoidRootPart")
	local PetRoot = Pet.PrimaryPart or Pet:FindFirstChild("HumanoidRootPart")
	if not PlayerRoot or not PetRoot then return end
	local EggType = Pet:GetAttribute("EggType")
	local RigName = Pet:GetAttribute("PetRigName")
	local Weight = Pet:GetAttribute("Weight")
	local EggToolsFolder = PetsToolFolder:FindFirstChild(EggType)
	local ToolTemplate = EggToolsFolder and EggToolsFolder:FindFirstChild(RigName)
	if not ToolTemplate or not ToolTemplate:IsA("Tool") then
		warn("[PickupPet] Tool template missing for", EggType, RigName)
		return
	end
	local Backpack = Player:FindFirstChild("Backpack")
	if not Backpack then return end
	PickupDebounces[Player] = true
	local Tool = ToolTemplate:Clone()
	Tool:SetAttribute("IsPetTool", true)
	Tool:SetAttribute("EggType", EggType)
	Tool:SetAttribute("PetRigName", RigName)
	Tool:SetAttribute("Weight", Weight)
	Tool:SetAttribute("MoneyPerSecond", Pet:GetAttribute("MoneyPerSecond") or 0)
	Tool.Parent = Backpack
	Pet:Destroy()
	task.delay(0.5, function()
		PickupDebounces[Player] = nil
	end)
end

PlaceEggRemote.OnServerEvent:Connect(function(Player, Place, Position)
	if typeof(Place) ~= "Instance" or not Place:IsA("BasePart") or Place.Name ~= "Place" or typeof(Position) ~= "Vector3" or not Place:IsDescendantOf(PlotsFolder) or not ValidDistance(Player, Position) then
		return
	end
	PlaceEgg(Player, Place, Position)
end)

PlacePetRemote.OnServerEvent:Connect(function(Player, Place, Position)
	if typeof(Place) ~= "Instance" or not Place:IsA("BasePart") or Place.Name ~= "Place" or typeof(Position) ~= "Vector3" or not Place:IsDescendantOf(PlotsFolder) or not ValidDistance(Player, Position) then
		return
	end
	PlacePet(Player, Place, Position)
end)

PickupPetRemote.OnServerEvent:Connect(function(Player, Pet)
	PickupPet(Player, Pet)
end)

Players.PlayerRemoving:Connect(function(Player)
	PlayerDebounces[Player] = nil
	PickupDebounces[Player] = nil
end)

local function RestorePet(Player, Plot, Place, Saved)
	local PetData = PetsModule[Saved.RigName]
	local Template = GetPetTemplate(Saved.EggType, Saved.RigName)
	if GetPlacedPetCount(Plot) >= MAX_PLACED_PETS then
		warn("[RestorePet] Plot full, cannot restore", Saved.RigName)
		return false
	end
	if not PetData or not Template then
		warn("[RestorePet] Missing data/template for", Saved.EggType, Saved.RigName)
		return false
	end
	local PlacedPets = Plot:FindFirstChild("PlacedPets")
	if not PlacedPets then
		PlacedPets = Instance.new("Folder")
		PlacedPets.Name = "PlacedPets"
		PlacedPets.Parent = Plot
	end
	local Pet = Template:Clone()
	Pet.Name = Saved.RigName
	local Weight = Saved.Weight or PET_WEIGHT_NORMAL_KG
	local BaseKG = PET_WEIGHT_NORMAL_KG
	Pet:SetAttribute("IsPlacedPet", true)
	Pet:SetAttribute("OwnerUserId", Player.UserId)
	Pet:SetAttribute("EggType", Saved.EggType)
	Pet:SetAttribute("PetRigName", Saved.RigName)
	Pet:SetAttribute("Weight", Weight)
	Pet:SetAttribute("Rarity", PetData.Rarity or "Common")
	Pet:SetAttribute("MoneyPerSecond", Saved.MoneyPerSecond or PetData.MoneyPerSecond or 0)
	Pet.Parent = PlacedPets
	if not PreparePet(Pet) then
		Pet:Destroy()
		return false
	end
	pcall(function() Pet:ScaleTo(Weight / BaseKG) end)
	local _, Size = Pet:GetBoundingBox()
	local Position = Place.CFrame:PointToWorldSpace(Vector3.new(Saved.X or 0, Place.Size.Y / 2 + Size.Y / 2, Saved.Z or 0))
	Pet:PivotTo(CFrame.new(Position) * Place.CFrame.Rotation)
	local EffectivePetData = {
		Rarity = PetData.Rarity,
		MoneyPerSecond = Saved.MoneyPerSecond or PetData.MoneyPerSecond or 0,
	}
	CreatePetInfoBoard(Pet, Saved.RigName, EffectivePetData, Weight)
	StartPetIncome(Player, Pet, EffectivePetData)
	StartPetMovement(Pet, Place)
	return true
end

local function ClearPlacedFolder(Plot, FolderName)
	local Folder = Plot:FindFirstChild(FolderName)
	if not Folder then return end
	for _, Object in ipairs(Folder:GetChildren()) do
		Object:Destroy()
	end
end

RestorePlacedData.OnInvoke = function(Player, Plot, SavedPets, SavedEggs)
	if not Player.Parent or not Plot.Parent then return false end
	local Place = Plot:FindFirstChild("Place")
	if not Place then return false end

	ClearPlacedFolder(Plot, "PlacedEggs")
	ClearPlacedFolder(Plot, "PlacedPets")

	local anyPlaced = false

	for _, SavedPet in ipairs(SavedPets or {}) do
		local success = pcall(function()
			if RestorePet(Player, Plot, Place, SavedPet) then
				anyPlaced = true
			end
		end)
		if not success then
			warn("[RestorePlacedData] Failed to restore pet", SavedPet.RigName)
		end
	end

	for _, SavedEgg in ipairs(SavedEggs or {}) do
		local success = pcall(function()
			local EggType = SavedEgg.EggType
			local EggData = EggModule[EggType]
			local Template = EggTemplates:FindFirstChild(EggType)
			if not EggData or not Template or not Template:IsA("Model") then
				warn("[RestorePlacedData] Missing egg template for", EggType)
				return
			end
			local PlacedEggs = Plot:FindFirstChild("PlacedEggs")
			if not PlacedEggs then
				PlacedEggs = Instance.new("Folder")
				PlacedEggs.Name = "PlacedEggs"
				PlacedEggs.Parent = Plot
			end
			local Egg = Template:Clone()
			Egg.Name = EggType
			Egg:SetAttribute("EggType", EggType)
			Egg:SetAttribute("OwnerUserId", Player.UserId)
			Egg:SetAttribute("EndTime", SavedEgg.EndTime)
			Egg:SetAttribute("RewardRig", SavedEgg.RewardRig)
			Egg.Parent = PlacedEggs
			if not PrepareEgg(Egg) then
				Egg:Destroy()
				return
			end
			local Position = Place.CFrame:PointToWorldSpace(Vector3.new(SavedEgg.X or 0, Place.Size.Y / 2, SavedEgg.Z or 0))
			local Board = CreateTimerBoard(Egg, EggData)
			local EndTime = SavedEgg.EndTime or os.time()
			if SavedEgg.Ready then
				Egg:ScaleTo(EGG_FINAL_SCALE)
				PositionEgg(Egg, Place, Position)
				MakeEggReady(Player, Egg, EggType, EggData, Board)
			else
				local TotalTime = EggData.EggTimer
				local Remaining = math.clamp(EndTime - os.time(), 0, TotalTime)
				local StartClock = os.clock() - (TotalTime - Remaining)
				task.spawn(function()
					RunEggGrowth(Player, EggType, Egg, Place, Position, Board, EggData, StartClock)
				end)
			end
			anyPlaced = true
		end)
		if not success then
			warn("[RestorePlacedData] Failed to restore egg", SavedEgg.EggType)
		end
	end

	if (#SavedPets > 0 or #SavedEggs > 0) then
		return anyPlaced
	else
		return true
	end
end

HatchEggRemote.OnServerEvent:Connect(function(Player, Egg)
	HatchPlacedEgg(Player, Egg)
end)

SaveEggTemplates()
