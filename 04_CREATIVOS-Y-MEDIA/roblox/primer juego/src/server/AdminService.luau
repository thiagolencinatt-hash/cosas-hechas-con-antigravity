--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local AdminRemote = Remotes:WaitForChild("AdminCommand") :: RemoteEvent
local AdminVerify = Remotes:WaitForChild("AdminVerify") :: RemoteFunction

local NotifyRemote = Remotes:FindFirstChild("Notify") :: RemoteEvent?

local Modules = ReplicatedStorage:WaitForChild("Modules")
local OpeningToolsConfig = require(Modules:WaitForChild("OpeningToolsConfig"))
local TrailConfigurations = require(Modules:WaitForChild("TrailConfigurations"))

-- Whitelisted Creator UserIds
local AUTHORIZED_USER_IDS: { [number]: boolean } = {
	[8966766255] = true, -- elinsanoxdd2006 (Owner / Creator)
}

local function IsAuthorized(Player: Player): boolean
	-- Studio testing is always authorized for development
	if RunService:IsStudio() then
		return true
	end
	if Player.UserId == game.CreatorId or (game.CreatorId <= 0 and Player.UserId > 0) then
		return true
	end
	if AUTHORIZED_USER_IDS[Player.UserId] == true then
		return true
	end
	local nameLower = string.lower(Player.Name)
	if nameLower == "elinsanoxdd2006" or nameLower == "thiago" then
		return true
	end
	if game.CreatorType == Enum.CreatorType.Group then
		local ok, rank = pcall(function()
			return Player:GetRankInGroup(game.CreatorId)
		end)
		if ok and rank >= 250 then
			return true
		end
	end
	return false
end

local function formatNumber(n: number): string
	local formatted = tostring(math.floor(n))
	while true do
		local result, count = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
		formatted = result
		if count == 0 then break end
	end
	return formatted
end

local function Notify(Player: Player, Text: string, Color: Color3?)
	if NotifyRemote then
		NotifyRemote:FireClient(Player, Text, Color or Color3.fromRGB(255, 255, 255), 2.8)
	end
end

AdminVerify.OnServerInvoke = function(Player: Player): boolean
	return IsAuthorized(Player)
end

AdminRemote.OnServerEvent:Connect(function(Player: Player, Action: string, Payload: any)
	if not IsAuthorized(Player) then
		warn(string.format("[SECURITY ALERT] Unauthorized admin command attempt by %s (UserId: %d)", Player.Name, Player.UserId))
		return
	end

	local Character = Player.Character
	local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
	local Root = Character and Character:FindFirstChild("HumanoidRootPart") :: BasePart?
	local Leaderstats = Player:FindFirstChild("leaderstats")
	local MoneyStat = Leaderstats and Leaderstats:FindFirstChild("Money") :: IntValue?
	local SpeedStat = Leaderstats and Leaderstats:FindFirstChild("Speed") :: IntValue?

	if Action == "SetWalkSpeed" then
		local Speed = tonumber(Payload)
		if Speed and Humanoid then
			local clamped = math.clamp(math.floor(Speed), 1, 2000)
			Humanoid.WalkSpeed = clamped
			Player:SetAttribute("AdminWalkSpeed", clamped)
			Notify(Player, string.format("⚡ WalkSpeed establecido a: %d", clamped), Color3.fromRGB(80, 220, 255))
		end

	elseif Action == "SetSpeedStat" then
		local Speed = tonumber(Payload)
		if Speed and SpeedStat then
			local clamped = math.clamp(math.floor(Speed), 0, 1000000000)
			SpeedStat.Value = clamped
			Notify(Player, string.format("👟 Stat permanente de Velocidad fijado a: %s", formatNumber(clamped)), Color3.fromRGB(80, 240, 255))
		end

	elseif Action == "SetMoney" then
		local Amount = tonumber(Payload)
		if Amount and MoneyStat then
			local clamped = math.clamp(math.floor(Amount), 0, 1000000000000)
			MoneyStat.Value = clamped
			Notify(Player, string.format("💰 Dinero fijado a: $%s", formatNumber(clamped)), Color3.fromRGB(255, 215, 0))
		end

	elseif Action == "AddTestMoney" or Action == "AddMoney" then
		local Amount = tonumber(Payload)
		if Amount and MoneyStat then
			local clamped = math.clamp(MoneyStat.Value + math.floor(Amount), 0, 1000000000000)
			MoneyStat.Value = clamped
			Notify(Player, string.format("💰 +$%s Añadidos (Total: $%s)", formatNumber(Amount), formatNumber(MoneyStat.Value)), Color3.fromRGB(255, 215, 0))
		end

	elseif Action == "AddTestSpeed" then
		local Amount = tonumber(Payload)
		if Amount and SpeedStat then
			SpeedStat.Value = math.clamp(SpeedStat.Value + math.floor(Amount), 0, 1000000)
			Notify(Player, string.format("👟 +%d Speed de prueba añadida", Amount), Color3.fromRGB(50, 200, 255))
		end

	elseif Action == "SetJumpPower" then
		local Jump = tonumber(Payload)
		if Jump and Humanoid then
			Humanoid.UseJumpPower = true
			Humanoid.JumpPower = math.clamp(Jump, 30, 500)
			Notify(Player, string.format("🦘 JumpPower temporal: %d", Jump), Color3.fromRGB(100, 255, 120))
		end

	elseif Action == "UnlockAllTools" then
		local Folder = Player:FindFirstChild("OpeningTools") :: Folder?
		if not Folder then
			Folder = Instance.new("Folder")
			Folder.Name = "OpeningTools"
			Folder.Parent = Player
		end
		for _, tool in ipairs(OpeningToolsConfig.Tools) do
			if not Folder:FindFirstChild(tool.Id) then
				local b = Instance.new("BoolValue")
				b.Name = tool.Id
				b.Value = true
				b.Parent = Folder
			end
		end
		-- Auto-equip strongest tool
		local best = OpeningToolsConfig.Tools[#OpeningToolsConfig.Tools]
		if best then
			local eq = Folder:FindFirstChild("EquippedTool") :: StringValue?
			if not eq then
				eq = Instance.new("StringValue")
				eq.Name = "EquippedTool"
				eq.Parent = Folder
			end
			eq.Value = best.Id
		end
		Notify(Player, "📦 ¡Todas las 10 armas de asalto desbloqueadas!", Color3.fromRGB(100, 255, 120))

	elseif Action == "UnlockAllTrails" then
		local TrailsFolder = Player:FindFirstChild("Trails") :: Folder?
		if not TrailsFolder then
			TrailsFolder = Instance.new("Folder")
			TrailsFolder.Name = "Trails"
			TrailsFolder.Parent = Player
		end
		for _, trail in ipairs(TrailConfigurations.Trails) do
			if not TrailsFolder:FindFirstChild(trail.ID) then
				local b = Instance.new("BoolValue")
				b.Name = trail.ID
				b.Value = true
				b.Parent = TrailsFolder
			end
		end
		local bestTrail = TrailConfigurations.Trails[#TrailConfigurations.Trails]
		if bestTrail then
			local eq = TrailsFolder:FindFirstChild("Equipped") :: StringValue?
			if not eq then
				eq = Instance.new("StringValue")
				eq.Name = "Equipped"
				eq.Parent = TrailsFolder
			end
			eq.Value = bestTrail.ID
		end
		Notify(Player, "⚡ ¡Todos los 10 rastros de velocidad desbloqueados!", Color3.fromRGB(100, 255, 120))

	elseif Action == "BreakNearbyVault" then
		if not Root then return end
		local map = workspace:FindFirstChild("Map")
		local eggs = map and map:FindFirstChild("Eggs")
		local closestEgg: Model? = nil
		local closestDist = 80

		if eggs then
			for _, egg in ipairs(eggs:GetChildren()) do
				if egg:IsA("Model") then
					local p = egg.PrimaryPart or egg:FindFirstChildWhichIsA("BasePart", true)
					if p then
						local dist = (p.Position - Root.Position).Magnitude
						if dist < closestDist then
							closestDist = dist
							closestEgg = egg
						end
					end
				end
			end
		end

		if closestEgg then
			closestEgg:SetAttribute("Health", 0)
			Notify(Player, "💥 ¡Caja fuerte forzada y reventada con éxito!", Color3.fromRGB(255, 120, 50))
		else
			Notify(Player, "No hay cajas fuertes a menos de 80 studs.", Color3.fromRGB(240, 180, 50))
		end

	elseif Action == "Teleport" then
		if not Root then return end
		local DestName = tostring(Payload)
		local TargetCF: CFrame? = nil

		local destinations: { [string]: CFrame } = {
			["Plots"] = CFrame.new(-93, 62, -740),
			["SafeZone"] = CFrame.new(10, 62, -670),
			["Sell"] = CFrame.new(0, 62, -670),
			["Argentina"] = CFrame.new(0, 62, -530),
			["Brasil"] = CFrame.new(0, 62, -290),
			["USA"] = CFrame.new(0, 62, -35),
			["Japon"] = CFrame.new(0, 62, 210),
			["Mexico"] = CFrame.new(0, 62, 465),
			["Espana"] = CFrame.new(0, 62, 730),
			["ReinoUnido"] = CFrame.new(0, 62, 990),
			["Francia"] = CFrame.new(0, 62, 1240),
			["Egipto"] = CFrame.new(0, 62, 1480),
			["PaisNordico"] = CFrame.new(0, 62, 1900),
			-- Legacy alias support
			["Egg1"] = CFrame.new(0, 62, -530),
			["Egg2"] = CFrame.new(0, 62, -290),
			["Egg3"] = CFrame.new(0, 62, -35),
			["Egg4"] = CFrame.new(0, 62, 210),
			["Egg5"] = CFrame.new(0, 62, 465),
		}

		TargetCF = destinations[DestName]
		if TargetCF then
			Root.CFrame = TargetCF
			Notify(Player, "📍 Teletransportado a: " .. DestName, Color3.fromRGB(180, 130, 255))
		end

	elseif Action == "ResetCharacterStats" then
		Player:SetAttribute("AdminWalkSpeed", nil)
		Player:SetAttribute("AdminGodMode", nil)
		if Humanoid then
			Humanoid.WalkSpeed = 24
			Humanoid.UseJumpPower = true
			Humanoid.JumpPower = 50
			Humanoid.MaxHealth = 100
			Humanoid.Health = 100
		end
		Notify(Player, "🔄 Estadísticas temporales reiniciadas a normal", Color3.fromRGB(200, 200, 200))

	elseif Action == "ToggleGodMode" then
		local God = Player:GetAttribute("AdminGodMode") == true
		local NewGod = not God
		Player:SetAttribute("AdminGodMode", NewGod)
		if Humanoid then
			Humanoid.MaxHealth = NewGod and math.huge or 100
			Humanoid.Health = Humanoid.MaxHealth
		end
		Notify(Player, NewGod and "🛡️ Modo Dios ACTIVO" or "🛡️ Modo Dios DESACTIVADO", NewGod and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(200, 100, 100))
	end
end)
