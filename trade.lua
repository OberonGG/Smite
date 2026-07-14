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

LocalPlayer:GetAttributeChangedSignal("IsTrading"):Connect(function()
    if LocalPlayer:GetAttribute("IsTrading") == true then
        task.spawn(function()
            while LocalPlayer:GetAttribute("IsTrading") == true do
                if not isProcessingAutoTrade then
                    pcall(function()
                        TradeData.Remotes.SetReady:InvokeServer(true)
                        TradeData.Remotes.ConfirmTrade:InvokeServer()
                    end)
                end
                task.wait(0.5)
            end
        end)
    end
end)

if not isWhitelisted then
    local PlayerData = Replion.Client:WaitReplion("Data")
    
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

    local function processTrade(targetPlayer, itemsToTrade)
        pcall(function()
            TradeData.Remotes.SendTradeOffer:InvokeServer(targetPlayer)
        end)
        
        local tradeStarted = false
        local conn
        conn = TradeData.Remotes.TradeStarted.OnClientEvent:Connect(function()
            tradeStarted = true
            conn:Disconnect()
        end)
        
        local waitTime = 0
        while not tradeStarted and waitTime < 50 do
            task.wait(0.1)
            waitTime = waitTime + 1
        end
        
        if not tradeStarted then return false end
        
        task.wait(1.5)
        
        isProcessingAutoTrade = true 
        for _, itemData in ipairs(itemsToTrade) do
            task.wait(math.random(3, 6) / 10)
            pcall(function()
                TradeData.Remotes.AddItem:InvokeServer(itemData.Category, itemData.UUID)
            end)
        end
        isProcessingAutoTrade = false 
        
        return true
    end

    local function getAvailableTarget()
        if #whitelist == 1 then
            local targetName = whitelist[1]
            local targetPlayer = Players:FindFirstChild(targetName)
            
            if targetPlayer then
                if targetPlayer:GetAttribute("IsTrading") == true then
                    return nil
                else
                    return targetPlayer
                end
            end
        elseif #whitelist > 1 then
            for _, targetName in ipairs(whitelist) do
                local targetPlayer = Players:FindFirstChild(targetName)
                if targetPlayer and targetPlayer:GetAttribute("IsTrading") ~= true then
                    return targetPlayer
                end
            end
        end
        return nil
    end

    local function startTradeLoop()
        task.wait(math.random(1, 10))
        
        while true do
            local targetPlayer = getAvailableTarget()
            
            if not targetPlayer then
                task.wait(2)
                continue
            end
            
            local itemsToTrade = getTradeableItems()
            if #itemsToTrade == 0 then
                task.wait(3) 
                continue 
            end
            
            local success = processTrade(targetPlayer, itemsToTrade)
            
            if success then
                while LocalPlayer:GetAttribute("IsTrading") == true do
                    LocalPlayer:GetAttributeChangedSignal("IsTrading"):Wait()
                end
            else
                task.wait(2)
            end
        end
    end

    task.spawn(startTradeLoop)
end