--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")

local NumberFormatter = require(ReplicatedStorage.Modules.NumberFormatter)
local TrailConfigurations = require(ReplicatedStorage.Modules.TrailConfigurations)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local eventsFolder = ReplicatedStorage:WaitForChild("Events", 5)
local trailEvent = eventsFolder:WaitForChild("TrailAction", 5)

local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes", 5)
local NotifyRemote = RemotesFolder:WaitForChild("Notify", 5)
local DataSyncRemote = RemotesFolder:WaitForChild("DataSynced", 5)

local function WaitForDescendant(Root, Name)
	local Found = Root:FindFirstChild(Name, true)
	local timeout = 0
	while not Found and timeout < 10 do
		task.wait(0.1)
		timeout += 0.1
		Found = Root:FindFirstChild(Name, true)
	end
	return Found
end

local trailsFrame = WaitForDescendant(playerGui, "TrailsFrame") :: Frame?
if not trailsFrame then
	return
end

local scrolling = trailsFrame:FindFirstChild("Scrolling") :: ScrollingFrame?
if not scrolling then
	return
end

local templatesFolder = ReplicatedStorage:FindFirstChild("Templates")
local template = templatesFolder and templatesFolder:FindFirstChild("TrailTemplate") :: Frame?
if not template then
	return
end

local trailsScale = trailsFrame:FindFirstChildOfClass("UIScale")
if not trailsScale then
	trailsScale = Instance.new("UIScale")
	trailsScale.Parent = trailsFrame
end

trailsFrame.Visible = false
trailsScale.Scale = 0

local isAnimating = false
local priceCache = {}

local function updateButtons(frame: Frame, info, isOwned: boolean, isEquipped: boolean)
	local buttons = frame:FindFirstChild("Buttons")
	if not buttons then return end

	local moneyBtn = (buttons:FindFirstChild("Money") or buttons:FindFirstChild("Wins")) :: ImageButton
	local robuxBtn = buttons:FindFirstChild("Robux") :: ImageButton
	local equipBtn = (buttons:FindFirstChild("Equip")
		or buttons:FindFirstChild("EquipButton")
		or buttons:FindFirstChild("Equipped")) :: ImageButton

	if moneyBtn then moneyBtn.Visible = not isOwned end
	if robuxBtn then robuxBtn.Visible = false end
	if equipBtn then equipBtn.Visible = isOwned end

	if isOwned then
		if equipBtn then
			local btnText = equipBtn:FindFirstChild("Text") :: TextLabel
			if isEquipped then
				equipBtn.AutoButtonColor = false
				equipBtn.BackgroundColor3 = Color3.fromRGB(85, 255, 127)
				if btnText then btnText.Text = "Unequip" end
			else
				equipBtn.AutoButtonColor = true
				equipBtn.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
				if btnText then btnText.Text = "Equip" end
			end
		end
	else
		if moneyBtn then
			local t = moneyBtn:FindFirstChild("Text") :: TextLabel
			if t then t.Text = NumberFormatter.Format(info.MoneyCost) end
		end
		if info.ProductId and info.ProductId ~= 0 and robuxBtn then
			robuxBtn.Visible = true
			local t = robuxBtn:FindFirstChild("Text") :: TextLabel
			if t then
				if priceCache[info.ProductId] then
					t.Text = tostring(priceCache[info.ProductId])
				else
					t.Text = "..."
					task.spawn(function()
						local ok, productInfo = pcall(function()
							return MarketplaceService:GetProductInfo(info.ProductId, Enum.InfoType.Product)
						end)
						if ok and productInfo then
							priceCache[info.ProductId] = productInfo.PriceInRobux
							t.Text = tostring(productInfo.PriceInRobux)
						else
							t.Text = "Error"
						end
					end)
				end
			end
		end
	end
end

local function refreshShopStates()
	local trails = player:FindFirstChild("Trails")
	if not trails then return end
	local equippedVal = trails:FindFirstChild("Equipped")
	if not equippedVal then return end

	local equippedId = equippedVal.Value
	local owned = {}
	for _, child in ipairs(trails:GetChildren()) do
		if child.Name ~= "Equipped" then
			owned[child.Name] = true
		end
	end

	for _, child in ipairs(scrolling:GetChildren()) do
		if child:IsA("Frame") then
			local info = TrailConfigurations.GetTrailById(child.Name)
			if info then
				local isOwned = owned[info.ID] == true
				local isEquipped = (equippedId == info.ID)
				updateButtons(child, info, isOwned, isEquipped)
			end
		end
	end
end

local shopBuilt = false
local function populateShop()
	if shopBuilt then return end
	shopBuilt = true

	for _, child in ipairs(scrolling:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end

	for _, info in ipairs(TrailConfigurations.Trails) do
		local clone = template:Clone()
		clone.Name = info.ID
		clone.Visible = true

		local nameLabel = clone:FindFirstChild("Name") :: TextLabel
		if nameLabel then nameLabel.Text = info.Name end

		local speedLabel = clone:FindFirstChild("SpeedBoost") :: TextLabel
		if speedLabel then speedLabel.Text = "+" .. tostring(info.SpeedBoost) .. " Speed" end

		local imageLabel = clone:FindFirstChild("Image") :: ImageLabel
		if imageLabel and info.Image then
			imageLabel.Image = info.Image
		end

		clone.Parent = scrolling

		local btns = clone:FindFirstChild("Buttons")
		if btns then
			local moneyBtn = (btns:FindFirstChild("Money") or btns:FindFirstChild("Wins")) :: ImageButton
			local robuxBtn = btns:FindFirstChild("Robux") :: ImageButton
			local equipBtn = (btns:FindFirstChild("Equip")
				or btns:FindFirstChild("EquipButton")
				or btns:FindFirstChild("Equipped")) :: ImageButton

			if moneyBtn then
				moneyBtn.MouseButton1Click:Connect(function()
					trailEvent:FireServer("BuyMoney", info.ID)
				end)
			end
			if robuxBtn then
				robuxBtn.MouseButton1Click:Connect(function()
					if typeof(info.ProductId) == "number" and info.ProductId > 0 then
						MarketplaceService:PromptProductPurchase(player, info.ProductId)
					end
				end)
			end
			if equipBtn then
				equipBtn.MouseButton1Click:Connect(function()
					local trails = player:FindFirstChild("Trails")
					local equipped = trails and trails:FindFirstChild("Equipped") :: StringValue
					if equipped and equipped.Value == info.ID then
						trailEvent:FireServer("Unequip", info.ID)
					else
						trailEvent:FireServer("Equip", info.ID)
					end
				end)
			end
		end
	end
end

local function OpenTrailsFrame()
	if trailsFrame.Visible and trailsScale.Scale >= 1 then return end
	refreshShopStates()
	isAnimating = true
	trailsFrame.Visible = true
	local Tween = TweenService:Create(trailsScale, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1})
	Tween:Play()
	Tween.Completed:Connect(function() isAnimating = false end)
end

local function CloseTrailsFrame()
	if not trailsFrame.Visible then return end
	isAnimating = true
	local Tween = TweenService:Create(trailsScale, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Scale = 0})
	Tween:Play()
	Tween.Completed:Connect(function()
		trailsFrame.Visible = false
		isAnimating = false
	end)
end

local function ToggleTrailsFrame()
	if isAnimating then return end
	if trailsFrame.Visible then CloseTrailsFrame() else OpenTrailsFrame() end
end

local closeButton = (trailsFrame:FindFirstChild("Close") or trailsFrame:FindFirstChild("CloseButton")) :: ImageButton
if closeButton then
	closeButton.MouseButton1Click:Connect(CloseTrailsFrame)
end

-- Conectar al botón del HUD (⚡ Rastros)
task.spawn(function()
	local petsGui = playerGui:WaitForChild("Pets", 10)
	local hud = petsGui and petsGui:WaitForChild("HUD", 10)
	local right = hud and hud:WaitForChild("Right", 10)
	local trailsBtn = right and right:WaitForChild("TrailsButton", 10) :: GuiButton?
	if trailsBtn then
		trailsBtn.Activated:Connect(function()
			ToggleTrailsFrame()
		end)
	end
end)

local function trySyncFromDataLoaded()
	if player:GetAttribute("DataLoaded") == true then
		refreshShopStates()
	end
end

local function init()
	populateShop()
	local trails = player:WaitForChild("Trails")
	trails.ChildAdded:Connect(refreshShopStates)
	trails:WaitForChild("Equipped").Changed:Connect(refreshShopStates)
	NotifyRemote.OnClientEvent:Connect(refreshShopStates)
	DataSyncRemote.OnClientEvent:Connect(refreshShopStates)
	player:GetAttributeChangedSignal("DataLoaded"):Connect(trySyncFromDataLoaded)

	refreshShopStates()
	trySyncFromDataLoaded()
end

init()
-- Connect physical 3D Shop prompt in lobby
task.spawn(function()
	local map = workspace:WaitForChild("Map", 15)
	local build = map and map:WaitForChild("Build", 15)
	local shop = (build and build:FindFirstChild("StandRastros", true)) or workspace:FindFirstChild("StandRastros", true)
	if not shop then
		task.wait(2)
		shop = workspace:FindFirstChild("StandRastros", true)
	end
	if shop then
		local pad = shop:FindFirstChild("InteractionPad")
		if pad then
			local prompt = pad:FindFirstChildWhichIsA("ProximityPrompt")
			if prompt then
				prompt.Triggered:Connect(function()
					ToggleTrailsFrame()
				end)
			end
			pad.Touched:Connect(function(hit)
				local char = hit:FindFirstAncestorOfClass("Model")
				if char and char == player.Character and not trailsFrame.Visible then
					OpenTrailsFrame()
				end
			end)
		end
	end
end)