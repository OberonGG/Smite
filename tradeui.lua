local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- logic modul game
local TradeData = require(ReplicatedStorage.Shared.Trading.TradeData)
local Replion = require(ReplicatedStorage.Packages.Replion)
local ItemUtility = require(ReplicatedStorage.Shared.ItemUtility)

local PlayerData = Replion.Client:WaitReplion("Data")

-- logic ui trade
local Fluent = loadstring(game:HttpGet("https://github.com/StyearX/Fluent-modded/releases/download/1.5.5/FluentPro"))()

local Window = Fluent:CreateWindow({
    Title = "Fish it Trade",
    SubTitle = "by Oberon | FluentUI",
    TabWidth = 120,
    Size = UDim2.fromOffset(550, 360),
    Acrylic = false,
    Theme = "AMOLED",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- logic apply custom font & size
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/StyearX/Fluent-modded/refs/heads/main/Addons/InterfaceManager.lua"))()
InterfaceManager:SetLibrary(Fluent)
InterfaceManager:ApplyCustomFont("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)

-- Fungsi tambahan untuk memaksa perbesar ukuran font (TextSize)
task.spawn(function()
    task.wait(0.5) -- Tunggu UI selesai di-render
    if Fluent.GUI then
        local function applySize(inst, depth)
            if depth > 15 then return end
            for _, ch in ipairs(inst:GetChildren()) do
                if ch:IsA("TextLabel") or ch:IsA("TextButton") or ch:IsA("TextBox") then
                    pcall(function()
                        -- Memaksa teks yang ukurannya kecil menjadi lebih besar
                        if ch.TextSize < 16 then
                            ch.TextSize = ch.TextSize + 3
                        end
                    end)
                end
                applySize(ch, depth + 1)
            end
        end
        applySize(Fluent.GUI, 0)
    end
end)

if CoreGui:FindFirstChild("OberonTradeToggle") then
    CoreGui.OberonTradeToggle:Destroy()
end

local ToggleGui = Instance.new("ScreenGui")
ToggleGui.Name = "OberonTradeToggle"
ToggleGui.Parent = CoreGui
ToggleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local ToggleButton = Instance.new("ImageButton")
ToggleButton.Parent = ToggleGui
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Position = UDim2.new(0, 15, 0.5, -100) 
ToggleButton.BackgroundTransparency = 1
ToggleButton.BorderSizePixel = 0
ToggleButton.ScaleType = Enum.ScaleType.Fit
ToggleButton.Image = "rbxassetid://88499385264699"

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = ToggleButton

-- logic draggable
local UserInputService = game:GetService("UserInputService")
local dragging, dragInput, dragStart, startPos

ToggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = ToggleButton.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

ToggleButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        ToggleButton.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X, 
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
    end
end)

local isUiOpen = true
local isDraggingMoved = false

ToggleButton.InputBegan:Connect(function() isDraggingMoved = false end)
ToggleButton.MouseButton1Down:Connect(function() isDraggingMoved = false end)

ToggleButton.MouseButton1Click:Connect(function()
    isUiOpen = not isUiOpen
    if isUiOpen then
        Window:Show()
    else
        Window:Hide()
    end
end)

-- logic tab
local Tabs = {
    Trading = Window:AddTab({ Title = "Trading", Icon = "arrow-right-left" }),
    Utilities = Window:AddTab({ Title = "Utilities", Icon = "settings" })
}
local Options = Fluent.Options

-- logic utility
local function getInventoryItems()
    local inventory = PlayerData:Get("Inventory") or PlayerData.Data.Inventory
    local runic, evo, secret = {}, {}, {}
    
    if not inventory then return runic, evo, secret end
    
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
    elseif targetItemString == "Forgotten & Secret Fish" then return secret
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

-- logic interface trading
local InventoryStatus = Tabs.Trading:AddParagraph({
    Title = "Inventory Status",
    Content = "Waiting for check...\n(e.g., x0 Runic, x0 Evo, x0 Forgotten & Secret Fish)"
})

local TradeLog = Tabs.Trading:AddParagraph({
    Title = "Trade Log",
    Content = "Retry: 0 | Success: 0 | Failed: 0 | Sent: 0"
})

local PlayerSection = Tabs.Trading:AddCollapsibleSection("Select Player", "users", false)
local PlayerDropdown = PlayerSection:AddDropdown("TargetPlayer", {
    Title = "Select Player for Trade",
    Values = {"@username"}, 
    Multi = false,
    Default = 1,
    Search = false 
})
PlayerSection:AddButton({
    Title = "Refresh Player",
    Callback = function()
        PlayerDropdown:SetValues(refreshPlayerList())
        Fluent:Notify({Title = "Server Info", Content = "Player list refreshed!", Duration = 3})
    end
})

local TradeSection = Tabs.Trading:AddCollapsibleSection("Trade Settings", "solar/box-broken", false)
local ItemDropdown = TradeSection:AddDropdown("TargetItem", {
    Title = "Select Item",
    Values = {"Runic Enchant Stone", "Evolved Enchant Stone", "Forgotten & Secret Fish"},
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
        InventoryStatus:SetDesc(string.format("x%d Runic, x%d Evo, x%d Forgotten & Secret Fish", #r, #e, #s))
        Fluent:Notify({Title = "Success", Content = "Inventory Checked!", Duration = 3})
    end
})

local StartToggle = TradeSection:AddToggle("StartTrade", {
    Title = "Start Trade", 
    Default = false 
})

-- logic state
local TotalItemsSuccess = 0
local RetryCount = 0
local SuccessCount = 0
local FailedCount = 0

local isTradingProcess = false
local isAddingItems = false 

-- logic trading
StartToggle:OnChanged(function()
    if Options.StartTrade.Value then
        if Options.TargetPlayer.Value == "@username" or Options.TargetPlayer.Value == "No Players Found" then
            Fluent:Notify({Title = "Error", Content = "Please refresh and select a valid player first!", Duration = 5})
            StartToggle:SetValue(false)
            return
        end
        
        if isTradingProcess then return end
        isTradingProcess = true
        
        task.spawn(function()
            local targetAmount = tonumber(Options.SendAmount.Value) or 1
            local targetName = Options.TargetPlayer.Value
            local selectedItem = Options.TargetItem.Value
            
            TotalItemsSuccess = 0
            RetryCount = 0
            SuccessCount = 0
            FailedCount = 0
            TradeLog:SetDesc(string.format("Retry: %d | Success: %d | Failed: %d | Sent: %d", RetryCount, SuccessCount, FailedCount, TotalItemsSuccess))
            
            Fluent:Notify({Title = "Started", Content = "Trade initiated with " .. targetName, Duration = 3})
            
            while Options.StartTrade.Value and TotalItemsSuccess < targetAmount do
                local targetPlayer = Players:FindFirstChild(targetName)
                if not targetPlayer then
                    Fluent:Notify({Title = "Error", Content = "Target player left the server!", Duration = 5})
                    StartToggle:SetValue(false)
                    break
                end

                local availableItems = getTargetItems(selectedItem)
                if #availableItems == 0 then
                    Fluent:Notify({Title = "Out of Stock", Content = "No more items in inventory!", Duration = 5})
                    StartToggle:SetValue(false)
                    break
                end

                local amountNeeded = targetAmount - TotalItemsSuccess
                local batchSize = math.min(20, amountNeeded, #availableItems)
                local batchItems = {}
                for i = 1, batchSize do
                    table.insert(batchItems, availableItems[i])
                end

                if targetPlayer:GetAttribute("IsTrading") ~= true and LocalPlayer:GetAttribute("IsTrading") ~= true then
                    RetryCount = RetryCount + 1
                    TradeLog:SetDesc(string.format("Retry: %d | Success: %d | Failed: %d | Sent: %d", RetryCount, SuccessCount, FailedCount, TotalItemsSuccess))
                    pcall(function() TradeData.Remotes.SendTradeOffer:InvokeServer(targetPlayer) end)
                end

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
                    FailedCount = FailedCount + 1
                    TradeLog:SetDesc(string.format("Retry: %d | Success: %d | Failed: %d | Sent: %d", RetryCount, SuccessCount, FailedCount, TotalItemsSuccess))
                    task.wait(1)
                    continue 
                end

                local sessionStartTime = tick()

                isAddingItems = true
                task.wait(1.5)
                local itemsAddedCount = 0
                for _, itemData in ipairs(batchItems) do
                    if LocalPlayer:GetAttribute("IsTrading") ~= true then break end
                    pcall(function()
                        local success = TradeData.Remotes.AddItem:InvokeServer(itemData.Category, itemData.UUID)
                        if success ~= false then itemsAddedCount = itemsAddedCount + 1 end
                    end)
                    task.wait(0.3)
                end
                isAddingItems = false 

                local tradeFinished = false
                local isSuccess = false
                
                local endConn = TradeData.Remotes.TradeEnded.OnClientEvent:Connect(function() 
                    tradeFinished = true 
                end)
                local compConn = TradeData.Remotes.TradeCompleted.OnClientEvent:Connect(function() 
                    tradeFinished = true
                    isSuccess = true 
                end)
                
                local stuckTimer = 0
                while not tradeFinished and stuckTimer < 30 and LocalPlayer:GetAttribute("IsTrading") == true do
                    task.wait(1)
                    stuckTimer = stuckTimer + 1
                end
                
                if endConn then endConn:Disconnect() end
                if compConn then compConn:Disconnect() end

                if stuckTimer >= 30 and LocalPlayer:GetAttribute("IsTrading") == true then
                    isAddingItems = true 
                    if (tick() - sessionStartTime) >= 28 then
                        pcall(function() TradeData.Remotes.CancelTrade:InvokeServer() end)
                    end
                    FailedCount = FailedCount + 1
                    task.wait(2.5)
                    isAddingItems = false
                elseif not isSuccess then
                    FailedCount = FailedCount + 1
                else
                    SuccessCount = SuccessCount + 1
                    TotalItemsSuccess = TotalItemsSuccess + itemsAddedCount 
                end
                
                TradeLog:SetDesc(string.format("Retry: %d | Success: %d | Failed: %d | Sent: %d", RetryCount, SuccessCount, FailedCount, TotalItemsSuccess))
                task.wait(2.5)
            end
            
            isTradingProcess = false
            if TotalItemsSuccess >= targetAmount then
                Fluent:Notify({Title = "Finished", Content = "Target amount reached successfully!", Duration = 5})
                StartToggle:SetValue(false)
            end
        end)
    else
        isTradingProcess = false
    end
end)

-- logic anti afk & auto accept
local AutoAcceptToggle = Tabs.Utilities:AddToggle("AutoAccept", {
    Title = "Auto Accept & Confirm Trade", 
    Default = false 
})

local AntiAfkToggle = Tabs.Utilities:AddToggle("AntiAfk", {
    Title = "Anti-AFK", 
    Default = false 
})

local originalTradeConnections = {}
task.spawn(function()
    task.wait(3)
    if getconnections then
        pcall(function()
            originalTradeConnections = getconnections(TradeData.Remotes.TradeOfferReceived.OnClientEvent)
        end)
    end
end)

AutoAcceptToggle:OnChanged(function(state)
    if getconnections then
        pcall(function()
            for _, conn in pairs(originalTradeConnections) do
                if state then
                    conn:Disable()
                else
                    conn:Enable()
                end
            end
        end)
    end
end)

TradeData.Remotes.TradeOfferReceived.OnClientEvent:Connect(function(sender)
    if Options.AutoAccept.Value then
        task.wait(0.2)
        pcall(function() TradeData.Remotes.AcceptTradeOffer:InvokeServer(sender) end)
    end
end)

LocalPlayer:GetAttributeChangedSignal("IsTrading"):Connect(function()
    if LocalPlayer:GetAttribute("IsTrading") == true and Options.AutoAccept.Value then
        task.spawn(function()
            local receiverStartTime = tick()
            local timeStuck = 0
            while LocalPlayer:GetAttribute("IsTrading") == true do
                if not Options.AutoAccept.Value then break end
                
                if timeStuck >= 30 then
                    isAddingItems = true 
                    if (tick() - receiverStartTime) >= 28 then
                        pcall(function() TradeData.Remotes.CancelTrade:InvokeServer() end)
                    end
                    task.wait(2.5)
                    isAddingItems = false
                    break
                end
                
                if not isAddingItems then
                    pcall(function()
                        TradeData.Remotes.SetReady:InvokeServer(true)
                        task.wait(0.2)
                        TradeData.Remotes.ConfirmTrade:InvokeServer()
                    end)
                end
                
                task.wait(0.5) 
                timeStuck = timeStuck + 0.5
            end
        end)
    end
end)

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