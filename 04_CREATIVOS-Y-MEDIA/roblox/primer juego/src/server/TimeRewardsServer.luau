-- Recompensas por tiempo conectado. Lógica original: RECOMPENSAS_DE_TIEMPO.rbxm (Wheez), reescrita para
-- validar todo en el servidor, usar leaderstats.Money y evitar reclamos duplicados.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

local GiftFolder = ReplicatedStorage:WaitForChild("GiftFolder")
local Gifts = require(GiftFolder:WaitForChild("SharedGiftData"))
local GetData = GiftFolder:WaitForChild("GetData")
local ClaimGift = GiftFolder:WaitForChild("ClaimGift")

local REFRESH_DELAY = 24 * 60 * 60 -- igual que el archivo original: cada 24 h se reinician tiempo y reclamos
local CURRENCY_MAP = { Coins = "Money" } -- "Coins" del archivo original = leaderstats.Money
local Store = DataStoreService:GetDataStore("GiftsDataStore")
local States = {}

local function findGift(number)
	for _, gift in ipairs(Gifts) do
		if gift.GiftNumber == number then
			return gift
		end
	end
	return nil
end

local function totalSeconds(state)
	return state.Old + (os.time() - state.JoinTime)
end

local function refreshIfNeeded(state)
	if os.time() - state.LastRefresh >= REFRESH_DELAY then
		state.Claimed = {}
		state.Old = 0
		state.JoinTime = os.time()
		state.LastRefresh = os.time()
	end
end

local function save(state)
	if not state.CanSave then
		return
	end
	local claimed = {}
	for number in pairs(state.Claimed) do
		table.insert(claimed, number)
	end
	local payload = {
		TotalSession = totalSeconds(state),
		ClaimedGifts = claimed,
		LastRefresh = state.LastRefresh,
	}
	for _ = 1, 3 do
		local ok, err = pcall(function()
			Store:UpdateAsync(state.Key, function()
				return payload
			end)
		end)
		if ok then
			return
		end
		warn("[TimeRewards] No se pudo guardar:", err)
		task.wait(1)
	end
end

local function onPlayerAdded(player)
	if States[player] then
		return
	end
	local state = {
		Key = tostring(player.UserId),
		Old = 0,
		JoinTime = os.time(),
		LastRefresh = os.time(),
		Claimed = {},
		Ready = false,
		CanSave = false,
		Busy = false,
	}
	States[player] = state

	local loaded, data = false, nil
	for _ = 1, 3 do
		local ok, result = pcall(Store.GetAsync, Store, state.Key)
		if ok then
			loaded, data = true, result
			break
		end
		task.wait(1)
	end
	if not player.Parent then
		States[player] = nil
		return
	end

	if loaded then
		state.CanSave = true
		if type(data) == "table" then
			state.Old = tonumber(data.TotalSession) or 0
			state.LastRefresh = tonumber(data.LastRefresh) or os.time()
			for _, number in ipairs(data.ClaimedGifts or {}) do
				local n = tonumber(number)
				if n then
					state.Claimed[n] = true
				end
			end
		end
	else
		-- Sin DataStore (p. ej. Studio sin acceso a la API): se juega con sesión temporal y NO se guarda,
		-- para no pisar el progreso real del jugador.
		warn("[TimeRewards] No se pudieron cargar los datos de", player.Name, "- sesión temporal, sin guardado.")
	end

	state.JoinTime = os.time()
	refreshIfNeeded(state)
	state.Ready = true
end

local function onPlayerRemoving(player)
	local state = States[player]
	States[player] = nil
	if state and state.Ready then
		save(state)
	end
end

GetData.OnServerInvoke = function(player)
	local state = States[player]
	local waited = os.clock()
	while state and not state.Ready and os.clock() - waited < 20 do
		task.wait(0.25)
	end
	if not state or not state.Ready then
		return nil
	end
	refreshIfNeeded(state)
	local claimed = {}
	for number in pairs(state.Claimed) do
		claimed[tostring(number)] = true
	end
	return {
		Total = totalSeconds(state),
		Claimed = claimed,
		RefreshIn = math.max(0, REFRESH_DELAY - (os.time() - state.LastRefresh)),
	}
end

ClaimGift.OnServerInvoke = function(player, giftNumber)
	if typeof(giftNumber) ~= "number" or giftNumber ~= giftNumber then
		return false
	end
	giftNumber = math.floor(giftNumber)
	local state = States[player]
	if not state or not state.Ready or state.Busy then
		return false
	end
	state.Busy = true
	local ok, granted = pcall(function()
		refreshIfNeeded(state)
		if state.Claimed[giftNumber] then
			return false
		end
		local gift = findGift(giftNumber)
		if not gift then
			return false
		end
		if totalSeconds(state) < gift.Time then
			return false
		end
		local leaderstats = player:FindFirstChild("leaderstats")
		local currencyName = CURRENCY_MAP[gift.Reward.Currency] or gift.Reward.Currency
		local currency = leaderstats and leaderstats:FindFirstChild(currencyName)
		if not currency then
			return false
		end
		state.Claimed[giftNumber] = true -- se marca ANTES de pagar: evita doble cobro
		currency.Value += gift.Reward.Amount
		return true
	end)
	state.Busy = false
	if ok and granted then
		task.spawn(save, state)
		return true
	end
	return false
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(onPlayerAdded, player)
end

game:BindToClose(function()
	task.wait(3)
end)
