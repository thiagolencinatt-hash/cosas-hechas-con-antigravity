-- Interfaz de recompensas por tiempo (en español). Todo se valida en el servidor; esto solo muestra y pide reclamar.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local gui = script.Parent
local GiftFolder = ReplicatedStorage:WaitForChild("GiftFolder")
local Gifts = require(GiftFolder:WaitForChild("SharedGiftData"))

local data = nil
for attempt = 1, 10 do
	local ok, res = pcall(function()
		return GiftFolder:WaitForChild("GetData"):InvokeServer()
	end)
	if ok and res then
		data = res
		break
	end
	task.wait(1)
end

if not data then
	data = { Total = 0, Claimed = {}, RefreshIn = 86400, LastRefresh = os.time() }
end

local startedAt = os.clock()
local claimedLocal = {}
local function applyData(newData)
	data = newData
	startedAt = os.clock()
	claimedLocal = {}
	for key in pairs(newData.Claimed or {}) do
		claimedLocal[tonumber(key)] = true
	end
end
applyData(data)

local function elapsed()
	return data.Total + (os.clock() - startedAt)
end

local function formatTime(seconds)
	seconds = math.max(0, math.floor(seconds))
	local h = seconds // 3600
	local m = (seconds % 3600) // 60
	local s = seconds % 60
	if h > 0 then
		return string.format("%02d:%02d:%02d", h, m, s)
	end
	return string.format("%02d:%02d", m, s)
end

local function formatNumber(n)
	local text = tostring(n)
	local formatted = text:reverse():gsub("(%d%d%d)", "%1,"):reverse()
	return (formatted:gsub("^,", ""))
end

local function make(className, props, parent)
	local inst = Instance.new(className)
	for key, value in pairs(props) do
		inst[key] = value
	end
	inst.Parent = parent
	return inst
end

local function round(parent, radius)
	make("UICorner", { CornerRadius = UDim.new(0, radius) }, parent)
end

local function stroke(parent, color, thickness)
	make("UIStroke", { Color = color, Thickness = thickness, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, parent)
end

local WHITE = Color3.new(1, 1, 1)
local GREEN = Color3.fromRGB(47, 255, 61)
local GREY = Color3.fromRGB(170, 175, 195)

local toggle = make("TextButton", {
	Name = "ToggleButton",
	AnchorPoint = Vector2.new(0, 0.5),
	Position = UDim2.new(0, 12, 0.5, -60),
	Size = UDim2.fromOffset(64, 64),
	BackgroundColor3 = Color3.fromRGB(32, 36, 58),
	Text = "🎁",
	TextSize = 34,
	Font = Enum.Font.GothamBold,
	TextColor3 = WHITE,
}, gui)
round(toggle, 14)
stroke(toggle, Color3.fromRGB(255, 200, 70), 2)

local toggleTimer = make("TextLabel", {
	Name = "Timer",
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 1, 2),
	Size = UDim2.new(1.2, 0, 0, 18),
	BackgroundTransparency = 1,
	Text = "--:--",
	TextSize = 14,
	Font = Enum.Font.GothamBold,
	TextColor3 = WHITE,
	TextStrokeTransparency = 0.4,
}, toggle)

local panel = make("Frame", {
	Name = "Panel",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(460, 420),
	BackgroundColor3 = Color3.fromRGB(24, 27, 46),
	Visible = false,
}, gui)
round(panel, 16)
stroke(panel, Color3.fromRGB(255, 200, 70), 2)

local scale = make("UIScale", {}, panel)
local function updateScale()
	local camera = Workspace.CurrentCamera
	if camera then
		local viewport = camera.ViewportSize
		scale.Scale = math.clamp(math.min(viewport.X / 560, viewport.Y / 500), 0.55, 1.1)
	end
end
updateScale()
if Workspace.CurrentCamera then
	Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
end

make("TextLabel", {
	Name = "Title",
	Position = UDim2.fromOffset(16, 10),
	Size = UDim2.new(1, -70, 0, 28),
	BackgroundTransparency = 1,
	Text = "🎁 Recompensas de tiempo",
	TextSize = 22,
	Font = Enum.Font.GothamBold,
	TextColor3 = WHITE,
	TextXAlignment = Enum.TextXAlignment.Left,
}, panel)

local refreshLabel = make("TextLabel", {
	Name = "RefreshIn",
	Position = UDim2.fromOffset(16, 38),
	Size = UDim2.new(1, -32, 0, 18),
	BackgroundTransparency = 1,
	Text = "Se reinician en: --:--:--",
	TextSize = 14,
	Font = Enum.Font.Gotham,
	TextColor3 = GREY,
	TextXAlignment = Enum.TextXAlignment.Left,
}, panel)

local closeButton = make("TextButton", {
	Name = "Close",
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -12, 0, 10),
	Size = UDim2.fromOffset(34, 34),
	BackgroundColor3 = Color3.fromRGB(200, 60, 60),
	Text = "✕",
	TextSize = 18,
	Font = Enum.Font.GothamBold,
	TextColor3 = WHITE,
}, panel)
round(closeButton, 10)

local grid = make("Frame", {
	Name = "List",
	Position = UDim2.fromOffset(16, 68),
	Size = UDim2.new(1, -32, 1, -84),
	BackgroundTransparency = 1,
}, panel)
make("UIGridLayout", {
	CellSize = UDim2.fromOffset(132, 104),
	CellPadding = UDim2.fromOffset(10, 10),
	SortOrder = Enum.SortOrder.LayoutOrder,
}, grid)

local cards = {}

local function stateOf(gift)
	if claimedLocal[gift.GiftNumber] then
		return "claimed"
	end
	if elapsed() >= gift.Time then
		return "ready"
	end
	return "locked"
end

local function resync()
	local ok, newData = pcall(function()
		return GiftFolder.GetData:InvokeServer()
	end)
	if ok and newData then
		applyData(newData)
	end
end

local busy = false
local function claim(gift)
	if busy or stateOf(gift) ~= "ready" then
		return
	end
	busy = true
	local ok, granted = pcall(function()
		return GiftFolder.ClaimGift:InvokeServer(gift.GiftNumber)
	end)
	if ok and granted == true then
		claimedLocal[gift.GiftNumber] = true
	else
		resync()
	end
	busy = false
end

for _, gift in ipairs(Gifts) do
	local card = make("TextButton", {
		Name = tostring(gift.GiftNumber),
		LayoutOrder = gift.GiftNumber,
		BackgroundColor3 = Color3.fromRGB(38, 42, 68),
		Text = "",
		AutoButtonColor = false,
	}, grid)
	round(card, 12)
	local cardStroke = make("UIStroke", { Color = Color3.fromRGB(70, 76, 110), Thickness = 2 }, card)
	make("TextLabel", {
		Position = UDim2.fromOffset(0, 4), Size = UDim2.new(1, 0, 0, 36), BackgroundTransparency = 1,
		Text = "🎁", TextSize = 28, Font = Enum.Font.GothamBold, TextColor3 = WHITE,
	}, card)
	make("TextLabel", {
		Name = "Reward", Position = UDim2.fromOffset(0, 40), Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1,
		Text = "$" .. formatNumber(gift.Reward.Amount), TextSize = 17, Font = Enum.Font.GothamBold,
		TextColor3 = Color3.fromRGB(255, 214, 90),
	}, card)
	local status = make("TextLabel", {
		Name = "Status", Position = UDim2.fromOffset(0, 66), Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1,
		Text = "", TextSize = 16, Font = Enum.Font.GothamBold, TextColor3 = WHITE,
	}, card)
	card.Activated:Connect(function()
		claim(gift)
	end)
	cards[gift.GiftNumber] = { gift = gift, status = status, stroke = cardStroke, card = card }
end

local function refresh()
	local nextRemaining = nil
	local anyReady = false
	local allClaimed = true
	for _, entry in pairs(cards) do
		local state = stateOf(entry.gift)
		if state == "claimed" then
			entry.status.Text = "Reclamado"
			entry.status.TextColor3 = GREY
			entry.stroke.Color = Color3.fromRGB(70, 76, 110)
		elseif state == "ready" then
			anyReady = true
			allClaimed = false
			entry.status.Text = "¡Reclamar!"
			entry.status.TextColor3 = GREEN
			entry.stroke.Color = GREEN
		else
			allClaimed = false
			local remaining = entry.gift.Time - elapsed()
			entry.status.Text = formatTime(remaining)
			entry.status.TextColor3 = WHITE
			entry.stroke.Color = Color3.fromRGB(70, 76, 110)
			if not nextRemaining or remaining < nextRemaining then
				nextRemaining = remaining
			end
		end
	end
	if anyReady then
		toggleTimer.Text = "¡LISTO!"
		toggleTimer.TextColor3 = GREEN
	elseif allClaimed then
		toggleTimer.Text = "Completo"
		toggleTimer.TextColor3 = GREY
	else
		toggleTimer.Text = formatTime(nextRemaining or 0)
		toggleTimer.TextColor3 = WHITE
	end
	local refreshIn = data.RefreshIn - (os.clock() - startedAt)
	refreshLabel.Text = "Se reinician en: " .. formatTime(refreshIn)
	if refreshIn <= 0 then
		resync()
	end
end

toggle.Activated:Connect(function()
	panel.Visible = not panel.Visible
end)
closeButton.Activated:Connect(function()
	panel.Visible = false
end)

-- Conectar también al botón de Regalos en HUD.Left
task.spawn(function()
	local player = Players.LocalPlayer
	local pGui = player:WaitForChild("PlayerGui")
	local pets = pGui:WaitForChild("Pets", 10)
	local hud = pets and pets:WaitForChild("HUD", 10)
	local left = hud and hud:WaitForChild("Left", 10)
	local gBtn = left and left:WaitForChild("GiftButton", 10) :: GuiButton?
	if gBtn then
		-- Si tenemos el botón integrado en HUD, ocultamos el toggle flotante aislado
		toggle.Visible = false
		gBtn.Activated:Connect(function()
			panel.Visible = not panel.Visible
		end)
	end
end)

task.spawn(function()
	while gui.Parent do
		refresh()
		task.wait(1)
	end
end)
