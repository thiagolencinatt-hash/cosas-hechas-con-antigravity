local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService")

local IndexData = require(ServerStorage:WaitForChild("IndexData"))
local ProfileStore = require(ServerStorage:WaitForChild("ProfileStore"))

local Map = workspace:WaitForChild("Map")
local PlotsFolder = Map:WaitForChild("Plots")

local ModelsFolder = ReplicatedStorage:WaitForChild("Models")
local OfflineStackTemplate = ModelsFolder:WaitForChild("OfflineStack")
local OfflineStackRotation = OfflineStackTemplate:GetPivot().Rotation

local Modules = ReplicatedStorage:WaitForChild("Modules")
local EggModule = require(Modules:WaitForChild("EggModule"))
local PetsModule = require(Modules:WaitForChild("PetsModule"))

local ToolGenerator = require(ServerStorage:WaitForChild("ToolGenerator"))
local EggToolsFolder, PetsToolFolder = ToolGenerator.EnsureGenerated()

local AUTOSAVE_TIME = 25
local OFFLINE_MULTIPLIER = 0.4

local Profiles = {}
local PendingRespawnTools = {}
local OfflinePending = {}
local PetsRestored = {}
local PlayerDataReady = {}
local SpawnedOfflineStacks = {}
local PlotOwnershipConnections = {}
local LastKnownOwner = {}
local PlayerPlots = {}

local RestoreFunction = ServerStorage:FindFirstChild("RestorePlacedData")
if not RestoreFunction then
	RestoreFunction = Instance.new("BindableFunction")
	RestoreFunction.Name = "RestorePlacedData"
	RestoreFunction.Parent = ServerStorage
end

local PlotReset = ServerStorage:FindFirstChild("PlotReset")
if not PlotReset then
	PlotReset = Instance.new("BindableEvent")
	PlotReset.Name = "PlotReset"
	PlotReset.Parent = ServerStorage
end

local RemotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
if not RemotesFolder then
	RemotesFolder = Instance.new("Folder")
	RemotesFolder.Name = "Remotes"
	RemotesFolder.Parent = ReplicatedStorage
end

local DataSyncRemote = RemotesFolder:FindFirstChild("DataSynced")
if not DataSyncRemote then
	DataSyncRemote = Instance.new("RemoteEvent")
	DataSyncRemote.Name = "DataSynced"
	DataSyncRemote.Parent = RemotesFolder
end

local DataTemplate = {
	Money = 0,
	Speed = 0,
	Strength = 0,
	StrengthLevel = 1,
	TreadmillLevel = 0,
	PlotLevel = 1,
	Pets = {},
	Eggs = {},
	Tools = {},
	OpeningTools = { Owned = { "MazoMadera" }, Equipped = "MazoMadera" },
	Trails = { Owned = {}, Equipped = "" },
	OfflinePending = 0,
	OfflineRate = 0,
	LastSeen = 0,
	Index = {},
}

local PlayerProfileStore = ProfileStore.New("PlayerProfileData_V1", DataTemplate)

ProfileStore.OnError:Connect(function(Message, StoreName, ProfileKey)
	warn(Message, StoreName, ProfileKey)
end)

local function GetKey(Player)
	return "Player_" .. Player.UserId
end

local function GetPlayerPlot(Player)
	local PlotName = Player:GetAttribute("PlotName")
	if PlotName then
		local Plot = PlotsFolder:FindFirstChild(PlotName)
		if Plot then
			return Plot
		end
	end
	for _, Plot in ipairs(PlotsFolder:GetChildren()) do
		if Plot:GetAttribute("OwnerUserId") == Player.UserId then
			return Plot
		end
	end
	return nil
end

local function GetTrustedPlot(Player)
	local Cached = PlayerPlots[Player]
	if Cached and Cached.Parent then
		return Cached
	end
	return GetPlayerPlot(Player)
end

local function WaitForPlot(Player)
	local Attempts = 0
	local WarnedSlow = false
	while true do
		local Plot = GetPlayerPlot(Player)
		if Plot then
			return Plot
		end
		if not Player.Parent then
			return nil
		end
		Attempts += 1
		if Attempts == 100 and not WarnedSlow then
			WarnedSlow = true
			warn("El Plot de " .. Player.Name .. " tarda más de lo esperado en asignarse")
		end
		task.wait(Attempts > 100 and 1 or 0.1)
	end
end

local function InvokeRestore(Player, Plot, Pets, Eggs)
	for Attempt = 1, 20 do
		local Success, Result = pcall(function()
			return RestoreFunction:Invoke(Player, Plot, Pets, Eggs)
		end)

		if Success and Result == true then
			return true
		end

		if Success then
			warn(
				"RestorePlacedData reported failure for "
					.. Player.Name
					.. ", attempt "
					.. Attempt
			)
		else
			warn(
				"RestorePlacedData invoke failed for "
					.. Player.Name
					.. ", attempt "
					.. Attempt
					.. ": "
					.. tostring(Result)
			)
		end

		if not Player.Parent then
			return false
		end

		task.wait(0.25)
	end
	warn(
		"Could not restore pets/eggs for "
			.. Player.Name
			.. " - RestorePlacedData never succeeded"
	)
	return false
end

local function CreateStats(Player)
	local Leaderstats = Player:FindFirstChild("leaderstats")
	if not Leaderstats then
		Leaderstats = Instance.new("Folder")
		Leaderstats.Name = "leaderstats"
		Leaderstats.Parent = Player
	end
	local Money = Leaderstats:FindFirstChild("Money")
	if not Money then
		Money = Instance.new("IntValue")
		Money.Name = "Money"
		Money.Value = 0
		Money.Parent = Leaderstats
	end
	local Speed = Leaderstats:FindFirstChild("Speed")
	if not Speed then
		Speed = Instance.new("IntValue")
		Speed.Name = "Speed"
		Speed.Value = 0
		Speed.Parent = Leaderstats
	end
	return Money, Speed
end

local function CreateTrailsFolder(Player)
	local Trails = Player:FindFirstChild("Trails")
	if not Trails then
		Trails = Instance.new("Folder")
		Trails.Name = "Trails"
		Trails.Parent = Player
	end
	local Equipped = Trails:FindFirstChild("Equipped")
	if not Equipped then
		Equipped = Instance.new("StringValue")
		Equipped.Name = "Equipped"
		Equipped.Value = ""
		Equipped.Parent = Trails
	end
	return Trails
end

local function EnforceSingleTrailsFolder(Player)
	local Found = {}
	for _, Child in ipairs(Player:GetChildren()) do
		if Child.Name == "Trails" and Child:IsA("Folder") then
			table.insert(Found, Child)
		end
	end
	if #Found > 1 then
		warn("[Diagnostic] DUPLICATE Trails folders on", Player.Name, "- count:", #Found, "- merging")
		table.sort(Found, function(A, B)
			return #A:GetChildren() > #B:GetChildren()
		end)
		local Keep = Found[1]
		for Index = 2, #Found do
			local Dupe = Found[Index]
			for _, Child in ipairs(Dupe:GetChildren()) do
				if Child.Name ~= "Equipped" and not Keep:FindFirstChild(Child.Name) then
					Child.Parent = Keep
				end
			end
			Dupe:Destroy()
		end
	end
end

local function GetRelativePosition(Place, Model)
	local Root = Model.PrimaryPart
		or Model:FindFirstChild("HumanoidRootPart")
		or Model:FindFirstChildWhichIsA("BasePart", true)
	if not Root then
		return 0, 0
	end
	local LocalPosition = Place.CFrame:PointToObjectSpace(Root.Position)
	return LocalPosition.X, LocalPosition.Z
end

local function SerializePlacedPets(Plot)
	local Results = {}
	local Place = Plot and Plot:FindFirstChild("Place")
	local Folder = Plot and Plot:FindFirstChild("PlacedPets")
	if not Place or not Folder then
		return Results
	end
	for _, Pet in ipairs(Folder:GetChildren()) do
		if not Pet:IsA("Model") or Pet:GetAttribute("IsPlacedPet") ~= true then
			continue
		end
		local EggType = Pet:GetAttribute("EggType")
		local RigName = Pet:GetAttribute("PetRigName") or Pet.Name
		if not EggType or not RigName then
			continue
		end
		local X, Z = GetRelativePosition(Place, Pet)
		table.insert(Results, {
			EggType = EggType,
			RigName = RigName,
			X = X,
			Z = Z,
			Weight = Pet:GetAttribute("Weight"),
			MoneyPerSecond = Pet:GetAttribute("MoneyPerSecond"),
		})
	end
	return Results
end

local function SerializePlacedEggs(Plot)
	local Results = {}
	local Place = Plot and Plot:FindFirstChild("Place")
	local Folder = Plot and Plot:FindFirstChild("PlacedEggs")
	if not Place or not Folder then
		return Results
	end
	for _, Egg in ipairs(Folder:GetChildren()) do
		if not Egg:IsA("Model") then
			continue
		end
		local EggType = Egg:GetAttribute("EggType") or Egg.Name
		if not EggModule[EggType] then
			continue
		end
		local X, Z = GetRelativePosition(Place, Egg)
		table.insert(Results, {
			EggType = EggType,
			X = X,
			Z = Z,
			EndTime = Egg:GetAttribute("EndTime") or os.time(),
			Ready = Egg:GetAttribute("Ready") == true,
			RewardRig = Egg:GetAttribute("RewardRig"),
		})
	end
	return Results
end

local function FindPetToolData(Tool)
	local EggType = Tool:GetAttribute("EggType")
	local RigName = Tool:GetAttribute("PetRigName") or Tool.Name
	if EggType then
		local EggFolder = PetsToolFolder:FindFirstChild(EggType)
		local Template = EggFolder and EggFolder:FindFirstChild(RigName)
		if Template and Template:IsA("Tool") then
			return { EggType = EggType, RigName = RigName }
		end
	end
	for _, EggFolder in ipairs(PetsToolFolder:GetChildren()) do
		local Template = EggFolder:FindFirstChild(Tool.Name)
		if Template and Template:IsA("Tool") then
			return { EggType = EggFolder.Name, RigName = Tool.Name }
		end
	end
	return nil
end

local function SerializeTools(Player)
	local Results = {}
	local SavedInstances = {}
	local function Scan(Container)
		if not Container then
			return
		end
		for _, Tool in ipairs(Container:GetChildren()) do
			if not Tool:IsA("Tool") or SavedInstances[Tool] then
				continue
			end
			SavedInstances[Tool] = true
			local PetToolData = FindPetToolData(Tool)
			if PetToolData then
				table.insert(Results, {
					Type = "Pet",
					EggType = PetToolData.EggType,
					RigName = PetToolData.RigName,
					Weight = Tool:GetAttribute("Weight"),
					MoneyPerSecond = Tool:GetAttribute("MoneyPerSecond") or 0,
				})
			elseif EggModule[Tool.Name] then
				table.insert(Results, {
					Type = "Egg",
					EggType = Tool.Name,
				})
			end
		end
	end
	Scan(Player:FindFirstChild("Backpack"))
	Scan(Player.Character)
	return Results
end

local function RestoreTools(Player, Tools)
	local Backpack = Player:WaitForChild("Backpack")
	for _, ToolData in ipairs(Tools or {}) do
		if ToolData.Type == "Egg" then
			local Template = EggToolsFolder:FindFirstChild(ToolData.EggType or "")
			if Template and Template:IsA("Tool") then
				local Tool = Template:Clone()
				Tool:SetAttribute("EggType", ToolData.EggType)
				Tool.Parent = Backpack
			else
				warn("No existe EggTool." .. tostring(ToolData.EggType))
			end
		elseif ToolData.Type == "Pet" then
			local EggFolder = PetsToolFolder:FindFirstChild(ToolData.EggType or "")
			local Template = EggFolder and EggFolder:FindFirstChild(ToolData.RigName or "")
			if Template and Template:IsA("Tool") then
				local Tool = Template:Clone()
				Tool:SetAttribute("IsPetTool", true)
				Tool:SetAttribute("EggType", ToolData.EggType)
				Tool:SetAttribute("PetRigName", ToolData.RigName)
				if ToolData.Weight then
					Tool:SetAttribute("Weight", ToolData.Weight)
				end
				Tool:SetAttribute("MoneyPerSecond", ToolData.MoneyPerSecond or 0)
				Tool.Parent = Backpack
			else
				warn("No existe PetsTool." .. tostring(ToolData.EggType) .. "." .. tostring(ToolData.RigName))
			end
		end
	end
end

local function SerializeTrails(Player)
	local Trails = Player:FindFirstChild("Trails")
	if not Trails then
		return { Owned = {}, Equipped = "" }
	end
	local Owned = {}
	for _, Child in ipairs(Trails:GetChildren()) do
		if Child.Name ~= "Equipped" then
			table.insert(Owned, Child.Name)
		end
	end
	local Equipped = Trails:FindFirstChild("Equipped")
	return {
		Owned = Owned,
		Equipped = Equipped and Equipped.Value or "",
	}
end

local function RestoreTrails(Player, TrailsData)
	local Trails = CreateTrailsFolder(Player)
	TrailsData = TrailsData or {}
	for _, TrailID in ipairs(TrailsData.Owned or {}) do
		if not Trails:FindFirstChild(TrailID) then
			local Owned = Instance.new("BoolValue")
			Owned.Name = TrailID
			Owned.Value = true
			Owned.Parent = Trails
		end
	end
	local Equipped = Trails:FindFirstChild("Equipped")
	if Equipped then
		Equipped.Value = TrailsData.Equipped or ""
	end
end

local function SerializeOpeningTools(Player)
	local Folder = Player:FindFirstChild("OpeningTools")
	if not Folder then
		return { Owned = { "MazoMadera" }, Equipped = "MazoMadera" }
	end
	local Owned = {}
	for _, Child in ipairs(Folder:GetChildren()) do
		if Child:IsA("BoolValue") and Child.Value == true then
			table.insert(Owned, Child.Name)
		end
	end
	local Eq = Folder:FindFirstChild("EquippedTool") :: StringValue?
	return {
		Owned = #Owned > 0 and Owned or { "MazoMadera" },
		Equipped = Eq and Eq.Value or "MazoMadera",
	}
end

local function RestoreOpeningTools(Player, ToolsData)
	local Folder = Player:FindFirstChild("OpeningTools")
	if not Folder then
		Folder = Instance.new("Folder")
		Folder.Name = "OpeningTools"
		Folder.Parent = Player
	end
	local Eq = Folder:FindFirstChild("EquippedTool") :: StringValue?
	if not Eq then
		Eq = Instance.new("StringValue")
		Eq.Name = "EquippedTool"
		Eq.Value = "MazoMadera"
		Eq.Parent = Folder
	end

	ToolsData = ToolsData or {}
	local OwnedList = ToolsData.Owned or { "MazoMadera" }
	for _, toolId in ipairs(OwnedList) do
		if not Folder:FindFirstChild(toolId) then
			local b = Instance.new("BoolValue")
			b.Name = toolId
			b.Value = true
			b.Parent = Folder
		end
	end
	if ToolsData.Equipped and ToolsData.Equipped ~= "" then
		Eq.Value = ToolsData.Equipped
	end
end

local function FormatMoney(Amount)
	Amount = math.floor(Amount or 0)
	local Sign = Amount < 0 and "-" or ""
	Amount = math.abs(Amount)
	local Suffixes = {
		{ 1e12, "t" },
		{ 1e9, "b" },
		{ 1e6, "m" },
		{ 1e3, "k" },
	}
	for _, Entry in ipairs(Suffixes) do
		local Threshold = Entry[1]
		local Suffix = Entry[2]
		if Amount >= Threshold then
			local Value = Amount / Threshold
			local Formatted
			if Value >= 100 then
				Formatted = string.format("%.0f", Value)
			elseif Value >= 10 then
				Formatted = string.format("%.1f", Value)
			else
				Formatted = string.format("%.2f", Value)
			end
			Formatted = Formatted:gsub("(%.%d-)0+$", "%1")
			Formatted = Formatted:gsub("%.$", "")
			return Sign .. Formatted .. Suffix
		end
	end
	return Sign .. tostring(Amount)
end

local function CalculateOfflineRate(Pets)
	local Rate = 0
	for _, Pet in ipairs(Pets or {}) do
		local PetData = PetsModule[Pet.RigName]
		if PetData then
			Rate += PetData.MoneyPerSecond or 0
		end
	end
	return Rate * OFFLINE_MULTIPLIER
end

local function ClearPlacedItems(Plot)
	if not Plot then
		return
	end
	local PetsFolder = Plot:FindFirstChild("PlacedPets")
	if PetsFolder then
		for _, Child in ipairs(PetsFolder:GetChildren()) do
			Child:Destroy()
		end
	end
	local EggsFolder = Plot:FindFirstChild("PlacedEggs")
	if EggsFolder then
		for _, Child in ipairs(EggsFolder:GetChildren()) do
			Child:Destroy()
		end
	end
end

local function DestroyOfflineStack(Plot)
	local Stack = SpawnedOfflineStacks[Plot]
	SpawnedOfflineStacks[Plot] = nil
	if Stack and Stack.Parent then
		Stack:Destroy()
	end
end

local function PlayOfflineStackCollectEffect(Stack)
	local Mesh = Stack:FindFirstChild("Mesh", true)
	if Mesh and Mesh:IsA("BasePart") then
		Mesh.Material = Enum.Material.Neon
		Mesh.Color = Color3.fromRGB(255, 255, 255)
		TweenService:Create(
			Mesh,
			TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{ Size = Vector3.new(0.05, 0.05, 0.05) }
		):Play()
	end
	task.delay(0.35, function()
		if Stack.Parent then
			Stack:Destroy()
		end
	end)
end

local function ConnectOfflineStackTouch(Stack, Plot)
	local TouchDebounce = false
	local function OnTouched(Hit)
		local Character = Hit:FindFirstAncestorOfClass("Model")
		local Player = Character and Players:GetPlayerFromCharacter(Character)
		if not Player or TouchDebounce then
			return
		end
		if Plot:GetAttribute("OwnerUserId") ~= Player.UserId then
			return
		end
		local Pending = OfflinePending[Player] or 0
		if Pending <= 0 then
			return
		end
		TouchDebounce = true
		OfflinePending[Player] = 0
		local Money = Player:WaitForChild("leaderstats"):WaitForChild("Money")
		Money.Value += math.floor(Pending)
		if SpawnedOfflineStacks[Plot] == Stack then
			SpawnedOfflineStacks[Plot] = nil
		end
		PlayOfflineStackCollectEffect(Stack)
	end
	for _, Object in ipairs(Stack:GetDescendants()) do
		if Object:IsA("BasePart") then
			Object.Touched:Connect(OnTouched)
		end
	end
end

local function GetOfflineStackHeight(Amount)
	if Amount <= 0 then
		return 0
	end
	local Base = 0.5
	local Extra = 0
	if Amount >= 1000000 then
		Extra = 1.0
	elseif Amount >= 1000 then
		Extra = 0.5
	end
	return Base + Extra
end

local function UpdateOfflineStack(Plot, Amount)
	local OfflinePart = Plot:FindFirstChild("OfflinePart")
	if not OfflinePart or not OfflinePart:IsA("BasePart") then
		return
	end
	if not Amount or Amount <= 0 then
		DestroyOfflineStack(Plot)
		return
	end
	local Stack = SpawnedOfflineStacks[Plot]
	if not Stack or not Stack.Parent then
		Stack = OfflineStackTemplate:Clone()
		if not Stack.PrimaryPart then
			Stack.PrimaryPart = Stack:FindFirstChild("Mesh")
				or Stack:FindFirstChildWhichIsA("BasePart", true)
		end
		Stack.Parent = workspace
		SpawnedOfflineStacks[Plot] = Stack
		ConnectOfflineStackTouch(Stack, Plot)
	end
	local HeightOffset = GetOfflineStackHeight(Amount)
	if Stack.PrimaryPart then
		Stack:PivotTo(
			CFrame.new(OfflinePart.Position + Vector3.new(0, HeightOffset, 0))
				* OfflineStackRotation
		)
	end
	local Board = Stack:FindFirstChild("OfflineBoard", true)
	local Generated = Board and Board:FindFirstChild("Generated", true)
	if Generated and Generated:IsA("TextLabel") then
		Generated.Text = "$" .. FormatMoney(Amount)
	end
end

local function ResetPlot(Plot)
	if not Plot then
		return
	end
	DestroyOfflineStack(Plot)
	ClearPlacedItems(Plot)
	Plot:SetAttribute("TreadmillLevel", 0)
	Plot:SetAttribute("PlotLevel", 1)
	PlotReset:Fire(Plot)
end

local function OnPlotOwnerChanged(Plot)
	local NewOwner = Plot:GetAttribute("OwnerUserId")
	if LastKnownOwner[Plot] == NewOwner then
		return
	end
	LastKnownOwner[Plot] = NewOwner
	if NewOwner then
		ResetPlot(Plot)
	end
end

local function WatchPlotOwnership(Plot)
	if PlotOwnershipConnections[Plot] then
		PlotOwnershipConnections[Plot]:Disconnect()
		PlotOwnershipConnections[Plot] = nil
	end
	LastKnownOwner[Plot] = Plot:GetAttribute("OwnerUserId")
	local Connection = Plot:GetAttributeChangedSignal("OwnerUserId"):Connect(function()
		OnPlotOwnerChanged(Plot)
	end)
	PlotOwnershipConnections[Plot] = Connection
end

local function SetupOfflinePart(Plot)
	local OfflinePart = Plot:FindFirstChild("OfflinePart")
	if not OfflinePart or not OfflinePart:IsA("BasePart") then
		return
	end
	ResetPlot(Plot)
	WatchPlotOwnership(Plot)
end

local function SyncProfileData(Player, Profile)
	if not PlayerDataReady[Player] then
		return
	end

	local Money, Speed = CreateStats(Player)
	local Plot = GetTrustedPlot(Player)
	local CanTrustPlot = Plot ~= nil and PetsRestored[Player] == true
	local Pets = Profile.Data.Pets or {}
	local Eggs = Profile.Data.Eggs or {}
	if CanTrustPlot then
		Pets = SerializePlacedPets(Plot)
		Eggs = SerializePlacedEggs(Plot)
	end
	Profile.Data.Money = Money.Value
	Profile.Data.Speed = Speed.Value
	Profile.Data.TreadmillLevel = Player:GetAttribute("TreadmillLevel") or 0
	Profile.Data.PlotLevel = Player:GetAttribute("PlotLevel") or 1
	Profile.Data.Pets = Pets
	Profile.Data.Eggs = Eggs
	Profile.Data.Tools = SerializeTools(Player)
	Profile.Data.OpeningTools = SerializeOpeningTools(Player)
	Profile.Data.Trails = SerializeTrails(Player)
	Profile.Data.OfflinePending = OfflinePending[Player] or 0
	Profile.Data.OfflineRate = CalculateOfflineRate(Pets)
	Profile.Data.LastSeen = os.time()
	Profile.Data.Index = IndexData.Serialize(Player)
end

local function InitializePlayer(Player, Profile)
	local Money, Speed = CreateStats(Player)
	PetsRestored[Player] = false
	PlayerDataReady[Player] = false
	IndexData.Init(Player, Profile.Data.Index)
	Money.Value = tonumber(Profile.Data.Money) or 0
	Speed.Value = tonumber(Profile.Data.Speed) or 0
	Player:SetAttribute("TreadmillLevel", tonumber(Profile.Data.TreadmillLevel) or 0)
	Player:SetAttribute("PlotLevel", tonumber(Profile.Data.PlotLevel) or 1)
	local LastSeen = tonumber(Profile.Data.LastSeen) or os.time()
	local OfflineRate = tonumber(Profile.Data.OfflineRate) or 0
	local ExistingPending = tonumber(Profile.Data.OfflinePending) or 0
	local SecondsAway = math.max(0, os.time() - LastSeen)
	OfflinePending[Player] = ExistingPending + SecondsAway * OfflineRate
	RestoreTools(Player, Profile.Data.Tools or {})
	RestoreOpeningTools(Player, Profile.Data.OpeningTools)
	RestoreTrails(Player, Profile.Data.Trails)
	EnforceSingleTrailsFolder(Player)

	if not Player.Parent then
		return
	end

	PlayerDataReady[Player] = true

	local Plot = WaitForPlot(Player)
	if Plot and Player.Parent then
		PlayerPlots[Player] = Plot
		Plot:SetAttribute("TreadmillLevel", Player:GetAttribute("TreadmillLevel"))
		Plot:SetAttribute("PlotLevel", Player:GetAttribute("PlotLevel"))
		UpdateOfflineStack(Plot, OfflinePending[Player])
		ClearPlacedItems(Plot)

		local SavedPets = Profile.Data.Pets or {}
		local SavedEggs = Profile.Data.Eggs or {}
		local RestoreSuccess
		if #SavedPets == 0 and #SavedEggs == 0 then
			RestoreSuccess = true
		else
			RestoreSuccess = InvokeRestore(Player, Plot, SavedPets, SavedEggs)
		end
		PetsRestored[Player] = RestoreSuccess
		if not RestoreSuccess then
			warn(
				"[InitializePlayer] Pet/Egg restore failed for "
					.. Player.Name
					.. " - keeping previously saved Pets/Eggs data untouched"
			)
		end
	end

	if Player.Parent then
		Player:SetAttribute("DataLoaded", true)
		DataSyncRemote:FireClient(Player)
	end
end

local function CaptureToolsOnDeath(Player)
	PendingRespawnTools[Player] = SerializeTools(Player)
end

local function HookHumanoidDeath(Character, Player)
	local Humanoid = Character:WaitForChild("Humanoid", 10)
	if not Humanoid then
		return
	end
	Humanoid.Died:Connect(function()
		CaptureToolsOnDeath(Player)
	end)
end

local function ConnectToolProtection(Player)
	Player.CharacterAdded:Connect(function(Character)
		local Pending = PendingRespawnTools[Player]
		if Pending then
			PendingRespawnTools[Player] = nil
			RestoreTools(Player, Pending)
		end
		HookHumanoidDeath(Character, Player)
	end)
	if Player.Character then
		HookHumanoidDeath(Player.Character, Player)
	end
end

local function PlayerAdded(Player)
	Player:SetAttribute("DataLoaded", false)
	if Player:GetAttribute("TreadmillLevel") == nil then
		Player:SetAttribute("TreadmillLevel", 0)
	end
	if Player:GetAttribute("PlotLevel") == nil then
		Player:SetAttribute("PlotLevel", 1)
	end
	CreateStats(Player)
	CreateTrailsFolder(Player)
	EnforceSingleTrailsFolder(Player)
	ConnectToolProtection(Player)
	task.spawn(function()
		local Profile = PlayerProfileStore:StartSessionAsync(GetKey(Player), {
			Cancel = function()
				return Player.Parent == nil
			end,
		})
		if not Profile then
			if Player.Parent then
				Player:Kick("No se pudieron cargar tus datos. Vuelve a entrar.")
			end
			return
		end
		Profile:AddUserId(Player.UserId)
		Profile:Reconcile()
		Profile.OnSessionEnd:Connect(function()
			Profiles[Player] = nil
			OfflinePending[Player] = nil
			PetsRestored[Player] = nil
			PlayerDataReady[Player] = nil
			PlayerPlots[Player] = nil
			if Player.Parent then
				Player:Kick("Tu sesión de datos terminó. Vuelve a entrar.")
			end
		end)
		if not Player.Parent then
			Profile:EndSession()
			return
		end
		Profiles[Player] = Profile
		InitializePlayer(Player, Profile)
	end)
end

Players.PlayerAdded:Connect(PlayerAdded)

Players.PlayerRemoving:Connect(function(Player)
	local Plot = GetTrustedPlot(Player)
	local Pending = PendingRespawnTools[Player]
	if Pending then
		PendingRespawnTools[Player] = nil
		RestoreTools(Player, Pending)
	end
	local Profile = Profiles[Player]
	if Profile then
		SyncProfileData(Player, Profile)
	end
	if Plot then
		ResetPlot(Plot)
	end
	if Profile then
		Profile:EndSession()
	end
	Profiles[Player] = nil
	OfflinePending[Player] = nil
	PetsRestored[Player] = nil
	PlayerDataReady[Player] = nil
	PlayerPlots[Player] = nil
	IndexData.Remove(Player)
end)

for _, Plot in ipairs(PlotsFolder:GetChildren()) do
	SetupOfflinePart(Plot)
end

PlotsFolder.ChildAdded:Connect(function(Plot)
	task.defer(function()
		SetupOfflinePart(Plot)
	end)
end)

for _, Player in ipairs(Players:GetPlayers()) do
	task.spawn(PlayerAdded, Player)
end

task.spawn(function()
	while true do
		task.wait(AUTOSAVE_TIME)
		for Player, Profile in pairs(Profiles) do
			task.spawn(function()
				SyncProfileData(Player, Profile)
				if Profile:IsActive() then
					Profile:Save()
				end
			end)
		end
	end
end)

game:BindToClose(function()
	for Player, Profile in pairs(Profiles) do
		SyncProfileData(Player, Profile)
		if Profile:IsActive() then
			Profile:Save()
		end
	end
end)