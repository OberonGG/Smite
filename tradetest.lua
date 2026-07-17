local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local config = _G.FishItConfig and _G.FishItConfig["Auto Trade"] or {["Whitelist Username"] = {}}
local whitelist = config["Whitelist Username"]
local isWhitelisted = table.find(whitelist, LocalPlayer.Name) ~= nil
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

Players.PlayerAdded:Connect(function(player)
	playerJoinTimes[player.UserId] = tick()
end)

if getconnections then
	local offerConnections = getconnections(TradeData.Remotes.TradeOfferReceived.OnClientEvent)
	for _, conn in pairs(offerConnections) do
		conn:Disable()
	end
end

TradeData.Remotes.TradeOfferReceived.OnClientEvent:Connect(function(sender)
	task.wait(0.2)
	pcall(function()
		TradeData.Remotes.AcceptTradeOffer:InvokeServer(sender)
	end)
end)

TradeData.Remotes.TradeStarted.OnClientEvent:Connect(function()
	readyToConfirm = not sendingActive
end)

LocalPlayer:GetAttributeChangedSignal("IsTrading"):Connect(function()
	if LocalPlayer:GetAttribute("IsTrading") == true then
		task.spawn(function()
			local timeStuck = 0
			while LocalPlayer:GetAttribute("IsTrading") == true do
				if LocalPlayer:GetAttribute("IsTrading") == false then break end
				if timeStuck >= 60 then
					isProcessingAutoTrade = true
					pcall(function() TradeData.Remotes.CancelTrade:InvokeServer() end)
					task.wait(0.5)
					pcall(function()
						local GuiControl = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("GuiControl"))
						if LocalPlayer.PlayerGui:FindFirstChild("! Trading") then
							LocalPlayer.PlayerGui["! Trading"].Enabled = false
						end
						GuiControl:Unlock()
						GuiControl:Close()
					end)
					LocalPlayer:SetAttribute("IsTrading", false)
					readyToConfirm = false
					sendingActive = false
					task.wait(1)
					isProcessingAutoTrade = false
					break
				end
				if readyToConfirm and not isProcessingAutoTrade then
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
end)

if not isWhitelisted then
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
						if isRunic or isSecretOrForgotten or isEvolvedEnchant then
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
		if joinTime and (tick() - joinTime) < 60 then
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
			if targetPlayer and tradeCooldowns[targetPlayer.UserId] and (tick() - tradeCooldowns[targetPlayer.UserId]) < 30 then
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
			if targetPlayer and tradeCooldowns[targetPlayer.UserId] and (tick() - tradeCooldowns[targetPlayer.UserId]) < 30 then
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
			pcall(function()
				TradeData.Remotes.AddItem:InvokeServer(itemData.Category, itemData.UUID)
			end)
		end
		isProcessingAutoTrade = false
		sendingActive = false
		readyToConfirm = true
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
			tradeCooldowns[targetPlayer.UserId] = tick()
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
					pcall(function() TradeData.Remotes.CancelTrade:InvokeServer() end)
					task.wait(0.5)
					if LocalPlayer:GetAttribute("IsTrading") == true then
						pcall(function()
							local GuiControl = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("GuiControl"))
							if LocalPlayer.PlayerGui:FindFirstChild("! Trading") then LocalPlayer.PlayerGui["! Trading"].Enabled = false end
							GuiControl:Unlock()
							GuiControl:Close()
						end)
						LocalPlayer:SetAttribute("IsTrading", false)
						readyToConfirm = false
						sendingActive = false
					end
				end
			else
				task.wait(2)
			end
		end
	end
	task.spawn(startTradeLoop)
end

local LP = LocalPlayer

pcall(function()
	if getconnections then
		for _, connection in pairs(getconnections(LP.Idled)) do
			connection:Disable()
		end
	end
end)
