local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local baseConfig = _G.FishItConfig and _G.FishItConfig["Auto Trade"] or {["Enabled"] = false, ["Whitelist Username"] = {}, ["Items"] = {}}
local isAutoTradeEnabled = baseConfig["Enabled"] == true
local whitelist = baseConfig["Whitelist Username"] or {}

local TradeData = require(ReplicatedStorage.Shared.Trading.TradeData)
local Replion = require(ReplicatedStorage.Packages.Replion)
local ItemUtility = require(ReplicatedStorage.Shared.ItemUtility)

local playerJoinTimes = {}
local lastTargetIndex = #whitelist > 0 and (LocalPlayer.UserId % #whitelist) or 0

for _, player in ipairs(Players:GetPlayers()) do
	if player ~= LocalPlayer and not playerJoinTimes[player.UserId] then
		playerJoinTimes[player.UserId] = 0
	end
end

Players.PlayerAdded:Connect(function(player)
	playerJoinTimes[player.UserId] = tick()
end)

task.spawn(function()
	task.wait(10)
	if getconnections then
		pcall(function()
			local offerConnections = getconnections(TradeData.Remotes.TradeOfferReceived.OnClientEvent)
			for _, conn in pairs(offerConnections) do
				conn:Disable()
			end
		end)
	end
	
	TradeData.Remotes.TradeOfferReceived.OnClientEvent:Connect(function(sender)
		task.wait(0.2)
		pcall(function()
			TradeData.Remotes.AcceptTradeOffer:InvokeServer(sender)
		end)
	end)
end)

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
		local currentConfig = _G.FishItConfig and _G.FishItConfig["Auto Trade"] or {["Items"] = {}}
		local currentFilter = currentConfig["Items"] or {}
		local wantRunic = currentFilter["Runic"] == true
		local wantEvo = currentFilter["Evo"] == true
		local wantFishTier = currentFilter["FishTier"] == true
		
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
			if isTargetReady(targetPlayer) then
				return targetPlayer
			end
			return nil
		end
		
		for i = 1, count do
			local index = (lastTargetIndex + i - 1) % count + 1
			local targetPlayer = Players:FindFirstChild(whitelist[index])
			if isTargetReady(targetPlayer) then
				lastTargetIndex = index
				return targetPlayer
			end
		end
		return nil
	end

	local function processTrade(targetPlayer, itemsToTrade)
		local startTime = tick()
		local maxDuration = 60
		
		local function checkTimeoutAndCancel()
			if (tick() - startTime) > maxDuration then
				pcall(function() TradeData.Remotes.CancelTrade:InvokeServer() end)
				pcall(function()
					local GuiControl = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("GuiControl"))
					if LocalPlayer.PlayerGui:FindFirstChild("! Trading") then LocalPlayer.PlayerGui["! Trading"].Enabled = false end
					GuiControl:Unlock()
					GuiControl:Close()
				end)
				LocalPlayer:SetAttribute("IsTrading", false)
				return true
			end
			return false
		end

		if LocalPlayer:GetAttribute("IsTrading") == true then return false end

		local tradeStarted = false
		local startConn = TradeData.Remotes.TradeStarted.OnClientEvent:Connect(function()
			tradeStarted = true
		end)

		local okSend, sendResult = pcall(function()
			return TradeData.Remotes.SendTradeOffer:InvokeServer(targetPlayer)
		end)
		
		if not okSend or not sendResult then
			startConn:Disconnect()
			return false
		end

		while not tradeStarted do
			if checkTimeoutAndCancel() then 
				startConn:Disconnect()
				return false 
			end
			task.wait(0.1)
		end
		startConn:Disconnect()

		task.wait(1.5)
		
		for _, itemData in ipairs(itemsToTrade) do
			if checkTimeoutAndCancel() then return false end
			task.wait(math.random(3, 6) / 10) 
			
			for addAttempt = 1, 3 do
				local okAdd, addSuccess = pcall(function()
					return TradeData.Remotes.AddItem:InvokeServer(itemData.Category, itemData.UUID)
				end)
				if okAdd and addSuccess then break end
				if LocalPlayer:GetAttribute("IsTrading") == false then break end
				task.wait(0.3)
			end
		end

		if checkTimeoutAndCancel() then return false end
		task.wait(0.5)
		
		local okReady, readyRes = pcall(function() return TradeData.Remotes.SetReady:InvokeServer(true) end)
		if not okReady or not readyRes then
			checkTimeoutAndCancel()
			return false
		end
		
		if checkTimeoutAndCancel() then return false end
		task.wait(0.5)
		
		local okConfirm, confirmRes = pcall(function() return TradeData.Remotes.ConfirmTrade:InvokeServer() end)
		if not okConfirm or not confirmRes then
			checkTimeoutAndCancel()
			return false
		end

		local tradeFinished = false
		local endConn = TradeData.Remotes.TradeEnded.OnClientEvent:Connect(function() tradeFinished = true end)
		local completeConn = TradeData.Remotes.TradeCompleted.OnClientEvent:Connect(function() tradeFinished = true end)

		while not tradeFinished do
			if checkTimeoutAndCancel() then break end
			task.wait(0.5)
		end
		
		endConn:Disconnect()
		completeConn:Disconnect()
		
		return tradeFinished
	end

	local function startTradeLoop()
		waitUntilReady()
		task.wait(2)
		while true do
			local itemsToTrade = {}
			for retry = 1, 3 do
				itemsToTrade = getTradeableItems()
				if #itemsToTrade > 0 then break end
				task.wait(1)
			end
			
			if #itemsToTrade == 0 then
				task.wait(3)
				continue
			end
			
			local targetPlayer = getAvailableTarget()
			if not targetPlayer then
				task.wait(2)
				continue
			end
			
			processTrade(targetPlayer, itemsToTrade)
			task.wait(1)
		end
	end
	
	task.spawn(startTradeLoop)
end

pcall(function()
	if getconnections then
		for _, connection in pairs(getconnections(LocalPlayer.Idled)) do
			connection:Disable()
		end
	end
end)