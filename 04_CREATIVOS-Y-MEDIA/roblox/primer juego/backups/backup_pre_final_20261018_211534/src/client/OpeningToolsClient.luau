--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local PetsGui = script.Parent
local Frame = PetsGui:WaitForChild("OpeningToolsFrame")
local CloseBtn = Frame:WaitForChild("Title"):WaitForChild("CloseBtn")
local Scroll = Frame:WaitForChild("ToolsScroll")
local Scale = Frame:FindFirstChildOfClass("UIScale") or Instance.new("UIScale", Frame)

local Modules = ReplicatedStorage:WaitForChild("Modules")
local OpeningToolsConfig = require(Modules:WaitForChild("OpeningToolsConfig"))

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local ToolActionRemote = Remotes:WaitForChild("OpeningToolsAction") :: RemoteEvent

local HUD = PetsGui:WaitForChild("HUD")
local RightHUD = HUD:WaitForChild("Right")
local ToolsBtn = RightHUD:WaitForChild("ToolsButton") :: GuiButton

local isOpen = false

local function setOpen(open: boolean)
	isOpen = open
	if open then
		Frame.Visible = true
		Scale.Scale = 0
		local tw = TweenService:Create(Scale, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1})
		tw:Play()
	else
		local tw = TweenService:Create(Scale, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Scale = 0})
		tw:Play()
		tw.Completed:Connect(function()
			if not isOpen then Frame.Visible = false end
		end)
	end
end

ToolsBtn.MouseButton1Click:Connect(function()
	setOpen(not isOpen)
end)

CloseBtn.MouseButton1Click:Connect(function()
	setOpen(false)
end)

-- Connect physical 3D Shop prompt in lobby
task.spawn(function()
	local map = workspace:WaitForChild("Map", 10)
	local build = map and map:WaitForChild("Build", 10)
	local shop = build and build:WaitForChild("TiendaArmas3D", 10)
	local pad = shop and shop:WaitForChild("InteractionPad", 10)
	local prompt = pad and pad:WaitForChild("ShopPrompt", 10) :: ProximityPrompt?
	if prompt then
		prompt.Triggered:Connect(function()
			setOpen(true)
		end)
	end
	if pad then
		pad.Touched:Connect(function(hit)
			local char = hit:FindFirstAncestorOfClass("Model")
			if char and char == Player.Character and not isOpen then
				setOpen(true)
			end
		end)
	end
end)

local function populate()
	for _, child in ipairs(Scroll:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end

	local folder = Player:WaitForChild("OpeningTools")
	local eqVal = folder:WaitForChild("EquippedTool") :: StringValue

	for i, tool in ipairs(OpeningToolsConfig.Tools) do
		local card = Instance.new("Frame")
		card.Name = "Card_" .. tool.Id
		card.Size = UDim2.new(1, 0, 0, 95)
		card.BackgroundColor3 = Color3.fromRGB(28, 34, 48)
		card.LayoutOrder = i
		card.Parent = Scroll

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 10)
		corner.Parent = card

		local stroke = Instance.new("UIStroke")
		stroke.Color = tool.Color
		stroke.Thickness = 1.5
		stroke.Parent = card

		local nameLbl = Instance.new("TextLabel")
		nameLbl.Size = UDim2.new(0.65, 0, 0.35, 0)
		nameLbl.Position = UDim2.new(0.04, 0, 0.08, 0)
		nameLbl.BackgroundTransparency = 1
		nameLbl.Text = string.format("🔨 %s (Poder: %d)", tool.Name, tool.BreakPower)
		nameLbl.TextColor3 = tool.Color
		nameLbl.Font = Enum.Font.FredokaOne
		nameLbl.TextScaled = true
		nameLbl.TextXAlignment = Enum.TextXAlignment.Left
		nameLbl.Parent = card

		local descLbl = Instance.new("TextLabel")
		descLbl.Size = UDim2.new(0.65, 0, 0.48, 0)
		descLbl.Position = UDim2.new(0.04, 0, 0.46, 0)
		descLbl.BackgroundTransparency = 1
		descLbl.Text = tool.Description .. string.format(" • Bioma: %s", tool.Biome or "General")
		descLbl.TextColor3 = Color3.fromRGB(200, 210, 225)
		descLbl.Font = Enum.Font.Gotham
		descLbl.TextSize = 12
		descLbl.TextWrapped = true
		descLbl.TextXAlignment = Enum.TextXAlignment.Left
		descLbl.Parent = card

		local isOwned = (tool.Id == "MazoMadera") or (folder:FindFirstChild(tool.Id) ~= nil)
		local isEquipped = (eqVal.Value == tool.Id)

		local actionBtn = Instance.new("TextButton")
		actionBtn.Size = UDim2.new(0.24, 0, 0.5, 0)
		actionBtn.Position = UDim2.new(0.72, 0, 0.25, 0)
		actionBtn.Font = Enum.Font.GothamBold
		actionBtn.TextScaled = true
		actionBtn.Parent = card

		local bCorner = Instance.new("UICorner")
		bCorner.CornerRadius = UDim.new(0, 8)
		bCorner.Parent = actionBtn

		if isEquipped then
			actionBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 80)
			actionBtn.Text = "EQUIPADO"
			actionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		elseif isOwned then
			actionBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 220)
			actionBtn.Text = "EQUIPAR"
			actionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			actionBtn.MouseButton1Click:Connect(function()
				ToolActionRemote:FireServer("Equip", tool.Id)
			end)
		else
			actionBtn.BackgroundColor3 = Color3.fromRGB(240, 150, 40)
			actionBtn.Text = string.format("$%d", tool.Price)
			actionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			actionBtn.MouseButton1Click:Connect(function()
				ToolActionRemote:FireServer("Buy", tool.Id)
			end)
		end
	end
end

local folder = Player:WaitForChild("OpeningTools")
folder.ChildAdded:Connect(populate)
folder:WaitForChild("EquippedTool").Changed:Connect(populate)

populate()
