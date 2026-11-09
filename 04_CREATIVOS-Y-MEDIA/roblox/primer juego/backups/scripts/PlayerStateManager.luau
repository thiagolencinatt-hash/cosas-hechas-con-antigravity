--!strict
-- ModuleScript: ServerScriptService.Modules.PlayerStateManager
-- Gestiona el estado centralizado y autoritativo de Monedas, Fuerza y Velocidad

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RNGService = require(script.Parent:WaitForChild("RNGService") :: ModuleScript)

export type RollResult = RNGService.RollResult

local PlayerStateManager = {}

local heldRelics: { [number]: RollResult } = {}
local playerCoins: { [number]: number } = {}
local playerSpeed: { [number]: number } = {}
local playerStrength: { [number]: number } = {}
local playerUpgrades: { [number]: { [string]: number } } = {}
local playerRebirths: { [number]: number } = {}
local playerTrophies: { [number]: number } = {}

-- Reliquias
function PlayerStateManager.SetHeldRelic(userId: number, relic: RollResult)
	heldRelics[userId] = relic
end

function PlayerStateManager.GetHeldRelic(userId: number): RollResult?
	return heldRelics[userId]
end

function PlayerStateManager.ConsumeHeldRelic(userId: number): RollResult?
	local relic = heldRelics[userId]
	heldRelics[userId] = nil
	return relic
end

-- Monedas
function PlayerStateManager.GetCoins(userId: number): number
	return playerCoins[userId] or 0
end

function PlayerStateManager.AddCoins(userId: number, amount: number): number
	local current = playerCoins[userId] or 0
	local updated = math.max(0, current + amount)
	playerCoins[userId] = updated
	return updated
end

-- Velocidad (Speed)
function PlayerStateManager.GetSpeed(userId: number): number
	return playerSpeed[userId] or 16
end

function PlayerStateManager.SetSpeed(userId: number, speed: number): number
	playerSpeed[userId] = speed
	return speed
end

function PlayerStateManager.AddSpeed(userId: number, amount: number): number
	local current = playerSpeed[userId] or 16
	local updated = math.min(current + amount, 150)
	playerSpeed[userId] = updated
	return updated
end

-- Fuerza (Strength)
function PlayerStateManager.GetStrength(userId: number): number
	return playerStrength[userId] or 10
end

function PlayerStateManager.SetStrength(userId: number, strength: number): number
	playerStrength[userId] = strength
	return strength
end

function PlayerStateManager.AddStrength(userId: number, amount: number): number
	local current = playerStrength[userId] or 10
	local updated = current + amount
	playerStrength[userId] = updated
	return updated
end

-- Mejoras (Upgrades)
function PlayerStateManager.GetUpgrade(userId: number, upgradeKey: string): number
	local ups = playerUpgrades[userId]
	return (ups and ups[upgradeKey]) or 1
end

function PlayerStateManager.SetUpgrade(userId: number, upgradeKey: string, level: number): number
	if not playerUpgrades[userId] then
		playerUpgrades[userId] = {}
	end
	playerUpgrades[userId][upgradeKey] = level
	return level
end

-- Aplicar velocidad fisica autoritativa al Humanoid
function PlayerStateManager.ApplyWalkSpeed(player: Player)
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not hum then return end
	local baseSpeed = PlayerStateManager.GetSpeed(player.UserId)
	player:SetAttribute("BaseSpeed", baseSpeed)
	local eggPenalty = player:GetAttribute("EggSpeedPenalty") or 0
	local finalSpeed = math.max(8, baseSpeed * (1 - eggPenalty))
	hum.WalkSpeed = finalSpeed
end

-- Renacimientos (Rebirths) & Trofeos (Wins)
function PlayerStateManager.GetRebirths(userId: number): number
	return playerRebirths[userId] or 0
end

function PlayerStateManager.AddRebirths(userId: number, amount: number): number
	local current = playerRebirths[userId] or 0
	local updated = math.max(0, current + amount)
	playerRebirths[userId] = updated
	return updated
end

function PlayerStateManager.GetTrophies(userId: number): number
	return playerTrophies[userId] or 0
end

function PlayerStateManager.AddTrophies(userId: number, amount: number): number
	local current = playerTrophies[userId] or 0
	local updated = math.max(0, current + amount)
	playerTrophies[userId] = updated
	return updated
end

-- Limpieza de sesion
function PlayerStateManager.CleanupPlayer(userId: number)
	heldRelics[userId] = nil
	playerCoins[userId] = nil
	playerSpeed[userId] = nil
	playerStrength[userId] = nil
	playerUpgrades[userId] = nil
	playerRebirths[userId] = nil
	playerTrophies[userId] = nil
end

return PlayerStateManager
