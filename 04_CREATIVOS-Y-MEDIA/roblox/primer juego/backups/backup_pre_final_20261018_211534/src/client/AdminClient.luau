local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local Gui = script.Parent
local ToggleBtn = Gui:WaitForChild("AdminToggleBtn")
local Window = Gui:WaitForChild("AdminWindow")
local CloseBtn = Window:WaitForChild("Header"):WaitForChild("CloseBtn")
local Scroll = Window:WaitForChild("ScrollContent")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local AdminRemote = Remotes:WaitForChild("AdminCommand") :: RemoteEvent
local AdminVerify = Remotes:WaitForChild("AdminVerify") :: RemoteFunction

-- Authorization Check
local isAuth = false
local success, res = pcall(function()
	return AdminVerify:InvokeServer()
end)

if success and res == true then
	isAuth = true
end

if not isAuth then
	Gui:Destroy()
	return
end

-- Toggle behavior
local function toggleWindow()
	Window.Visible = not Window.Visible
end

ToggleBtn.MouseButton1Click:Connect(toggleWindow)
CloseBtn.MouseButton1Click:Connect(function()
	Window.Visible = false
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.F2 then
		toggleWindow()
	end
end)

-- Button Bindings
local function bind(btnName, action, payload)
	local b = Scroll:FindFirstChild(btnName)
	if b and b:IsA("TextButton") then
		b.MouseButton1Click:Connect(function()
			AdminRemote:FireServer(action, payload)
		end)
	end
end

bind("Speed16Btn", "SetWalkSpeed", 16)
bind("Speed50Btn", "SetWalkSpeed", 50)
bind("Speed100Btn", "SetWalkSpeed", 100)
bind("Jump80Btn", "SetJumpPower", 85)

bind("Money10kBtn", "AddTestMoney", 10000)
bind("Money100kBtn", "AddTestMoney", 100000)
bind("SpeedStat50Btn", "AddTestSpeed", 50)

bind("TpPlotsBtn", "Teleport", "Plots")
bind("TpSafeBtn", "Teleport", "SafeZone")
bind("TpEgg1Btn", "Teleport", "Egg1")
bind("TpEgg3Btn", "Teleport", "Egg3")
bind("TpEgg5Btn", "Teleport", "Egg5")

bind("GodModeBtn", "ToggleGodMode", nil)
bind("ResetStatsBtn", "ResetCharacterStats", nil)