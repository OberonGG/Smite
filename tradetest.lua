local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Mengambil konfigurasi
local config = _G.FishItConfig and _G.FishItConfig["Auto Trade"] or {["Enabled"] = false, ["Whitelist Username"] = {}, ["Items"] = {}}
local isAutoTradeEnabled = config["Enabled"] == true
local whitelist = config["Whitelist Username"] or {}
local itemFilter = config["Items"] or {}
local wantRunic = itemFilter["Runic"] == true
local wantEvo = itemFilter["Evo"] == true
local wantFishTier = itemFilter["FishTier"] == true

local TradeData = require(ReplicatedStorage.Shared.Trading.TradeData)
local Replion = require(ReplicatedStorage.Packages.Replion)
local ItemUtility = require(ReplicatedStorage.Shared.ItemUtility)

-- Variabel Status
local isProcessingAutoTrade = false
local sendingActive = false
local isSendingRequest = false
local tradeCooldowns = {}
local playerJoinTimes = {}
local lastTargetIndex = #whitelist > 0 and (LocalPlayer.UserId % #whitelist) or 0

-- Mencatat waktu join pemain yang sudah ada di server
for _, player in ipairs(Players:GetPlayers()) do
	if player ~= LocalPlayer and not playerJoinTimes[player.UserId] then
		playerJoinTimes[player.UserId] = 0
	end
end

-- Mencatat waktu join pemain baru (Memberi jeda loading untuk akun stok)
Players.PlayerAdded:Connect(function(player)
	playerJoinTimes[player.UserId] = tick()
end)

-- Mematikan Pop-up UI bawaan game HANYA SEKALI (Mencegah sabotase listener sendiri)
local function disableOfferListener()
	if getconnections then
		pcall(function()
			local offerConnections = getconnections(TradeData.Remotes.TradeOfferReceived.OnClientEvent)
			for _, conn in pairs(offerConnections) do
				conn:Disable()
			end
		end)
	end
end
disableOfferListener()

-- 1. STANDALONE AUTO ACCEPT OFFER (Bypass Pop-up & Terima dari siapapun)
TradeData.Remotes.TradeOfferReceived.OnClientEvent:Connect(function(sender)
	task.wait(0.2)
	pcall(function()
		TradeData.Remotes.AcceptTradeOffer:InvokeServer(sender)
	end)
end)

-- 2. STANDALONE AUTO CONFIRM TRADE UI (Spam SetReady & Confirm tanpa peduli target)
local function watchTradingState()
	task.spawn(function()
		local timeStuck = 0
		while LocalPlayer:GetAttribute("IsTrading") == true do
			if LocalPlayer:GetAttribute("IsTrading") == false then break end
			
			-- Proteksi Anti-Stuck 60 Detik
			if timeStuck >= 60 then
				isProcessingAutoTrade = true
				local cancelConfirmed = false
				for attempt = 1, 3 do
					local ok, success = pcall(function()
						return TradeData.Remotes.CancelTrade:InvokeServer()
					end)
					if ok and success then
						cancelConfirmed = true
						break
					end
					task.wait(0.5)
				end
				pcall(function()
					local GuiControl = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("GuiControl"))
					if LocalPlayer.PlayerGui:FindFirstChild("! Trading") then
						LocalPlayer.PlayerGui["! Trading"].Enabled = false
					end
					GuiControl:Unlock()
					GuiControl:Close()
				end)
				if not cancelConfirmed then
					LocalPlayer:SetAttribute("IsTrading", false)
				end
				sendingActive = false
				task.wait(1)
				isProcessingAutoTrade = false
				break
			end
			
			-- Auto Accept UI Standalone 
			-- (isProcessingAutoTrade akan selalu false bagi akun stok)
			if not isProcessingAutoTrade then
				pcall(function()
					TradeData.Remotes.SetReady:InvokeServer(true)
					TradeData.Remotes.ConfirmTrade:InvokeServer()
				end)
			end
			task.wait(0.5)
			timeStuck = timeStuck + 0.5
		end
	end)
end

LocalPlayer:GetAttributeChangedSignal("IsTrading"):Connect(function()
	if LocalPlayer:GetAttribute("IsTrading") == true then
		watchTradingState()
	end
end)

if LocalPlayer:GetAttribute("IsTrading") == true then
	watchTradingState()
end

-- ==========================================
-- SCRIPT PENGIRIM (TUYUL) - HANYA BERJALAN JIKA ENABLED = TRUE
-- ==========================================
if isAutoTradeEnabled then
	local PlayerData = Replion.Client:WaitReplion("Data")
	local ReplicatedPlayerData = Replion.Client:WaitReplion("ReplicatedPlayerData")

	local function waitUntilReady()
		if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			LocalPlayer.CharacterAdded:Wait()
		end
		task.wait(2)
		local previousCount = -1
		local stableStreak = 0
		while stableStreak < 3 do
			local inventory = PlayerData:Get("Inventory") or PlayerData.Data.Inventory
			local currentCount = 0
			if inventory then
				for _, items in pairs(inventory) do
					if type(items) == "table" then
						currentCount = currentCount + #items
					end
				end
			end
			if currentCount == previousCount then
				stableStreak = stableStreak + 1
			else
				stableStreak = 0
			end
			previousCount = currentCount
			task.wait(1.5)
		end
	end

	local function getTradeableItems()
		local tradeable = {}
		local inventory = PlayerData:Get("Inventory") or PlayerData.Data.Inventory
		if not inventory then return tradeable end
		for categoryName, items in pairs(inventory) do
			if type(items) == "table" then
				for _, item in ipairs(items) do
					local itemData = ItemUtility.GetItemDataFromItemType(categoryName, item.Id)
					if itemData and itemData.Data then
						local isLocked = false
						if type(item.Metadata) == "table" then
							if item.Metadata.TradeLock ~= nil or item.Metadata.TradeLocked == true then
								isLocked = true
							end
						end
						local isFavorited = (item.Favorited == true)
						if isLocked or isFavorited then
							continue
						end
						local id = tonumber(item.Id)
						local isRunic = (id == 929)
						local isEvolvedEnchant = (id == 558)
						local isSecretOrForgotten = false
						if itemData.Data.Type == "Fish" then
							local tier = tonumber(itemData.Data.Tier)
							if tier == 7 or tier == 8 then
								isSecretOrForgotten = true
							end
						end
						local matchesFilter = (isRunic and wantRunic) or (isEvolvedEnchant and wantEvo) or (isSecretOrForgotten and wantFishTier)
						if matchesFilter then
							table.insert(tradeable, {
								UUID = item.UUID,
								Category = itemData.Data.Type
							})
						end
						if #tradeable >= 20 then break end
					end
				end
			end
			if #tradeable >= 20 then break end
		end
		return tradeable
	end

	local function isTargetReady(targetPlayer)
		if not targetPlayer then return false end
		if targetPlayer == LocalPlayer then return false end
		if targetPlayer:GetAttribute("IsTrading") == true then return false end
		
		-- 3. JEDA WAKTU MASUK (Grace Period)
		-- Memberi jeda 80 detik agar akun stok memuat script auto-acceptnya
		local joinTime = playerJoinTimes[targetPlayer.UserId]
		if joinTime and joinTime > 0 and (tick() - joinTime) < 80 then
			return false
		end
		
		local userKey = "User_" .. tostring(targetPlayer.UserId)
		local userData = ReplicatedPlayerData:Get(userKey)
		local tradeSettings = userData and userData.TradeSettings or nil
		if not tradeSettings or not tradeSettings.Trades then
			return false
		end
		return true
	end

	local function getAvailableTarget()
		local count = #whitelist
		if count == 0 then return nil end
		if count == 1 then
			local targetPlayer = Players:FindFirstChild(whitelist[1])
			-- Cek Cooldown untuk menghindari Tunnel Vision
			if targetPlayer and tradeCooldowns[targetPlayer.UserId] and (tick() - tradeCooldowns[targetPlayer.UserId]) < 15 then
				return nil
			end
			if isTargetReady(targetPlayer) then
				return targetPlayer
			end
			return nil
		end
		-- Rotasi Target (Mencegah stuck di username urutan pertama)
		for i = 1, count do
			local index = (lastTargetIndex + i - 1) % count + 1
			local targetPlayer = Players:FindFirstChild(whitelist[index])
			if targetPlayer and tradeCooldowns[targetPlayer.UserId] and (tick() - tradeCooldowns[targetPlayer.UserId]) < 15 then
				continue
			end
			if isTargetReady(targetPlayer) then
				lastTargetIndex = index
				return targetPlayer
			end
		end
		return nil
	end

	local function processTrade(targetPlayer)
		if LocalPlayer:GetAttribute("IsTrading") == true then return false end
		if isSendingRequest then return false end
		
		local itemsToTrade = getTradeableItems()
		if #itemsToTrade == 0 then
			return false
		end
		
		isSendingRequest = true
		task.delay(5, function()
			isSendingRequest = false
		end)
		
		local tradeStarted = false
		local maxAttempts = 3
		for attempt = 1, maxAttempts do
			if LocalPlayer:GetAttribute("IsTrading") == true then break end
			if targetPlayer:GetAttribute("IsTrading") == true then break end
			sendingActive = true
			local success = TradeData.Remotes.SendTradeOffer:InvokeServer(targetPlayer)
			if not success then
				sendingActive = false
				break
			end
			local conn
			conn = TradeData.Remotes.TradeStarted.OnClientEvent:Connect(function()
				tradeStarted = true
			end)
			local waitTime = 0
			while not tradeStarted and waitTime < 20 do
				task.wait(0.1)
				waitTime = waitTime + 0.1
			end
			conn:Disconnect()
			if tradeStarted then
				break
			end
			sendingActive = false
			if attempt < maxAttempts then
				task.wait(2)
			end
		end
		if not tradeStarted then
			sendingActive = false
			return false
		end
		task.wait(1.5)
		isProcessingAutoTrade = true
		for _, itemData in ipairs(itemsToTrade) do
			task.wait(math.random(3, 6) / 10)
			for addAttempt = 1, 3 do
				local ok, addSuccess = pcall(function()
					return TradeData.Remotes.AddItem:InvokeServer(itemData.Category, itemData.UUID)
				end)
				if ok and addSuccess then
					break
				end
				if LocalPlayer:GetAttribute("IsTrading") == false then
					break
				end
				task.wait(0.3)
			end
		end
		isProcessingAutoTrade = false
		sendingActive = false
		return true
	end

	local function startTradeLoop()
		waitUntilReady()
		task.wait(2)
		while true do
			local itemsToTrade = getTradeableItems()
			if #itemsToTrade == 0 then
				task.wait(3)
				continue
			end
			local targetPlayer = getAvailableTarget()
			if not targetPlayer then
				task.wait(2)
				continue
			end
			local success = processTrade(targetPlayer)
			if success then
				local tradeFinished = false
				local endConn = TradeData.Remotes.TradeEnded.OnClientEvent:Connect(function()
					tradeFinished = true
				end)
				local completeConn = TradeData.Remotes.TradeCompleted.OnClientEvent:Connect(function()
					tradeFinished = true
				end)
				local elapsed = 0
				while not tradeFinished and elapsed < 60 do
					if LocalPlayer:GetAttribute("IsTrading") == false then break end
					task.wait(1)
					elapsed = elapsed + 1
				end
				endConn:Disconnect()
				completeConn:Disconnect()
				if elapsed >= 60 and LocalPlayer:GetAttribute("IsTrading") == true then
					local cancelConfirmed = false
					for attempt = 1, 3 do
						local ok, cancelSuccess = pcall(function()
							return TradeData.Remotes.CancelTrade:InvokeServer()
						end)
						if ok and cancelSuccess then
							cancelConfirmed = true
							break
						end
						task.wait(0.5)
					end
					if LocalPlayer:GetAttribute("IsTrading") == true then
						pcall(function()
							local GuiControl = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("GuiControl"))
							if LocalPlayer.PlayerGui:FindFirstChild("! Trading") then LocalPlayer.PlayerGui["! Trading"].Enabled = false end
							GuiControl:Unlock()
							GuiControl:Close()
						end)
						if not cancelConfirmed then
							LocalPlayer:SetAttribute("IsTrading", false)
						end
						sendingActive = false
					end
				end
				-- Menerapkan Cooldown agar script mencari target whitelist yang lain
				tradeCooldowns[targetPlayer.UserId] = tick()
			else
				tradeCooldowns[targetPlayer.UserId] = tick()
				task.wait(2)
			end
		end
	end
	task.spawn(startTradeLoop)
end

-- ==========================================
-- PROTEKSI ANTI-AFK (NON-INPUT, SANGAT AMAN)
-- ==========================================
pcall(function()
	if getconnections then
		for _, connection in pairs(getconnections(LocalPlayer.Idled)) do
			connection:Disable()
		end
	end
end)