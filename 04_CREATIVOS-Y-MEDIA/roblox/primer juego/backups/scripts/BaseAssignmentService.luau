--!strict
--[[
    BaseAssignmentService.server.luau
    Authoritative Base Ownership & Dynamic Training System for VAULT POP!
    - Dynamic base assignment (Base_1 to Base_5).
    - Functional Treadmill: Character running, WalkSpeed gain, BaseSpeed sync, +Speed indicators.
    - Functional Strength: Character barbell lifting, Strength gain, +Fuerza indicators.
    - Full two-way sync with PlayerStateManager and StatsUpdated remote.
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local TweenService = game:GetService("TweenService")

local Modules = ServerScriptService:WaitForChild("Modules", 10)
local PlayerStateManager = require(Modules:WaitForChild("PlayerStateManager") :: ModuleScript)

local Remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
local TrainingStateChanged = Remotes:WaitForChild("TrainingStateChanged") :: RemoteEvent
local RequestStopTraining = Remotes:WaitForChild("RequestStopTraining") :: RemoteEvent
local StatsUpdated = Remotes:WaitForChild("StatsUpdated") :: RemoteEvent

local SafeZone = Workspace:WaitForChild("SafeZone", 10)
local BasePlots = SafeZone and SafeZone:WaitForChild("BasePlots", 10)
if not BasePlots then
	warn("[BaseAssignmentService] No se encontro SafeZone.BasePlots!")
	return
end

type BaseData = {
	model: Model,
	name: string,
	owner: Player?,
	treadmillLevel: number,
	strengthLevel: number,
}

local bases: { [string]: BaseData } = {}
local playerToBase: { [number]: string } = {}

type ActiveTraining = {
	machineType: string,
	baseName: string,
	stationModel: Model,
	lastTick: number,
}
local activeTraining: { [number]: ActiveTraining } = {}

local MAX_TRAIN_DISTANCE = 6.0
local MAX_STATION_LEVEL = 10

local function getTreadmillCost(level: number): number
	return math.floor(100 * (1.8 ^ (level - 1)))
end

local function getStrengthCost(level: number): number
	return math.floor(120 * (1.8 ^ (level - 1)))
end

-- ===================================================================
-- UI & VISUAL EFFECTS
-- ===================================================================
local function showFloatingIndicator(head: BasePart, text: string, color: Color3)
	local bbg = Instance.new("BillboardGui")
	bbg.Name = "TrainingPopIndicator"
	bbg.Size = UDim2.new(4.5, 0, 1.2, 0)
	bbg.StudsOffset = Vector3.new(0, 2.5, 0)
	bbg.AlwaysOnTop = true
	bbg.LightInfluence = 0
	bbg.Parent = head

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, 0, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.FredokaOne
	lbl.Text = text
	lbl.TextColor3 = color
	lbl.TextStrokeColor3 = Color3.fromRGB(20, 20, 25)
	lbl.TextStrokeTransparency = 0
	lbl.TextScaled = true
	lbl.Parent = bbg

	local tweenInfo = TweenInfo.new(0.85, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(bbg, tweenInfo, { StudsOffset = Vector3.new(0, 4.8, 0) })
	local fadeTween = TweenService:Create(lbl, tweenInfo, { TextTransparency = 1, TextStrokeTransparency = 1 })
	tween:Play()
	fadeTween:Play()
	task.delay(0.9, function()
		bbg:Destroy()
	end)
end

-- Crea la barra con pesas visible sostenida por el personaje
local function givePlayerBarbell(char: Model): Model?
	local root = char:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not root then return nil end

	local old = char:FindFirstChild("PlayerBarbell")
	if old then old:Destroy() end

	local barbellModel = Instance.new("Model")
	barbellModel.Name = "PlayerBarbell"

	local bar = Instance.new("Part")
	bar.Name = "Bar"
	bar.Size = Vector3.new(6.5, 0.4, 0.4)
	bar.Color = Color3.fromRGB(220, 225, 235)
	bar.Material = Enum.Material.Metal
	bar.CanCollide = false
	bar.Anchored = false
	bar.CFrame = root.CFrame * CFrame.new(0, 0.6, -1.3)
	bar.Parent = barbellModel

	for _, offset in ipairs({ -2.8, 2.8 }) do
		local plate = Instance.new("Part")
		plate.Name = "WeightPlate"
		plate.Size = Vector3.new(0.5, 2.6, 2.6)
		plate.Color = Color3.fromRGB(45, 45, 52)
		plate.Material = Enum.Material.SmoothPlastic
		plate.CanCollide = false
		plate.Anchored = false
		plate.CFrame = bar.CFrame * CFrame.new(offset, 0, 0)
		plate.Parent = barbellModel

		local weld = Instance.new("WeldConstraint")
		weld.Part0 = bar
		weld.Part1 = plate
		weld.Parent = bar
	end

	local rootJoint = Instance.new("Motor6D")
	rootJoint.Name = "BarbellJoint"
	rootJoint.Part0 = root
	rootJoint.Part1 = bar
	rootJoint.C0 = CFrame.new(0, 0.4, -1.4)
	rootJoint.Parent = bar

	barbellModel.Parent = char
	return barbellModel
end

local function removePlayerBarbell(char: Model)
	local b = char:FindFirstChild("PlayerBarbell")
	if b then b:Destroy() end
end

local function setRackBarbellTransparency(stationModel: Model, transparency: number)
	for _, name in ipairs({ "Barbell", "PlateL", "PlateR" }) do
		local p = stationModel:FindFirstChild(name) :: BasePart?
		if p then p.Transparency = transparency end
	end
end

-- Actualiza letrero de base
local function updateBaseSign(baseData: BaseData)
	local sign = baseData.model:FindFirstChild("BaseSign")
	local signBoard = sign and sign:FindFirstChild("SignBoard")
	local ownerGui = signBoard and signBoard:FindFirstChild("OwnerGui")
	local ownerLabel = ownerGui and ownerGui:FindFirstChild("OwnerLabel") :: TextLabel?
	if ownerLabel then
		local baseNum = baseData.name:gsub("Base_", "")
		if baseData.owner then
			ownerLabel.Text = string.format("BASE %s — %s", baseNum, baseData.owner.DisplayName:upper())
			ownerLabel.TextColor3 = Color3.fromRGB(100, 255, 120)
		else
			ownerLabel.Text = string.format("BASE %s — DISPONIBLE", baseNum)
			ownerLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
		end
	end
end

local function updateStationGui(baseData: BaseData, machineType: string)
	local station = if machineType == "Treadmill" 
		then baseData.model:FindFirstChild("TreadmillStation") 
		else baseData.model:FindFirstChild("StrengthStation")
	if not station then return end
	local infoGui = station:FindFirstChild("StationInfoGui", true)
	if not infoGui then return end
	local titleLabel = infoGui:FindFirstChild("TitleLabel", true) :: TextLabel?
	local subLabel = infoGui:FindFirstChild("SubLabel", true) :: TextLabel?
	local lvl = if machineType == "Treadmill" then baseData.treadmillLevel else baseData.strengthLevel
	local cost = if machineType == "Treadmill" then getTreadmillCost(lvl) else getStrengthCost(lvl)
	if machineType == "Treadmill" then
		if titleLabel then titleLabel.Text = string.format("🏃 TREADMILL (Nivel %d)", lvl) end
		if subLabel then subLabel.Text = string.format("+%.1f Vel/s | [R] Mejorar (%d 🪙)", 1.0 + (lvl - 1) * 0.5, cost) end
	else
		if titleLabel then titleLabel.Text = string.format("💪 STRENGTH (Nivel %d)", lvl) end
		if subLabel then subLabel.Text = string.format("+%.1f Fuerza/s | [R] Mejorar (%d 🪙)", 2.0 + (lvl - 1) * 1.0, cost) end
	end
end

-- ===================================================================
-- ASIGNACION DE BASES
-- ===================================================================
local function assignBaseToPlayer(player: Player): string?
	local userId = player.UserId
	player.CharacterAdded:Connect(function()
		task.wait(0.2)
		PlayerStateManager.ApplyWalkSpeed(player)
	end)
	if player.Character then
		PlayerStateManager.ApplyWalkSpeed(player)
	end
	if playerToBase[userId] then return playerToBase[userId] end
	for i = 1, 5 do
		local name = "Base_" .. i
		local bData = bases[name]
		if bData and bData.owner == nil then
			bData.owner = player
			playerToBase[userId] = name
			updateBaseSign(bData)
			bData.model:SetAttribute("OwnerUserId", userId)
			bData.model:SetAttribute("OwnerName", player.Name)
			player:SetAttribute("AssignedBase", name)
			print(string.format("[BaseAssignment] Asignada %s a %s (%d)", name, player.Name, userId))
			return name
		end
	end
	return nil
end

local function releaseBase(player: Player)
	local userId = player.UserId
	local baseName = playerToBase[userId]
	if baseName and bases[baseName] then
		local bData = bases[baseName]
		bData.owner = nil
		bData.treadmillLevel = 1
		bData.strengthLevel = 1
		updateBaseSign(bData)
		updateStationGui(bData, "Treadmill")
		bData.model:SetAttribute("OwnerUserId", nil)
		bData.model:SetAttribute("OwnerName", nil)
		updateBaseSign(bData)
		updateStationGui(bData, "Treadmill")
		updateStationGui(bData, "Strength")
		print(string.format("[BaseAssignment] Liberada %s de %s", baseName, player.Name))
	end
	playerToBase[userId] = nil
	activeTraining[userId] = nil
	player:SetAttribute("AssignedBase", nil)
end

-- ===================================================================
-- CONTROL DE ENTRENAMIENTO
-- ===================================================================
local function stopTraining(player: Player)
	local userId = player.UserId
	local tData = activeTraining[userId]
	if not tData then return end
	local st = tData.stationModel
	local char = player.Character

	if tData.machineType == "Treadmill" and st then
		local led = st:FindFirstChild("StatusLED") :: BasePart?
		if led then led.Color = Color3.fromRGB(80, 255, 120) end
	elseif tData.machineType == "Strength" and st then
		setRackBarbellTransparency(st, 0)
		if char then removePlayerBarbell(char) end
	end

	activeTraining[userId] = nil
	player:SetAttribute("IsTraining", false)
	TrainingStateChanged:FireClient(player, false, tData.machineType, "")
end

local function setupBaseInteractions(baseModel: Model, bData: BaseData)
	-- 1. Treadmill
	local tm = baseModel:FindFirstChild("TreadmillStation")
	if tm then
		local belt = tm:FindFirstChild("Belt") :: BasePart?
		local trainPrompt = belt and belt:FindFirstChildOfClass("ProximityPrompt")
		if trainPrompt then
			trainPrompt.ActionText = "Correr en Cinta"
			trainPrompt.ObjectText = "Treadmill"
			trainPrompt.Triggered:Connect(function(player: Player)
				local userId = player.UserId
				if bData.owner and bData.owner ~= player then return end
				if activeTraining[userId] then
					stopTraining(player)
					return
				end
				local char = player.Character
				local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
				local hum = char and char:FindFirstChildOfClass("Humanoid")
				if not root or not hum or hum.Health <= 0 then return end
				if (root.Position - belt.Position).Magnitude > MAX_TRAIN_DISTANCE then return end

				-- Alinear al personaje en la cinta mirando a la consola
				local consolePart = tm:FindFirstChild("ConsolePillar") or tm:FindFirstChild("ConsoleScreen")
				local lookTarget = if consolePart then consolePart.Position else belt.Position + Vector3.new(0, 0, 10)
				root.CFrame = CFrame.lookAt(
					Vector3.new(belt.Position.X, belt.Position.Y + 2.8, belt.Position.Z),
					Vector3.new(lookTarget.X, belt.Position.Y + 2.8, lookTarget.Z)
				)

				activeTraining[userId] = {
					machineType = "Treadmill",
					baseName = bData.name,
					stationModel = tm,
					lastTick = os.clock(),
				}
				player:SetAttribute("IsTraining", true)
				local led = tm:FindFirstChild("StatusLED") :: BasePart?
				if led then led.Color = Color3.fromRGB(60, 220, 255) end
				TrainingStateChanged:FireClient(player, true, "Treadmill", "Velocidad")
			end)
		end

		local console = tm:FindFirstChild("ConsolePillar") or tm:FindFirstChild("ConsoleScreen")
		local upgPrompt = (console and console:FindFirstChildOfClass("ProximityPrompt"))
			or (tm:FindFirstChild("UpgradePrompt", true) :: ProximityPrompt?)
		if upgPrompt then
			upgPrompt.ActionText = "Mejorar Cinta"
			upgPrompt.ObjectText = "Upgrade [R]"
			upgPrompt.KeyboardKeyCode = Enum.KeyCode.R
			upgPrompt.Triggered:Connect(function(player: Player)
				if bData.owner and bData.owner ~= player then return end
				if bData.treadmillLevel >= MAX_STATION_LEVEL then return end
				local cost = getTreadmillCost(bData.treadmillLevel)
				local userCoins = PlayerStateManager.GetCoins(player.UserId)
				if userCoins >= cost then
					PlayerStateManager.AddCoins(player.UserId, -cost)
					bData.treadmillLevel = bData.treadmillLevel + 1
					updateStationGui(bData, "Treadmill")
				end
			end)
		end
	end

	-- 2. Strength
	local ss = baseModel:FindFirstChild("StrengthStation")
	if ss then
		local mat = ss:FindFirstChild("LiftingMat") :: BasePart?
		local trainPrompt = mat and mat:FindFirstChildOfClass("ProximityPrompt")
		if trainPrompt then
			trainPrompt.ActionText = "Levantar Pesas"
			trainPrompt.ObjectText = "Strength"
			trainPrompt.Triggered:Connect(function(player: Player)
				local userId = player.UserId
				if bData.owner and bData.owner ~= player then return end
				if activeTraining[userId] then
					stopTraining(player)
					return
				end
				local char = player.Character
				local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
				local hum = char and char:FindFirstChildOfClass("Humanoid")
				if not root or not hum or hum.Health <= 0 then return end
				if (root.Position - mat.Position).Magnitude > MAX_TRAIN_DISTANCE then return end

				-- Alinear al personaje en el tapete de pesas mirando al rack
				local rackPart = ss:FindFirstChild("RackCrossbar") or ss:FindFirstChild("RackUprightL")
				local lookTarget = if rackPart then rackPart.Position else mat.Position + Vector3.new(0, 0, 10)
				root.CFrame = CFrame.lookAt(
					Vector3.new(mat.Position.X, mat.Position.Y + 2.8, mat.Position.Z),
					Vector3.new(lookTarget.X, mat.Position.Y + 2.8, lookTarget.Z)
				)

				activeTraining[userId] = {
					machineType = "Strength",
					baseName = bData.name,
					stationModel = ss,
					lastTick = os.clock(),
				}
				player:SetAttribute("IsTraining", true)
				setRackBarbellTransparency(ss, 1)
				givePlayerBarbell(char)
				TrainingStateChanged:FireClient(player, true, "Strength", "Fuerza")
			end)
		end

		local rack = ss:FindFirstChild("RackCrossbar")
		local upgPrompt = (rack and rack:FindFirstChildOfClass("ProximityPrompt"))
			or (ss:FindFirstChild("UpgradePrompt", true) :: ProximityPrompt?)
		if upgPrompt then
			upgPrompt.ActionText = "Mejorar Pesas"
			upgPrompt.ObjectText = "Upgrade [R]"
			upgPrompt.KeyboardKeyCode = Enum.KeyCode.R
			upgPrompt.Triggered:Connect(function(player: Player)
				if bData.owner and bData.owner ~= player then return end
				if bData.strengthLevel >= MAX_STATION_LEVEL then return end
				local cost = getStrengthCost(bData.strengthLevel)
				local userCoins = PlayerStateManager.GetCoins(player.UserId)
				if userCoins >= cost then
					PlayerStateManager.AddCoins(player.UserId, -cost)
					bData.strengthLevel = bData.strengthLevel + 1
					updateStationGui(bData, "Strength")
				end
			end)
		end
	end
end

-- ===================================================================
-- INICIALIZAR BASES
-- ===================================================================
for i = 1, 5 do
	local bName = "Base_" .. i
	local bModel = BasePlots:FindFirstChild(bName)
	if bModel and bModel:IsA("Model") then
		local bData: BaseData = {
			model = bModel,
			name = bName,
			owner = nil,
			treadmillLevel = 1,
			strengthLevel = 1,
		}
		bases[bName] = bData
		updateBaseSign(bData)
		updateStationGui(bData, "Treadmill")
		updateStationGui(bData, "Strength")
		setupBaseInteractions(bModel, bData)
	end
end

-- ===================================================================
-- BUCLE DE ENTRENAMIENTO (1 segundo por tick)
-- ===================================================================
task.spawn(function()
	while true do
		task.wait(1.0)
		for _, player in ipairs(Players:GetPlayers()) do
			local userId = player.UserId
			local tData = activeTraining[userId]
			if tData then
				local char = player.Character
				local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
				local hum = char and char:FindFirstChildOfClass("Humanoid")
				local head = char and char:FindFirstChild("Head") :: BasePart?
				local st = tData.stationModel
				local centerPart = st and (st.PrimaryPart or st:FindFirstChildWhichIsA("BasePart"))
				
				if not root or not hum or hum.Health <= 0 or not centerPart or (root.Position - centerPart.Position).Magnitude > MAX_TRAIN_DISTANCE then
					stopTraining(player)
				else
					local bData = bases[tData.baseName]
					if tData.machineType == "Treadmill" then
						local lvl = bData and bData.treadmillLevel or 1
						local tmEff = PlayerStateManager.GetUpgrade(userId, "TreadmillEfficiency")
						local speedGain = (1.0 + (lvl - 1) * 0.5) * (1 + (tmEff - 1) * 0.5)
						local newSpeed = PlayerStateManager.AddSpeed(userId, speedGain)
						local coinsGained = 2 + lvl
						local newCoins = PlayerStateManager.AddCoins(userId, coinsGained)

						-- Sincronizar velocidad autoritativa del personaje
						PlayerStateManager.ApplyWalkSpeed(player)

						-- Indicador flotante 3D sobre la cabeza
						if head then
							showFloatingIndicator(head, string.format("+%.1f ⚡ Vel (+%d 🪙)", speedGain, coinsGained), Color3.fromRGB(60, 225, 255))
						end

						-- Notificar HUD del cliente
						StatsUpdated:FireClient(player, {
							Speed = newSpeed,
							Strength = PlayerStateManager.GetStrength(userId),
							Coins = newCoins,
							SpeedUpgrade = PlayerStateManager.GetUpgrade(userId, "SpeedUpgrade"),
							StrengthEfficiency = PlayerStateManager.GetUpgrade(userId, "StrengthEfficiency"),
							TreadmillEfficiency = tmEff,
						})

					elseif tData.machineType == "Strength" then
						local lvl = bData and bData.strengthLevel or 1
						local strEff = PlayerStateManager.GetUpgrade(userId, "StrengthEfficiency")
						local strGain = (2.0 + (lvl - 1) * 1.0) * (1 + (strEff - 1) * 0.5)
						local newStr = PlayerStateManager.AddStrength(userId, strGain)
						local coinsGained = 3 + lvl * 2
						local newCoins = PlayerStateManager.AddCoins(userId, coinsGained)

						-- Sincronizar fuerza autoritativa del personaje
						player:SetAttribute("Strength", newStr)

						-- Si transporta huevo, recalcular penalizacion mitigada de inmediato
						if player:GetAttribute("CarryingEgg") == true then
							local eggWeight = player:GetAttribute("CarriedEggWeight") or 10
							local excess = math.max(0, eggWeight - newStr * 1.0)
							local penalty = math.clamp(excess / 100, 0, 0.40)
							player:SetAttribute("EggSpeedPenalty", penalty)
						end
						PlayerStateManager.ApplyWalkSpeed(player)

						-- Indicador flotante 3D sobre la cabeza
						if head then
							showFloatingIndicator(head, string.format("+%.1f 💪 Fuerza (+%d 🪙)", strGain, coinsGained), Color3.fromRGB(255, 180, 50))
						end

						-- Notificar HUD del cliente
						StatsUpdated:FireClient(player, {
							Speed = PlayerStateManager.GetSpeed(userId),
							Strength = newStr,
							Coins = newCoins,
							SpeedUpgrade = PlayerStateManager.GetUpgrade(userId, "SpeedUpgrade"),
							StrengthEfficiency = strEff,
							TreadmillEfficiency = PlayerStateManager.GetUpgrade(userId, "TreadmillEfficiency"),
						})
					end
				end
			end
		end
	end
end)

RequestStopTraining.OnServerEvent:Connect(function(player: Player)
	stopTraining(player)
end)

Players.PlayerAdded:Connect(function(player: Player)
	assignBaseToPlayer(player)
end)

Players.PlayerRemoving:Connect(function(player: Player)
	releaseBase(player)
end)

for _, p in ipairs(Players:GetPlayers()) do
	assignBaseToPlayer(p)
end

print("[BaseAssignmentService] Inicializado: 5 bases activas y autorizadas con entrenamiento animado.")
