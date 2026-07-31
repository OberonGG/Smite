local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Mengambil modul dari game
local TradeData = require(ReplicatedStorage.Shared.Trading.TradeData)
local Replion = require(ReplicatedStorage.Packages.Replion)
local ItemUtility = require(ReplicatedStorage.Shared.ItemUtility)

local PlayerData = Replion.Client:WaitReplion("Data")

-- Load UI FluentPro
local Fluent = loadstring(game:HttpGet("https://github.com/StyearX/Fluent-modded/releases/download/1.5.5/FluentPro"))()

local Window = Fluent:CreateWindow({
    Title = "Fish it Trade",
    SubTitle = "by Oberon | FluentUI",
    TabWidth = 120,
    Size = UDim2.fromOffset(520, 320),
    Acrylic = true,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Trading = Window:AddTab({ Title = "Trading", Icon = "arrow-right-left" }),
    Utilities = Window:AddTab({ Title = "Utilities", Icon = "settings" })
}

local Options = Fluent.Options

-- ==========================================
-- FUNGSI UTILITAS PENCARIAN INVENTORY
-- ==========================================
local function getInventoryItems()
    local inventory = PlayerData:Get("Inventory") or PlayerData.Data.Inventory
    local runic, evo, secret = {}, {}, {}
    
    if not inventory then return runic, evo, secret end
    
    for categoryName, items in pairs(inventory) do
        if type(items) == "table" then
            for _, item in ipairs(items) do
                local itemData = ItemUtility.GetItemDataFromItemType(categoryName, item.Id)
                if itemData and itemData.Data then
                    -- Cek TradeLocked dan Favorited
                    local isLocked = false
                    if type(item.Metadata) == "table" then
                        if item.Metadata.TradeLock ~= nil or item.Metadata.TradeLocked == true then
                            isLocked = true
                        end
                    end
                    local isFavorited = (item.Favorited == true)
                    
                    if not isLocked and not isFavorited then
                        local id = tonumber(item.Id)
                        local data = {UUID = item.UUID, Category = itemData.Data.Type}
                        
                        if id == 929 then
                            table.insert(runic, data)
                        elseif id == 558 then
                            table.insert(evo, data)
                        elseif itemData.Data.Type == "Fish" then
                            local tier = tonumber(itemData.Data.Tier)
                            if tier == 7 or tier == 8 then
                                table.insert(secret, data)
                            end
                        end
                    end
                end
            end
        end
    end
    return runic, evo, secret
end

local function getTargetItems(targetItemString)
    local runic, evo, secret = getInventoryItems()
    if targetItemString == "Runic Enchant Stone" then return runic
    elseif targetItemString == "Evolved Enchant Stone" then return evo
    elseif targetItemString == "Secret Fish" then return secret
    end
    return {}
end

local function refreshPlayerList()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(list, p.Name)
        end
    end
    if #list == 0 then table.insert(list, "No Players Found") end
    return list
end

-- ==========================================
-- 1. INFORMATION & LOGS
-- ==========================================
local InventoryStatus = Tabs.Trading:AddParagraph({
    Title = "Inventory Status",
    Content = "Waiting for check...\n(e.g., x0 Runic, x0 Evo, x0 Secret)"
})

local TradeLog = Tabs.Trading:AddParagraph({
    Title = "Trade Log",
    Content = "Sent: 0 | Success: 0 | Failed: 0"
})

-- ==========================================
-- 2. ACCORDION: SELECT PLAYER
-- ==========================================
local PlayerSection = Tabs.Trading:AddCollapsibleSection("Select Player", "users", false)

local PlayerDropdown = PlayerSection:AddDropdown("TargetPlayer", {
    Title = "Select Player for Trade",
    Values = refreshPlayerList(), 
    Multi = false,
    Default = 1,
    Search = false 
})

PlayerSection:AddButton({
    Title = "Refresh Player",
    Callback = function()
        PlayerDropdown:SetValues(refreshPlayerList())
        Fluent:Notify({
            Title = "Server Info",
            Content = "Player list refreshed!",
            Duration = 3
        })
    end
})

-- ==========================================
-- 3. ACCORDION: TRADE SETTINGS
-- ==========================================
local TradeSection = Tabs.Trading:AddCollapsibleSection("Trade Settings", "box", true)

local ItemDropdown = TradeSection:AddDropdown("TargetItem", {
    Title = "Select Item",
    Values = {"Runic Enchant Stone", "Evolved Enchant Stone", "Secret Fish"},
    Multi = false,
    Default = 1,
    Search = false 
})

local AmountInput = TradeSection:AddInput("SendAmount", {
    Title = "Amount to Send",
    Default = "1",
    Numeric = true,
    Finished = false,
    Placeholder = "Enter amount here"
})

TradeSection:AddButton({
    Title = "Check Inventory",
    Callback = function()
        local r, e, s = getInventoryItems()
        InventoryStatus:SetDesc(string.format("x%d Runic, x%d Evo, x%d Secret", #r, #e, #s))
        Fluent:Notify({
            Title = "Success",
            Content = "Inventory Checked!",
            Duration = 3
        })
    end
})

local StartToggle = TradeSection:AddToggle("StartTrade", {
    Title = "Start Trade", 
    Default = false 
})

-- Variabel Tracking Trade
local TotalSuccess = 0
local TotalFailed = 0
local isTradingProcess = false

-- LOGIKA PENGIRIM (Sistem Batch & Exact Amount)
StartToggle:OnChanged(function()
    if Options.StartTrade.Value then
        if isTradingProcess then return end
        isTradingProcess = true
        
        task.spawn(function()
            local targetAmount = tonumber(Options.SendAmount.Value) or 1
            local targetName = Options.TargetPlayer.Value
            local selectedItem = Options.TargetItem.Value
            
            TotalSuccess = 0
            TotalFailed = 0
            TradeLog:SetDesc(string.format("Target: %d | Success: %d | Failed: %d", targetAmount, TotalSuccess, TotalFailed))
            
            while Options.StartTrade.Value and TotalSuccess < targetAmount do
                -- 1. Cek apakah target masih ada di server
                local targetPlayer = Players:FindFirstChild(targetName)
                if not targetPlayer then
                    Fluent:Notify({Title = "Error", Content = "Target player left the server!", Duration = 5})
                    StartToggle:SetValue(false)
                    break
                end

                -- 2. Cek ketersediaan barang di inventory
                local availableItems = getTargetItems(selectedItem)
                if #availableItems == 0 then
                    Fluent:Notify({Title = "Out of Stock", Content = "No more items in inventory!", Duration = 5})
                    StartToggle:SetValue(false)
                    break
                end

                -- 3. Siapkan Batch (Max 20 atau sisa dari targetAmount)
                local amountNeeded = targetAmount - TotalSuccess
                local batchSize = math.min(20, amountNeeded, #availableItems)
                local batchItems = {}
                for i = 1, batchSize do
                    table.insert(batchItems, availableItems[i])
                end

                -- 4. Kirim Trade Request (Tunggu target tidak trading)
                if targetPlayer:GetAttribute("IsTrading") == false and LocalPlayer:GetAttribute("IsTrading") == false then
                    pcall(function()
                        TradeData.Remotes.SendTradeOffer:InvokeServer(targetPlayer)
                    end)
                end

                -- Tunggu Trade Started (Timeout 10 detik untuk request)
                local tradeStarted = false
                local waitTime = 0
                while not tradeStarted and waitTime < 10 and Options.StartTrade.Value do
                    if LocalPlayer:GetAttribute("IsTrading") == true then
                        tradeStarted = true
                    end
                    task.wait(0.5)
                    waitTime = waitTime + 0.5
                end

                if not tradeStarted then
                    task.wait(1)
                    continue -- Ulangi kirim offer
                end

                -- 5. Dalam Trade: Masukkan Barang
                task.wait(1.5)
                local itemsAddedCount = 0
                for _, itemData in ipairs(batchItems) do
                    if LocalPlayer:GetAttribute("IsTrading") == false then break end
                    pcall(function()
                        local success = TradeData.Remotes.AddItem:InvokeServer(itemData.Category, itemData.UUID)
                        if success ~= false then itemsAddedCount = itemsAddedCount + 1 end
                    end)
                    task.wait(0.3)
                end

                -- Konfirmasi Trade
                if LocalPlayer:GetAttribute("IsTrading") == true then
                    pcall(function()
                        TradeData.Remotes.SetReady:InvokeServer(true)
                        task.wait(0.2)
                        TradeData.Remotes.ConfirmTrade:InvokeServer()
                    end)
                end

                -- 6. Monitor Trade Selesai atau Stuck (Anti-stuck 30s)
                local tradeFinished = false
                local isSuccess = false
                
                local endConn = TradeData.Remotes.TradeEnded.OnClientEvent:Connect(function() tradeFinished = true end)
                local compConn = TradeData.Remotes.TradeCompleted.OnClientEvent:Connect(function() 
                    tradeFinished = true; isSuccess = true 
                end)
                
                local stuckTimer = 0
                while not tradeFinished and stuckTimer < 30 and LocalPlayer:GetAttribute("IsTrading") == true do
                    task.wait(1)
                    stuckTimer = stuckTimer + 1
                end
                
                endConn:Disconnect()
                compConn:Disconnect()

                -- Logika Anti-Stuck & Kalkulasi Log
                if stuckTimer >= 30 and LocalPlayer:GetAttribute("IsTrading") == true then
                    pcall(function() TradeData.Remotes.CancelTrade:InvokeServer() end)
                    TotalFailed = TotalFailed + itemsAddedCount
                    task.wait(2)
                elseif not isSuccess then
                    TotalFailed = TotalFailed + itemsAddedCount
                else
                    TotalSuccess = TotalSuccess + itemsAddedCount
                end
                
                TradeLog:SetDesc(string.format("Target: %d | Success: %d | Failed: %d", targetAmount, TotalSuccess, TotalFailed))
                
                -- Jeda sebelum trade batch berikutnya
                task.wait(2)
            end
            
            isTradingProcess = false
            if TotalSuccess >= targetAmount then
                Fluent:Notify({Title = "Finished", Content = "Target amount reached successfully!", Duration = 5})
                StartToggle:SetValue(false)
            end
        end)
    else
        isTradingProcess = false
    end
end)

-- ==========================================
-- 4. UTILITIES (AUTO ACCEPT & ANTI-AFK)
-- ==========================================
local AutoAcceptToggle = Tabs.Utilities:AddToggle("AutoAccept", {
    Title = "Auto Accept Trade (Receiver)", 
    Default = false 
})

local AntiAfkToggle = Tabs.Utilities:AddToggle("AntiAfk", {
    Title = "Anti-AFK", 
    Default = false 
})

-- Disable pop-up UI bawaan game
task.spawn(function()
    task.wait(3)
    if getconnections then
        pcall(function()
            for _, conn in pairs(getconnections(TradeData.Remotes.TradeOfferReceived.OnClientEvent)) do
                conn:Disable()
            end
        end)
    end
end)

-- Tahap 1: Bypass UI & Accept Offer
TradeData.Remotes.TradeOfferReceived.OnClientEvent:Connect(function(sender)
    if Options.AutoAccept.Value then
        task.wait(0.2)
        pcall(function()
            TradeData.Remotes.AcceptTradeOffer:InvokeServer(sender)
        end)
    end
end)

-- Tahap 2: Auto Confirm Buta (Hanya jalan jika Auto Accept nyala)
local function watchTradingStateReceiver()
    task.spawn(function()
        local timeStuck = 0
        while LocalPlayer:GetAttribute("IsTrading") == true do
            if not Options.AutoAccept.Value then break end -- Berhenti jika toggle dimatikan di tengah jalan
            
            -- Anti-stuck 30 detik untuk penerima
            if timeStuck >= 30 then
                pcall(function() TradeData.Remotes.CancelTrade:InvokeServer() end)
                task.wait(2)
                break
            end
            
            pcall(function()
                TradeData.Remotes.SetReady:InvokeServer(true)
                task.wait(0.2)
                TradeData.Remotes.ConfirmTrade:InvokeServer()
            end)
            
            task.wait(1)
            timeStuck = timeStuck + 1
        end
    end)
end

LocalPlayer:GetAttributeChangedSignal("IsTrading"):Connect(function()
    if LocalPlayer:GetAttribute("IsTrading") == true and Options.AutoAccept.Value then
        watchTradingStateReceiver()
    end
end)

-- Anti-AFK
AntiAfkToggle:OnChanged(function()
    if getconnections then
        pcall(function()
            for _, connection in pairs(getconnections(LocalPlayer.Idled)) do
                if Options.AntiAfk.Value then
                    connection:Disable()
                else
                    connection:Enable()
                end
            end
        end)
    end
end)

Window:SelectTab(1)
Fluent:Notify({Title = "Fish it Trade", Content = "Loaded successfully!", Duration = 5})
