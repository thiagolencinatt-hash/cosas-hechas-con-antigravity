--!strict
-- BackgroundMusicClient.luau
-- Controlador de Música de Fondo: Reproduce música amigable, alegre y relajante en bucle continuo.

local SoundService = game:GetService("SoundService")
local ContentProvider = game:GetService("ContentProvider")

-- Lista de pistas amigables y alegres oficiales de Roblox
local TRACKS = {
	"rbxassetid://1843404009", -- Cheerful / friendly ambient
	"rbxassetid://1841398518", -- Gentle playful melody
	"rbxassetid://1838662141", -- Cheerful uplifting
}

local TARGET_VOLUME = 0.22 -- Nivel suave y amigable, no invasivo
local currentTrackIndex = 1

local bgmSound = SoundService:FindFirstChild("FriendlyBGM") :: Sound?
if not bgmSound then
	bgmSound = Instance.new("Sound")
	bgmSound.Name = "FriendlyBGM"
	bgmSound.Looped = false
	bgmSound.Volume = TARGET_VOLUME
	bgmSound.SoundGroup = nil
	bgmSound.Parent = SoundService
end

local isTransitioning = false

local function playTrack(index: number)
	if not bgmSound then return end
	isTransitioning = true

	local trackId = TRACKS[index]
	bgmSound.SoundId = trackId
	bgmSound.Volume = TARGET_VOLUME
	bgmSound.TimePosition = 0

	-- Pre-cargar suavemente
	task.spawn(function()
		pcall(function()
			ContentProvider:PreloadAsync({ bgmSound })
		end)
	end)

	local ok, err = pcall(function()
		bgmSound:Play()
	end)
	if not ok then
		warn("[BackgroundMusic] Error al iniciar pista:", err)
	end

	isTransitioning = false
end

-- Cuando una pista termina naturalmente, pasar a la siguiente
bgmSound.Ended:Connect(function()
	currentTrackIndex = (currentTrackIndex % #TRACKS) + 1
	playTrack(currentTrackIndex)
end)

-- Iniciar música de inmediato
playTrack(currentTrackIndex)

-- Guardián de continuidad: Si se detiene por lag o carga de escena, reiniciar suavemente
task.spawn(function()
	while true do
		task.wait(4)
		if bgmSound and not bgmSound.IsPlaying and not isTransitioning then
			pcall(function()
				bgmSound:Play()
			end)
		end
	end
end)
