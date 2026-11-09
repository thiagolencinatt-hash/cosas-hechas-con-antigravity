--!strict
-- Script: ServerScriptService.EggService
-- Gestión autoritativa de recolección de huevos, transporte visual, velocidad, persecución y muteces

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local ServerScriptService = game:GetService("ServerScriptService")

local BeastDataModule = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("BeastDataModule") :: ModuleScript)
local BossChaseManager = require(ServerScriptService:WaitForChild("BossChaseManager") :: ModuleScript)
local DroppedEggManager = require(ServerScriptService:WaitForChild("Modules"):WaitForChild("DroppedEggManager") :: ModuleScript)
local PlayerStateManager = require(ServerScriptService:WaitForChild("Modules"):WaitForChild("PlayerStateManager") :: ModuleScript)

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local EggStateChanged = Remotes:WaitForChild("EggStateChanged") :: RemoteEvent
local DropEgg = Remotes:WaitForChild("DropEgg") :: RemoteEvent

export type CarriedEggData = DroppedEggManager.DroppedEggData

local carriedEggs: { [number]: CarriedEggData } = {}
local lastInteractTime: { [number]: number } = {}
local connectedPrompts: { [ProximityPrompt]: boolean } = {}
local MAX_INTERACT_DISTANCE = 18

-- Calcula penalización de velocidad basada en Fuerza del jugador
local function calculatePenalty(eggWeight: number, playerStrength: number): number
	local excess = math.max(0, eggWeight - (playerStrength * 1.0))
	return math.clamp(excess / 100, 0, 0.40) -- Máximo 40% de lentitud
end

-- Limpieza y restauración autoritativa de velocidad
local function removeCarriedEgg(player: Player, keepSessionData: boolean)
	local userId = player.UserId
	local prevEgg = carriedEggs[userId]
	if prevEgg then
		BossChaseManager.CancelChase(prevEgg.BiomeIndex)
	end
	if not keepSessionData then
		carriedEggs[userId] = nil
	end

	player:SetAttribute("CarryingEgg", false)
	player:SetAttribute("EggSpeedPenalty", 0)
	player:SetAttribute("CarriedEggName", nil)
	player:SetAttribute("CarriedEggWeight", nil)
	player:SetAttribute("CarriedEggScale", nil)

	local char = player.Character
	if char then
		local oldEgg = char:FindFirstChild("CarriedEggModel")
		if oldEgg then oldEgg:Destroy() end
	end

	PlayerStateManager.ApplyWalkSpeed(player)
	EggStateChanged:FireClient(player, { Carrying = false })
end

-- Asigna físicamente el modelo del huevo al torso/manos o cabeza según su tamaño
local function attachEggToCharacter(player: Player, eggDef: BeastDataModule.BiomeEggDef, penalty: number, scale: number?)
	local s = scale or 1.0
	local char = player.Character
	if not char then return end

	local root = char:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not root then return end

	-- Buscar torso para R15 o R6
	local attachPart = (char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or root) :: BasePart

	local oldEgg = char:FindFirstChild("CarriedEggModel")
	if oldEgg then oldEgg:Destroy() end

	local eggModel = Instance.new("Model")
	eggModel.Name = "CarriedEggModel"

	local eggPart = Instance.new("Part")
	eggPart.Name = "EggPart"
	eggPart.Shape = Enum.PartType.Ball
	eggPart.Size = Vector3.new(2.0 * s, 2.6 * s, 2.0 * s)
	eggPart.Color = eggDef.EggColor
	eggPart.Material = Enum.Material.SmoothPlastic
	eggPart.CanCollide = false
	eggPart.Massless = true
	eggPart.Anchored = false

	-- Si es Grande o Colosal: portar sobre la cabeza / pecho alto para no tapar visión ni suelo
	-- Si es Pequeño o Mediano: portar delante a la altura de las manos
	local offsetCFrame: CFrame
	if s >= 1.35 then
		offsetCFrame = attachPart.CFrame * CFrame.new(0, 1.85 * (s * 0.75), -0.55 * s)
	else
		offsetCFrame = attachPart.CFrame * CFrame.new(0, -0.2, -1.25 * s)
	end

	eggPart.CFrame = offsetCFrame
	eggPart.Parent = eggModel

	local light = Instance.new("PointLight")
	light.Color = eggDef.AccentColor
	light.Range = 10 * s
	light.Brightness = 1.4
	light.Parent = eggPart

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = attachPart
	weld.Part1 = eggPart
	weld.Parent = eggPart

	-- Billboard informativo sobre el huevo transportado
	local bbg = Instance.new("BillboardGui")
	bbg.Name = "EggGui"
	bbg.Size = UDim2.new(4.2, 0, 1.4, 0)
	bbg.StudsOffset = Vector3.new(0, (2.6 * s) / 2 + 0.8, 0)
	bbg.AlwaysOnTop = true
	bbg.LightInfluence = 0
	bbg.Parent = eggPart

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0.55, 0)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.FredokaOne
	title.Text = "🥚 " .. eggDef.EggName
	title.TextColor3 = eggDef.AccentColor
	title.TextStrokeColor3 = Color3.fromRGB(20, 20, 25)
	title.TextStrokeTransparency = 0
	title.TextScaled = true
	title.Parent = bbg

	local sub = Instance.new("TextLabel")
	sub.Size = UDim2.new(1, 0, 0.40, 0)
	sub.Position = UDim2.new(0, 0, 0.58, 0)
	sub.BackgroundTransparency = 1
	sub.Font = Enum.Font.GothamBold
	local pct = math.round(penalty * 100)
	sub.Text = string.format("%d kg %s", eggDef.EggWeight, pct > 0 and string.format("(-%d%% Vel)", pct) or "(Sin retraso)")
	sub.TextColor3 = pct > 0 and Color3.fromRGB(255, 180, 80) or Color3.fromRGB(120, 255, 140)
	sub.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	sub.TextStrokeTransparency = 0.5
	sub.TextScaled = true
	sub.Parent = bbg

	eggModel.Parent = char
end

-- Asigna los datos y estado de transporte a un jugador
local function equipCarriedEgg(player: Player, eggData: CarriedEggData)
	local userId = player.UserId
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not char or not hum or hum.Health <= 0 then return end

	carriedEggs[userId] = eggData

	local eggDef = BeastDataModule.GetBiomeEgg(eggData.BiomeIndex)
	if not eggDef then return end

	local str = player:GetAttribute("Strength") or 10
	local penalty = calculatePenalty(eggData.Weight, str)

	player:SetAttribute("CarryingEgg", true)
	player:SetAttribute("EggSpeedPenalty", penalty)
	player:SetAttribute("CarriedEggName", eggData.EggName)
	player:SetAttribute("CarriedEggWeight", eggData.Weight)
	player:SetAttribute("CarriedEggScale", eggData.SizeScale)

	PlayerStateManager.ApplyWalkSpeed(player)
	attachEggToCharacter(player, eggDef, penalty, eggData.SizeScale)

	EggStateChanged:FireClient(player, {
		Carrying = true,
		IsNewPickup = true,
		EggName = eggData.EggName,
		Weight = eggData.Weight,
		Penalty = math.round(penalty * 100),
		CurrentSpeed = hum.WalkSpeed,
	})

	-- Iniciar persecución INMEDIATA del jefe del bioma
	BossChaseManager.StartChase(player, eggData.BiomeIndex, function(p)
		removeCarriedEgg(p, false)
	end)
end

-- Recolección inicial de huevo desde nido fijo o silvestre
local function onCollectPromptTriggered(prompt: ProximityPrompt, player: Player)
	local userId = player.UserId
	local now = os.clock()

	if lastInteractTime[userId] and now - lastInteractTime[userId] < 0.3 then return end
	lastInteractTime[userId] = now

	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not char or not root or not hum or hum.Health <= 0 then return end

	local promptPart = prompt.Parent :: BasePart?
	if not promptPart then return end

	local dist = (root.Position - promptPart.Position).Magnitude
	if dist > MAX_INTERACT_DISTANCE then
		warn(string.format("[EggService] Recogida rechazada por distancia: %s a %.1f studs", player.Name, dist))
		return
	end

	-- Validación de límite: Solo 1 huevo simultáneo por jugador
	if carriedEggs[userId] ~= nil then
		EggStateChanged:FireClient(player, {
			Carrying = true,
			Warning = "⚠️ ¡Ya llevas un huevo! Deposítalo en tu incubadora o colócalo en tu base.",
			EggName = carriedEggs[userId].EggName,
			Weight = carriedEggs[userId].Weight,
		})
		return
	end

	local nestModel = promptPart:FindFirstAncestor("EggNest")
	local wildModel = promptPart:FindFirstAncestor("WildEgg")
	local sourceModel = wildModel or nestModel
	if not sourceModel then return end

	-- Mutex atómico para evitar que dos jugadores agarren el mismo huevo simultáneamente
	if sourceModel:GetAttribute("BeingCollected") == true then return end
	sourceModel:SetAttribute("BeingCollected", true)

	local biomeIndex = sourceModel:GetAttribute("BiomeIndex") :: number?
	if not biomeIndex then
		sourceModel:SetAttribute("BeingCollected", nil)
		return
	end

	local eggDef = BeastDataModule.GetBiomeEgg(biomeIndex)
	if not eggDef then
		sourceModel:SetAttribute("BeingCollected", nil)
		return
	end

	local eggWeight = (sourceModel:GetAttribute("Weight") :: number?) or eggDef.EggWeight
	local sizeScale = (sourceModel:GetAttribute("SizeScale") :: number?) or 1.0
	local sizeVariant = (sourceModel:GetAttribute("SizeVariant") :: string?) or "Estándar"

	-- Tirada autoritativa de rareza en servidor, con bono según tamaño de huevo
	local sizeDef = BeastDataModule.GetSizeVariant(sizeVariant)
	local rolledRarity = BeastDataModule.RollRarity(sizeDef.RarityBonus)

	local eggData: CarriedEggData = {
		EggId = HttpService:GenerateGUID(false),
		BiomeIndex = biomeIndex,
		BiomeName = eggDef.BiomeName,
		EggName = eggDef.EggName .. " (" .. sizeVariant .. ")",
		Weight = eggWeight,
		Rarity = rolledRarity,
		CollectedAt = now,
		SizeScale = sizeScale,
		SizeVariant = sizeVariant,
	}

	-- Si es silvestre, eliminar el modelo de forma inmediata
	if wildModel then
		wildModel:Destroy()
	elseif nestModel then
		-- Si es el nido fijo, ocultar visualmente y respawnear a los 6 segundos
		prompt.Enabled = false
		promptPart.Transparency = 1
		local bbg = promptPart:FindFirstChildOfClass("BillboardGui")
		if bbg then bbg.Enabled = false end

		task.delay(6.0, function()
			if promptPart and promptPart.Parent then
				promptPart.Transparency = 0
				prompt.Enabled = true
				if bbg then bbg.Enabled = true end
				nestModel:SetAttribute("BeingCollected", nil)
			end
		end)
	end

	equipCarriedEgg(player, eggData)
	print(string.format("[EggService] %s agarró %s (%s, Bioma %d, %d kg)", player.Name, eggDef.EggName, sizeVariant, biomeIndex, eggWeight))
end

-- Conectar un ProximityPrompt con seguridad anti-duplicados
local function hookCollectPrompt(prompt: ProximityPrompt)
	if connectedPrompts[prompt] then return end
	connectedPrompts[prompt] = true

	prompt.HoldDuration = 0.05
	prompt.MaxActivationDistance = 16
	prompt.RequiresLineOfSight = false
	prompt.ActionText = "Recoger Huevo"

	prompt.Triggered:Connect(function(player: Player)
		onCollectPromptTriggered(prompt, player)
	end)
end

-- Conectar TODOS los nidos fijos y huevos silvestres existentes y futuros
local function setupNests()
	local arena = Workspace:WaitForChild("BossArena", 10)
	local zones = arena and arena:WaitForChild("Zones", 5)
	if not zones then return end

	-- 1. Conectar prompts ya existentes en el DataModel
	for _, desc in ipairs(zones:GetDescendants()) do
		if desc:IsA("ProximityPrompt") and desc.Name == "CollectEggPrompt" then
			hookCollectPrompt(desc)
		end
	end

	-- 2. Conectar prompts que se creen dinámicamente en tiempo de ejecución
	zones.DescendantAdded:Connect(function(desc)
		if desc:IsA("ProximityPrompt") and desc.Name == "CollectEggPrompt" then
			hookCollectPrompt(desc)
		end
	end)
end

-- Solicitud de soltar huevo: cae de forma segura y queda protegido 30s sin reroll
DropEgg.OnServerEvent:Connect(function(player: Player)
	local userId = player.UserId
	local eggData = carriedEggs[userId]
	if eggData then
		local char = player.Character
		local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
		local dropPos = (root and root.Position) or Vector3.new(0, 1.2, 250 + (eggData.BiomeIndex - 1) * 500)
		removeCarriedEgg(player, false)
		DroppedEggManager.SpawnDroppedEgg(eggData, dropPos, player, function(p, data)
			equipCarriedEgg(p, data)
		end)
		EggStateChanged:FireClient(player, {
			Carrying = false,
			Warning = "🥚 Soltaste el huevo. Está protegido para ti durante 30s en el suelo.",
		})
	else
		removeCarriedEgg(player, false)
	end
end)

-- Muerte del jugador: huevo cae protegido en vez de perderse
Players.PlayerAdded:Connect(function(player: Player)
	player.CharacterAdded:Connect(function(char)
		local hum = char:WaitForChild("Humanoid") :: Humanoid
		local root = char:WaitForChild("HumanoidRootPart") :: BasePart
		hum.Died:Connect(function()
			local userId = player.UserId
			local eggData = carriedEggs[userId]
			if eggData then
				local deathPos = root.Position
				removeCarriedEgg(player, false)
				DroppedEggManager.SpawnDroppedEgg(eggData, deathPos, player, function(p, data)
					equipCarriedEgg(p, data)
				end)
				EggStateChanged:FireClient(player, {
					Carrying = false,
					Warning = "⚠️ ¡Has caído! Tu huevo está a salvo y protegido en el bioma por 30s.",
				})
			else
				removeCarriedEgg(player, false)
			end
		end)
	end)
end)

-- Limpieza al desconectar
Players.PlayerRemoving:Connect(function(player: Player)
	local userId = player.UserId
	local eggData = carriedEggs[userId]
	if eggData then
		BossChaseManager.CancelChase(eggData.BiomeIndex)
		local char = player.Character
		local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
		local dropPos = (root and root.Position) or Vector3.new(0, 1.2, 250 + (eggData.BiomeIndex - 1) * 500)
		DroppedEggManager.SpawnDroppedEgg(eggData, dropPos, player, function(p, data)
			equipCarriedEgg(p, data)
		end)
		carriedEggs[userId] = nil
	end
	lastInteractTime[userId] = nil
end)

-- Bindables de gestión
local clearEggBindable = ServerScriptService:FindFirstChild("ClearPlayerEggBindable") :: BindableFunction?
if not clearEggBindable then
	clearEggBindable = Instance.new("BindableFunction")
	clearEggBindable.Name = "ClearPlayerEggBindable"
	clearEggBindable.Parent = ServerScriptService
end
clearEggBindable.OnInvoke = function(player: Player)
	removeCarriedEgg(player, false)
	return true
end

local takeEggBindable = ServerScriptService:FindFirstChild("TakePlayerCarriedEggBindable") :: BindableFunction?
if not takeEggBindable then
	takeEggBindable = Instance.new("BindableFunction")
	takeEggBindable.Name = "TakePlayerCarriedEggBindable"
	takeEggBindable.Parent = ServerScriptService
end
takeEggBindable.OnInvoke = function(player: Player)
	local userId = player.UserId
	local eggData = carriedEggs[userId]
	if not eggData then return nil end
	removeCarriedEgg(player, false)
	return eggData
end

local retrieveEggBindable = ServerScriptService:FindFirstChild("RetrieveEggBindable") :: BindableFunction?
if not retrieveEggBindable then
	retrieveEggBindable = Instance.new("BindableFunction")
	retrieveEggBindable.Name = "RetrieveEggBindable"
	retrieveEggBindable.Parent = ServerScriptService
end
retrieveEggBindable.OnInvoke = function(player: Player, eggData: CarriedEggData)
	equipCarriedEgg(player, eggData)
	return true
end

setupNests()
print("[EggService] Inicializado: Conexión universal de prompts activos y futuros, persecución inmediata y transporte visual.")
