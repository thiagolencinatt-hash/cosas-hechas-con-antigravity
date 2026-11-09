--!strict
-- ModuleScript: ServerScriptService.Modules.BaseIncubatorManager
-- Gestiona el ciclo de vida, validaciones y estado de las 10 incubadoras en las 5 bases.

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

local BeastDataModule = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("BeastDataModule") :: ModuleScript)
local CreatureInventoryManager = require(script.Parent:WaitForChild("CreatureInventoryManager") :: ModuleScript)

export type IncubatorSlotData = {
	Status: string,
	EggId: string,
	BiomeIndex: number,
	EggName: string,
	Weight: number,
	Rarity: BeastDataModule.Rarity,
	FinishTime: number,
}

local BaseIncubatorManager = {}
local testSpeedMode = false

local INCUBATION_TIMES: { [BeastDataModule.Rarity]: number } = {
	Comun = 45,
	PocoComun = 120,
	Rara = 300,
	Epica = 720,
	Legendaria = 1500,
	Mitica = 3000,
}

local incubatorDataStore = nil
pcall(function()
	incubatorDataStore = DataStoreService:GetDataStore("VaultPop_Incubators_v1")
end)

function BaseIncubatorManager.SetTestSpeedMode(enabled: boolean)
	testSpeedMode = enabled
	print("[BaseIncubatorManager] TestSpeedMode: " .. tostring(enabled))
end

function BaseIncubatorManager.GetIncubationDuration(rarity: BeastDataModule.Rarity): number
	if testSpeedMode then return 5 end
	return INCUBATION_TIMES[rarity] or 45
end

function BaseIncubatorManager.UpdateVisuals(model: Model)
	local status = (model:GetAttribute("Status") :: string?) or "Empty"
	local biomeIndex = (model:GetAttribute("BiomeIndex") :: number?) or 1
	local finishTime = (model:GetAttribute("FinishTime") :: number?) or 0

	local podBase = model:FindFirstChild("PodBase") :: BasePart?
	local podRing = model:FindFirstChild("PodRing") :: BasePart?
	local eggDisplay = model:FindFirstChild("EggDisplay") :: BasePart?
	local light = podBase and podBase:FindFirstChildWhichIsA("PointLight")
	local bbg = podBase and podBase:FindFirstChild("IncubatorGui") :: BillboardGui?
	local prompt = podBase and podBase:FindFirstChildOfClass("ProximityPrompt")

	local statusLbl = bbg and bbg:FindFirstChild("StatusLabel") :: TextLabel?
	local timerLbl = bbg and bbg:FindFirstChild("TimerLabel") :: TextLabel?

	local eggDef = BeastDataModule.GetBiomeEgg(biomeIndex)

	if status == "Empty" then
		if podRing then podRing.Color = Color3.fromRGB(60, 210, 255) end
		if light then light.Color = Color3.fromRGB(60, 210, 255) end
		if eggDisplay then eggDisplay.Transparency = 1 end
		if statusLbl then
			statusLbl.Text = "[ VACÍA / DISPONIBLE ]"
			statusLbl.TextColor3 = Color3.fromRGB(100, 255, 130)
		end
		if timerLbl then
			timerLbl.Text = "Presiona [E] para depositar"
			timerLbl.TextColor3 = Color3.fromRGB(220, 230, 245)
		end
		if prompt then
			prompt.ActionText = "Depositar Huevo"
			prompt.Enabled = true
		end

	elseif status == "Incubating" then
		local now = os.time()
		local rem = math.max(0, finishTime - now)

		if podRing then podRing.Color = Color3.fromRGB(255, 165, 40) end
		if light then light.Color = Color3.fromRGB(255, 165, 40) end
		if eggDisplay and eggDef then
			eggDisplay.Transparency = 0
			eggDisplay.Color = eggDef.EggColor
		end
		if statusLbl then
			statusLbl.Text = "🥚 INCUBANDO..."
			statusLbl.TextColor3 = Color3.fromRGB(255, 200, 70)
		end
		if timerLbl then
			local mins = math.floor(rem / 60)
			local secs = rem % 60
			timerLbl.Text = string.format("⏳ %02d:%02d", mins, secs)
			timerLbl.TextColor3 = Color3.fromRGB(255, 230, 100)
		end
		if prompt then
			prompt.ActionText = "Incubando..."
			prompt.Enabled = false
		end

	elseif status == "Ready" then
		if podRing then podRing.Color = Color3.fromRGB(60, 255, 120) end
		if light then light.Color = Color3.fromRGB(60, 255, 120) end
		if eggDisplay and eggDef then
			eggDisplay.Transparency = 0
			eggDisplay.Color = eggDef.EggColor
		end
		if statusLbl then
			statusLbl.Text = "✨ ¡LISTA PARA ABRIR! ✨"
			statusLbl.TextColor3 = Color3.fromRGB(100, 255, 120)
		end
		if timerLbl then
			timerLbl.Text = "Presiona [E] para abrir [POP!]"
			timerLbl.TextColor3 = Color3.fromRGB(255, 235, 80)
		end
		if prompt then
			prompt.ActionText = "Abrir Huevo [POP!]"
			prompt.Enabled = true
		end
	end
end

function BaseIncubatorManager.GetIncubatorModel(baseName: string, slotIndex: number): Model?
	local safeZone = Workspace:FindFirstChild("SafeZone")
	local plots = safeZone and safeZone:FindFirstChild("BasePlots")
	local baseFolder = plots and plots:FindFirstChild(baseName)
	return baseFolder and baseFolder:FindFirstChild("Incubator_" .. slotIndex) :: Model?
end

function BaseIncubatorManager.DepositEgg(player: Player, baseName: string, slotIndex: number, eggData: any): (boolean, string)
	local incubator = BaseIncubatorManager.GetIncubatorModel(baseName, slotIndex)
	if not incubator then
		return false, "Incubadora no encontrada."
	end

	local assignedBase = player:GetAttribute("AssignedBase")
	if assignedBase ~= baseName then
		return false, "¡Esta no es tu base! Debes usar las incubadoras de tu propia base."
	end

	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
	local podBase = incubator:FindFirstChild("PodBase") :: BasePart?
	if not root or not podBase or (root.Position - podBase.Position).Magnitude > 14 then
		return false, "Estás demasiado lejos de la incubadora."
	end

	if incubator:GetAttribute("Status") ~= "Empty" then
		return false, "Esta incubadora ya está ocupada."
	end

	local duration = BaseIncubatorManager.GetIncubationDuration(eggData.Rarity)
	local finishTime = os.time() + duration

	incubator:SetAttribute("Status", "Incubating")
	incubator:SetAttribute("EggId", eggData.EggId)
	incubator:SetAttribute("BiomeIndex", eggData.BiomeIndex)
	incubator:SetAttribute("EggName", eggData.EggName)
	incubator:SetAttribute("Weight", eggData.Weight)
	incubator:SetAttribute("Rarity", eggData.Rarity)
	incubator:SetAttribute("FinishTime", finishTime)

	BaseIncubatorManager.UpdateVisuals(incubator)
	BaseIncubatorManager.SaveBaseIncubators(player.UserId, baseName)

	print(string.format("[BaseIncubator] %s depositó %s en %s Slot %d (Tiempo: %ds)", 
		player.Name, eggData.EggName, baseName, slotIndex, duration))
	return true, "¡Huevo depositado con éxito!"
end

function BaseIncubatorManager.HatchEgg(player: Player, baseName: string, slotIndex: number): (boolean, string, any?)
	local incubator = BaseIncubatorManager.GetIncubatorModel(baseName, slotIndex)
	if not incubator then
		return false, "Incubadora no encontrada.", nil
	end

	local assignedBase = player:GetAttribute("AssignedBase")
	if assignedBase ~= baseName then
		return false, "Esta no es tu base.", nil
	end

	local status = incubator:GetAttribute("Status") :: string?
	local finishTime = (incubator:GetAttribute("FinishTime") :: number?) or 0
	local now = os.time()

	if status ~= "Ready" and now < finishTime then
		return false, "El huevo todavía se está incubando.", nil
	end

	incubator:SetAttribute("Status", "Hatching")

	local biomeIndex = (incubator:GetAttribute("BiomeIndex") :: number?) or 1
	local rarity = (incubator:GetAttribute("Rarity") :: BeastDataModule.Rarity) or "Comun"

	local creature = CreatureInventoryManager.CreateFromEgg(biomeIndex, rarity)
	CreatureInventoryManager.AddCreature(player.UserId, creature)

	incubator:SetAttribute("Status", "Empty")
	incubator:SetAttribute("EggId", "")
	incubator:SetAttribute("BiomeIndex", 0)
	incubator:SetAttribute("EggName", "")
	incubator:SetAttribute("Rarity", "")
	incubator:SetAttribute("FinishTime", 0)

	BaseIncubatorManager.UpdateVisuals(incubator)
	BaseIncubatorManager.SaveBaseIncubators(player.UserId, baseName)

	print(string.format("[BaseIncubator] %s eclosionó %s (%s) en %s Slot %d!", 
		player.Name, creature.Name, creature.Rarity, baseName, slotIndex))

	return true, "¡Huevo eclosionado con éxito!", creature
end

function BaseIncubatorManager.SaveBaseIncubators(userId: number, baseName: string)
	if not incubatorDataStore then return end
	local slots = {}
	for s = 1, 2 do
		local inc = BaseIncubatorManager.GetIncubatorModel(baseName, s)
		if inc then
			slots[s] = {
				Status = inc:GetAttribute("Status"),
				EggId = inc:GetAttribute("EggId"),
				BiomeIndex = inc:GetAttribute("BiomeIndex"),
				EggName = inc:GetAttribute("EggName"),
				Weight = inc:GetAttribute("Weight"),
				Rarity = inc:GetAttribute("Rarity"),
				FinishTime = inc:GetAttribute("FinishTime"),
			}
		end
	end
	pcall(function()
		incubatorDataStore:SetAsync(tostring(userId) .. "_incubators", slots)
	end)
end

function BaseIncubatorManager.LoadBaseIncubators(userId: number, baseName: string)
	if not incubatorDataStore then return end
	local success, saved = pcall(function()
		return incubatorDataStore:GetAsync(tostring(userId) .. "_incubators")
	end)

	if success and typeof(saved) == "table" then
		for s = 1, 2 do
			local data = saved[s]
			local inc = BaseIncubatorManager.GetIncubatorModel(baseName, s)
			if inc and data and data.Status and data.Status ~= "Empty" then
				inc:SetAttribute("Status", data.Status)
				inc:SetAttribute("EggId", data.EggId or "")
				inc:SetAttribute("BiomeIndex", data.BiomeIndex or 1)
				inc:SetAttribute("EggName", data.EggName or "")
				inc:SetAttribute("Weight", data.Weight or 10)
				inc:SetAttribute("Rarity", data.Rarity or "Comun")
				inc:SetAttribute("FinishTime", data.FinishTime or 0)
				BaseIncubatorManager.UpdateVisuals(inc)
			end
		end
	end
end

return BaseIncubatorManager
