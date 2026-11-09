--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local OpeningToolsConfig = require(Modules:WaitForChild("OpeningToolsConfig"))

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local ToolActionRemote = Remotes:WaitForChild("OpeningToolsAction") :: RemoteEvent
local NotifyRemote = Remotes:FindFirstChild("Notify") :: RemoteEvent?

-- Create DamageEggShell remote if not present
local DamageRemote = Remotes:FindFirstChild("DamageEggShell") :: RemoteEvent?
if not DamageRemote then
	DamageRemote = Instance.new("RemoteEvent")
	DamageRemote.Name = "DamageEggShell"
	DamageRemote.Parent = Remotes
end

local function Notify(Player: Player, Text: string, Color: Color3?)
	if NotifyRemote then
		NotifyRemote:FireClient(Player, Text, Color or Color3.fromRGB(255, 255, 255), 2.5)
	end
end

local function GetOpeningToolsFolder(Player: Player): Folder
	local Folder = Player:FindFirstChild("OpeningTools") :: Folder?
	if not Folder then
		Folder = Instance.new("Folder")
		Folder.Name = "OpeningTools"
		Folder.Parent = Player
	end
	return Folder
end

local function GetEquippedToolVal(Player: Player): StringValue
	local Folder = GetOpeningToolsFolder(Player)
	local Eq = Folder:FindFirstChild("EquippedTool") :: StringValue?
	if not Eq then
		Eq = Instance.new("StringValue")
		Eq.Name = "EquippedTool"
		Eq.Value = "MazoMadera"
		Eq.Parent = Folder
	end
	return Eq
end

local function OwnsTool(Player: Player, ToolId: string): boolean
	if ToolId == "MazoMadera" or ToolId == "BasicResonator" then return true end
	local Folder = GetOpeningToolsFolder(Player)
	return Folder:FindFirstChild(ToolId) ~= nil
end

local function CreatePhysicalWeapon(ToolInfo: any): Tool
	local tool = Instance.new("Tool")
	tool.Name = ToolInfo.Name
	tool.ToolTip = ToolInfo.Description .. string.format(" (Poder de Ruptura: %d)", ToolInfo.BreakPower)
	tool.CanBeDropped = false
	tool.RequiresHandle = true
	tool:SetAttribute("BreakPower", ToolInfo.BreakPower)
	tool:SetAttribute("IsWeapon", true)
	tool:SetAttribute("ToolId", ToolInfo.Id)

	-- Handle
	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(0.5, 2.2, 0.5)
	handle.Material = Enum.Material.Wood
	handle.Color = Color3.fromRGB(80, 50, 30)
	handle.CanCollide = false
	handle.Parent = tool

	-- Head / Blade
	local head = Instance.new("Part")
	head.Name = "WeaponHead"
	head.Size = Vector3.new(1.8, 1.2, 1.4)
	head.CFrame = handle.CFrame * CFrame.new(0, 1.3, 0)
	head.Material = ToolInfo.Material or Enum.Material.Metal
	head.Color = ToolInfo.ModelColor or ToolInfo.Color
	head.CanCollide = false
	head.Parent = tool

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = handle
	weld.Part1 = head
	weld.Parent = handle

	-- PointLight for energy weapons
	local light = Instance.new("PointLight")
	light.Color = ToolInfo.Color
	light.Range = 10
	light.Brightness = 2
	light.Parent = head

	return tool
end

local function GivePhysicalToolToPlayer(Player: Player, ToolId: string)
	local ToolInfo = OpeningToolsConfig.GetToolById(ToolId)
	if not ToolInfo then
		-- Fallback to default
		ToolId = "MazoMadera"
		ToolInfo = OpeningToolsConfig.GetToolById(ToolId)
		if not ToolInfo then return end
	end

	local function clearOld(container: Instance?)
		if not container then return end
		for _, item in ipairs(container:GetChildren()) do
			if item:IsA("Tool") and (item:GetAttribute("IsOpeningTool") == true or item:GetAttribute("IsWeapon") == true) then
				item:Destroy()
			end
		end
	end
	clearOld(Player:FindFirstChild("Backpack"))
	clearOld(Player.Character)

	local newTool = CreatePhysicalWeapon(ToolInfo)
	newTool.Parent = Player:WaitForChild("Backpack")
end

local function BuyTool(Player: Player, ToolId: string)
	local ToolInfo = OpeningToolsConfig.GetToolById(ToolId)
	if not ToolInfo then return end
	if OwnsTool(Player, ToolId) then
		Notify(Player, "¡Ya posees esta arma!", Color3.fromRGB(240, 200, 60))
		return
	end

	local Leaderstats = Player:FindFirstChild("leaderstats")
	local Money = Leaderstats and Leaderstats:FindFirstChild("Money") :: IntValue?
	if not Money then return end

	if Money.Value < ToolInfo.Price then
		Notify(Player, string.format("¡Monedas insuficientes! Cuesta $%d", ToolInfo.Price), Color3.fromRGB(255, 80, 80))
		return
	end

	Money.Value -= ToolInfo.Price

	local Folder = GetOpeningToolsFolder(Player)
	local Val = Instance.new("BoolValue")
	Val.Name = ToolId
	Val.Value = true
	Val.Parent = Folder

	local Eq = GetEquippedToolVal(Player)
	Eq.Value = ToolId
	GivePhysicalToolToPlayer(Player, ToolId)

	Notify(Player, string.format("¡Compraste y equipaste: %s! (Daño: %d)", ToolInfo.Name, ToolInfo.BreakPower), Color3.fromRGB(100, 255, 120))
end

local function EquipTool(Player: Player, ToolId: string)
	if not OwnsTool(Player, ToolId) then
		Notify(Player, "¡No posees esta arma!", Color3.fromRGB(255, 80, 80))
		return
	end

	local Eq = GetEquippedToolVal(Player)
	Eq.Value = ToolId
	GivePhysicalToolToPlayer(Player, ToolId)

	local ToolInfo = OpeningToolsConfig.GetToolById(ToolId)
	Notify(Player, string.format("Arma equipada: %s (Daño: %d)", ToolInfo and ToolInfo.Name or ToolId, ToolInfo and ToolInfo.BreakPower or 1), Color3.fromRGB(80, 220, 255))
end

ToolActionRemote.OnServerEvent:Connect(function(Player: Player, Action: string, ToolId: string)
	if typeof(Action) ~= "string" or typeof(ToolId) ~= "string" then return end

	if Action == "Buy" then
		BuyTool(Player, ToolId)
	elseif Action == "Equip" then
		EquipTool(Player, ToolId)
	end
end)

local function SetupPlayer(Player: Player)
	local Eq = GetEquippedToolVal(Player)
	local Folder = GetOpeningToolsFolder(Player)
	if not Folder:FindFirstChild("MazoMadera") then
		local b = Instance.new("BoolValue")
		b.Name = "MazoMadera"
		b.Value = true
		b.Parent = Folder
	end

	Eq.Changed:Connect(function(newToolId: string)
		GivePhysicalToolToPlayer(Player, newToolId)
	end)

	Player.CharacterAdded:Connect(function()
		task.wait(0.5)
		GivePhysicalToolToPlayer(Player, Eq.Value)
	end)

	if Player.Character then
		task.defer(function()
			GivePhysicalToolToPlayer(Player, Eq.Value)
		end)
	end
end

Players.PlayerAdded:Connect(SetupPlayer)
for _, p in ipairs(Players:GetPlayers()) do
	SetupPlayer(p)
end
