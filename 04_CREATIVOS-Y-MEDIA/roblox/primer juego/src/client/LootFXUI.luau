-- Texto flotante "+$" al entregar el botin, lluvia de monedas y sonido.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("LootFX")

local function format(n)
	local s = tostring(math.floor(n))
	while true do
		local r, c = string.gsub(s, "^(-?%d+)(%d%d%d)", "%1,%2")
		s = r
		if c == 0 then break end
	end
	return s
end

remote.OnClientEvent:Connect(function(amount)
	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local anchor = Instance.new("Part")
	anchor.Anchored = true
	anchor.CanCollide = false
	anchor.CanQuery = false
	anchor.CanTouch = false
	anchor.Transparency = 1
	anchor.Size = Vector3.one
	local start = hrp.Position + Vector3.new(0, 4, 0)
	anchor.Position = start
	anchor.Parent = workspace
	Debris:AddItem(anchor, 2.5)

	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.fromOffset(300, 80)
	gui.AlwaysOnTop = false
	gui.Parent = anchor
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = "+$" .. format(amount)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBlack
	label.TextColor3 = Color3.fromRGB(255, 220, 70)
	label.Parent = gui
	local stroke = Instance.new("UIStroke"); stroke.Thickness = 3.5; stroke.Color = Color3.fromRGB(70, 40, 0); stroke.Parent = label
	local grad = Instance.new("UIGradient")
	grad.Color = ColorSequence.new(Color3.fromRGB(255, 245, 160), Color3.fromRGB(255, 170, 30)); grad.Rotation = 90; grad.Parent = label
	local scale = Instance.new("UIScale"); scale.Scale = 0.2; scale.Parent = label

	TweenService:Create(scale, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1.15 }):Play()
	TweenService:Create(anchor, TweenInfo.new(1.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = start + Vector3.new(0, 7, 0) }):Play()
	local fade = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, 1.1)
	TweenService:Create(label, fade, { TextTransparency = 1 }):Play()
	TweenService:Create(stroke, fade, { Transparency = 1 }):Play()

	-- lluvia de monedas
	local emitter = Instance.new("ParticleEmitter")
	emitter.Color = ColorSequence.new(Color3.fromRGB(255, 225, 90), Color3.fromRGB(255, 160, 20))
	emitter.LightEmission = 1
	emitter.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.9), NumberSequenceKeypoint.new(1, 0) })
	emitter.Speed = NumberRange.new(14, 28)
	emitter.SpreadAngle = Vector2.new(60, 60)
	emitter.EmissionDirection = Enum.NormalId.Top
	emitter.Acceleration = Vector3.new(0, -45, 0)
	emitter.Lifetime = NumberRange.new(0.8, 1.4)
	emitter.Rate = 0
	emitter.Parent = anchor
	emitter:Emit(math.clamp(20 + math.floor(math.log10(math.max(amount, 1)) * 8), 20, 70))

	-- Sonido de entrega eliminado a pedido del usuario
end)
