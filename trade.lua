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

-- === Trade session state (fixes the SetReady/ConfirmTrade race) ===
local currentTradeKey = nil
local hasSetReady = false
local hasConfirmed = false
local readyToConfirm = false -- receiver: true immediately. sender: true only after AddItem loop finishes.

local function getTradeReplion()
    if not currentTradeKey then return nil end
    local ok, result = pcall(function()
        return Replion.Client:GetReplion(currentTradeKey)
    end)
    if ok then return result end
    return nil
end

-- Mirrors the client's own anti-scam lock: after PlayersReady, ConfirmTrade is only
-- safe once (LastModifiedTime + ConfirmCountdownTime) has elapsed. If LastModifiedTime
-- changes again mid-wait (offer edited), the wait restarts automatically.
local function waitForConfirmWindow(tradeReplion)
    local countdown = TradeData.ConfirmCountdownTime or 3
    while true do
        local lastModified = tradeReplion:Get("LastModifiedTime")
        if not lastModified then return end
        local remaining = (lastModified + countdown) - workspace:GetServerTimeNow()
        if remaining <= 0 then return end
        task.wait(math.min(remaining, 0.3))
    end
end

if getconnections then
    local offerConnections = getconnections(TradeData.Remotes.TradeOfferReceived.OnClientEvent)
    for _, conn in pairs(offerConnections) do
        conn:Disable()
    end
end

TradeData.Remotes.TradeOfferReceived.OnClientEvent:Connect(function(sender)
    task.wait(0.2)
    if isProcessingAutoTrade then return end
    pcall(function()
        TradeData.Remotes.AcceptTradeOffer:InvokeServer(sender)
    end)
end)

-- Captures the trade session key the moment a trade starts and resets all
-- ready/confirm state for THIS session. Whitelisted (receiver) accounts are
-- allowed to ready immediately; sender accounts stay locked out until their
-- own AddItem loop finishes (set in processTrade below).
TradeData.Remotes.TradeStarted.OnClientEvent:Connect(function(tradeKey)
    currentTradeKey = tradeKey
    hasSetReady = false
    hasConfirmed = false
    readyToConfirm = isWhitelisted
end)

LocalPlayer:GetAttributeChangedSignal("IsTrading"):Connect(function()
    if LocalPlayer:GetAttribute("IsTrading") == true then
        task.spawn(function()
            local timeStuck = 0
            while LocalPlayer:GetAttribute("IsTrading") == true do
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
                    currentTradeKey = nil
                    hasSetReady = false
                    hasConfirmed = false
                    readyToConfirm = false
                    task.wait(1)
                    isProcessingAutoTrade = false
                    break
                end

                -- Only attempt ready/confirm once this account is actually allowed to
                -- (receiver: always; sender: only after items are done being added),
                -- and never while items are mid-add.
                if readyToConfirm and not isProcessingAutoTrade then
                    if not hasSetReady then
                        local ok = pcall(function()
                            TradeData.Remotes.SetReady:InvokeServer(true)
                        end)
                        if ok then
                            hasSetReady = true
                        end
                    elseif not hasConfirmed then
                        local tradeReplion = getTradeReplion()
                        if tradeReplion and tradeReplion:Get("PlayersReady") == true then
                            waitForConfirmWindow(tradeReplion)
                            local ok = pcall(function()
                                TradeData.Remotes.ConfirmTrade:InvokeServer()
                            end)
                            if ok then
                                hasConfirmed = true
                            end
                        end
                    end
                end

                task.wait(0.5)
                timeStuck = timeStuck + 0.5
            end
        end)
    end
end)

if not isWhitelisted then
    local PlayerData = Replion.Client:WaitReplion("Data")

    -- Requested gate: don't start scanning/trading until character + inventory
    -- have actually settled. Waits for character load, then polls inventory item
    -- count until it stops changing for 3 consecutive checks (~4.5s stable).
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

    local function processTrade(targetPlayer)
        local itemsToTrade = getTradeableItems()
        if #itemsToTrade == 0 then
            return false
        end

        task.wait(2)

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
        readyToConfirm = true -- only now is this account allowed to SetReady/ConfirmTrade

        return true
    end

    local function getAvailableTarget()
        if #whitelist == 0 then return nil end

        if #whitelist == 1 then
            local targetName = whitelist[1]
            local targetPlayer = Players:FindFirstChild(targetName)
            if targetPlayer and targetPlayer ~= LocalPlayer and targetPlayer:GetAttribute("IsTrading") ~= true then
                return targetPlayer
            end

        else
            local shuffled = {}
            for _, name in ipairs(whitelist) do
                table.insert(shuffled, name)
            end

            for i = #shuffled, 2, -1 do
                local j = math.random(i)
                shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
            end

            for _, targetName in ipairs(shuffled) do
                local targetPlayer = Players:FindFirstChild(targetName)
                if targetPlayer and targetPlayer ~= LocalPlayer and targetPlayer:GetAttribute("IsTrading") ~= true then
                    return targetPlayer
                end
            end
        end

        return nil
    end

    local function startTradeLoop()
        waitUntilReady()
        task.wait(math.random(1, 10))

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
                local stuckTimer = 0
                while LocalPlayer:GetAttribute("IsTrading") == true and stuckTimer < 80 do
                    task.wait(1)
                    stuckTimer = stuckTimer + 1
                end

                if LocalPlayer:GetAttribute("IsTrading") == true then
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
                        currentTradeKey = nil
                        hasSetReady = false
                        hasConfirmed = false
                        readyToConfirm = false
                    end
                end
            else
                task.wait(2)
            end
        end
    end
    task.spawn(startTradeLoop)
end
