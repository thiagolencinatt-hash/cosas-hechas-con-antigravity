--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local BiomesConfig = require(Modules:WaitForChild("BiomesConfig"))

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local TrialActionRemote = Remotes:WaitForChild("TrialAction") :: RemoteEvent
local TrialProgressRemote = Remotes:WaitForChild("TrialProgress") :: RemoteEvent
local NotifyRemote = Remotes:FindFirstChild("Notify") :: RemoteEvent?

local Map = workspace:WaitForChild("Map")
local CheckpointsFolder = Map:WaitForChild("TrialsCheckpoints")

local function Notify(Player: Player, Text: string, Color: Color3?)
	if NotifyRemote then
		NotifyRemote:FireClient(Player, Text, Color or Color3.fromRGB(255, 255, 255), 3)
	end
end

type ActiveTrial = {
	BiomeId: number,
	StartTime: number,
	CurrentCheckpoint: number,
	TotalCheckpoints: number,
	TargetTime: number,
	RewardCoins: number,
	LastCheckpointTime: number,
}

local ActiveTrials: { [Player]: ActiveTrial } = {}
local TrialCooldowns: { [Player]: number } = {}

local function StartTrial(Player: Player, BiomeId: number)
	local Biome = BiomesConfig.GetBiomeById(BiomeId)
	if not Biome or not Biome.Trial then return end

	local Now = os.clock()
	local LastAttempt = TrialCooldowns[Player] or 0
	if Now - LastAttempt < 5 then
		Notify(Player, "Espera unos segundos antes de reiniciar el desafío.", Color3.fromRGB(240, 180, 50))
		return
	end

	ActiveTrials[Player] = {
		BiomeId = BiomeId,
		StartTime = Now,
		CurrentCheckpoint = 0,
		TotalCheckpoints = Biome.Trial.Checkpoints,
		TargetTime = Biome.Trial.TargetTime,
		RewardCoins = Biome.Trial.RewardCoins,
		LastCheckpointTime = Now,
	}

	TrialProgressRemote:FireClient(Player, "Start", {
		TrialName = Biome.Trial.Name,
		TargetTime = Biome.Trial.TargetTime,
		TotalCheckpoints = Biome.Trial.Checkpoints,
		CurrentCheckpoint = 0,
		RewardCoins = Biome.Trial.RewardCoins,
	})

	Notify(Player, string.format("🚩 ¡Iniciaste: %s! Llega a la meta en menos de %ds", Biome.Trial.Name, Biome.Trial.TargetTime), Color3.fromRGB(100, 220, 255))
end

local function CancelTrial(Player: Player)
	if ActiveTrials[Player] then
		ActiveTrials[Player] = nil
		TrialProgressRemote:FireClient(Player, "Cancel", {})
		Notify(Player, "Desafío cancelado.", Color3.fromRGB(200, 100, 100))
	end
end

local function HandleCheckpointHit(Player: Player, cpIndex: number, biomeId: number)
	local Trial = ActiveTrials[Player]
	if not Trial or Trial.BiomeId ~= biomeId then return end

	-- Check sequence
	if cpIndex == Trial.CurrentCheckpoint + 1 then
		local Now = os.clock()
		local Elapsed = Now - Trial.StartTime

		-- Time limit exceeded?
		if Elapsed > Trial.TargetTime + 1 then
			ActiveTrials[Player] = nil
			TrialProgressRemote:FireClient(Player, "Fail", { Reason = "¡Tiempo agotado!" })
			Notify(Player, "⏰ ¡Tiempo agotado! Inténtalo de nuevo.", Color3.fromRGB(255, 90, 90))
			return
		end

		Trial.CurrentCheckpoint = cpIndex
		Trial.LastCheckpointTime = Now

		-- Reached finish line?
		if cpIndex >= Trial.TotalCheckpoints then
			ActiveTrials[Player] = nil
			TrialCooldowns[Player] = Now

			local Leaderstats = Player:FindFirstChild("leaderstats")
			local Money = Leaderstats and Leaderstats:FindFirstChild("Money") :: IntValue?
			if Money then
				Money.Value += Trial.RewardCoins
			end

			TrialProgressRemote:FireClient(Player, "Complete", {
				Time = Elapsed,
				Reward = Trial.RewardCoins,
			})

			Notify(Player, string.format("🏆 ¡DESAFÍO COMPLETADO en %.2fs! +$%d Monedas", Elapsed, Trial.RewardCoins), Color3.fromRGB(80, 255, 120), 4)
		else
			TrialProgressRemote:FireClient(Player, "Update", {
				CurrentCheckpoint = cpIndex,
				TotalCheckpoints = Trial.TotalCheckpoints,
			})
		end
	end
end

-- Connect checkpoint physical touched events
for _, model in ipairs(CheckpointsFolder:GetChildren()) do
	local cpIndex = model:GetAttribute("CheckpointIndex") :: number?
	local biomeId = (model:GetAttribute("BiomeId") :: number?) or 1
	local hitbox = model:FindFirstChild("Hitbox") :: BasePart?

	if hitbox and cpIndex then
		hitbox.Touched:Connect(function(hit)
			local char = hit:FindFirstAncestorOfClass("Model")
			local player = char and Players:GetPlayerFromCharacter(char)
			if player then
				if cpIndex == 1 and not ActiveTrials[player] then
					-- Stepping on start pad auto-starts trial 1
					StartTrial(player, biomeId)
				end
				HandleCheckpointHit(player, cpIndex, biomeId)
			end
		end)
	end
end

TrialActionRemote.OnServerEvent:Connect(function(Player: Player, Action: string, Payload: any)
	if Action == "Start" then
		local BiomeId = tonumber(Payload) or 1
		StartTrial(Player, BiomeId)
	elseif Action == "Cancel" then
		CancelTrial(Player)
	end
end)

Players.PlayerRemoving:Connect(function(Player)
	ActiveTrials[Player] = nil
	TrialCooldowns[Player] = nil
end)
