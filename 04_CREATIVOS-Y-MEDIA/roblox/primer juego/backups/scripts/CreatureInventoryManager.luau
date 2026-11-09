--!strict
-- ModuleScript: ServerScriptService.Modules.CreatureInventoryManager
-- Gestiona el inventario persistente de criaturas obtenidas por eclosión

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BeastDataModule = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("BeastDataModule") :: ModuleScript)

export type CreatureRecord = {
	CreatureId: string,
	SpeciesId: string,
	Name: string,
	BiomeIndex: number,
	Rarity: BeastDataModule.Rarity,
	Level: number,
	BaseHp: number,
	BaseDmg: number,
	BaseIncome: number,
	VisualColor: Color3,
	ObtainedAt: number,
}

local CreatureInventoryManager = {}

local playerInventories: { [number]: { CreatureRecord } } = {}
local DATASTORE_KEY = "VaultPop_CreatureInventory_v1"
local creatureDataStore = nil

pcall(function()
	creatureDataStore = DataStoreService:GetDataStore(DATASTORE_KEY)
end)

function CreatureInventoryManager.GetInventory(userId: number): { CreatureRecord }
	if not playerInventories[userId] then
		playerInventories[userId] = {}
	end
	return playerInventories[userId]
end

function CreatureInventoryManager.AddCreature(userId: number, creature: CreatureRecord): boolean
	if not playerInventories[userId] then
		playerInventories[userId] = {}
	end

	for _, existing in ipairs(playerInventories[userId]) do
		if existing.CreatureId == creature.CreatureId then
			warn("[CreatureInventory] Intento de añadir criatura duplicada: " .. creature.CreatureId)
			return false
		end
	end

	table.insert(playerInventories[userId], creature)

	local player = Players:GetPlayerByUserId(userId)
	if player then
		local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
		local CreatureInventoryUpdated = Remotes and Remotes:FindFirstChild("CreatureInventoryUpdated") :: RemoteEvent?
		if CreatureInventoryUpdated then
			CreatureInventoryUpdated:FireClient(player, playerInventories[userId])
		end
	end

	CreatureInventoryManager.SaveInventory(userId)
	print(string.format("[CreatureInventory] %d obtuvo: %s (%s, Bioma %d, +%d/s)", 
		userId, creature.Name, creature.Rarity, creature.BiomeIndex, creature.BaseIncome))
	return true
end

function CreatureInventoryManager.CreateFromEgg(biomeIndex: number, rarity: BeastDataModule.Rarity): CreatureRecord
	local species = BeastDataModule.GetCreature(biomeIndex, rarity)
	local now = os.time()

	if species then
		return {
			CreatureId = HttpService:GenerateGUID(false),
			SpeciesId = species.Id,
			Name = species.Name,
			BiomeIndex = biomeIndex,
			Rarity = rarity,
			Level = 1,
			BaseHp = species.BaseHp,
			BaseDmg = species.BaseDmg,
			BaseIncome = species.BaseIncome,
			VisualColor = species.VisualColor,
			ObtainedAt = now,
		}
	else
		local eggDef = BeastDataModule.GetBiomeEgg(biomeIndex)
		return {
			CreatureId = HttpService:GenerateGUID(false),
			SpeciesId = string.format("b%d_%s", biomeIndex, rarity:lower()),
			Name = string.format("Espíritu de %s", eggDef and eggDef.BiomeName or "Bioma " .. biomeIndex),
			BiomeIndex = biomeIndex,
			Rarity = rarity,
			Level = 1,
			BaseHp = 100 + biomeIndex * 10,
			BaseDmg = 15 + biomeIndex * 2,
			BaseIncome = 1,
			VisualColor = eggDef and eggDef.EggColor or Color3.fromRGB(150, 150, 150),
			ObtainedAt = now,
		}
	end
end

function CreatureInventoryManager.LoadInventory(userId: number)
	if creatureDataStore then
		local success, savedData = pcall(function()
			return creatureDataStore:GetAsync(tostring(userId))
		end)

		if success and typeof(savedData) == "table" then
			local loaded: { CreatureRecord } = {}
			for _, item in ipairs(savedData) do
				if typeof(item) == "table" and item.CreatureId and item.Name then
					table.insert(loaded, {
						CreatureId = item.CreatureId,
						SpeciesId = item.SpeciesId or "unknown",
						Name = item.Name,
						BiomeIndex = item.BiomeIndex or 1,
						Rarity = item.Rarity or "Comun",
						Level = item.Level or 1,
						BaseHp = item.BaseHp or 100,
						BaseDmg = item.BaseDmg or 15,
						BaseIncome = item.BaseIncome or 1,
						VisualColor = if item.VisualColorR then Color3.fromRGB(item.VisualColorR, item.VisualColorG, item.VisualColorB) else Color3.fromRGB(180, 180, 180),
						ObtainedAt = item.ObtainedAt or os.time(),
					})
				end
			end
			playerInventories[userId] = loaded
			print(string.format("[CreatureInventory] Cargadas %d criaturas para %d desde DataStore.", #loaded, userId))
			return
		end
	end

	if not playerInventories[userId] then
		playerInventories[userId] = {}
	end
end

function CreatureInventoryManager.SaveInventory(userId: number)
	local inv = playerInventories[userId]
	if not inv or not creatureDataStore then return end

	local toSave = {}
	for _, c in ipairs(inv) do
		table.insert(toSave, {
			CreatureId = c.CreatureId,
			SpeciesId = c.SpeciesId,
			Name = c.Name,
			BiomeIndex = c.BiomeIndex,
			Rarity = c.Rarity,
			Level = c.Level,
			BaseHp = c.BaseHp,
			BaseDmg = c.BaseDmg,
			BaseIncome = c.BaseIncome,
			VisualColorR = math.round(c.VisualColor.R * 255),
			VisualColorG = math.round(c.VisualColor.G * 255),
			VisualColorB = math.round(c.VisualColor.B * 255),
			ObtainedAt = c.ObtainedAt,
		})
	end

	pcall(function()
		creatureDataStore:SetAsync(tostring(userId), toSave)
	end)
end

function CreatureInventoryManager.CleanupPlayer(userId: number)
	CreatureInventoryManager.SaveInventory(userId)
	playerInventories[userId] = nil
end

return CreatureInventoryManager
