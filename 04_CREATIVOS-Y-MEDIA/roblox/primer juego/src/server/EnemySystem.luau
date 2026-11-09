--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local RemotesFolder = ReplicatedStorage:FindFirstChild("Remotes") :: Folder
if not RemotesFolder then
	RemotesFolder = Instance.new("Folder")
	RemotesFolder.Name = "Remotes"
	RemotesFolder.Parent = ReplicatedStorage
end

local function GetOrCreateRemote(Name: string, ClassName: string?): Instance
	local Remote = RemotesFolder:FindFirstChild(Name)
	if not Remote then
		Remote = Instance.new(ClassName or "RemoteEvent")
		Remote.Name = Name
		Remote.Parent = RemotesFolder
	end
	return Remote
end

local EggSoundRemote = GetOrCreateRemote("EggSound") :: RemoteEvent
local DropEggRemote = GetOrCreateRemote("DropEgg") :: RemoteEvent
local NotifyRemote = GetOrCreateRemote("Notify") :: RemoteEvent
local ClaimEggShellEvent = GetOrCreateRemote("ClaimEggShell", "BindableEvent") :: BindableEvent
local ResetEggShellEvent = GetOrCreateRemote("ResetEggShell", "BindableEvent") :: BindableEvent
local TeleportHomeRemote = GetOrCreateRemote("TeleportHome") :: RemoteEvent

local function Notify(Player: Player?, Text: string, Color: Color3?, Duration: number?)
	if not Player then return end
	NotifyRemote:FireClient(Player, Text, Color or Color3.fromRGB(255, 255, 255), Duration or 3)
end

local Map = workspace:WaitForChild("Map")
local EggsFolder = Map:WaitForChild("Eggs")
local EnemiesFolder = Map:WaitForChild("EnemyPos")
local PlotsFolder = Map:WaitForChild("Plots")

local ZonesFolder = Map:WaitForChild("Zones")
local SafeZoneFolder = ZonesFolder:WaitForChild("SafeZone")
local SafeZonePart = SafeZoneFolder:WaitForChild("InteractPart") :: BasePart

local Modules = ReplicatedStorage:WaitForChild("Modules")
local EnemyModule = require(Modules:WaitForChild("EnemyModule"))
local EggModule = require(Modules:WaitForChild("EggModule"))
local SafeTiers = require(Modules:WaitForChild("SafeTiers"))

local ToolGenerator = require(ServerStorage:WaitForChild("ToolGenerator"))
local EggToolsFolder = select(1, ToolGenerator.EnsureGenerated())

local Boards = ServerStorage:WaitForChild("Assets"):WaitForChild("Boards")
local EggReGenTemplate = Boards:WaitForChild("EggReGen")
local DespawnTemplate = Boards:WaitForChild("Despawn")

local EGG_DISTANCE = 0
local EGG_HEIGHT = 3.8
local ENEMY_UPDATE_TIME = 0.15
local ENEMY_ARRIVAL_DISTANCE = 1.5
local ENEMY_DEFAULT_TURN_SPEED = 10
local ENEMY_CHASE_DELAY = 0.1
local ENEMY_EGG_ALERT_DISTANCE = 65
local ENEMY_ARREST_DISTANCE = 4.5
local GRAB_ACTIVATION_DISTANCE = 10
local PICKUP_DROPPED_DISTANCE = 10
local PATROL_WALK_SPEED = 12
local ZONE_LEASH_MARGIN = 26      -- studs fuera de su zona antes de abandonar la persecucion
local PATROL_MARGIN = 16          -- distancia minima a los muros de la zona
local STUCK_TIME = 2.2            -- segundos sin avanzar para considerarse atascado
local STUCK_MIN_MOVE = 1.2        -- avance minimo esperado en ese lapso
local STEER_PROBE = 11            -- alcance del sensor de obstaculos

local PlayerEggs: { [Player]: any } = {}
local EggOwners: { [Instance]: Player } = {}
local LockedEggModels: { [Instance]: boolean } = {}
local DroppedEggs: { [Instance]: any } = {}

local PlayerPlots: { [Player]: Instance } = {}
local PlotOwners: { [Instance]: Player } = {}

local SafeZoneDebounce: { [Player]: boolean } = {}
local EnemyHitDebounce: { [Player]: boolean } = {}

local EnemyRegistry: { [Model]: any } = {}
local AlertEnemyToDroppedEgg: (DroppedInfo: any, DropPosition: Vector3) -> ()

local function GetPlotInfo(Plot: Instance): Frame?
	local Sign = Plot:FindFirstChild("Sign")
	local InfoPart = Sign and Sign:FindFirstChild("InfoPart")
	local InfoSurface = InfoPart and InfoPart:FindFirstChild("InfoSurface")
	return InfoSurface and InfoSurface:FindFirstChild("InfoFrame") :: Frame?
end

local function UpdatePlotInfo(Plot: Instance, Player: Player)
	local InfoFrame = GetPlotInfo(Plot)
	if not InfoFrame then return end

	local PlayerLogo = InfoFrame:FindFirstChild("PlayerLogo") :: ImageLabel?
	local PlayerName = InfoFrame:FindFirstChild("PlayerName") :: TextLabel?

	if PlayerName then
		PlayerName.Text = "Base de " .. Player.Name
	end

	if PlayerLogo then
		local Success, Image = pcall(function()
			return Players:GetUserThumbnailAsync(
				Player.UserId,
				Enum.ThumbnailType.HeadShot,
				Enum.ThumbnailSize.Size420x420
			)
		end)
		if Success then
			PlayerLogo.Image = Image
		end
	end
end

local function ClearPlotInfo(Plot: Instance)
	local InfoFrame = GetPlotInfo(Plot)
	if not InfoFrame then return end

	local PlayerLogo = InfoFrame:FindFirstChild("PlayerLogo") :: ImageLabel?
	local PlayerName = InfoFrame:FindFirstChild("PlayerName") :: TextLabel?

	if PlayerLogo then PlayerLogo.Image = "" end
	if PlayerName then PlayerName.Text = "Parcela Libre" end
end

local function AssignPlot(Player: Player): Instance?
	if PlayerPlots[Player] then
		return PlayerPlots[Player]
	end

	for _, Plot in ipairs(PlotsFolder:GetChildren()) do
		if not PlotOwners[Plot] then
			PlotOwners[Plot] = Player
			PlayerPlots[Player] = Plot
			Player:SetAttribute("PlotName", Plot.Name)
			Plot:SetAttribute("OwnerUserId", Player.UserId)
			UpdatePlotInfo(Plot, Player)
			return Plot
		end
	end

	warn("No available Plot for " .. Player.Name)
	return nil
end

local function TeleportToPlot(Player: Player)
	local Plot = PlayerPlots[Player] or AssignPlot(Player)
	if not Plot then return end

	local PlayerSpawn = Plot:FindFirstChild("PlayerSpawn") :: BasePart?
	if not PlayerSpawn then
		warn(Plot.Name .. " needs a PlayerSpawn")
		return
	end

	local Character = Player.Character
	if not Character or not Character:FindFirstChild("HumanoidRootPart") then
		return
	end

	Character:PivotTo(PlayerSpawn.CFrame * CFrame.new(0, 3, 0))
end

local function SetEggPromptEnabled(SourceModel: Instance, Enabled: boolean)
	for _, Object in ipairs(SourceModel:GetDescendants()) do
		if Object:IsA("ProximityPrompt") then
			Object.Enabled = Enabled
		end
	end
end

local function HideEggModel(SourceModel: Instance): { any }
	local HiddenParts = {}
	for _, Object in ipairs(SourceModel:GetDescendants()) do
		if Object:IsA("BasePart") then
			table.insert(HiddenParts, {
				Part = Object,
				Transparency = Object.Transparency,
				CanCollide = Object.CanCollide,
				CanTouch = Object.CanTouch,
				CanQuery = Object.CanQuery,
			})
			Object.Transparency = 1
			Object.CanCollide = false
			Object.CanTouch = false
			Object.CanQuery = false
		end
	end
	return HiddenParts
end

local function RestoreEggModel(HiddenParts: { any }?)
	for _, Data in ipairs(HiddenParts or {}) do
		local Part = Data.Part :: BasePart?
		if Part and Part.Parent then
			Part.Transparency = Data.Transparency
			Part.CanCollide = Data.CanCollide
			Part.CanTouch = Data.CanTouch
			Part.CanQuery = Data.CanQuery
		end
	end
end

local function CreateCarriedEgg(SourceModel: Instance, OriginalTransparencies: { any }?): Model
	local CarriedModel = SourceModel:Clone() :: Model
	CarriedModel.Name = "CarriedEgg"

	local PartIndex = 0
	for _, Object in ipairs(CarriedModel:GetDescendants()) do
		if Object:IsA("ProximityPrompt") or Object:IsA("Script") or Object:IsA("LocalScript") then
			Object:Destroy()
		elseif Object:IsA("BasePart") then
			PartIndex += 1
			local OriginalData = OriginalTransparencies and OriginalTransparencies[PartIndex]
			Object.Transparency = OriginalData and OriginalData.Transparency or 0
			Object.Anchored = true
			Object.CanCollide = false
			Object.CanTouch = false
			Object.CanQuery = false
		end
	end

	CarriedModel.Parent = workspace
	return CarriedModel
end

local function CreateRegenBoard(SourceModel: Model, EggType: string): BillboardGui?
	local MainPart = SourceModel.PrimaryPart or SourceModel:FindFirstChildWhichIsA("BasePart", true) :: BasePart?
	if not MainPart then
		warn(SourceModel.Name .. " does not contain a BasePart")
		return nil
	end

	local Board = EggReGenTemplate:Clone() :: BillboardGui
	Board.Name = "EggReGenBoard"
	Board.AlwaysOnTop = false
	Board.MaxDistance = 45
	Board.Adornee = MainPart
	Board.Parent = MainPart

	local Title = Board:FindFirstChild("Title", true) :: TextLabel?
	local TimeLabel = Board:FindFirstChild("Time", true) :: TextLabel?

	local EggData = EggModule[EggType]
	local Tier = SafeTiers.FromModel(SourceModel)
	if Title then
		Title.Text = string.format("%s · %s", EggData and EggData.EggName or EggType, Tier.ShortName)
	end
	if TimeLabel then
		TimeLabel.Text = "ROBAR"
	end

	-- el cartel se ubica siempre por encima de la caja, segun su tamano real
	local _, Size = SourceModel:GetBoundingBox()
	Board.StudsOffsetWorldSpace = Vector3.new(0, Size.Y / 2 + 1.6, 0)
	Board.Size = UDim2.new(0, 190, 0, 70)

	return Board
end

local function SetPlayerStealing(Player: Player?, Stealing: boolean)
	if not Player then return end
	Player:SetAttribute("IsStealing", Stealing)
	local carried = Stealing and PlayerEggs[Player] or nil
	local reward = carried and carried.SourceModel and carried.SourceModel:GetAttribute("Reward")
	Player:SetAttribute("LootValue", (Stealing and typeof(reward) == "number") and reward or 0)
end

local function UnlockEgg(EggData: any)
	if EggData.Board and EggData.Board.Parent then
		EggData.Board:Destroy()
	end

	RestoreEggModel(EggData.HiddenParts)

	local SourceModel = EggData.SourceModel
	if SourceModel and SourceModel.Parent then
		LockedEggModels[SourceModel] = nil
		-- la caja vuelve sellada: vida completa, puerta cerrada y cartel nuevo (lo resuelve EggShellSystem)
		ResetEggShellEvent:Fire(SourceModel)
		SetEggPromptEnabled(SourceModel, true)
	end
end

local function ClaimDroppedEgg(DroppedInfo: any)
	if DroppedInfo.Claimed then return end
	DroppedInfo.Claimed = true

	if DroppedInfo.DespawnThread then
		task.cancel(DroppedInfo.DespawnThread)
		DroppedInfo.DespawnThread = nil
	end

	if DroppedInfo.DroppedModel and DroppedInfo.DroppedModel.Parent then
		DroppedInfo.DroppedModel:Destroy()
	end

	DroppedEggs[DroppedInfo.SourceModel] = nil

	if DroppedInfo.SourceModel then
		EggOwners[DroppedInfo.SourceModel] = nil
		if DroppedInfo.SourceModel.Parent then
			DroppedInfo.SourceModel:SetAttribute("OwnerUserId", nil)
		end
	end

	UnlockEgg(DroppedInfo)
end

local function ResetEggImmediately(EggData: any)
	if EggData.CarriedModel and EggData.CarriedModel.Parent then
		EggData.CarriedModel:Destroy()
	end
	UnlockEgg(EggData)
end

local GetFreeSlot, InsideOwnBase, GetPlaceCFrame, OpenBox, CountBoxes, MAX_BOXES_IN_BASE, BoxInfo
local BeginBaseOpening
local function StartEggRespawn(EggData: any)
	if EggData.CarriedModel and EggData.CarriedModel.Parent then
		EggData.CarriedModel:Destroy()
	end

	local EggDataModule = EggModule[EggData.Type]
	local Tier = SafeTiers.FromModel(EggData.SourceModel)
	local SpawnTime = math.max(1, math.floor(((EggDataModule and EggDataModule.TimeSpawn or 10)) * Tier.RespawnMultiplier + 0.5))
	local TimeLabel = EggData.Board and EggData.Board:FindFirstChild("Time", true) :: TextLabel?

	for Remaining = SpawnTime, 0, -1 do
		if TimeLabel then
			TimeLabel.Text = tostring(Remaining)
		end
		if Remaining > 0 then
			task.wait(1)
		end
	end

	UnlockEgg(EggData)
end

-- ===== Apertura en la base: pedestal + cronometro + secuencia =====
local OpenTimerRemote = GetOrCreateRemote("OpenTimer", "RemoteEvent") :: RemoteEvent
local OpenSafeInBase = GetOrCreateRemote("OpenSafeInBase", "BindableEvent") :: BindableEvent

local function GetBaseOpenCFrame(Player: Player): CFrame
	-- (compatibilidad) devuelve el espacio libre mas cercano, sin reservarlo
	local Slot = GetFreeSlot(Player)
	if Slot then
		local Top = Slot:GetAttribute("TopY") or Slot.Position.Y
		local Pos = Vector3.new(Slot.Position.X, Top, Slot.Position.Z)
		return CFrame.lookAt(Pos, Pos - Vector3.zAxis)
	end
	return CFrame.new(0, 10, 0)
end

-- espacios del piso de la base (Plot.EspaciosCajas.EspacioN)
function GetFreeSlot(Player: Player): BasePart?
	local Plot = PlayerPlots[Player]
	local Folder = Plot and Plot:FindFirstChild("EspaciosCajas")
	if not Folder then return nil end
	local Character = Player.Character
	local Root = Character and Character:FindFirstChild("HumanoidRootPart")
	local Best, BestD = nil, math.huge
	for _, P in ipairs(Folder:GetChildren()) do
		if P:IsA("BasePart") and P:GetAttribute("Indice") and not P:GetAttribute("Ocupado") then
			local D = Root and (P.Position - Root.Position).Magnitude or P:GetAttribute("Indice")
			if D < BestD then Best, BestD = P, D end
		end
	end
	return Best
end

function InsideOwnBase(Player: Player): boolean
	local Plot = PlayerPlots[Player]
	local Place = Plot and Plot:FindFirstChild("Place")
	local Character = Player.Character
	local Root = Character and Character:FindFirstChild("HumanoidRootPart")
	if not (Place and Root) then return false end
	local Rel = Place.CFrame:PointToObjectSpace(Root.Position)
	return math.abs(Rel.X) <= Place.Size.X / 2 + 1 and math.abs(Rel.Z) <= Place.Size.Z / 2 + 1 and Rel.Y > -6 and Rel.Y < 14
end

local function SetSlotState(Slot: BasePart, Busy: boolean)
	Slot:SetAttribute("Ocupado", Busy or nil)
	local Folder = Slot.Parent
	local Index = Slot:GetAttribute("Indice")
	local Ring = Folder and Folder:FindFirstChild("AnilloEspacio" .. tostring(Index))
	local Color = Busy and Color3.fromRGB(255, 200, 60) or Color3.fromRGB(80, 230, 255)
	if Ring then
		Ring.Color = Color
		local L = Ring:FindFirstChild("LuzEspacio")
		if L then L.Color = Color; L.Brightness = Busy and 2 or 0.8 end
	end
	if Folder then
		for _, P in ipairs(Folder:GetChildren()) do
			if P.Name == "MarcaEspacio" .. tostring(Index) then P.Color = Color end
		end
	end
end

MAX_BOXES_IN_BASE = 12
BoxInfo = {}
local OpenReadyBoxRemote = GetOrCreateRemote("OpenReadyBox") :: RemoteEvent

function CountBoxes(Player: Player): number
	local n = 0
	for _, m in ipairs(workspace:GetChildren()) do
		if m.Name == "CajaEnApertura" and m:GetAttribute("OwnerUserId") == Player.UserId then n += 1 end
	end
	return n
end

-- la caja queda delante del jugador, dentro de su base, mirandolo de frente
function GetPlaceCFrame(Player: Player): CFrame?
	if CountBoxes(Player) >= MAX_BOXES_IN_BASE then return nil end
	local Plot = PlayerPlots[Player]
	local Place = Plot and Plot:FindFirstChild("Place")
	local Character = Player.Character
	local Root = Character and Character:FindFirstChild("HumanoidRootPart")
	if not (Place and Root) then return nil end
	local look = Vector3.new(Root.CFrame.LookVector.X, 0, Root.CFrame.LookVector.Z)
	if look.Magnitude < 0.1 then look = Vector3.new(0, 0, -1) end
	local target = Root.Position + look.Unit * 5
	local rel = Place.CFrame:PointToObjectSpace(target)
	local hx, hz = Place.Size.X / 2 - 3.5, Place.Size.Z / 2 - 3.5
	rel = Vector3.new(math.clamp(rel.X, -hx, hx), Place.Size.Y / 2, math.clamp(rel.Z, -hz, hz))
	local pos = Place.CFrame:PointToWorldSpace(rel)
	local toPlayer = Vector3.new(Root.Position.X - pos.X, 0, Root.Position.Z - pos.Z)
	if toPlayer.Magnitude < 0.1 then toPlayer = Vector3.zAxis end
	return CFrame.lookAt(pos, pos - toPlayer.Unit) -- frente (+Z local) hacia el jugador
end

function OpenBox(Player: Player, display: Model)
	local info = BoxInfo[display]
	if not info or not display.Parent then return end
	if display:GetAttribute("OwnerUserId") ~= Player.UserId then return end
	if display:GetAttribute("Ready") ~= true or display:GetAttribute("Opening") then return end
	display:SetAttribute("Opening", true)
	for _, d in ipairs(display:GetDescendants()) do
		if d.Name == "PromptAbrir" or d.Name == "CartelLista" then d:Destroy() end
	end
	BoxInfo[display] = nil
	OpenSafeInBase:Fire(Player, display, info.EggType, info.SourceModel)
end

local function MarkBoxReady(Player: Player, display: Model)
	display:SetAttribute("Ready", true)
	local part = display.PrimaryPart or display:FindFirstChildWhichIsA("BasePart", true)
	if not part then return end
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "PromptAbrir"; prompt.ActionText = "Abrir caja"; prompt.ObjectText = "¡LISTA!"
	prompt.HoldDuration = 0.3; prompt.MaxActivationDistance = 12; prompt.RequiresLineOfSight = false
	prompt.Parent = part
	prompt.Triggered:Connect(function(who) if who == Player then OpenBox(Player, display) end end)
	local bb = Instance.new("BillboardGui"); bb.Name = "CartelLista"; bb.Size = UDim2.fromOffset(150, 50)
	bb.StudsOffsetWorldSpace = Vector3.new(0, 7, 0); bb.MaxDistance = 120; bb.Parent = part
	local t = Instance.new("TextLabel"); t.Size = UDim2.fromScale(1, 1); t.BackgroundTransparency = 1; t.Font = Enum.Font.FredokaOne
	t.TextScaled = true; t.Text = "🔓 ¡LISTA!"; t.TextColor3 = Color3.fromRGB(130, 255, 80); t.Parent = bb
	local s = Instance.new("UIStroke"); s.Thickness = 3.5; s.Color = Color3.fromRGB(10, 50, 10); s.Parent = t
	local glow = Instance.new("PointLight"); glow.Name = "LuzLista"; glow.Color = Color3.fromRGB(130, 255, 80); glow.Range = 14; glow.Brightness = 2.5; glow.Parent = part
end

OpenReadyBoxRemote.OnServerEvent:Connect(function(Player: Player, target)
	if target == "all" then
		for _, m in ipairs(workspace:GetChildren()) do
			if m.Name == "CajaEnApertura" and m:GetAttribute("OwnerUserId") == Player.UserId and m:GetAttribute("Ready") == true then
				OpenBox(Player, m)
				task.wait(0.4)
			end
		end
	elseif typeof(target) == "Instance" and target:IsA("Model") then
		OpenBox(Player, target)
	end
end)

function BeginBaseOpening(Player: Player, EggData: any, CustomPos: Vector3?)
	local EggType = EggData.Type
	local SourceModel = EggData.SourceModel
	local Tier = SafeTiers.FromModel(SourceModel)
	-- se construye una copia visible, cerrada, de la caja sobre el pedestal de la base
	local display = SourceModel and SourceModel:Clone()
	if display and EggData.HiddenParts then
		local original = {}
		for _, Data in ipairs(EggData.HiddenParts) do
			if Data.Part then original[Data.Part] = Data end
		end
		local srcParts, dispParts = SourceModel:GetDescendants(), display:GetDescendants()
		for i, d in ipairs(dispParts) do
			local sp = srcParts[i]
			if d:IsA("BasePart") and sp and original[sp] then
				d.Transparency = original[sp].Transparency
			end
		end
	end
	if not display then
		ResetEggImmediately(EggData)
		return
	end
	for _, d in ipairs(display:GetDescendants()) do
		if d:IsA("ProximityPrompt") or d:IsA("Script") or d:IsA("LocalScript") then d:Destroy() end
		if d:IsA("BillboardGui") then d:Destroy() end
	end
	display.Name = "CajaEnApertura"
	for k, v in pairs(SourceModel:GetAttributes()) do display:SetAttribute(k, v) end
	display:SetAttribute("EggLocked", true)

	local openCF: CFrame? = nil
	if typeof(CustomPos) == "Vector3" and CountBoxes(Player) < MAX_BOXES_IN_BASE then
		local Plot = PlayerPlots[Player]
		local Place = Plot and Plot:FindFirstChild("Place") :: BasePart?
		local Character = Player.Character
		local Root = Character and Character:FindFirstChild("HumanoidRootPart") :: BasePart?
		if Place and Root then
			local rel = Place.CFrame:PointToObjectSpace(CustomPos)
			local hx, hz = Place.Size.X / 2 - 2, Place.Size.Z / 2 - 2
			local clampedRel = Vector3.new(math.clamp(rel.X, -hx, hx), Place.Size.Y / 2, math.clamp(rel.Z, -hz, hz))
			local worldPos = Place.CFrame:PointToWorldSpace(clampedRel)
			local toPlayer = Vector3.new(Root.Position.X - worldPos.X, 0, Root.Position.Z - worldPos.Z)
			if toPlayer.Magnitude < 0.1 then toPlayer = Vector3.zAxis end
			openCF = CFrame.lookAt(worldPos, worldPos - toPlayer.Unit)
		end
	end
	if not openCF then
		openCF = GetPlaceCFrame(Player)
	end
	if not openCF then
		display:Destroy()
		ResetEggImmediately(EggData)
		Notify(Player, "⚠️ Tu base está llena (máximo " .. MAX_BOXES_IN_BASE .. " cajas)", Color3.fromRGB(255, 180, 60), 3)
		return
	end
	display:PivotTo(openCF)
	do -- la base de la caja queda apoyada exactamente sobre la tapa del pedestal
		local bbCF, bbSize = display:GetBoundingBox()
		local lift = openCF.Position.Y - (bbCF.Position.Y - bbSize.Y / 2)
		display:PivotTo(display:GetPivot() + Vector3.new(0, lift, 0))
	end
	for _, d in ipairs(display:GetDescendants()) do
		if d:IsA("BasePart") then d.Anchored = true; d.CanCollide = false end
	end
	display.Parent = workspace

	-- quitar la caja que se transportaba
	if EggData.CarriedModel and EggData.CarriedModel.Parent then
		EggData.CarriedModel:Destroy()
	end

	-- cronometro: duracion segun la categoria
	local openDuration = math.max(3, math.floor((4 + Tier.HoldDuration * 6) * (Tier.RespawnMultiplier or 1) + 0.5))
	if Player:GetAttribute("AperturaRapida") then openDuration = math.max(2, math.floor(openDuration * 0.5 + 0.5)) end
	OpenTimerRemote:FireClient(Player, "Start", display, openDuration)

	display:SetAttribute("OwnerUserId", Player.UserId)
	display:SetAttribute("OpenDuration", openDuration)
	display:SetAttribute("EndTime", os.time() + openDuration)
	display:SetAttribute("Ready", false)
	BoxInfo[display] = { EggType = EggType, SourceModel = SourceModel }
	display.AncestryChanged:Connect(function(_, parent) if not parent then BoxInfo[display] = nil end end)
	task.spawn(function()
		local t0 = os.clock()
		local instant = false
		while os.clock() - t0 < openDuration do
			if not display.Parent then return end
			if (Player:GetAttribute("AbrirYa") or 0) > t0 then instant = true break end
			task.wait(0.2)
		end
		if not display.Parent then return end
		OpenTimerRemote:FireClient(Player, "Stop", display)
		-- re-sellar la caja original del mapa
		task.spawn(function()
			StartEggRespawn(EggData)
		end)
		MarkBoxReady(Player, display)
		if instant then OpenBox(Player, display) end
	end)
	-- "Abrir Todo YA" tambien abre las que ya estaban listas
	local conn
	conn = Player:GetAttributeChangedSignal("AbrirYa"):Connect(function()
		if not display.Parent then conn:Disconnect() return end
		if display:GetAttribute("Ready") == true then OpenBox(Player, display) end
	end)
end

local function DropCurrentEgg(Player: Player)
	local EggData = PlayerEggs[Player]
	if not EggData then return end

	PlayerEggs[Player] = nil
	EggSoundRemote:FireClient(Player, "Stop")
	SetPlayerStealing(Player, false)

	if EggData.SourceModel then
		EggOwners[EggData.SourceModel] = nil
		if EggData.SourceModel.Parent then
			EggData.SourceModel:SetAttribute("OwnerUserId", nil)
		end
	end

	ResetEggImmediately(EggData)
end

local function PickUpDroppedEgg(Player: Player, DroppedInfo: any)
	if PlayerEggs[Player] then return end
	if DroppedInfo.Claimed then return end

	DroppedInfo.Claimed = true

	local Character = Player.Character
	local RootPart = Character and Character:FindFirstChild("HumanoidRootPart")
	if not RootPart then return end

	if DroppedInfo.DespawnThread then
		task.cancel(DroppedInfo.DespawnThread)
		DroppedInfo.DespawnThread = nil
	end

	if DroppedInfo.DroppedModel and DroppedInfo.DroppedModel.Parent then
		DroppedInfo.DroppedModel:Destroy()
	end

	DroppedEggs[DroppedInfo.SourceModel] = nil

	local CarriedModel = CreateCarriedEgg(DroppedInfo.SourceModel, DroppedInfo.HiddenParts)

	local EggData = {
		Type = DroppedInfo.Type,
		EggFolder = DroppedInfo.EggFolder,
		SourceModel = DroppedInfo.SourceModel,
		CarriedModel = CarriedModel,
		HiddenParts = DroppedInfo.HiddenParts,
		Board = DroppedInfo.Board,
		StealTime = os.clock(),
	}

	PlayerEggs[Player] = EggData
	EggOwners[DroppedInfo.SourceModel] = Player
	SetPlayerStealing(Player, true)

	EggSoundRemote:FireClient(Player, "Start")

	DroppedInfo.SourceModel:SetAttribute("OwnerUserId", Player.UserId)

	local EggDataModule = EggModule[DroppedInfo.Type]
	Notify(
		Player,
		string.format("🚨 ¡Robaste el %s! ¡Huye de la policía!", EggDataModule and EggDataModule.EggName or DroppedInfo.Type),
		Color3.fromRGB(255, 210, 90),
		3
	)
end

local function DropEggOnGround(Player: Player)
	local EggData = PlayerEggs[Player]
	if not EggData then return end

	local Character = Player.Character
	local RootPart = Character and Character:FindFirstChild("HumanoidRootPart") :: BasePart?

	if not RootPart then
		DropCurrentEgg(Player)
		return
	end

	PlayerEggs[Player] = nil
	EggSoundRemote:FireClient(Player, "Stop")
	SetPlayerStealing(Player, false)

	local DroppedModel = EggData.CarriedModel
	if not DroppedModel or not DroppedModel.Parent then
		ResetEggImmediately(EggData)
		return
	end

	DroppedModel:PivotTo(RootPart.CFrame * CFrame.new(0, -1.5, -3))

	local MainPart = DroppedModel.PrimaryPart or DroppedModel:FindFirstChildWhichIsA("BasePart", true) :: BasePart?
	local DespawnBoard = DespawnTemplate:Clone() :: BillboardGui
	DespawnBoard.Name = "DespawnBoard"
	DespawnBoard.AlwaysOnTop = false
	DespawnBoard.MaxDistance = 45

	if MainPart then
		DespawnBoard.Adornee = MainPart
		DespawnBoard.Parent = MainPart
	end

	local TimeLabel = DespawnBoard:FindFirstChild("Time", true) :: TextLabel?
	local TitleLabel = DespawnBoard:FindFirstChild("Title", true) :: TextLabel?

	local EggDataModule = EggModule[EggData.Type]
	if TitleLabel then
		TitleLabel.Text = EggDataModule and EggDataModule.EggName or EggData.Type
	end

	local DroppedTier = SafeTiers.FromModel(EggData.SourceModel)
	local DespawnTime = math.max(1, math.floor(((EggDataModule and EggDataModule.DespawnTime or 10)) * DroppedTier.DespawnMultiplier + 0.5))

	if MainPart then
		local Prompt = Instance.new("ProximityPrompt")
		Prompt.Name = "PickupDroppedEgg"
		Prompt.ActionText = "Recoger Caja Fuerte"
		Prompt.ObjectText = EggDataModule and EggDataModule.EggName or EggData.Type
		Prompt.HoldDuration = 0
		Prompt.Style = Enum.ProximityPromptStyle.Custom
		Prompt.MaxActivationDistance = PICKUP_DROPPED_DISTANCE
		Prompt.RequiresLineOfSight = false
		Prompt.Parent = MainPart
	end

	local DroppedInfo = {
		Type = EggData.Type,
		EggFolder = EggData.EggFolder,
		SourceModel = EggData.SourceModel,
		HiddenParts = EggData.HiddenParts,
		Board = EggData.Board,
		DroppedModel = DroppedModel,
		Claimed = false,
	}

	DroppedEggs[EggData.SourceModel] = DroppedInfo

	if AlertEnemyToDroppedEgg then
		AlertEnemyToDroppedEgg(DroppedInfo, DroppedModel:GetPivot().Position)
	end

	if MainPart then
		local Prompt = MainPart:FindFirstChild("PickupDroppedEgg") :: ProximityPrompt?
		if Prompt then
			Prompt.Triggered:Connect(function(TriggeredPlayer)
				PickUpDroppedEgg(TriggeredPlayer, DroppedInfo)
			end)
		end
	end

	DroppedInfo.DespawnThread = task.spawn(function()
		for Remaining = DespawnTime, 0, -1 do
			if not DroppedModel.Parent then return end
			if TimeLabel then
				TimeLabel.Text = tostring(Remaining)
			end
			if Remaining > 0 then
				task.wait(1)
			end
		end
		ClaimDroppedEgg(DroppedInfo)
	end)
end

local function PickUpEggFromModel(Player: Player, SourceModel: Model)
	if PlayerEggs[Player] then return end

	local Character = Player.Character
	local RootPart = Character and Character:FindFirstChild("HumanoidRootPart")
	if not RootPart then return end


	local EggFolder = SourceModel.Parent
	while EggFolder and EggFolder.Parent ~= EggsFolder do
		EggFolder = EggFolder.Parent
	end

	if not EggFolder or EggFolder.Parent ~= EggsFolder then
		return
	end

	local EggType = EggFolder.Name
	if not EggModule[EggType] then return end

	if LockedEggModels[SourceModel] or SourceModel:GetAttribute("EggLocked") == true then
		return
	end

	LockedEggModels[SourceModel] = true
	SourceModel:SetAttribute("EggLocked", true)

	SetEggPromptEnabled(SourceModel, false)

	local HiddenParts = HideEggModel(SourceModel)
	local CarriedModel = CreateCarriedEgg(SourceModel, HiddenParts)
	local Board = CreateRegenBoard(SourceModel, EggType)

	local EggData = {
		Type = EggType,
		EggFolder = EggFolder,
		SourceModel = SourceModel,
		CarriedModel = CarriedModel,
		HiddenParts = HiddenParts,
		Board = Board,
		StealTime = os.clock(),
	}

	PlayerEggs[Player] = EggData
	EggOwners[SourceModel] = Player
	SetPlayerStealing(Player, true)

	EggSoundRemote:FireClient(Player, "Start")
	SourceModel:SetAttribute("OwnerUserId", Player.UserId)

	local EggDataModule = EggModule[EggType]
	Notify(
		Player,
		string.format("🚨 ¡ROBASTE LA %s! ¡LA POLICÍA TE PERSIGUE!", (EggDataModule and EggDataModule.EggName or EggType):upper()),
		Color3.fromRGB(255, 60, 60),
		4
	)
end
local function PickUpEgg(Player: Player, Prompt: ProximityPrompt)
	local SourceModel = Prompt:FindFirstAncestorOfClass("Model")
	if SourceModel then
		PickUpEggFromModel(Player, SourceModel)
	end
end

ClaimEggShellEvent.Event:Connect(function(Player: Player, EggModel: Model)
	if typeof(EggModel) == "Instance" and EggModel:IsA("Model") then
		PickUpEggFromModel(Player, EggModel)
	end
end)

local function DeliverEgg(Player: Player, CustomPos: Vector3?)
	local EggData = PlayerEggs[Player]
	if not EggData then return end

	local EggType = EggData.Type
	PlayerEggs[Player] = nil
	EggSoundRemote:FireClient(Player, "Stop")
	SetPlayerStealing(Player, false)

	if EggData.SourceModel then
		EggOwners[EggData.SourceModel] = nil
		if EggData.SourceModel.Parent then
			EggData.SourceModel:SetAttribute("OwnerUserId", nil)
		end
	end

	-- la caja llega CERRADA a la base: se coloca en el pedestal de apertura y arranca el cronometro.
	-- La apertura, el ladron, el pago y el registro ocurren recien cuando el timer llega a 0.
	local EggDataModule = EggModule[EggType]
	Notify(
		Player,
		string.format("🏠 ¡%s EN LA BASE! Abriéndola...", (EggDataModule and EggDataModule.EggName or EggType)),
		Color3.fromRGB(80, 240, 120),
		3
	)
	BeginBaseOpening(Player, EggData, CustomPos)
end

local function ConnectEggPrompt(Prompt: Instance)
	if not Prompt:IsA("ProximityPrompt") then return end
	Prompt.Style = Enum.ProximityPromptStyle.Custom
	Prompt.MaxActivationDistance = GRAB_ACTIVATION_DISTANCE
	Prompt.RequiresLineOfSight = false

	Prompt.Triggered:Connect(function(Player)
		PickUpEgg(Player, Prompt)
	end)
end

local function ConnectEggPrompts()
	for _, Object in ipairs(EggsFolder:GetDescendants()) do
		ConnectEggPrompt(Object)
	end
	EggsFolder.DescendantAdded:Connect(function(Object)
		ConnectEggPrompt(Object)
	end)
end

DropEggRemote.OnServerEvent:Connect(function(Player, CustomPos: any)
	local EggData = PlayerEggs[Player]
	if EggData and InsideOwnBase(Player) then
		if not EggData.Delivering then
			EggData.Delivering = true
			DeliverEgg(Player, CustomPos)
		end
		return
	end
	DropEggOnGround(Player)
end)

TeleportHomeRemote.OnServerEvent:Connect(function(Player: Player)
	if Player:GetAttribute("IsStealing") == true then
		Notify(
			Player,
			"⚠️ ¡No puedes teletransportarte mientras llevas una caja fuerte robada! ¡Huye a pie o enfréntate a la policía!",
			Color3.fromRGB(255, 90, 90),
			3.5
		)
		return
	end

	TeleportToPlot(Player)
	Notify(
		Player,
		"🏠 ¡Teletransportado a tu base!",
		Color3.fromRGB(90, 240, 140),
		2.5
	)
end)

RunService.Heartbeat:Connect(function()
	for Player, EggData in pairs(PlayerEggs) do
		local Character = Player.Character
		local RootPart = Character and Character:FindFirstChild("HumanoidRootPart") :: BasePart?
		local CarriedModel = EggData.CarriedModel :: Model?

		if RootPart and CarriedModel and CarriedModel.Parent then
			CarriedModel:PivotTo(RootPart.CFrame * CFrame.new(0, EGG_HEIGHT, -EGG_DISTANCE))
		else
			DropCurrentEgg(Player)
		end
	end
end)

-- POLICE ARREST & TARGET LOGIC
local function ArrestPlayer(Player: Player, EnemyData: any)
	if EnemyHitDebounce[Player] then return end
	EnemyHitDebounce[Player] = true

	local EggData = PlayerEggs[Player]
	if EggData then
		DropCurrentEgg(Player)
	end

	local countryName = EnemyData.Country or "este país"
	local officerName = EnemyData.BossName or "Oficial de Policía"
	Notify(
		Player,
		string.format("🚨 ¡ARRESTADO POR %s! El tesoro de %s fue recuperado.", officerName, countryName),
		Color3.fromRGB(255, 60, 60),
		4
	)

	TeleportToPlot(Player)

	task.delay(2.5, function()
		EnemyHitDebounce[Player] = nil
	end)
end

-- zona segura: todo lo que esta del lado de las bases de la linea de la SafeZone
local SafeLineZ = nil
local function IsInSafeArea(Position: Vector3): boolean
	if not SafeLineZ then
		local Zones = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Zones")
		local Safe = Zones and Zones:FindFirstChild("SafeZone")
		local Part = Safe and (Safe:FindFirstChild("InteractPart") or Safe:FindFirstChildWhichIsA("BasePart", true))
		SafeLineZ = Part and (Part.Position.Z + 2) or -647
	end
	return Position.Z < SafeLineZ
end

local function FindTargetForEnemy(EnemyData: any, EnemyRoot: BasePart, GuardPos: Vector3?): (Player?, BasePart?)
	local BestPlayer: Player? = nil
	local BestRoot: BasePart? = nil
	local BestDistance = math.huge

	-- STRICT AGGRO: ONLY chase players currently carrying a stolen safe from this country/zone
	for Player, EggData in pairs(PlayerEggs) do
		if EggData.Type ~= EnemyData.EggsChase then continue end
		if Player:GetAttribute("IsStealing") ~= true then continue end

		local Character = Player.Character
		local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
		local RootPart = Character and Character:FindFirstChild("HumanoidRootPart") :: BasePart?

		if Humanoid and Humanoid.Health > 0 and RootPart then
			-- persigue mientras el ladron no haya cruzado la zona segura
			if not IsInSafeArea(RootPart.Position) then
				local Distance = (EnemyRoot.Position - RootPart.Position).Magnitude
				if Distance < BestDistance then
					BestDistance = Distance
					BestPlayer = Player
					BestRoot = RootPart
				end
			end
		end
	end

	return BestPlayer, BestRoot
end

local function ConnectEnemyDamage(EnemyRig: Model, EnemyData: any)
	local RootPart = EnemyRig:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not RootPart then return end

	RootPart.Touched:Connect(function(Hit)
		local Character = Hit:FindFirstAncestorOfClass("Model")
		local Player = Character and Players:GetPlayerFromCharacter(Character)
		if not Player then return end

		local pRoot = Character:FindFirstChild("HumanoidRootPart") :: BasePart?
		if pRoot and IsInSafeArea(pRoot.Position) then return end

		local EggData = PlayerEggs[Player]
		if EggData and EggData.Type == EnemyData.EggsChase then
			ArrestPlayer(Player, EnemyData)
		end
	end)
end

local function FindEnemyRig(EnemyContainer: Instance): Model?
	local DirectRig = EnemyContainer:FindFirstChild("Rig")
	if DirectRig and DirectRig:IsA("Model") and DirectRig:FindFirstChild("HumanoidRootPart") then
		return DirectRig
	end

	for _, Object in ipairs(EnemyContainer:GetDescendants()) do
		if Object:IsA("Model") and Object:FindFirstChild("HumanoidRootPart") then
			return Object
		end
	end
	return nil
end

local function AnchorEnemyModel(Model: Model)
	for _, Object in ipairs(Model:GetDescendants()) do
		if Object:IsA("BasePart") then
			Object.Anchored = true
			Object.CanTouch = true
		end
	end
end

AlertEnemyToDroppedEgg = function(DroppedInfo: any, DropPosition: Vector3)
	local BestRig: Model? = nil
	local BestRegistry: any = nil
	local BestDistance = math.huge

	for EnemyRig, Registry in pairs(EnemyRegistry) do
		if not EnemyRig.Parent then continue end
		local State = Registry.State
		if State.EggTarget then continue end
		if Registry.EnemyData.EggsChase ~= DroppedInfo.Type then continue end

		local Distance = (Registry.RootPart.Position - DropPosition).Magnitude
		if Distance > ENEMY_EGG_ALERT_DISTANCE then continue end

		if Distance < BestDistance then
			BestDistance = Distance
			BestRig = EnemyRig
			BestRegistry = Registry
		end
	end

	if not BestRig or not BestRegistry then return end

	local State = BestRegistry.State
	State.EggTarget = DroppedInfo
	State.GoalPosition = DropPosition
	State.Chasing = true

	BestRig:SetAttribute("TargetUserId", nil)
end

-- Efecto "spotted": signo ❗ con pop-up elástico + silbato cuando el policía detecta al jugador.
local SPOTTED_SOUND_ID = "rbxassetid://9117261480"
local SpottedCooldown: { [Model]: number } = {}

local function PlaySpottedAlert(EnemyRig: Model)
	local now = os.clock()
	if now - (SpottedCooldown[EnemyRig] or 0) < 3 then
		return
	end
	SpottedCooldown[EnemyRig] = now
	local TweenService = game:GetService("TweenService")
	local Debris = game:GetService("Debris")
	local head = EnemyRig:FindFirstChild("Head") :: BasePart?
	if not head then
		return
	end
	local old = head:FindFirstChild("SpottedAlert")
	if old then
		old:Destroy()
	end
	local gui = Instance.new("BillboardGui")
	gui.Name = "SpottedAlert"
	gui.Size = UDim2.fromOffset(64, 64)
	gui.StudsOffsetWorldSpace = Vector3.new(0, 3.4, 0)
	gui.AlwaysOnTop = true
	gui.MaxDistance = 150
	local label = Instance.new("TextLabel")
	label.AnchorPoint = Vector2.new(0.5, 0.5)
	label.Position = UDim2.fromScale(0.5, 0.5)
	label.Size = UDim2.fromScale(0, 0)
	label.BackgroundTransparency = 1
	label.Text = "❗"
	label.TextScaled = true
	label.Font = Enum.Font.GothamBlack
	label.TextColor3 = Color3.fromRGB(255, 50, 50)
	label.Parent = gui
	gui.Parent = head
	TweenService:Create(label, TweenInfo.new(0.45, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), { Size = UDim2.fromScale(1, 1) }):Play()
	local whistle = Instance.new("Sound")
	whistle.Name = "SpottedWhistle"
	whistle.SoundId = SPOTTED_SOUND_ID
	whistle.Volume = 0.8
	whistle.RollOffMaxDistance = 120
	whistle.Parent = head
	whistle:Play()
	task.delay(1.5, function()
		if label.Parent then
			TweenService:Create(label, TweenInfo.new(0.3), { TextTransparency = 1 }):Play()
		end
	end)
	Debris:AddItem(gui, 2)
	Debris:AddItem(whistle, 3)
end

-- LIMITES DE ZONA, RUTA DE PATRULLA Y EVASION DE OBSTACULOS
local function GetZoneBounds(EnemyName: string): (Vector3?, Vector3?)
	local Index = tonumber(string.match(EnemyName, "%d+"))
	if not Index then return nil, nil end
	local Zone = ZonesFolder:FindFirstChild("Zone" .. Index)
	if not Zone then return nil, nil end

	local Floor = Zone:FindFirstChild("Floor") :: BasePart?
	if Floor then
		local Half = Floor.Size / 2
		return Floor.Position - Half, Floor.Position + Half
	end

	local Min: Vector3?, Max: Vector3? = nil, nil
	for _, Object in ipairs(Zone:GetDescendants()) do
		if Object:IsA("BasePart") then
			local A = Object.Position - Object.Size / 2
			local B = Object.Position + Object.Size / 2
			Min = Min and Vector3.new(math.min(Min.X, A.X), math.min(Min.Y, A.Y), math.min(Min.Z, A.Z)) or A
			Max = Max and Vector3.new(math.max(Max.X, B.X), math.max(Max.Y, B.Y), math.max(Max.Z, B.Z)) or B
		end
	end
	return Min, Max
end

local function InsideZone(Position: Vector3, Min: Vector3?, Max: Vector3?, Margin: number): boolean
	if not Min or not Max then return true end
	return Position.X >= Min.X - Margin and Position.X <= Max.X + Margin
		and Position.Z >= Min.Z - Margin and Position.Z <= Max.Z + Margin
end

local BlockParams = OverlapParams.new()
BlockParams.MaxParts = 6

local function IsPointClear(Point: Vector3, Rig: Model): boolean
	BlockParams.FilterType = Enum.RaycastFilterType.Exclude
	BlockParams.FilterDescendantsInstances = { Rig }
	local Hits = workspace:GetPartBoundsInBox(CFrame.new(Point + Vector3.new(0, 4, 0)), Vector3.new(8, 8, 8), BlockParams)
	for _, Part in ipairs(Hits) do
		if Part.CanCollide then return false end
	end
	return true
end

-- Circuito de patrulla contenido dentro de la propia zona del oficial
local function BuildPatrolRoute(Rig: Model, Pos: BasePart, Min: Vector3?, Max: Vector3?): { Vector3 }
	local Y = Pos.Position.Y
	local Route = { Pos.Position }

	if not Min or not Max then
		return Route
	end

	local MinX, MaxX = Min.X + PATROL_MARGIN, Max.X - PATROL_MARGIN
	local MinZ, MaxZ = Min.Z + PATROL_MARGIN, Max.Z - PATROL_MARGIN
	local CenterX, CenterZ = (MinX + MaxX) / 2, (MinZ + MaxZ) / 2
	local Width, Length = MaxX - MinX, MaxZ - MinZ

	local Shape = {
		{ -0.30, -0.34 }, { 0.22, -0.20 }, { 0.32, 0.12 },
		{ 0.04, 0.34 }, { -0.30, 0.20 }, { -0.12, -0.02 },
	}

	for _, Offset in ipairs(Shape) do
		local Point = Vector3.new(
			math.clamp(CenterX + Offset[1] * Width, MinX, MaxX),
			Y,
			math.clamp(CenterZ + Offset[2] * Length, MinZ, MaxZ)
		)
		-- si el punto cae sobre un obstaculo solido, se corre hacia el centro de la zona
		for _ = 1, 3 do
			if IsPointClear(Point, Rig) then break end
			local Towards = Vector3.new(CenterX - Point.X, 0, CenterZ - Point.Z)
			if Towards.Magnitude < 1 then break end
			Point = Point + Towards.Unit * 9
		end
		Route[#Route + 1] = Point
	end

	return Route
end

local SteerParams = RaycastParams.new()
SteerParams.FilterType = Enum.RaycastFilterType.Exclude

local function SteerAround(Rig: Model, Origin: Vector3, Direction: Vector3): Vector3
	local Flat = Vector3.new(Direction.X, 0, Direction.Z)
	if Flat.Magnitude < 0.01 then return Direction end
	Flat = Flat.Unit

	SteerParams.FilterDescendantsInstances = { Rig }
	local Start = Origin + Vector3.new(0, 3.5, 0)
	if not workspace:Raycast(Start, Flat * STEER_PROBE, SteerParams) then
		return Flat
	end

	for _, Angle in ipairs({ 35, -35, 65, -65, 100, -100 }) do
		local Alternative = CFrame.Angles(0, math.rad(Angle), 0) * Flat
		if not workspace:Raycast(Start, Alternative * STEER_PROBE, SteerParams) then
			return Alternative.Unit
		end
	end
	return Flat
end

local function StartEnemy(EnemyName: string, EnemyContainer: Instance)
	local EnemyData = EnemyModule[EnemyName]
	if not EnemyData then
		warn(EnemyName .. " does not exist in EnemyModule")
		return
	end

	local EnemyRig = FindEnemyRig(EnemyContainer)
	local Pos = EnemyContainer:FindFirstChild("Pos") :: BasePart?

	if not EnemyRig or not Pos then
		warn(EnemyName .. " needs a Rig and a Pos")
		return
	end

	local RootPart = EnemyRig:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not RootPart then
		warn(EnemyRig.Name .. " needs a HumanoidRootPart")
		return
	end

	if EnemyRegistry[EnemyRig] then
		-- ya inicializado: evita bucles, conexiones y NPCs duplicados
		return
	end

	AnchorEnemyModel(EnemyRig)

	if not EnemyRig.PrimaryPart then
		EnemyRig.PrimaryPart = RootPart
	end

	EnemyRig:PivotTo(RootPart.CFrame)

	local MoveSpeed = EnemyData.EnemySpeed or 16
	local TurnSpeed = EnemyData.TurnSpeed or ENEMY_DEFAULT_TURN_SPEED

	-- Rig Accessories & Light/Siren Setup
	local SirenSound = RootPart:FindFirstChild("SirenSound") :: Sound?
	local RedStrobe = EnemyRig:FindFirstChild("RedStrobe") :: BasePart?
	local BlueStrobe = EnemyRig:FindFirstChild("BlueStrobe") :: BasePart?
	local RedLight = RedStrobe and RedStrobe:FindFirstChild("BeaconLight") :: PointLight?
	local BlueLight = BlueStrobe and BlueStrobe:FindFirstChild("BeaconLight") :: PointLight?

	local Head = EnemyRig:FindFirstChild("Head") :: BasePart?
	local TitleGui = Head and Head:FindFirstChild("PoliceTitleGui") :: BillboardGui?
	if TitleGui then
		TitleGui.AlwaysOnTop = false
		TitleGui.MaxDistance = 45
	end
	local Frame = TitleGui and TitleGui:FindFirstChild("Frame") :: Frame?
	local TitleLabel = Frame and Frame:FindFirstChild("TitleLabel") :: TextLabel?
	local DescLabel = Frame and Frame:FindFirstChild("DescLabel") :: TextLabel?

	local DefaultTitleText = string.format("%s %s", EnemyData.Flag or "👮", EnemyData.BossName or EnemyName)
	local DefaultDescText = string.format("Patrulla Oficial — %s", EnemyData.Country or "Nacional")

	if TitleLabel then TitleLabel.Text = DefaultTitleText end
	if DescLabel then DescLabel.Text = DefaultDescText end

	ConnectEnemyDamage(EnemyRig, EnemyData)

	-- Realistic country-zone patrol waypoints
	local X0 = Pos.Position.X
	local Y0 = Pos.Position.Y
	local Z0 = Pos.Position.Z

	-- Ruta de patrulla calculada sobre los limites reales de la zona del oficial
	local ZoneMin, ZoneMax = GetZoneBounds(EnemyName)
	local Waypoints = BuildPatrolRoute(EnemyRig, Pos, ZoneMin, ZoneMax)
	if #Waypoints < 2 then
		Waypoints = { Vector3.new(X0, Y0, Z0), Vector3.new(X0 + 18, Y0, Z0 + 18), Vector3.new(X0 - 18, Y0, Z0 + 10) }
	end

	local EnemyState = {
		GoalPosition = Waypoints[1],
		Chasing = false,
		EggTarget = nil,
		Waypoints = Waypoints,
		PatrolIndex = 1,
		WaitUntil = 0,
		StrobeTick = 0,
		ZoneMin = ZoneMin,
		ZoneMax = ZoneMax,
		LastPosition = Vector3.new(X0, Y0, Z0),
		LastProgress = os.clock(),
	}

	local function AdvanceWaypoint(Pause: number?)
		EnemyState.PatrolIndex = (EnemyState.PatrolIndex % #EnemyState.Waypoints) + 1
		EnemyState.GoalPosition = EnemyState.Waypoints[EnemyState.PatrolIndex]
		EnemyState.WaitUntil = os.clock() + (Pause or 0)
		EnemyState.LastProgress = os.clock()
	end

	EnemyRegistry[EnemyRig] = {
		EnemyData = EnemyData,
		RootPart = RootPart,
		Pos = Pos,
		State = EnemyState,
	}

	-- AI Evaluation Loop
	task.spawn(function()
		while EnemyRig.Parent do
			if EnemyState.EggTarget then
				task.wait(ENEMY_UPDATE_TIME)
				continue
			end

			local TargetPlayer, TargetRoot = FindTargetForEnemy(EnemyData, RootPart, Pos.Position)

			-- el policia te sigue por todo el mapa hasta que pasas la zona segura
			local TargetInZone = TargetRoot ~= nil and not IsInSafeArea(TargetRoot.Position)

			if TargetPlayer and TargetRoot and TargetInZone then
				EnemyRig:SetAttribute("TargetUserId", TargetPlayer.UserId)
				-- el jugador no tiene vida: el arresto depende solo de la distancia al policia
				if (RootPart.Position - TargetRoot.Position).Magnitude <= 5.5 then
					ArrestPlayer(TargetPlayer, EnemyData)
				end
				EnemyState.GoalPosition = TargetRoot.Position
				EnemyState.Chasing = true
				EnemyState.LastProgress = os.clock()
			else
				if EnemyState.Chasing then
					-- el sospechoso salio de la zona o se perdio: se vuelve a la ronda
					EnemyState.GoalPosition = EnemyState.Waypoints[EnemyState.PatrolIndex]
					EnemyState.WaitUntil = 0
					EnemyState.LastProgress = os.clock()
				end
				EnemyRig:SetAttribute("TargetUserId", nil)
				EnemyState.Chasing = false
			end

			task.wait(ENEMY_UPDATE_TIME)
		end
	end)

	-- Visual Strobe & Siren Effect Loop
	task.spawn(function()
		local WasChasing = false
		while EnemyRig.Parent do
			if EnemyState.Chasing and not WasChasing then
				PlaySpottedAlert(EnemyRig)
			end
			WasChasing = EnemyState.Chasing
			if EnemyState.Chasing then
				-- Active Chase: Siren and Strobes Flashing
				if SirenSound and not SirenSound.IsPlaying then
					SirenSound.Volume = 0.55
					SirenSound.Looped = true
					SirenSound:Play()
				end

				EnemyState.StrobeTick = (EnemyState.StrobeTick + 1) % 4
				if EnemyState.StrobeTick < 2 then
					if RedStrobe then RedStrobe.Material = Enum.Material.Neon end
					if RedLight then RedLight.Brightness = 3 end
					if BlueStrobe then BlueStrobe.Material = Enum.Material.SmoothPlastic end
					if BlueLight then BlueLight.Brightness = 0 end
				else
					if RedStrobe then RedStrobe.Material = Enum.Material.SmoothPlastic end
					if RedLight then RedLight.Brightness = 0 end
					if BlueStrobe then BlueStrobe.Material = Enum.Material.Neon end
					if BlueLight then BlueLight.Brightness = 3 end
				end

				if TitleLabel then
					TitleLabel.Text = "🚨 ¡PERSECUCIÓN POLICIAL! 🚨"
					TitleLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
				end
				if DescLabel then
					DescLabel.Text = "¡ALTO EN NOMBRE DE LA LEY!"
					DescLabel.TextColor3 = Color3.fromRGB(255, 230, 80)
				end
			else
				-- Normal Patrol: Silence and Idle Lights
				if SirenSound and SirenSound.IsPlaying then
					SirenSound:Stop()
				end

				if RedStrobe then RedStrobe.Material = Enum.Material.SmoothPlastic end
				if RedLight then RedLight.Brightness = 0 end
				if BlueStrobe then BlueStrobe.Material = Enum.Material.SmoothPlastic end
				if BlueLight then BlueLight.Brightness = 0 end

				if TitleLabel then
					TitleLabel.Text = DefaultTitleText
					TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
				end
				if DescLabel then
					DescLabel.Text = DefaultDescText
					DescLabel.TextColor3 = Color3.fromRGB(180, 220, 255)
				end
			end

			task.wait(0.12)
		end
	end)

	-- Movement & Kinematic Stepping Connection
	local MovementConnection: RBXScriptConnection?
	MovementConnection = RunService.Heartbeat:Connect(function(DeltaTime: number)
		if not EnemyRig.Parent then
			if MovementConnection then MovementConnection:Disconnect() end
			if SirenSound and SirenSound.IsPlaying then SirenSound:Stop() end
			EnemyRegistry[EnemyRig] = nil
			return
		end

		-- Handle Dropped Egg Retrieval
		if EnemyState.EggTarget and EnemyState.EggTarget.Claimed then
			EnemyState.EggTarget = nil
			EnemyState.Chasing = false
			EnemyState.GoalPosition = EnemyState.Waypoints[EnemyState.PatrolIndex]
			EnemyRig:SetAttribute("TargetUserId", nil)
		end

		local CurrentCFrame = EnemyRig:GetPivot()
		local CurrentPosition = CurrentCFrame.Position
		local GoalPosition = EnemyState.GoalPosition
		local CurrentSpeed = EnemyState.Chasing and MoveSpeed or PATROL_WALK_SPEED

		local FlatOffset = Vector3.new(GoalPosition.X - CurrentPosition.X, 0, GoalPosition.Z - CurrentPosition.Z)
		local Distance = FlatOffset.Magnitude

		if EnemyState.Chasing then
			-- In Chase: Sprint directly towards suspect
			if Distance > ENEMY_ARRIVAL_DISTANCE then
				local Direction = SteerAround(EnemyRig, CurrentPosition, FlatOffset.Unit)
				local Step = math.min(Distance, CurrentSpeed * DeltaTime)
				local NewPosition = CurrentPosition + Direction * Step
				local FacingCFrame = CFrame.new(NewPosition, NewPosition + Direction)
				local Alpha = math.clamp(TurnSpeed * DeltaTime, 0, 1)
				local NewRotation = CurrentCFrame.Rotation:Lerp(FacingCFrame.Rotation, Alpha)

				local RunBob = math.sin(os.clock() * 12) * 0.12
				EnemyRig:PivotTo(CFrame.new(NewPosition.X, Y0 + RunBob, NewPosition.Z) * NewRotation)

				-- Distance arrest trigger
				if Distance <= ENEMY_ARREST_DISTANCE then
					local targetId = EnemyRig:GetAttribute("TargetUserId") :: number?
					if targetId then
						local targetPlayer = Players:GetPlayerByUserId(targetId)
						if targetPlayer then
							ArrestPlayer(targetPlayer, EnemyData)
						end
					end
				end
			elseif EnemyState.EggTarget then
				local DroppedInfo = EnemyState.EggTarget
				EnemyState.EggTarget = nil
				EnemyState.Chasing = false
				EnemyState.GoalPosition = EnemyState.Waypoints[EnemyState.PatrolIndex]
				EnemyRig:SetAttribute("TargetUserId", nil)
				ClaimDroppedEgg(DroppedInfo)
			end
		else
			-- In Patrol: Walk route and inspect waypoints
			local now = os.clock()
			if now < EnemyState.WaitUntil then
				-- Pausing at waypoint, looking around
				local IdleBob = math.sin(now * 3) * 0.04
				EnemyRig:PivotTo(CFrame.new(CurrentPosition.X, Y0 + IdleBob, CurrentPosition.Z) * CurrentCFrame.Rotation)
			else
				if Distance > 2.2 then
					local Direction = SteerAround(EnemyRig, CurrentPosition, FlatOffset.Unit)
					local Step = math.min(Distance, CurrentSpeed * DeltaTime)
					local NewPosition = CurrentPosition + Direction * Step

					-- nunca sale de su propia zona
					if EnemyState.ZoneMin and EnemyState.ZoneMax then
						NewPosition = Vector3.new(
							math.clamp(NewPosition.X, EnemyState.ZoneMin.X + 6, EnemyState.ZoneMax.X - 6),
							NewPosition.Y,
							math.clamp(NewPosition.Z, EnemyState.ZoneMin.Z + 6, EnemyState.ZoneMax.Z - 6)
						)
					end

					local FacingCFrame = CFrame.new(NewPosition, NewPosition + Direction)
					local Alpha = math.clamp(TurnSpeed * DeltaTime, 0, 1)
					local NewRotation = CurrentCFrame.Rotation:Lerp(FacingCFrame.Rotation, Alpha)

					local WalkBob = math.sin(now * 6) * 0.08
					EnemyRig:PivotTo(CFrame.new(NewPosition.X, Y0 + WalkBob, NewPosition.Z) * NewRotation)

					-- recuperacion si queda trabado contra un obstaculo
					if (NewPosition - EnemyState.LastPosition).Magnitude > STUCK_MIN_MOVE then
						EnemyState.LastPosition = NewPosition
						EnemyState.LastProgress = now
					elseif now - EnemyState.LastProgress > STUCK_TIME then
						AdvanceWaypoint(0.4)
						EnemyState.LastPosition = NewPosition
					end
				else
					-- Reached patrol waypoint! Pause to inspect, then advance
					AdvanceWaypoint(1.8)
				end
			end
		end
	end)
end

local function LoadEnemies()
	for EnemyName in pairs(EnemyModule) do
		local EnemyContainer = EnemiesFolder:FindFirstChild(EnemyName)
		if EnemyContainer then
			StartEnemy(EnemyName, EnemyContainer)
		else
			warn("EnemyPos does not contain " .. EnemyName)
		end
	end
end

SafeZonePart.Touched:Connect(function(Hit)
	local Character = Hit:FindFirstAncestorOfClass("Model")
	local Player = Character and Players:GetPlayerFromCharacter(Character)
	if not Player or not PlayerEggs[Player] or SafeZoneDebounce[Player] then
		return
	end

	SafeZoneDebounce[Player] = true
	local Carry = PlayerEggs[Player]
	if Carry and not Carry.HintShown then
		Carry.HintShown = true
		EggSoundRemote:FireClient(Player, "Stop")
		Notify(Player, "🏠 ¡A salvo! Entrá a tu base para dejar la caja en un espacio libre", Color3.fromRGB(120, 230, 255), 4)
	end

	task.delay(1, function()
		SafeZoneDebounce[Player] = nil
	end)
end)

local function ConnectPlayer(Player: Player)
	AssignPlot(Player)

	Player.CharacterAdded:Connect(function(Character)
		Character:WaitForChild("HumanoidRootPart")
		task.wait(0.2)
		TeleportToPlot(Player)
	end)

	Player.CharacterRemoving:Connect(function()
		DropCurrentEgg(Player)
	end)

	if Player.Character then
		task.defer(function()
			Player.Character:WaitForChild("HumanoidRootPart")
			TeleportToPlot(Player)
		end)
	end
end

Players.PlayerAdded:Connect(ConnectPlayer)

Players.PlayerRemoving:Connect(function(Player: Player)
	DropCurrentEgg(Player)

	local Plot = PlayerPlots[Player]
	if Plot then
		PlotOwners[Plot] = nil
		PlayerPlots[Player] = nil
		Plot:SetAttribute("OwnerUserId", nil)
		ClearPlotInfo(Plot)
	end

	SafeZoneDebounce[Player] = nil
	EnemyHitDebounce[Player] = nil
end)

for _, Player in ipairs(Players:GetPlayers()) do
	ConnectPlayer(Player)
end

-- ===== EN LA BASE: aviso para dejar la caja con E donde quieras =====
local BaseHint = {}
RunService.Heartbeat:Connect(function()
	for Player, EggData in pairs(PlayerEggs) do
		if not EggData.Delivering and not EggData.BaseHint and InsideOwnBase(Player) then
			EggData.BaseHint = true
			Notify(Player, "📦 Presioná E para dejar la caja donde quieras en tu base", Color3.fromRGB(120, 230, 255), 3.5)
		end
	end
end)

ConnectEggPrompts()
LoadEnemies()