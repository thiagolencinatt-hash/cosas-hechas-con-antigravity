--!strict
-- Cronometros de apertura en la base (varias cajas a la vez).
-- Cada caja: cartel con tiempo y barra, vibracion creciente, luz que late y sonido de mecanismo.
-- HUD: la caja mas proxima a abrirse y cuantas hay en espera.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("OpenTimer")
local C = Color3.fromRGB
local TICK_ID = "rbxassetid://9125672726"

local screen = Instance.new("ScreenGui")
screen.Name = "OpenTimerGui"; screen.ResetOnSpawn = false; screen.IgnoreGuiInset = true; screen.DisplayOrder = 45
screen.Parent = player:WaitForChild("PlayerGui")

-- ===== panel del HUD =====
local hud = Instance.new("Frame")
hud.AnchorPoint = Vector2.new(0.5, 0); hud.Position = UDim2.fromScale(0.5, 0.15); hud.Size = UDim2.fromOffset(360, 92)
hud.BackgroundColor3 = Color3.new(1, 1, 1); hud.Visible = false; hud.Parent = screen
Instance.new("UICorner", hud).CornerRadius = UDim.new(0, 16)
local hg = Instance.new("UIGradient"); hg.Rotation = 90; hg.Color = ColorSequence.new(C(52, 56, 80), C(18, 20, 30)); hg.Parent = hud
local ho = Instance.new("UIStroke"); ho.Thickness = 5; ho.Color = C(12, 12, 16); ho.Parent = hud
local hin = Instance.new("Frame"); hin.BackgroundTransparency = 1; hin.Position = UDim2.fromOffset(5, 5); hin.Size = UDim2.new(1, -10, 1, -10); hin.Parent = hud
Instance.new("UICorner", hin).CornerRadius = UDim.new(0, 12)
local his = Instance.new("UIStroke"); his.Thickness = 2.5; his.Color = C(255, 205, 60); his.Parent = hin
local hscale = Instance.new("UIScale"); hscale.Parent = hud

local function label(parent, y, h, text, color, size)
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1; l.Position = UDim2.fromOffset(0, y); l.Size = UDim2.new(1, 0, 0, h)
	l.Font = Enum.Font.FredokaOne; l.Text = text; l.TextColor3 = color; l.TextSize = size; l.ZIndex = 2; l.Parent = parent
	local st = Instance.new("UIStroke"); st.Thickness = 3; st.Color = C(0, 0, 0); st.Parent = l
	return l
end
local titleLbl = label(hud, 6, 24, "🔓 ABRIENDO CAJA FUERTE", C(255, 225, 90), 20)
local timeLbl = label(hud, 28, 36, "00:00s", Color3.new(1, 1, 1), 34)
local barBg = Instance.new("Frame")
barBg.Position = UDim2.fromOffset(16, 70); barBg.Size = UDim2.new(1, -32, 0, 12); barBg.BackgroundColor3 = C(10, 10, 16)
barBg.BorderSizePixel = 0; barBg.ClipsDescendants = true; barBg.ZIndex = 2; barBg.Parent = hud
Instance.new("UICorner", barBg).CornerRadius = UDim.new(0, 6)
local barFill = Instance.new("Frame"); barFill.Size = UDim2.fromScale(1, 1); barFill.BorderSizePixel = 0; barFill.ZIndex = 2; barFill.Parent = barBg
Instance.new("UICorner", barFill).CornerRadius = UDim.new(0, 6)
local fg = Instance.new("UIGradient"); fg.Rotation = 90; fg.Color = ColorSequence.new(Color3.new(1, 1, 1), C(180, 180, 180)); fg.Parent = barFill

-- ===== un cartel por caja =====
local timers = {} -- [model] = data

local function makeBillboard(adornee)
	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.fromOffset(210, 100); bb.StudsOffsetWorldSpace = Vector3.new(0, 7.5, 0); bb.AlwaysOnTop = false
	bb.MaxDistance = 160; bb.Adornee = adornee; bb.Parent = screen
	local card = Instance.new("Frame"); card.Size = UDim2.fromScale(1, 1); card.BackgroundColor3 = Color3.new(1, 1, 1); card.Parent = bb
	Instance.new("UICorner", card).CornerRadius = UDim.new(0, 14)
	local g = Instance.new("UIGradient"); g.Rotation = 90; g.Color = ColorSequence.new(C(48, 52, 76), C(16, 18, 28)); g.Parent = card
	local st = Instance.new("UIStroke"); st.Thickness = 4; st.Color = C(12, 12, 16); st.Parent = card
	local inner = Instance.new("Frame"); inner.BackgroundTransparency = 1; inner.Position = UDim2.fromOffset(4, 4); inner.Size = UDim2.new(1, -8, 1, -8); inner.Parent = card
	Instance.new("UICorner", inner).CornerRadius = UDim.new(0, 11)
	local is = Instance.new("UIStroke"); is.Thickness = 2; is.Color = C(255, 205, 60); is.Parent = inner
	local t = Instance.new("TextLabel"); t.BackgroundTransparency = 1; t.Position = UDim2.fromScale(0, 0.08); t.Size = UDim2.fromScale(1, 0.56)
	t.Font = Enum.Font.FredokaOne; t.TextScaled = true; t.TextColor3 = Color3.new(1, 1, 1); t.Text = "00:00s"; t.Parent = card
	local ts = Instance.new("UIStroke"); ts.Thickness = 3; ts.Color = C(0, 0, 0); ts.Parent = t
	local bg = Instance.new("Frame"); bg.Position = UDim2.fromScale(0.08, 0.7); bg.Size = UDim2.fromScale(0.84, 0.16); bg.BackgroundColor3 = C(10, 10, 16)
	bg.BorderSizePixel = 0; bg.ClipsDescendants = true; bg.Parent = card
	Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 6)
	local f = Instance.new("Frame"); f.Size = UDim2.fromScale(1, 1); f.BorderSizePixel = 0; f.Parent = bg
	Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
	local scale = Instance.new("UIScale"); scale.Scale = 0.3; scale.Parent = card
	TweenService:Create(scale, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
	return bb, t, f
end

local function stop(model)
	local d = timers[model]
	if not d then return end
	timers[model] = nil
	if d.model.Parent and d.home then d.model:PivotTo(d.home) end
	if d.light then d.light:Destroy() end
	if d.bb then d.bb:Destroy() end
end

local function fmt(sec)
	sec = math.max(0, math.ceil(sec))
	return string.format("%02d:%02ds", math.floor(sec / 60), sec % 60)
end

local function colorFor(ratio)
	return ratio > 0.5 and C(90, 225, 110) or (ratio > 0.2 and C(245, 195, 50) or C(255, 75, 75))
end

remote.OnClientEvent:Connect(function(kind, model, duration)
	if kind == "Start" and typeof(model) == "Instance" then
		stop(model)
		local part = model:IsA("Model") and (model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)) or model
		local bb, t, f = makeBillboard(part)
		local light
		if part and part:IsA("BasePart") then
			light = Instance.new("PointLight"); light.Color = C(120, 230, 255); light.Range = 14; light.Brightness = 0; light.Parent = part
		end
		timers[model] = { model = model, home = model:IsA("Model") and model:GetPivot() or nil, t0 = os.clock(), total = duration or 5,
			bb = bb, text = t, fill = f, light = light, nextTick = 0 }
		if not hud.Visible then
			hud.Visible = true
			hscale.Scale = 0.4
			TweenService:Create(hscale, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
		end
	elseif kind == "Stop" then
		if typeof(model) == "Instance" then stop(model) else for m in pairs(timers) do stop(m) end end
	end
end)

RunService.RenderStepped:Connect(function()
	local now = os.clock()
	local soonest, soonestRemaining, count = nil, math.huge, 0
	for model, d in pairs(timers) do
		if not model.Parent then
			stop(model)
		else
			count += 1
			local elapsed = now - d.t0
			local remaining = d.total - elapsed
			local ratio = math.clamp(remaining / d.total, 0, 1)
			local col = colorFor(ratio)
			d.text.Text = fmt(remaining)
			d.fill.Size = UDim2.fromScale(ratio, 1)
			d.fill.BackgroundColor3 = col
			if d.home then
				local amp = 0.03 + 0.16 * (1 - ratio)
				local function r() return (math.random() - 0.5) * 2 end
				model:PivotTo(d.home * CFrame.new(r() * amp, 0, r() * amp) * CFrame.Angles(0, r() * amp * 0.12, r() * amp * 0.08))
			end
			if d.light then
				local pulse = 0.5 + 0.5 * math.sin(elapsed * (6 + 12 * (1 - ratio)))
				d.light.Brightness = 1 + 4 * pulse * (1.2 - ratio)
				d.light.Color = col
			end
			-- Sonido de mecanismo al colocar caja eliminado a pedido del usuario
			if remaining < soonestRemaining then soonest, soonestRemaining = d, remaining end
		end
	end
	if count == 0 then
		hud.Visible = false
	elseif soonest then
		local ratio = math.clamp(soonestRemaining / soonest.total, 0, 1)
		titleLbl.Text = count > 1 and ("🔓 ABRIENDO " .. count .. " CAJAS") or "🔓 ABRIENDO CAJA FUERTE"
		timeLbl.Text = fmt(soonestRemaining)
		barFill.Size = UDim2.fromScale(ratio, 1)
		barFill.BackgroundColor3 = colorFor(ratio)
	end
end)
