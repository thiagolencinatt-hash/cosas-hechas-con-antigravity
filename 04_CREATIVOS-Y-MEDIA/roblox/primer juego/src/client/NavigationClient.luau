--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local PetsGui = script.Parent

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local TeleportHomeRemote = Remotes:WaitForChild("TeleportHome") :: RemoteEvent
local NotifyRemote = Remotes:FindFirstChild("Notify") :: RemoteEvent?

local function Notify(text: string, color: Color3?)
	if NotifyRemote then
		NotifyRemote:FireClient(Player, text, color or Color3.fromRGB(255, 255, 255), 2.5)
	end
end

local HUD = PetsGui:WaitForChild("HUD")
local Left = HUD:WaitForChild("Left")
local Right = HUD:WaitForChild("Right")

-- 1. Botón de Teletransporte a Base (HomeButton)
local HomeButton = Left:WaitForChild("HomeButton") :: TextButton
HomeButton.Activated:Connect(function()
	TeleportHomeRemote:FireServer()
end)

-- 2. Botón de Silenciar / Mute (SoundButton)
local SoundButton = Left:WaitForChild("SoundButton") :: TextButton
local SoundText = SoundButton:FindFirstChild("Text") :: TextLabel?

local isMuted = false
SoundButton.Activated:Connect(function()
	isMuted = not isMuted
	if isMuted then
		SoundService.Volume = 0
		if SoundText then
			SoundText.Text = "🔇 Silencio"
			SoundText.TextColor3 = Color3.fromRGB(180, 180, 190)
		end
		Notify("🔇 Audio silenciado", Color3.fromRGB(200, 200, 210))
	else
		SoundService.Volume = 1
		if SoundText then
			SoundText.Text = "🔊 Audio"
			SoundText.TextColor3 = Color3.fromRGB(255, 255, 255)
		end
		Notify("🔊 Audio activado", Color3.fromRGB(100, 240, 140))
	end
-- 4. Botón Reclamar Recompensas Offline
local OfflineFrame = PetsGui:FindFirstChild("Offline")
if OfflineFrame then
	local claimBtn = OfflineFrame:FindFirstChild("Claim", true) :: GuiButton?
	if claimBtn then
		claimBtn.Activated:Connect(function()
			OfflineFrame.Visible = false
			Notify("💰 ¡Recompensas offline reclamadas!", Color3.fromRGB(100, 255, 120))
		end)
	end
	local closeBtn = OfflineFrame:FindFirstChild("Close", true) :: GuiButton?
	if closeBtn then
		closeBtn.Activated:Connect(function()
			OfflineFrame.Visible = false
		end)
	end
	local doubleBtn = OfflineFrame:FindFirstChild("Double", true) :: GuiButton?
	if doubleBtn then
		doubleBtn.Activated:Connect(function()
			Notify("⭐ ¡Multiplicador disponible en la tienda!", Color3.fromRGB(255, 215, 0))
		end)
	end
end
local function applyMicroAnimations(btn: GuiObject)
	local scale = btn:FindFirstChildOfClass("UIScale")
	if not scale then
		scale = Instance.new("UIScale")
		scale.Scale = 1
		scale.Parent = btn
	end

	local hoverIn = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local hoverOut = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local pressIn = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	btn.MouseEnter:Connect(function()
		TweenService:Create(scale, hoverIn, { Scale = 1.08 }):Play()
	end)

	btn.MouseLeave:Connect(function()
		TweenService:Create(scale, hoverOut, { Scale = 1.0 }):Play()
	end)

	if btn:IsA("GuiButton") then
		btn.MouseButton1Down:Connect(function()
			TweenService:Create(scale, pressIn, { Scale = 0.94 }):Play()
		end)
		btn.MouseButton1Up:Connect(function()
			TweenService:Create(scale, hoverIn, { Scale = 1.08 }):Play()
		end)
	end
end

for _, item in ipairs(Left:GetChildren()) do
	if item:IsA("GuiObject") and not item:IsA("UIListLayout") then
		applyMicroAnimations(item)
	end
end

for _, item in ipairs(Right:GetChildren()) do
	if item:IsA("GuiObject") and not item:IsA("UIListLayout") then
		applyMicroAnimations(item)
	end
end
