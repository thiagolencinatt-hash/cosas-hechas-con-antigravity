--!strict
-- Alerta de policias: signo "!" con rebote, silbato y destello azul/rojo cuando detectan un robo.
-- En la zona segura / verde (Z <= -645) las alertas se silencian y desactivan por completo.
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer
local enemyPos = workspace:WaitForChild("Map"):WaitForChild("EnemyPos")
local WHISTLE = "rbxassetid://9117261480"

local screen = Instance.new("ScreenGui")
screen.Name = "PoliceFlashGui"
screen.ResetOnSpawn = false
screen.IgnoreGuiInset = true
screen.DisplayOrder = 40
screen.Parent = player:WaitForChild("PlayerGui")

local function isInSafeGreenZone(): boolean
	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
	if hrp and hrp.Position.Z <= -645 then
		return true
	end
	return false
end

local function screenFlash()
	if isInSafeGreenZone() then return end
	for _, color in ipairs({ Color3.fromRGB(230, 30, 30), Color3.fromRGB(30, 90, 240), Color3.fromRGB(230, 30, 30) }) do
		if isInSafeGreenZone() then break end
		local f = Instance.new("Frame")
		f.Size = UDim2.fromScale(1, 1)
		f.BackgroundColor3 = color
		f.BackgroundTransparency = 0.78
		f.BorderSizePixel = 0
		f.Parent = screen
		TweenService:Create(f, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 1 }):Play()
		Debris:AddItem(f, 0.3)
		task.wait(0.18)
	end
end

local function alertOver(rig: Model)
	if isInSafeGreenZone() then return end
	local head = rig:FindFirstChild("Head") or rig:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not head then return end

	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.fromOffset(80, 80)
	gui.StudsOffset = Vector3.new(0, 4.5, 0)
	gui.AlwaysOnTop = false
	gui.MaxDistance = 90
	gui.DistanceLowerLimit = 8
	gui.Parent = head
	
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = "!"
	label.TextScaled = true
	label.Font = Enum.Font.GothamBlack
	label.TextColor3 = Color3.fromRGB(255, 70, 60)
	label.Parent = gui
	
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 3.5
	stroke.Color = Color3.new(1, 1, 1)
	stroke.Parent = label
	
	local scale = Instance.new("UIScale")
	scale.Scale = 0.1
	scale.Parent = label
	
	TweenService:Create(scale, TweenInfo.new(0.45, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), { Scale = 1.1 }):Play()
	TweenService:Create(gui, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { StudsOffset = Vector3.new(0, 5.8, 0) }):Play()
	
	local fade = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, 1.2)
	TweenService:Create(label, fade, { TextTransparency = 1 }):Play()
	TweenService:Create(stroke, fade, { Transparency = 1 }):Play()
	Debris:AddItem(gui, 1.8)

	local cam = workspace.CurrentCamera
	local near = cam and (cam.CFrame.Position - head.Position).Magnitude < 120
	if near and not isInSafeGreenZone() then
		local s = Instance.new("Sound")
		s.SoundId = WHISTLE
		s.Volume = 0.7
		s.RollOffMaxDistance = 120
		s.Parent = head
		s:Play()
		Debris:AddItem(s, 2)
	end
end

local function watch(rig: Model)
	if rig:GetAttribute("_AlertWatched") then return end
	rig:SetAttribute("_AlertWatched", true)
	local last = rig:GetAttribute("TargetUserId")
	rig:GetAttributeChangedSignal("TargetUserId"):Connect(function()
		local now = rig:GetAttribute("TargetUserId")
		if now ~= nil and last == nil then
			if not isInSafeGreenZone() then
				alertOver(rig)
				if now == player.UserId then
					task.spawn(screenFlash)
				end
			end
		end
		last = now
	end)
end

for _, d in ipairs(enemyPos:GetDescendants()) do
	if d:IsA("Model") and d.Name == "Rig" then watch(d) end
end
enemyPos.DescendantAdded:Connect(function(d)
	if d:IsA("Model") and d.Name == "Rig" then task.defer(watch, d) end
end)
