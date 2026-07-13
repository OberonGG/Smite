-- ==================================================
-- FULL SCRIPT AUTO TRADE FISH IT (DUAL-ROLE)
-- BYPASS UI + AUTO LOOP INVENTORY + AUTO CONFIRM
-- ==================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local config = _G.FishItConfig and _G.FishItConfig["Auto Trade"] or {["Whitelist Username"] = {}}
local whitelist = config["Whitelist Username"]
local isWhitelisted = table.find(whitelist, LocalPlayer.Name) ~= nil

local TradeData = require(ReplicatedStorage.Shared.Trading.TradeData)
local Replion = require(ReplicatedStorage.Packages.Replion)

if isWhitelisted then
    -- ==========================================
    -- ROLE: PENERIMA (WHITELIST / PENGEPUL)
    -- ==========================================
    
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
                    pcall(function()
                        TradeData.Remotes.SetReady:InvokeServer(true)
                        TradeData.Remotes.ConfirmTrade:InvokeServer()
                    end)
                    task.wait(1)
                end
            end)
        end
    end)

else
    -- ==========================================
    -- ROLE: PENGIRIM (TUYUL / CLONE)
    -- ==========================================
    
    local PlayerData = Replion.Client:WaitReplion("Data")
    
    local function getTradeableItems()
        local tradeable = {}
        local inventory = PlayerData:Get("Inventory") or PlayerData.Data.Inventory
        if not inventory then return tradeable end
        
        for categoryName, categoryData in pairs(inventory) do
            if type(categoryData) == "table" then
                for uuid, item in pairs(categoryData) do
                    local id = tonumber(item.Id) or tonumber(item.ID)
                    local tier = tonumber(item.Tier)
                    
                    local isRunic = (id == 929)
                    local isSecretOrForgotten = (tier == 7 or tier == 8)
                    
                    if isRunic or isSecretOrForgotten then
                        table.insert(tradeable, {
                            UUID = item.UUID or uuid,
                            Category = categoryName
                        })
                    end
                    
                    if #tradeable >= 20 then break end
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
        while not tradeStarted and waitTime < 10 do
            task.wait(1)
            waitTime = waitTime + 1
        end
        
        if not tradeStarted then return false end
        
        for _, itemData in ipairs(itemsToTrade) do
            task.wait(math.random(5, 8) / 10)
            pcall(function()
                TradeData.Remotes.AddItem:InvokeServer(itemData.Category, itemData.UUID, 1)
            end)
        end
        
        task.spawn(function()
            while LocalPlayer:GetAttribute("IsTrading") == true do
                pcall(function()
                    TradeData.Remotes.SetReady:InvokeServer(true)
                    TradeData.Remotes.ConfirmTrade:InvokeServer()
                end)
                task.wait(1)
            end
        end)
        
        return true
    end

    local function startTradeLoop(targetPlayer)
        while task.wait(3) do
            local itemsToTrade = getTradeableItems()
            
            if #itemsToTrade == 0 then
                break 
            end
            
            local success = processTrade(targetPlayer, itemsToTrade)
            
            if success then
                while LocalPlayer:GetAttribute("IsTrading") == true do
                    task.wait(1)
                end
                task.wait(4)
            end
        end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if table.find(whitelist, player.Name) then
            task.spawn(function()
                startTradeLoop(player)
            end)
        end
    end

    Players.PlayerAdded:Connect(function(player)
        if table.find(whitelist, player.Name) then
            task.spawn(function()
                task.wait(3)
                startTradeLoop(player)
            end)
        end
    end)
end