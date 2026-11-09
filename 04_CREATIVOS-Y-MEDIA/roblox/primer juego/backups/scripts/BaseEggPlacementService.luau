--!strict
-- Script: ServerScriptService.BaseEggPlacementService
-- Permite a los jugadores colocar físicamente sus huevos transportados en cualquier punto válido dentro de su base

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local BeastDataModule = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("BeastDataModule") :: ModuleScript)
local DroppedEggManager = require(ServerScriptService:WaitForChild("Modules"):WaitForChild("DroppedEggManager") :: ModuleScript)

type CarriedEggData = DroppedEggManager.DroppedEggData

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local PlaceEggInBase = Remotes:WaitForChild("PlaceEggInBase") :: RemoteFunction
local EggStateChanged = Remotes:WaitForChild("EggStateChanged") :: RemoteEvent

local takeEggBindable = ServerScriptService:WaitForChild("TakePlayerCarriedEggBindable") :: BindableFunction
local clearEggBindable = ServerScriptService:WaitForChild("ClearPlayerEggBindable") :: BindableFunction

local basePlotsFolder = Workspace:WaitForChild("SafeZone"):WaitForChild("BasePlots") :: Folder

-- Registro de huevos colocados en parcelas: baseName -> { [eggId]: CarriedEggData }
local placedEggsInBase: { [string]: { [string]: CarriedEggData } } = {}

-- Obtiene la parcela asignada a un jugador
local function getPlayerBase(player: Player): (Model?, BasePart?)
	local assignedBaseName = player:GetAttribute("AssignedBase") :: string?
	if not assignedBaseName then
		local userId = player.UserId
		for _, child in ipairs(basePlotsFolder:GetChildren()) do
			if child:IsA("Model") and child:GetAttribute("OwnerUserId") == userId then
				assignedBaseName = child.Name
				break
			end
		end
	end
	if not assignedBaseName then return nil, nil end

	local baseModel = basePlotsFolder:FindFirstChild(assignedBaseName) :: Model?
	local floorPart = baseModel and baseModel:FindFirstChild("Floor") :: BasePart?
	return baseModel, floorPart
end

-- Valida si una posición está estrictamente dentro de la superficie del suelo de la base
local function isPositionInsideBaseFloor(pos: Vector3, floor: BasePart): boolean
	local fPos = floor.Position
	local fSize = floor.Size
	local halfX = (fSize.X / 2) - 2.5
	local halfZ = (fSize.Z / 2) - 2.5

	local insideX = math.abs(pos.X - fPos.X) <= halfX
	local insideZ = math.abs(pos.Z - fPos.Z) <= halfZ
	local validY = pos.Y >= (fPos.Y - 1.0) and pos.Y <= (fPos.Y + 15.0)

	return insideX and insideZ and validY
end

-- Crea el modelo 3D físico del huevo en la base con su ProximityPrompt para volver a recogerlo
local function spawnPlacedEggModel(baseModel: Model, floorPart: BasePart, pos: Vector3, eggData: CarriedEggData): Model
	local placedFolder = baseModel:FindFirstChild("PlacedEggs") :: Folder?
	if not placedFolder then
		placedFolder = Instance.new("Folder")
		placedFolder.Name = "PlacedEggs"
		placedFolder.Parent = baseModel
	end

	local s = eggData.SizeScale or 1.0
	local eggDef = BeastDataModule.GetBiomeEgg(eggData.BiomeIndex)
	local eggColor = (eggDef and eggDef.EggColor) or Color3.fromRGB(80, 180, 70)
	local accentColor = (eggDef and eggDef.AccentColor) or Color3.fromRGB(255, 215, 0)

	local floorTopY = floorPart.Position.Y + (floorPart.Size.Y / 2)
	local eggHalfHeight = (2.6 * s) / 2
	local finalY = floorTopY + eggHalfHeight

	local eggModel = Instance.new("Model")
	eggModel.Name = "PlacedEgg_" .. eggData.EggId
	eggModel:SetAttribute("EggId", eggData.EggId)
	eggModel:SetAttribute("BiomeIndex", eggData.BiomeIndex)
	eggModel:SetAttribute("Rarity", eggData.Rarity)
	eggModel:SetAttribute("Weight", eggData.Weight)
	eggModel:SetAttribute("EggName", eggData.EggName)
	eggModel:SetAttribute("SizeVariant", eggData.SizeVariant)

	-- Parte principal del huevo
	local eggPart = Instance.new("Part")
	eggPart.Name = "EggPart"
	eggPart.Shape = Enum.PartType.Ball
	eggPart.Size = Vector3.new(2.0 * s, 2.6 * s, 2.0 * s)
	eggPart.CFrame = CFrame.new(pos.X, finalY, pos.Z)
	eggPart.Color = eggColor
	eggPart.Material = Enum.Material.SmoothPlastic
	eggPart.Anchored = true
	eggPart.CanCollide = true
	eggPart.Parent = eggModel
	eggModel.PrimaryPart = eggPart

	-- Pedestal / Anillo decorativo en el suelo
	local baseRing = Instance.new("Part")
	baseRing.Name = "BaseRim"
	baseRing.Shape = Enum.PartType.Cylinder
	baseRing.Size = Vector3.new(0.3, 2.8 * s, 2.8 * s)
	baseRing.CFrame = CFrame.new(pos.X, floorTopY + 0.15, pos.Z) * CFrame.Angles(0, 0, math.rad(90))
	baseRing.Color = accentColor
	baseRing.Material = Enum.Material.Neon
	baseRing.Anchored = true
	baseRing.CanCollide = false
	baseRing.Parent = eggModel

	-- Luz puntual suave
	local light = Instance.new("PointLight")
	light.Color = accentColor
	light.Range = 9 * s
	light.Brightness = 1.2
	light.Parent = eggPart

	-- Billboard superior informativo
	local bbg = Instance.new("BillboardGui")
	bbg.Name = "PlacedEggGui"
	bbg.Size = UDim2.new(4.5, 0, 1.8, 0)
	bbg.StudsOffset = Vector3.new(0, 2.0 * s + 0.6, 0)
	bbg.AlwaysOnTop = true
	bbg.LightInfluence = 0
	bbg.Parent = eggPart

	local titleLbl = Instance.new("TextLabel")
	titleLbl.Size = UDim2.new(1, 0, 0.45, 0)
	titleLbl.BackgroundTransparency = 1
	titleLbl.Font = Enum.Font.FredokaOne
	titleLbl.Text = "🥚 " .. eggData.EggName
	titleLbl.TextColor3 = accentColor
	titleLbl.TextStrokeColor3 = Color3.fromRGB(20, 20, 25)
	titleLbl.TextStrokeTransparency = 0
	titleLbl.TextScaled = true
	titleLbl.Parent = bbg

	local subLbl = Instance.new("TextLabel")
	subLbl.Size = UDim2.new(1, 0, 0.35, 0)
	subLbl.Position = UDim2.new(0, 0, 0.50, 0)
	subLbl.BackgroundTransparency = 1
	subLbl.Font = Enum.Font.GothamBold
	subLbl.Text = string.format("[%s] • %d kg (En Parcela)", eggData.Rarity, eggData.Weight)
	subLbl.TextColor3 = Color3.fromRGB(240, 245, 255)
	subLbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	subLbl.TextStrokeTransparency = 0.5
	subLbl.TextScaled = true
	subLbl.Parent = bbg

	-- ProximityPrompt para volver a recoger el huevo colocado
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "PickupPlacedEggPrompt"
	prompt.ActionText = "Recoger Huevo"
	prompt.ObjectText = eggData.EggName
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.HoldDuration = 0.05
	prompt.MaxActivationDistance = 14
	prompt.RequiresLineOfSight = false
	prompt.Parent = eggPart

	prompt.Triggered:Connect(function(interactor: Player)
		local baseOwnerId = baseModel:GetAttribute("OwnerUserId") :: number?
		if baseOwnerId and interactor.UserId ~= baseOwnerId then
			EggStateChanged:FireClient(interactor, {
				Warning = "❌ Este huevo está en la parcela de otro jugador.",
			})
			return
		end

		if interactor:GetAttribute("CarryingEgg") == true then
			EggStateChanged:FireClient(interactor, {
				Warning = "⚠️ Ya estás transportando otro huevo. Deposita o coloca ese primero.",
			})
			return
		end

		-- Recoger el huevo colocado y volver a transportarlo
		local baseName = baseModel.Name
		if placedEggsInBase[baseName] then
			placedEggsInBase[baseName][eggData.EggId] = nil
		end
		eggModel:Destroy()

		-- Invocar el EggService para transportar este huevo recuperado
		local retrieveBindable = ServerScriptService:FindFirstChild("RetrieveEggBindable") :: BindableFunction?
		if retrieveBindable then
			retrieveBindable:Invoke(interactor, eggData)
		end
	end)

	eggModel.Parent = placedFolder
	return eggModel
end

-- RemoteFunction: El cliente solicita colocar su huevo en una posición seleccionada de su base
PlaceEggInBase.OnServerInvoke = function(player: Player, targetPosition: Vector3?): { success: boolean, message: string }
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not char or not root then
		return { success = false, message = "Personaje no disponible." }
	end

	-- Verificar si el jugador lleva un huevo
	if player:GetAttribute("CarryingEgg") ~= true then
		return { success = false, message = "No estás transportando ningún huevo para colocar." }
	end

	-- Obtener base y piso del jugador
	local baseModel, floorPart = getPlayerBase(player)
	if not baseModel or not floorPart then
		return { success = false, message = "No tienes una parcela asignada para colocar huevos." }
	end

	-- Si no se envió posición explícita, usar posición frontal del jugador
	local posToPlace = targetPosition or (root.Position + (root.CFrame.LookVector * 4.0))

	-- Validar distancia del jugador al punto de colocación (máx 18 studs)
	local dist = (root.Position - posToPlace).Magnitude
	if dist > 18 then
		return { success = false, message = "El punto seleccionado está demasiado lejos de tu personaje." }
	end

	-- Validar que la posición esté estrictamente dentro de la base propia
	if not isPositionInsideBaseFloor(posToPlace, floorPart) then
		return { success = false, message = "El punto debe estar dentro de tu parcela propia." }
	end

	-- Traspaso atómico del huevo transportado
	local eggData = takeEggBindable:Invoke(player) :: CarriedEggData?
	if not eggData then
		return { success = false, message = "Error al transferir el huevo." }
	end

	local baseName = baseModel.Name
	if not placedEggsInBase[baseName] then
		placedEggsInBase[baseName] = {}
	end
	placedEggsInBase[baseName][eggData.EggId] = eggData

	-- Crear el modelo físico en el suelo
	spawnPlacedEggModel(baseModel, floorPart, posToPlace, eggData)

	print(string.format("[BaseEggPlacementService] %s colocó %s en %s en (%.1f, %.1f)", 
		player.Name, eggData.EggName, baseName, posToPlace.X, posToPlace.Z))

	return { success = true, message = string.format("¡Huevo colocado con éxito en tu base!") }
end

print("[BaseEggPlacementService] Inicializado: Soporte autoritativo para colocar huevos libremente en parcelas de base.")
