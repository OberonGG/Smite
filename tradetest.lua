local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
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
local isProcessingAutoTrade = false
local readyToConfirm = false
local sendingActive = false
local isSendingRequest = false
local tradeCooldowns = {}
local playerJoinTimes = {}
local lastTargetIndex = #whitelist > 0 and (LocalPlayer.UserId % #whitelist) or 0

print(("[AutoTrade] SCRIPT LOADED | Name=%s | Enabled=%s | WhitelistCount=%d"):format(LocalPlayer.Name, tostring(isAutoTradeEnabled), #whitelist))

for _, player in ipairs(Players:GetPlayers()) do
	if player ~= LocalPlayer and not playerJoinTimes[player.UserId] then
		playerJoinTimes[player.UserId] = 0
	end
end

Players.PlayerAdded:Connect(function(player)
	playerJoinTimes[player.UserId] = tick()
	print(("[AutoTrade] PlayerAdded: %s"):format(player.Name))
end)

local ourAcceptConnection = nil

local function disableOfferListener()
	if getconnections then
		local ok, err = pcall(function()
			local offerConnections = getconnections(TradeData.Remotes.TradeOfferReceived.OnClientEvent)
			local count = 0
			for _, conn in pairs(offerConnections) do
				if conn ~= ourAcceptConnection then
					conn:Disable()
					count = count + 1
				end
			end
			print(("[AutoTrade] disableOfferListener: disabled %d connection(s)"):format(count))
		end)
		if not ok then
			warn("[AutoTrade] disableOfferListener FAILED: " .. tostring(err))
		end
	else
		warn("[AutoTrade] getconnections NOT AVAILABLE on this executor")
	end
end

disableOfferListener()
task.spawn(function()
	for _ = 1, 40 do
		task.wait(0.5)
		disableOfferListener()
	end
end)

ourAcceptConnection = TradeData.Remotes.TradeOfferReceived.OnClientEvent:Connect(function(sender)
	print(("[AutoTrade] TradeOfferReceived from: %s"):format(sender and sender.Name or "unknown"))
	task.wait(0.2)
	local ok, err = pcall(function()
		TradeData.Remotes.AcceptTradeOffer:InvokeServer(sender)
	end)
	if ok then
		print("[AutoTrade] AcceptTradeOffer InvokeServer call completed (no error)")
	else
		warn("[AutoTrade] AcceptTradeOffer FAILED: " .. tostring(err))
	end
end)

TradeData.Remotes.TradeStarted.OnClientEvent:Connect(function()
	readyToConfirm = not sendingActive
	print("[AutoTrade] TradeStarted event fired, readyToConfirm=" .. tostring(readyToConfirm))
end)

if LocalPlayer:GetAttribute("IsTrading") == true then
	readyToConfirm = not sendingActive
	print("[AutoTrade] IsTrading already TRUE at script load")
end

local function watchTradingState()
	print("[AutoTrade] watchTradingState() STARTED")
	task.spawn(function()
		local timeStuck = 0
		while LocalPlayer:GetAttribute("IsTrading") == true do
			if LocalPlayer:GetAttribute("IsTrading") == false then break end
			if timeStuck >= 60 then
				warn("[AutoTrade] timeStuck >= 60, forcing cancel")
				isProcessingAutoTrade = true
				local cancelConfirmed = false
				for attempt = 1, 3 do
					local ok, success = pcall(function()
						return TradeData.Remotes.CancelTrade:InvokeServer()
					end)
					print(("[AutoTrade] CancelTrade attempt %d: ok=%s success=%s"):format(attempt, tostring(ok), tostring(success)))
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
					warn("[AutoTrade] CancelTrade never confirmed by server, forced IsTrading=false locally")
				end
				readyToConfirm = false
				sendingActive = false
				task.wait(1)
				isProcessingAutoTrade = false
				break
			end
			if not isProcessingAutoTrade then
				local ok, err = pcall(function()
					TradeData.Remotes.SetReady:InvokeServer(true)
					TradeData.Remotes.ConfirmTrade:InvokeServer()
				end)
				if ok then
					print(("[AutoTrade] SetReady+ConfirmTrade sent (t=%.1fs)"):format(timeStuck))
				else
					warn(("[AutoTrade] SetReady/ConfirmTrade FAILED (t=%.1fs): %s"):format(timeStuck, tostring(err)))
				end
			end
			task.wait(0.5)
			timeStuck = timeStuck + 0.5
		end
		print("[AutoTrade] watchTradingState() LOOP ENDED (IsTrading=" .. tostring(LocalPlayer:GetAttribute("IsTrading")) .. ")")
	end)
end

LocalPlayer:GetAttributeChangedSignal("IsTrading"):Connect(function()
	local state = LocalPlayer:GetAttribute("IsTrading")
	print("[AutoTrade] IsTrading changed to: " .. tostring(state))
	if state == true then
		watchTradingState()
	end
end)

if LocalPlayer:GetAttribute("IsTrading") == true then
	watchTradingState()
end

if isAutoTradeEnabled then
	print("[AutoTrade] isAutoTradeEnabled=true, entering sender logic block")
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
		print("[AutoTrade] waitUntilReady() DONE")
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
			if targetPlayer and tradeCooldowns[targetPlayer.UserId] and (tick() - tradeCooldowns[targetPlayer.UserId]) < 15 then
				return nil
			end
			if isTargetReady(targetPlayer) then
				return targetPlayer
			end
			return nil
		end
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
		print("[AutoTrade] processTrade() -> target: " .. targetPlayer.Name)
		if LocalPlayer:GetAttribute("IsTrading") == true then return false end
		if isSendingRequest then return false end
		local itemsToTrade = getTradeableItems()
		print("[AutoTrade] itemsToTrade count: " .. #itemsToTrade)
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
			print(("[AutoTrade] SendTradeOffer attempt %d -> success=%s"):format(attempt, tostring(success)))
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
				print(("[AutoTrade] TradeStarted confirmed on attempt %d"):format(attempt))
				break
			end
			warn(("[AutoTrade] Attempt %d timed out after 20s, no TradeStarted"):format(attempt))
			sendingActive = false
			if attempt < maxAttempts then
				task.wait(2)
			end
		end
		if not tradeStarted then
			sendingActive = false
			warn("[AutoTrade] processTrade FAILED: tradeStarted never confirmed after all attempts")
			return false
		end
		task.wait(1.5)
		isProcessingAutoTrade = true
		for _, itemData in ipairs(itemsToTrade) do
			task.wait(math.random(3, 6) / 10)
			local added = false
			for addAttempt = 1, 3 do
				local ok, addSuccess = pcall(function()
					return TradeData.Remotes.AddItem:InvokeServer(itemData.Category, itemData.UUID)
				end)
				if ok and addSuccess then
					added = true
					break
				end
				if LocalPlayer:GetAttribute("IsTrading") == false then
					break
				end
				task.wait(0.3)
			end
			print(("[AutoTrade] AddItem %s (%s) -> added=%s"):format(itemData.UUID, itemData.Category, tostring(added)))
		end
		isProcessingAutoTrade = false
		sendingActive = false
		readyToConfirm = true
		return true
	end

	local function startTradeLoop()
		print("[AutoTrade] startTradeLoop() STARTED, waiting inventory ready...")
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
			print("[AutoTrade] processTrade result: " .. tostring(success))
			if success then
				local tradeFinished = false
				local endConn = TradeData.Remotes.TradeEnded.OnClientEvent:Connect(function()
					tradeFinished = true
					print("[AutoTrade] TradeEnded event fired")
				end)
				local completeConn = TradeData.Remotes.TradeCompleted.OnClientEvent:Connect(function()
					tradeFinished = true
					print("[AutoTrade] TradeCompleted event fired")
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
					warn("[AutoTrade] Trade wait timeout 60s, forcing cancel")
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
						readyToConfirm = false
						sendingActive = false
					end
				end
				tradeCooldowns[targetPlayer.UserId] = tick()
			else
				tradeCooldowns[targetPlayer.UserId] = tick()
				task.wait(2)
			end
		end
	end
	task.spawn(startTradeLoop)
else
	print("[AutoTrade] isAutoTradeEnabled=false, sender logic SKIPPED (receiver-only mode)")
end

local LP = LocalPlayer

pcall(function()
	if getconnections then
		for _, connection in pairs(getconnections(LP.Idled)) do
			connection:Disable()
		end
	end
end)

print("[AutoTrade] === SCRIPT FULLY INITIALIZED ===")