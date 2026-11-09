--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local AdminRemote = Remotes:WaitForChild("AdminCommand") :: RemoteEvent
local AdminVerify = Remotes:WaitForChild("AdminVerify") :: RemoteFunction

local NotifyRemote = Remotes:FindFirstChild("Notify") :: RemoteEvent?

-- Whitelisted Creator UserIds
local AUTHORIZED_USER_IDS: { [number]: boolean } = {
	[8966766255] = true, -- elinsanoxdd2006 (Owner / Creator)
}

local function IsAuthorized(Player: Player): boolean
	if AUTHORIZED_USER_IDS[Player.UserId] == true then
		return true
	end
	if RunService:IsStudio() and (Player.UserId == game.CreatorId or Player.UserId <= 0) then
		return true
	end
	return false
end

local function Notify(Player: Player, Text: string, Color: Color3?)
	if NotifyRemote then
		NotifyRemote:FireClient(Player, Text, Color or Color3.fromRGB(255, 255, 255), 2.5)
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
	local StrengthStat = Leaderstats and Leaderstats:FindFirstChild("Strength") :: IntValue?

	if Action == "SetWalkSpeed" then
		local Speed = tonumber(Payload)
		if Speed and Humanoid then
			Humanoid.WalkSpeed = math.clamp(Speed, 16, 250)
			Notify(Player, string.format("⚡ WalkSpeed temporal: %d", Speed), Color3.fromRGB(80, 220, 255))
		end

	elseif Action == "SetJumpPower" then
		local Jump = tonumber(Payload)
		if Jump and Humanoid then
			Humanoid.UseJumpPower = true
			Humanoid.JumpPower = math.clamp(Jump, 50, 200)
			Notify(Player, string.format("🦘 JumpPower temporal: %d", Jump), Color3.fromRGB(100, 255, 120))
		end

	elseif Action == "AddTestMoney" then
		local Amount = tonumber(Payload)
		if Amount and MoneyStat then
			MoneyStat.Value = math.clamp(MoneyStat.Value + Amount, 0, 1000000000)
			Notify(Player, string.format("💰 +$%d Dinero de prueba añadido", Amount), Color3.fromRGB(255, 215, 0))
		end

	elseif Action == "AddTestStrength" then
		local Amount = tonumber(Payload)
		if Amount and StrengthStat then
			StrengthStat.Value = math.clamp(StrengthStat.Value + Amount, 0, 1000000)
			Notify(Player, string.format("💪 +%d Fuerza de prueba añadida", Amount), Color3.fromRGB(255, 160, 40))
		end

	elseif Action == "AddTestSpeed" then
		local Amount = tonumber(Payload)
		if Amount and SpeedStat then
			SpeedStat.Value = math.clamp(SpeedStat.Value + Amount, 0, 1000000)
			Notify(Player, string.format("👟 +%d Speed de prueba añadida", Amount), Color3.fromRGB(50, 200, 255))
		end

	elseif Action == "Teleport" then
		if not Root then return end
		local DestName = tostring(Payload)
		local TargetCF: CFrame? = nil

		if DestName == "SafeZone" then
			TargetCF = CFrame.new(10, 62, -700)
		elseif DestName == "Egg1" then
			TargetCF = CFrame.new(0, 62, -600)
		elseif DestName == "Egg2" then
			TargetCF = CFrame.new(0, 62, -450)
		elseif DestName == "Egg3" then
			TargetCF = CFrame.new(0, 62, -300)
		elseif DestName == "Egg4" then
			TargetCF = CFrame.new(0, 62, -150)
		elseif DestName == "Egg5" then
			TargetCF = CFrame.new(0, 62, 50)
		elseif DestName == "Sell" then
			TargetCF = CFrame.new(0, 62, -670)
		elseif DestName == "Plots" then
			TargetCF = CFrame.new(-93, 62, -740)
		end

		if TargetCF then
			Root.CFrame = TargetCF
			Notify(Player, "📍 Teletransportado a: " .. DestName, Color3.fromRGB(180, 130, 255))
		end

	elseif Action == "ResetCharacterStats" then
		if Humanoid then
			Humanoid.WalkSpeed = 16
			Humanoid.JumpPower = 50
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
