--!strict
-- Script: ServerScriptService.IncubatorService
-- Gestiona la interacción autoritativa, depósito de huevos, cuenta regresiva y eclosión POP!

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Modules = ServerScriptService:WaitForChild("Modules", 10)
local BaseIncubatorManager = require(Modules:WaitForChild("BaseIncubatorManager") :: ModuleScript)
local CreatureInventoryManager = require(Modules:WaitForChild("CreatureInventoryManager") :: ModuleScript)
local BeastDataModule = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("BeastDataModule") :: ModuleScript)

local Remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
local DepositEggInIncubator = Remotes:WaitForChild("DepositEggInIncubator") :: RemoteFunction
local HatchIncubatorEgg = Remotes:WaitForChild("HatchIncubatorEgg") :: RemoteFunction
local IncubatorPopEffect = Remotes:WaitForChild("IncubatorPopEffect") :: RemoteEvent
local EggStateChanged = Remotes:WaitForChild("EggStateChanged") :: RemoteEvent

local SafeZone = Workspace:WaitForChild("SafeZone", 10)
local BasePlots = SafeZone and SafeZone:WaitForChild("BasePlots", 10)
if not BasePlots then
	warn("[IncubatorService] No se encontró SafeZone.BasePlots!")
	return
end

-- ===================================================================
-- PROCESO AUTORITATIVO DE DEPÓSITO
-- ===================================================================
local function handleDepositRequest(player: Player, baseName: string, slotIndex: number): (boolean, string)
	local incubator = BaseIncubatorManager.GetIncubatorModel(baseName, slotIndex)
	if not incubator then
		return false, "Incubadora no encontrada."
	end

	-- 1. Validar propiedad de base
	local assignedBase = player:GetAttribute("AssignedBase")
	if assignedBase ~= baseName then
		return false, "¡Esta no es tu base! Solo puedes depositar en tus propias incubadoras."
	end

	-- 2. Validar que la incubadora esté vacía
	if incubator:GetAttribute("Status") ~= "Empty" then
		return false, "Esta incubadora ya está ocupada."
	end

	-- 3. Validar distancia física
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
	local podBase = incubator:FindFirstChild("PodBase") :: BasePart?
	if not root or not podBase or (root.Position - podBase.Position).Magnitude > 14 then
		return false, "Estás demasiado lejos de la incubadora."
	end

	-- 4. Validar que el jugador realmente lleve un huevo
	local isCarrying = player:GetAttribute("CarryingEgg") == true
	if not isCarrying then
		return false, "¡No estás transportando ningún huevo! Recoge uno en los biomas primero."
	end

	-- 5. Tomar el huevo autoritativamente de EggService
	local takeEggBindable = ServerScriptService:FindFirstChild("TakePlayerCarriedEggBindable") :: BindableFunction?
	if not takeEggBindable then
		return false, "Error interno de EggService."
	end

	local eggData = takeEggBindable:Invoke(player)
	if not eggData then
		return false, "No se pudo transferir el huevo transportado."
	end

	-- 6. Depositar el huevo en la incubadora
	local success, msg = BaseIncubatorManager.DepositEgg(player, baseName, slotIndex, eggData)
	if not success then
		warn("[IncubatorService] Falló el depósito de " .. player.Name .. ": " .. msg)
		return false, msg
	end

	return true, "¡Huevo depositado con éxito!"
end

-- ===================================================================
-- PROCESO AUTORITATIVO DE ECLOSIÓN (POP!)
-- ===================================================================
local function handleHatchRequest(player: Player, baseName: string, slotIndex: number): (boolean, string, any?)
	local incubator = BaseIncubatorManager.GetIncubatorModel(baseName, slotIndex)
	if not incubator then
		return false, "Incubadora no encontrada.", nil
	end

	local assignedBase = player:GetAttribute("AssignedBase")
	if assignedBase ~= baseName then
		return false, "Esta no es tu base.", nil
	end

	local biomeIndex = (incubator:GetAttribute("BiomeIndex") :: number?) or 1
	local eggDef = BeastDataModule.GetBiomeEgg(biomeIndex)

	local success, msg, creature = BaseIncubatorManager.HatchEgg(player, baseName, slotIndex)
	if not success or not creature then
		return false, msg, nil
	end

	-- Disparar efectos de eclosión POP! a los clientes
	local podBase = incubator:FindFirstChild("PodBase") :: BasePart?
	local popPos = podBase and podBase.Position or Vector3.zero

	IncubatorPopEffect:FireAllClients({
		BaseName = baseName,
		SlotIndex = slotIndex,
		Position = popPos,
		Creature = creature,
		EggColor = eggDef and eggDef.EggColor or Color3.fromRGB(240, 240, 240),
		AccentColor = eggDef and eggDef.AccentColor or Color3.fromRGB(255, 215, 80),
	})

	return true, "¡Huevo eclosionado con éxito!", creature
end

-- ===================================================================
-- CONECTAR PROXIMITY PROMPTS DE LAS 10 INCUBADORAS
-- ===================================================================
local function setupIncubatorPrompts()
	for b = 1, 5 do
		local baseName = "Base_" .. b
		local baseFolder = BasePlots:FindFirstChild(baseName)
		if baseFolder then
			for slot = 1, 2 do
				local incubator = baseFolder:FindFirstChild("Incubator_" .. slot) :: Model?
				local podBase = incubator and incubator:FindFirstChild("PodBase") :: BasePart?
				local prompt = podBase and podBase:FindFirstChildOfClass("ProximityPrompt")

				if prompt then
					prompt.Triggered:Connect(function(player: Player)
						local status = incubator:GetAttribute("Status") :: string?
						if status == "Empty" then
							local ok, msg = handleDepositRequest(player, baseName, slot)
							if not ok then
								EggStateChanged:FireClient(player, {
									Warning = msg,
								})
							end
						elseif status == "Ready" then
							local ok, msg, creature = handleHatchRequest(player, baseName, slot)
							if not ok then
								EggStateChanged:FireClient(player, {
									Warning = msg,
								})
							end
						end
					end)
				end
			end
		end
	end
end

-- ===================================================================
-- CONEXIÓN CON REMOTEFUNCTIONS DEL CLIENTE
-- ===================================================================
DepositEggInIncubator.OnServerInvoke = function(player: Player, baseName: string, slotIndex: number): any
	if typeof(baseName) ~= "string" or typeof(slotIndex) ~= "number" then
		return { success = false, message = "Datos inválidos." }
	end
	local ok, msg = handleDepositRequest(player, baseName, slotIndex)
	return { success = ok, message = msg }
end

HatchIncubatorEgg.OnServerInvoke = function(player: Player, baseName: string, slotIndex: number): any
	if typeof(baseName) ~= "string" or typeof(slotIndex) ~= "number" then
		return { success = false, message = "Datos inválidos." }
	end
	local ok, msg, creature = handleHatchRequest(player, baseName, slotIndex)
	return { success = ok, message = msg, creature = creature }
end

-- ===================================================================
-- BUCLE DEL SERVIDOR: CUENTA REGRESIVA Y TRANSICIONES DE ESTADO (1s)
-- ===================================================================
task.spawn(function()
	while true do
		task.wait(1.0)
		local now = os.time()
		for b = 1, 5 do
			local baseName = "Base_" .. b
			local baseFolder = BasePlots:FindFirstChild(baseName)
			if baseFolder then
				for slot = 1, 2 do
					local inc = baseFolder:FindFirstChild("Incubator_" .. slot) :: Model?
					if inc then
						local status = inc:GetAttribute("Status") :: string?
						local finishTime = (inc:GetAttribute("FinishTime") :: number?) or 0

						if status == "Incubating" then
							if now >= finishTime then
								inc:SetAttribute("Status", "Ready")
								BaseIncubatorManager.UpdateVisuals(inc)
							else
								BaseIncubatorManager.UpdateVisuals(inc)
							end
						end
					end
				end
			end
		end
	end
end)

-- Inicialización de jugadores y sincronización de datos
Players.PlayerAdded:Connect(function(player: Player)
	CreatureInventoryManager.LoadInventory(player.UserId)

	player:GetAttributeChangedSignal("AssignedBase"):Connect(function()
		local assignedBase = player:GetAttribute("AssignedBase")
		if typeof(assignedBase) == "string" and assignedBase ~= "" then
			BaseIncubatorManager.LoadBaseIncubators(player.UserId, assignedBase)
		end
	end)
end)

Players.PlayerRemoving:Connect(function(player: Player)
	local assignedBase = player:GetAttribute("AssignedBase") :: string?
	if assignedBase then
		BaseIncubatorManager.SaveBaseIncubators(player.UserId, assignedBase)
	end
	CreatureInventoryManager.CleanupPlayer(player.UserId)
end)

setupIncubatorPrompts()
print("[IncubatorService] Inicializado: 10 incubadoras conectadas autoritativamente con soporte de depósito, tiempo y eclosión.")
