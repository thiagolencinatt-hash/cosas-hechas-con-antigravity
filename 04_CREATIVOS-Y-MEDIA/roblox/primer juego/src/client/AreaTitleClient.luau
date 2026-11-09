--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer

local Gui = script.Parent :: ScreenGui
local Banner = Gui:WaitForChild("ZoneBanner4K") :: Frame
local UIScale = Banner:WaitForChild("Scale") :: UIScale
local Shine = Banner:WaitForChild("Shine") :: Frame
local Content = Banner:WaitForChild("Content") :: Frame
local ZoneTitle = Content:WaitForChild("ZoneTitle") :: TextLabel
local SpeedLabel = Content:WaitForChild("SpeedLabel") :: TextLabel
local Sound = Banner:WaitForChild("AreaAppearSound") :: Sound

type ZoneDef = {
	Name: string,
	Flag: string,
	ZoneNumber: number,
	RecSpeed: string,
	MinZ: number,
	MaxZ: number,
}

local ZONES: { ZoneDef } = {
	{ Name = "ARGENTINA", Flag = "🇦🇷", ZoneNumber = 1, RecSpeed = "16+", MinZ = -645, MaxZ = -430 },
	{ Name = "BRASIL", Flag = "🇧🇷", ZoneNumber = 2, RecSpeed = "25+", MinZ = -430, MaxZ = -150 },
	{ Name = "ESTADOS UNIDOS", Flag = "🇺🇸", ZoneNumber = 3, RecSpeed = "45+", MinZ = -150, MaxZ = 80 },
	{ Name = "JAPÓN", Flag = "🇯🇵", ZoneNumber = 4, RecSpeed = "75+", MinZ = 80, MaxZ = 340 },
	{ Name = "MÉXICO", Flag = "🇲🇽", ZoneNumber = 5, RecSpeed = "120+", MinZ = 340, MaxZ = 595 },
	{ Name = "ESPAÑA", Flag = "🇪🇸", ZoneNumber = 6, RecSpeed = "180+", MinZ = 595, MaxZ = 865 },
	{ Name = "REINO UNIDO", Flag = "🇬🇧", ZoneNumber = 7, RecSpeed = "260+", MinZ = 865, MaxZ = 1115 },
	{ Name = "FRANCIA", Flag = "🇫🇷", ZoneNumber = 8, RecSpeed = "380+", MinZ = 1115, MaxZ = 1365 },
	{ Name = "EGIPTO", Flag = "🇪🇬", ZoneNumber = 9, RecSpeed = "520+", MinZ = 1365, MaxZ = 1600 },
	{ Name = "PAÍS NÓRDICO", Flag = "❄️", ZoneNumber = 10, RecSpeed = "750+", MinZ = 1600, MaxZ = 2200 },
}

local currentZoneIdx: number? = nil
local lastShownZoneIdx: number? = nil
local lastShownTime = 0
local activeTweens: { Tween } = {}
local animToken = 0

local function CancelActiveTweens()
	for _, tw in ipairs(activeTweens) do
		pcall(function()
			tw:Cancel()
		end)
	end
	table.clear(activeTweens)
end

local function PlayTween(inst: Instance, info: TweenInfo, props: { [string]: any }): Tween
	local tw = TweenService:Create(inst, info, props)
	table.insert(activeTweens, tw)
	tw:Play()
	return tw
end

local function ShowZoneNotification(zone: ZoneDef)
	animToken += 1
	local myToken = animToken

	CancelActiveTweens()

	-- Textos profesionales 4K estrictamente según lo solicitado
	ZoneTitle.Text = zone.Flag .. " ZONA " .. zone.ZoneNumber .. " • " .. zone.Name
	SpeedLabel.Text = "⚡ Velocidad recomendada: <font color='#FFE34D'><b>" .. zone.RecSpeed .. "</b></font>"

	-- Posicion inicial oculta arriba
	Banner.Visible = true
	Banner.Position = UDim2.new(0.5, 0, 0, -110)
	UIScale.Scale = 0.82
	Shine.Position = UDim2.new(-0.35, 0, 0.5, 0)

	-- Sonido silenciado para evitar ruidos molestos al entrar a la zona de tiendas
	pcall(function()
		Sound.Volume = 0
	end)

	-- Animacion 4K con rebote suave
	local dropInfo = TweenInfo.new(0.42, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	PlayTween(Banner, dropInfo, { Position = UDim2.new(0.5, 0, 0, 24) })
	PlayTween(UIScale, dropInfo, { Scale = 1.0 })

	-- Destello cromado que recorre el cartel
	task.delay(0.15, function()
		if myToken ~= animToken then return end
		local shineInfo = TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		PlayTween(Shine, shineInfo, { Position = UDim2.new(1.35, 0, 0.5, 0) })
	end)

	-- Permanencia momentanea (3.5s) y salida fluida
	task.delay(3.6, function()
		if myToken ~= animToken then return end
		local exitInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		PlayTween(Banner, exitInfo, { Position = UDim2.new(0.5, 0, 0, -110) })
		PlayTween(UIScale, exitInfo, { Scale = 0.85 })

		task.delay(0.36, function()
			if myToken == animToken then
				Banner.Visible = false
			end
		end)
	end)
end

local function GetZoneAtZ(z: number): (number?, ZoneDef?)
	if z <= -645 then
		return nil, nil
	end
	for i, zone in ipairs(ZONES) do
		if z >= zone.MinZ and z < zone.MaxZ then
			return i, zone
		end
	end
	if z >= ZONES[#ZONES].MinZ then
		return #ZONES, ZONES[#ZONES]
	end
	return nil, nil
end

local checkAccumulator = 0
local CHECK_STEP = 0.1

RunService.Heartbeat:Connect(function(dt)
	checkAccumulator += dt
	if checkAccumulator < CHECK_STEP then return end
	checkAccumulator = 0

	local char = Player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not hrp then return end

	local z = hrp.Position.Z
	local zoneIdx, zoneDef = GetZoneAtZ(z)

	if zoneIdx ~= currentZoneIdx then
		currentZoneIdx = zoneIdx
		local now = os.clock()

		if zoneIdx and zoneDef then
			if zoneIdx ~= lastShownZoneIdx or (now - lastShownTime) > 6 then
				lastShownZoneIdx = zoneIdx
				lastShownTime = now
				ShowZoneNotification(zoneDef)
			end
		else
			lastShownZoneIdx = nil
			if Banner.Visible then
				CancelActiveTweens()
				local exitInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
				PlayTween(Banner, exitInfo, { Position = UDim2.new(0.5, 0, 0, -120) })
				task.delay(0.31, function()
					Banner.Visible = false
				end)
			end
		end
	end
end)
