--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local mouse = Player:GetMouse()
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local DropEggRemote = Remotes:WaitForChild("DropEgg") :: RemoteEvent

local Gui = script.Parent
local EffectFrame = Gui:WaitForChild("Effect") :: Frame
local DropButton = Gui:WaitForChild("DropButton") :: TextButton

EffectFrame.Visible = false
DropButton.Visible = false

local scale = DropButton:FindFirstChildOfClass("UIScale") or Instance.new("UIScale", DropButton)
scale.Scale = 1

-- Anillo de previsualizacion para colocar la caja con el mouse en la base
local previewRing = Instance.new("Part")
previewRing.Name = "DropBoxPreview"
previewRing.Shape = Enum.PartType.Cylinder
previewRing.Size = Vector3.new(0.2, 4.2, 4.2)
previewRing.Material = Enum.Material.Neon
previewRing.Color = Color3.fromRGB(90, 245, 120)
previewRing.Transparency = 0.35
previewRing.Anchored = true
previewRing.CanCollide = false
previewRing.CanQuery = false
previewRing.CanTouch = false

local mouseHoverValid = false
local mouseHoverPos: Vector3? = nil

local function getMyBasePlace(): BasePart?
	local plots = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Plots")
	if not plots then return nil end
	for _, p in ipairs(plots:GetChildren()) do
		if p:GetAttribute("OwnerUserId") == Player.UserId then
			return p:FindFirstChild("Place") :: BasePart?
		end
	end
	return nil
end

local function FireDrop(pos: Vector3?)
	if Player:GetAttribute("IsStealing") == true then
		DropEggRemote:FireServer(pos)
	end
end

DropButton.Activated:Connect(function()
	FireDrop(mouseHoverValid and mouseHoverPos or nil)
end)

local btnText = DropButton:FindFirstChild("Text") :: TextLabel?

-- Tecla E o Click: soltar en la posicion del mouse si es valida, o en frente del avatar
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.E then
		FireDrop(mouseHoverValid and mouseHoverPos or nil)
	elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
		if Player:GetAttribute("IsStealing") == true and mouseHoverValid and mouseHoverPos then
			FireDrop(mouseHoverPos)
		end
	end
end)

-- Click del mouse directo en el suelo de la base para colocar la caja
mouse.Button1Down:Connect(function()
	if Player:GetAttribute("IsStealing") == true and mouseHoverValid and mouseHoverPos then
		FireDrop(mouseHoverPos)
	end
end)

DropButton.MouseEnter:Connect(function()
	TweenService:Create(scale, TweenInfo.new(0.12), { Scale = 1.05 }):Play()
end)
DropButton.MouseLeave:Connect(function()
	TweenService:Create(scale, TweenInfo.new(0.12), { Scale = 1.0 }):Play()
end)
DropButton.MouseButton1Down:Connect(function()
	TweenService:Create(scale, TweenInfo.new(0.08), { Scale = 0.95 }):Play()
end)
DropButton.MouseButton1Up:Connect(function()
	TweenService:Create(scale, TweenInfo.new(0.08), { Scale = 1.05 }):Play()
end)

-- Actualizacion continua: control de viñeta roja (fuera de zona segura) y mouse hover en base propia
RunService.RenderStepped:Connect(function()
	local isStealing = Player:GetAttribute("IsStealing") == true
	local char = Player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
	local inSafeZone = hrp and hrp.Position.Z <= -645

	if isStealing then
		DropButton.Visible = true
		-- La viñeta roja se apaga 100% en la zona verde
		EffectFrame.Visible = not inSafeZone

		if btnText then
			if inSafeZone then
				btnText.Text = "📦 DEJAR CAJA FUERTE [CLICK / E]"
			else
				btnText.Text = "💥 SOLTAR CAJA FUERTE [E]"
			end
		end

		-- Chequeo de colocacion con mouse en base propia
		local place = getMyBasePlace()
		local hit = mouse.Hit and mouse.Hit.Position
		if place and hit then
			local rel = place.CFrame:PointToObjectSpace(hit)
			local hx, hz = place.Size.X / 2 - 1.2, place.Size.Z / 2 - 1.2
			if math.abs(rel.X) <= hx and math.abs(rel.Z) <= hz and rel.Y < 8 then
				mouseHoverValid = true
				mouseHoverPos = Vector3.new(hit.X, place.Position.Y + place.Size.Y / 2, hit.Z)
				previewRing.Parent = workspace
				previewRing.CFrame = CFrame.new(mouseHoverPos + Vector3.new(0, 0.1, 0)) * CFrame.Angles(0, 0, math.pi / 2)
			else
				mouseHoverValid = false
				mouseHoverPos = nil
				previewRing.Parent = nil
			end
		else
			mouseHoverValid = false
			mouseHoverPos = nil
			previewRing.Parent = nil
		end
	else
		DropButton.Visible = false
		EffectFrame.Visible = false
		mouseHoverValid = false
		mouseHoverPos = nil
		previewRing.Parent = nil
	end
end)
