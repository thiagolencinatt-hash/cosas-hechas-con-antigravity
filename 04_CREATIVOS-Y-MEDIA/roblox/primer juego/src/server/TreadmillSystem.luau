local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Map = workspace:WaitForChild("Map")
local PlotsFolder = Map:WaitForChild("Plots")

local Modules = ReplicatedStorage:WaitForChild("Modules")

local UpgradeModule = require(
	Modules:WaitForChild("UpgradeModule")
)

local TrailConfigurations = require(
	Modules:WaitForChild("TrailConfigurations")
)

local TreadmillData =
	UpgradeModule.TreadmillUpgrade

local PlotUpgradeData =
	UpgradeModule.PlotUpgrade

local Models = ReplicatedStorage:WaitForChild("Models")
local TreadmillsFolder = Models:WaitForChild("Treadmills")

local BASE_WALK_SPEED = 16
local WALK_SPEED_PER_SPEED_POINT = 0.15
local STARTING_SPEED_STAT = 15
local TRAINING_DELAY = 0.5

local PurchaseDebounces = {}
local TrainingPlayers = {}
local TrainingCooldowns = {}
local TreadmillTouchConnections = {}

local Remotes =
	ReplicatedStorage:FindFirstChild("Remotes")

if not Remotes then
	Remotes = Instance.new("Folder")
	Remotes.Name = "Remotes"
	Remotes.Parent = ReplicatedStorage
end

local PurchaseRemote =
	Remotes:FindFirstChild("PurchaseUpgrade")

if not PurchaseRemote then
	PurchaseRemote = Instance.new("RemoteEvent")
	PurchaseRemote.Name = "PurchaseUpgrade"
	PurchaseRemote.Parent = Remotes
end

local function GetLeaderstats(Player)
	local Leaderstats =
		Player:FindFirstChild("leaderstats")

	if not Leaderstats then
		Leaderstats = Instance.new("Folder")
		Leaderstats.Name = "leaderstats"
		Leaderstats.Parent = Player
	end

	return Leaderstats
end

local function GetSpeed(Player)
	local Leaderstats = GetLeaderstats(Player)
	local Speed = Leaderstats:FindFirstChild("Speed")

	if not Speed then
		Speed = Instance.new("IntValue")
		Speed.Name = "Speed"
		Speed.Value = STARTING_SPEED_STAT
		Speed.Parent = Leaderstats
	end

	return Speed
end

local function GetTrailSpeedBonus(Player)
	local Trails = Player:FindFirstChild("Trails")

	if not Trails then
		return 0
	end

	local Equipped = Trails:FindFirstChild("Equipped")

	if not Equipped or not Equipped:IsA("StringValue") or Equipped.Value == "" then
		return 0
	end

	local Info = TrailConfigurations.GetTrailById(Equipped.Value)

	if not Info or not Info.SpeedBoost then
		return 0
	end

	return Info.SpeedBoost
end

local function UpdateWalkSpeed(Player)
	local Character = Player.Character

	local Humanoid = Character
		and Character:FindFirstChildOfClass(
			"Humanoid"
		)

	if not Humanoid then
		return
	end

	local adminSpeed = Player:GetAttribute("AdminWalkSpeed")
	if typeof(adminSpeed) == "number" and adminSpeed > 0 then
		Humanoid.WalkSpeed = adminSpeed
		return
	end

	local Speed = GetSpeed(Player)

	Humanoid.WalkSpeed =
		BASE_WALK_SPEED
		+ Speed.Value * WALK_SPEED_PER_SPEED_POINT
end

local function PlayCharacterRunAnimation(
	Character,
	Humanoid
)
	local Animator =
		Humanoid:FindFirstChildOfClass("Animator")

	if not Animator then
		Animator = Instance.new("Animator")
		Animator.Parent = Humanoid
	end

	local AnimateScript =
		Character:FindFirstChild("Animate")

	if not AnimateScript then
		warn(Character.Name .. " does not contain Animate")
		return nil
	end

	local RunFolder =
		AnimateScript:FindFirstChild("run")

	if not RunFolder then
		warn("Animate.run was not found")
		return nil
	end

	local RunAnimation =
		RunFolder:FindFirstChildWhichIsA(
			"Animation",
			true
		)

	if not RunAnimation
		or RunAnimation.AnimationId == ""
	then
		warn("The run animation was not found")
		return nil
	end

	local Success, RunTrack = pcall(function()
		return Animator:LoadAnimation(
			RunAnimation
		)
	end)

	if not Success or not RunTrack then
		warn("Could not load the run animation")
		return nil
	end

	RunTrack.Name = "TreadmillRunAnimation"
	RunTrack.Priority =
		Enum.AnimationPriority.Action

	RunTrack.Looped = true
	RunTrack:Play(0.15)
	RunTrack:AdjustSpeed(1)

	return RunTrack
end

local function SetUpgradeSignVisible(
	UpgradePart,
	Visible
)
	local SurfaceGui =
		UpgradePart:FindFirstChildWhichIsA(
			"SurfaceGui",
			true
		)

	if UpgradePart:IsA("BasePart") then
		UpgradePart.Transparency =
			Visible and 0 or 1

		UpgradePart.CanCollide = Visible
		UpgradePart.CanTouch = Visible
		UpgradePart.CanQuery = Visible
	end

	for _, Object in ipairs(
		UpgradePart:GetDescendants()
		) do
		if Object:IsA("BasePart") then
			Object.Transparency =
				Visible and 0 or 1

			Object.CanCollide = Visible
			Object.CanTouch = Visible
			Object.CanQuery = Visible
		end
	end

	if SurfaceGui then
		SurfaceGui.Enabled = Visible
	end
end

local function OwnsPlot(Player, Plot)
	return Plot:GetAttribute("OwnerUserId")
		== Player.UserId
end

local function StartTraining(
	Player,
	Plot,
	TreadPart
)
	if TrainingPlayers[Player]
		or TrainingCooldowns[Player]
	then
		return
	end

	if not OwnsPlot(Player, Plot) then
		return
	end

	local Level =
		Plot:GetAttribute("TreadmillLevel") or 0

	local LevelData = TreadmillData[Level]

	if Level <= 0 or not LevelData then
		return
	end

	local Character = Player.Character

	local RootPart = Character
		and Character:FindFirstChild(
			"HumanoidRootPart"
		)

	local Humanoid = Character
		and Character:FindFirstChildOfClass(
			"Humanoid"
		)

	if not Character
		or not RootPart
		or not Humanoid
		or Humanoid.Health <= 0
	then
		return
	end

	TrainingPlayers[Player] = true

	Character:PivotTo(
		TreadPart.CFrame
			* CFrame.new(
				0,
				TreadPart.Size.Y / 2 + 3,
				0
			)
	)

	local RunTrack =
		PlayCharacterRunAnimation(
			Character,
			Humanoid
		)

	local PlayerAttachment =
		Instance.new("Attachment")

	PlayerAttachment.Name =
		"TreadmillPlayerAttachment"

	PlayerAttachment.Parent = RootPart

	local TreadmillAttachment =
		Instance.new("Attachment")

	TreadmillAttachment.Name =
		"TreadmillCenterAttachment"

	TreadmillAttachment.Position = Vector3.new(
		0,
		TreadPart.Size.Y / 2 + 3,
		0
	)

	TreadmillAttachment.Parent = TreadPart

	local AlignPosition =
		Instance.new("AlignPosition")

	AlignPosition.Name =
		"TreadmillAlignPosition"

	AlignPosition.Attachment0 =
		PlayerAttachment

	AlignPosition.Attachment1 =
		TreadmillAttachment

	AlignPosition.RigidityEnabled = true
	AlignPosition.MaxForce = math.huge
	AlignPosition.Responsiveness = 200
	AlignPosition.Parent = RootPart

	local AlignOrientation =
		Instance.new("AlignOrientation")

	AlignOrientation.Name =
		"TreadmillAlignOrientation"

	AlignOrientation.Attachment0 =
		PlayerAttachment

	AlignOrientation.Attachment1 =
		TreadmillAttachment

	AlignOrientation.RigidityEnabled = true
	AlignOrientation.MaxTorque = math.huge
	AlignOrientation.Responsiveness = 200
	AlignOrientation.Parent = RootPart

	local Active = true
	local JumpConnection
	local StateConnection
	local DiedConnection
	local CharacterRemovingConnection
	local FractionalCarry = 0

	local function StopTraining(Jumped)
		if not Active then
			return
		end

		Active = false
		TrainingPlayers[Player] = nil
		TrainingCooldowns[Player] = true

		if RunTrack then
			RunTrack:Stop(0.15)
			RunTrack:Destroy()
			RunTrack = nil
		end

		if JumpConnection then
			JumpConnection:Disconnect()
		end

		if StateConnection then
			StateConnection:Disconnect()
		end

		if DiedConnection then
			DiedConnection:Disconnect()
		end

		if CharacterRemovingConnection then
			CharacterRemovingConnection:Disconnect()
		end

		if AlignPosition.Parent then
			AlignPosition:Destroy()
		end

		if AlignOrientation.Parent then
			AlignOrientation:Destroy()
		end

		if PlayerAttachment.Parent then
			PlayerAttachment:Destroy()
		end

		if TreadmillAttachment.Parent then
			TreadmillAttachment:Destroy()
		end

		if Jumped
			and Humanoid.Parent
			and Humanoid.Health > 0
		then
			Humanoid.Jump = true
		end

		task.delay(1, function()
			TrainingCooldowns[Player] = nil
		end)
	end

	JumpConnection =
		Humanoid:GetPropertyChangedSignal(
			"Jump"
		):Connect(function()
		if Humanoid.Jump then
			StopTraining(true)
		end
	end)

	StateConnection =
		Humanoid.StateChanged:Connect(function(
			_,
			NewState
		)
		if NewState
			== Enum.HumanoidStateType.Jumping
		then
			StopTraining(true)
		end
	end)

	DiedConnection =
		Humanoid.Died:Connect(function()
			StopTraining(false)
		end)

	CharacterRemovingConnection =
		Player.CharacterRemoving:Connect(function(
			RemovingCharacter
		)
		if RemovingCharacter == Character then
			StopTraining(false)
		end
	end)

	task.spawn(function()
		while Active
			and Player.Parent
			and Character.Parent
			and Humanoid.Health > 0
		do
			task.wait(TRAINING_DELAY)

			if not Active then
				break
			end

			local CurrentLevel =
				Plot:GetAttribute(
					"TreadmillLevel"
				) or 0

			local CurrentData =
				TreadmillData[CurrentLevel]

			if not CurrentData then
				StopTraining(false)
				break
			end

			local Speed = GetSpeed(Player)
			local TrailBonus = GetTrailSpeedBonus(Player)
			local RawGain = (CurrentData.Speed or 1) + TrailBonus + FractionalCarry
			local WholeGain = math.floor(RawGain)

			FractionalCarry = RawGain - WholeGain

			Speed.Value += WholeGain

			UpdateWalkSpeed(Player)
		end
	end)
end

local function SpawnTreadmillModel(Plot, TreadmillPos, Level)
	local Existing = Plot:FindFirstChild("TreadmillModel")

	if Existing then
		if Existing:GetAttribute("Level") == Level then
			return Existing:FindFirstChild(
				"TreadPart",
				true
			)
		end

		Existing:Destroy()
	end

	if Level <= 0 then
		return nil
	end

	local ModelTemplate =
		TreadmillsFolder:FindFirstChild(
			tostring(Level)
		)

	if not ModelTemplate
		or not ModelTemplate:IsA("Model")
	then
		warn(
			"Models.Treadmills does not contain "
				.. tostring(Level)
		)

		return nil
	end

	local NewModel = ModelTemplate:Clone()
	NewModel.Name = "TreadmillModel"
	NewModel:SetAttribute("Level", Level)

	for _, Object in ipairs(
		NewModel:GetDescendants()
		) do
		if Object:IsA("BasePart") then
			Object.Anchored = true
		end
	end

	NewModel.Parent = Plot
	NewModel:PivotTo(TreadmillPos.CFrame)

	local TreadPart =
		NewModel:FindFirstChild("TreadPart", true)

	if not TreadPart then
		warn(
			ModelTemplate.Name
				.. " needs a TreadPart"
		)

		return nil
	end

	TreadPart.CanCollide = true
	TreadPart.CanTouch = true

	return TreadPart
end

local function ConnectTreadmillTouch(Plot, TreadPart)
	local ExistingConnection =
		TreadmillTouchConnections[Plot]

	if ExistingConnection then
		ExistingConnection:Disconnect()
		TreadmillTouchConnections[Plot] = nil
	end

	if not TreadPart then
		return
	end

	TreadmillTouchConnections[Plot] =
		TreadPart.Touched:Connect(function(Hit)
			local Character =
			Hit:FindFirstAncestorOfClass("Model")

			local Player = Character
			and Players:GetPlayerFromCharacter(
				Character
			)

			if Player then
				StartTraining(
					Player,
					Plot,
					TreadPart
				)
			end
		end)
end

local function SyncPlot(Player, Plot)
	if not Player
		or not Plot
		or not OwnsPlot(Player, Plot)
	then
		return
	end

	local TreadmillLevel =
		Player:GetAttribute("TreadmillLevel") or 0

	local PlotLevel =
		Player:GetAttribute("PlotLevel") or 1

	Plot:SetAttribute(
		"TreadmillLevel",
		TreadmillLevel
	)

	Plot:SetAttribute(
		"PlotLevel",
		PlotLevel
	)

	local TreadmillPos =
		Plot:FindFirstChild("TreadmillPos")

	local TreadPart = nil

	if TreadmillPos then
		TreadPart = SpawnTreadmillModel(
			Plot,
			TreadmillPos,
			TreadmillLevel
		)
	end

	ConnectTreadmillTouch(Plot, TreadPart)

	local TreadmillUpgradePart =
		Plot:FindFirstChild(
			"TreadmillUpgradePart"
		)

	if TreadmillUpgradePart then
		SetUpgradeSignVisible(
			TreadmillUpgradePart,
			TreadmillLevel > 0
		)

	end
end

local function SyncPlotOwner(Plot)
	local OwnerUserId =
		Plot:GetAttribute("OwnerUserId")

	if not OwnerUserId then
		return
	end

	local Player =
		Players:GetPlayerByUserId(OwnerUserId)

	if Player then
		SyncPlot(Player, Plot)
	end
end

local function GetCost(Data)
	if not Data then
		return nil
	end

	if string.lower(tostring(Data.Cost))
		== "free"
	then
		return 0
	end

	return tonumber(Data.Cost)
end

local function PurchaseUpgrade(
	Player,
	Plot,
	UpgradeType
)
	if PurchaseDebounces[Player] then
		return
	end

	if typeof(Plot) ~= "Instance"
		or not Plot:IsDescendantOf(PlotsFolder)
		or not OwnsPlot(Player, Plot)
	then
		local resolvedPlot = nil
		for _, p in ipairs(PlotsFolder:GetChildren()) do
			if OwnsPlot(Player, p) then
				resolvedPlot = p
				break
			end
		end
		if resolvedPlot then
			Plot = resolvedPlot
		else
			return
		end
	end

	local Leaderstats =
		Player:FindFirstChild("leaderstats")

	local Money = Leaderstats
		and Leaderstats:FindFirstChild("Money")

	if not Money then
		return
	end

	local CurrentTreadmill =
		math.max(1, Player:GetAttribute("TreadmillLevel") or 1)

	local CurrentPlot =
		math.max(1, Player:GetAttribute("PlotLevel") or 1)

	local NewLevel
	local UpgradeData
	local AttributeName

	if UpgradeType == "Main" then
		NewLevel = CurrentPlot + 1
		UpgradeData =
			PlotUpgradeData[NewLevel]

		AttributeName = "PlotLevel"

	elseif UpgradeType == "Treadmill" then
		NewLevel = CurrentTreadmill + 1

		UpgradeData =
			TreadmillData[NewLevel]

		AttributeName = "TreadmillLevel"
	else
		return
	end

	if not UpgradeData then
		return
	end

	local Cost = GetCost(UpgradeData)

	if not Cost or Money.Value < Cost then
		local N = Remotes:FindFirstChild("Notify")
		if N and Cost then
			N:FireClient(Player, "💸 Te faltan $" .. tostring(math.floor(Cost - Money.Value)) .. " para mejorar", Color3.fromRGB(255, 90, 90), 2.5)
		end
		return
	end

	PurchaseDebounces[Player] = true

	Money.Value -= Cost

	Player:SetAttribute(
		AttributeName,
		NewLevel
	)

	SyncPlot(Player, Plot)
	if AttributeName == "TreadmillLevel" then
		local N = Remotes:FindFirstChild("Notify")
		if N then
			N:FireClient(Player, "🏃 ¡Cinta mejorada a NIVEL " .. NewLevel .. "!", Color3.fromRGB(120, 255, 90), 3)
		end
	end

	task.delay(0.4, function()
		PurchaseDebounces[Player] = nil
	end)
end

PurchaseRemote.OnServerEvent:Connect(function(
	Player,
	Plot,
	UpgradeType
)
	PurchaseUpgrade(
		Player,
		Plot,
		UpgradeType
	)
end)

local function ConnectPlot(Plot)
	local TreadmillUpgradePart =
		Plot:WaitForChild(
			"TreadmillUpgradePart",
			10
		)

	Plot:WaitForChild("TreadmillPos", 10)

	if TreadmillUpgradePart then
		SetUpgradeSignVisible(
			TreadmillUpgradePart,
			false
		)

		local Prompt = TreadmillUpgradePart:FindFirstChild("MejorarCintaPrompt") :: ProximityPrompt?
		if not Prompt then
			Prompt = Instance.new("ProximityPrompt")
			Prompt.Name = "MejorarCintaPrompt"
			Prompt.ActionText = "Mejorar cinta"
			Prompt.ObjectText = "Cinta de correr"
			Prompt.HoldDuration = 0.2
			Prompt.MaxActivationDistance = 14
			Prompt.RequiresLineOfSight = false
			Prompt.Parent = TreadmillUpgradePart
		end
		Prompt.Triggered:Connect(function(TriggeringPlayer)
			PurchaseUpgrade(TriggeringPlayer, Plot, "Treadmill")
		end)
	end

	Plot:GetAttributeChangedSignal(
		"OwnerUserId"
	):Connect(function()
		SyncPlotOwner(Plot)
	end)

	SyncPlotOwner(Plot)
end

local function ConnectPlayer(Player)
	if Player:GetAttribute("TreadmillLevel") == nil then
		Player:SetAttribute("TreadmillLevel", 1)
	end

	if Player:GetAttribute("PlotLevel") == nil then
		Player:SetAttribute("PlotLevel", 1)
	end

	local Speed = GetSpeed(Player)

	Speed:GetPropertyChangedSignal(
		"Value"
	):Connect(function()
		UpdateWalkSpeed(Player)
	end)

	Player:GetAttributeChangedSignal(
		"TreadmillLevel"
	):Connect(function()
		for _, Plot in ipairs(
			PlotsFolder:GetChildren()
			) do
			if OwnsPlot(Player, Plot) then
				SyncPlot(Player, Plot)
			end
		end
	end)

	Player:GetAttributeChangedSignal(
		"PlotLevel"
	):Connect(function()
		for _, Plot in ipairs(
			PlotsFolder:GetChildren()
			) do
			if OwnsPlot(Player, Plot) then
				SyncPlot(Player, Plot)
			end
		end
	end)

	Player.CharacterAdded:Connect(function(Character)
		Character:WaitForChild("Humanoid")

		task.wait()
		UpdateWalkSpeed(Player)
	end)

	if Player.Character then
		task.defer(function()
			Player.Character:WaitForChild("Humanoid")
			UpdateWalkSpeed(Player)
		end)
	end
end

Players.PlayerAdded:Connect(ConnectPlayer)

Players.PlayerRemoving:Connect(function(Player)
	PurchaseDebounces[Player] = nil
	TrainingPlayers[Player] = nil
	TrainingCooldowns[Player] = nil
end)

for _, Player in ipairs(Players:GetPlayers()) do
	ConnectPlayer(Player)
end

for _, Plot in ipairs(PlotsFolder:GetChildren()) do
	task.spawn(ConnectPlot, Plot)
end

PlotsFolder.ChildAdded:Connect(function(Plot)
	task.spawn(ConnectPlot, Plot)
end)
