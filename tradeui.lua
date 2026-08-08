-- ==========================================
-- ORVION | MAIN LOGIC
-- Fish it Trade Hub
-- ==========================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Game modules
local TradeData    = require(ReplicatedStorage.Shared.Trading.TradeData)
local Replion      = require(ReplicatedStorage.Packages.Replion)
local ItemUtility  = require(ReplicatedStorage.Shared.ItemUtility)
local PlayerData   = Replion.Client:WaitReplion("Data")

-- ==========================================
-- LOAD UI LIBRARY FROM GITHUB
-- ==========================================
local CustomLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/KnullXDgt/orvion/refs/heads/main/orvionlibrary.lua"))()

-- ==========================================
-- INVENTORY HELPERS
-- ==========================================

local function refreshPlayerList()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(list, p.Name)
        end
    end
    return list
end

local function getItemsByName(targetName)
    local inventory = PlayerData:Get("Inventory") or PlayerData.Data.Inventory
    local result = {}
    if not inventory then return result end
    for categoryName, items in pairs(inventory) do
        if type(items) == "table" then
            for _, item in ipairs(items) do
                local itemData = ItemUtility.GetItemDataFromItemType(categoryName, item.Id)
                if itemData and itemData.Data and itemData.Data.Type == "Fish" then
                    local name = itemData.Data.Name or tostring(item.Id)
                    if name == targetName then
                        table.insert(result, {UUID = item.UUID, Category = itemData.Data.Type})
                    end
                end
            end
        end
    end
    return result
end

local RARITY_TIER_MAP = {
    Common = 1, Uncommon = 2, Rare = 3, Epic = 4,
    Legendary = 5, Mythic = 6, Secret = 7, Forgotten = 8
}

local function getItemsByRarity(rarityLabel)
    local inventory = PlayerData:Get("Inventory") or PlayerData.Data.Inventory
    local result = {}
    if not inventory then return result end
    local targetTier = RARITY_TIER_MAP[rarityLabel]
    if not targetTier then return result end
    for categoryName, items in pairs(inventory) do
        if type(items) == "table" then
            for _, item in ipairs(items) do
                local itemData = ItemUtility.GetItemDataFromItemType(categoryName, item.Id)
                if itemData and itemData.Data and itemData.Data.Type == "Fish" then
                    local tier = tonumber(itemData.Data.Tier)
                    if tier == targetTier then
                        table.insert(result, {UUID = item.UUID, Category = itemData.Data.Type})
                    end
                end
            end
        end
    end
    return result
end

local function getItemsByStone(stoneName)
    local inventory = PlayerData:Get("Inventory") or PlayerData.Data.Inventory
    local result = {}
    if not inventory then return result end
    for categoryName, items in pairs(inventory) do
        if type(items) == "table" then
            for _, item in ipairs(items) do
                local itemData = ItemUtility.GetItemDataFromItemType(categoryName, item.Id)
                if itemData and itemData.Data then
                    local id = tonumber(item.Id)
                    local dataName = (itemData.Data.Name or ""):lower()
                    local isStone = (id == 929) or (id == 558) or dataName:find("enchant stone", 1, true)
                    if isStone then
                        local displayName = itemData.Data.Name or tostring(item.Id)
                        if displayName == stoneName then
                            table.insert(result, {UUID = item.UUID, Category = itemData.Data.Type})
                        end
                    end
                end
            end
        end
    end
    return result
end

-- ==========================================
-- WINDOW & TOGGLE BUTTON
-- ==========================================
local Window = CustomLib:CreateWindow({
    Title = "Orvion | | Evolving Everyday"
})

local _orvionGui = CoreGui:FindFirstChild("OrvionGui")
local ToggleButton = Instance.new("ImageButton", _orvionGui)
ToggleButton.Name = "OrvionToggleButton"
ToggleButton.Size = UDim2.new(0, 45, 0, 45)
ToggleButton.Position = UDim2.new(0, 15, 0.5, -100)
ToggleButton.BackgroundTransparency = 1
ToggleButton.BorderSizePixel = 0
ToggleButton.ScaleType = Enum.ScaleType.Fit
ToggleButton.Image = "rbxassetid://88499385264699"
ToggleButton.ZIndex = 5

local UICorner2 = Instance.new("UICorner", ToggleButton)
UICorner2.CornerRadius = UDim.new(1, 0)

do
    local dragging2, dragInput2, dragStart2, startPos2
    ToggleButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging2 = true
            dragStart2 = input.Position
            startPos2 = ToggleButton.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging2 = false end
            end)
        end
    end)
    ToggleButton.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput2 = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput2 and dragging2 then
            local delta = input.Position - dragStart2
            ToggleButton.Position = UDim2.new(startPos2.X.Scale, startPos2.X.Offset + delta.X, startPos2.Y.Scale, startPos2.Y.Offset + delta.Y)
        end
    end)
end

local isUiOpen = true
ToggleButton.MouseButton1Click:Connect(function()
    isUiOpen = not isUiOpen
    if CoreGui:FindFirstChild("OrvionGui") then
        local mainFrame = CoreGui.OrvionGui:FindFirstChild("MainFrame")
        if mainFrame then mainFrame.Visible = isUiOpen end
    end
end)

-- ==========================================
-- STATE MANAGEMENT
-- ==========================================
local State = {
    TargetPlayer    = "",
    AutoAccept      = false,
    AntiAfk         = false,

    ByName_Item     = "",
    ByName_Amount   = "1",
    ByName_Running  = false,

    ByRarity_Rarity  = "Common",
    ByRarity_Amount  = "1",
    ByRarity_Running = false,

    ByStone_Stone   = "",
    ByStone_Amount  = "1",
    ByStone_Running = false,
}

-- ==========================================
-- TABS
-- ==========================================
local Tabs = {
    Info          = Window:AddTab("Info"),
    Trading       = Window:AddTab("Trading"),
    Utilities     = Window:AddTab("Utilities"),
}

-- ==========================================
-- INFO TAB
-- ==========================================
local InfoSection = Tabs.Info:AddCollapsibleSection("About Orvion", true)
InfoSection:AddParagraph({
    Title = "What is Orvion?",
    Content = "Orvion is my first Lua scripting project. I made this hub to learn, improve, and try out new ideas. It might not be perfect, but I'll keep making it better with every update.\nAlso huge thanks to idan (Meng Hub) for the UI idea and inspiration, I really appreciate it.",
})

-- ==========================================
-- TRADING TAB
-- ==========================================

local function cancelActiveTrade()
    if LocalPlayer:GetAttribute("IsTrading") == true then
        pcall(function() TradeData.Remotes.CancelTrade:InvokeServer() end)
        pcall(function()
            local GuiControl = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("GuiControl"))
            if LocalPlayer.PlayerGui:FindFirstChild("! Trading") then
                LocalPlayer.PlayerGui["! Trading"].Enabled = false
            end
            GuiControl:Unlock()
            GuiControl:Close()
        end)
        LocalPlayer:SetAttribute("IsTrading", false)
    end
end

local function runTradeLoop(opts)
    local getItemsFn      = opts.getItemsFn
    local statusPara      = opts.statusPara
    local toggleRef       = opts.toggleRef
    local stateRunningKey = opts.stateRunningKey
    local targetAmount    = tonumber(opts.amount) or 1
    local targetName      = opts.targetPlayer

    local totalSent  = 0
    local retryCount = 0
    local success    = 0
    local failed     = 0
    local isStopping = false
    local isAddingItems = false
    isAddingItemsGlobal = false

    local function setStatus(txt)
        statusPara:SetDesc(txt)
    end

    local function stopLoop(reason)
        if isStopping then return end
        isStopping = true
        State[stateRunningKey] = false
        local tog = toggleRef.toggle
        if tog then tog:SetValue(false) end
        if reason then
            CustomLib:Notify("Trade Complete", reason, 5)
        end
        isStopping = false
    end

    setStatus("Retry: 0 | Success: 0 | Failed: 0 | Sent: 0")

    task.spawn(function()
        while State[stateRunningKey] and totalSent < targetAmount do
            local targetPlayer = Players:FindFirstChild(targetName)
            if not targetPlayer then
                stopLoop("Player not found. Trade stopped.")
                break
            end

            local availableItems = getItemsFn()
            if #availableItems == 0 then
                State[stateRunningKey] = false
                isStopping = true
                local tog = toggleRef.toggle
                if tog then tog:SetValue(false) end
                CustomLib:Notify("Trade Complete", string.format("Inventory empty! Total sent: %d item(s).", totalSent), 5)
                isStopping = false
                break
            end

            local amountNeeded = targetAmount - totalSent
            local batchSize = math.min(20, amountNeeded, #availableItems)
            local batchItems = {}
            for i = 1, batchSize do
                table.insert(batchItems, availableItems[i])
            end

            local waitClear = 0
            while (targetPlayer:GetAttribute("IsTrading") == true or LocalPlayer:GetAttribute("IsTrading") == true)
                and waitClear < 10 do
                task.wait(0.5)
                waitClear = waitClear + 0.5
            end
            if not State[stateRunningKey] then break end

            retryCount = retryCount + 1
            setStatus(string.format("Retry: %d | Success: %d | Failed: %d | Sent: %d", retryCount, success, failed, totalSent))

            local tradeFinished = false
            local isSuccess     = false
            local endConn  = TradeData.Remotes.TradeEnded.OnClientEvent:Connect(function()
                tradeFinished = true
            end)
            local compConn = TradeData.Remotes.TradeCompleted.OnClientEvent:Connect(function()
                tradeFinished = true
                isSuccess     = true
            end)

            isAddingItems = true
            isAddingItemsGlobal = true
            local ok, sendSuccess = pcall(function()
                return TradeData.Remotes.SendTradeOffer:InvokeServer(targetPlayer)
            end)

            if not ok or sendSuccess == false then
                endConn:Disconnect()
                compConn:Disconnect()
                failed = failed + 1
                isAddingItems = false
                isAddingItemsGlobal = false
                setStatus(string.format("Retry: %d | Success: %d | Failed: %d | Sent: %d", retryCount, success, failed, totalSent))
                task.wait(2.5)
                continue
            end

            local tradeStarted = false
            local startConn = TradeData.Remotes.TradeStarted.OnClientEvent:Connect(function()
                tradeStarted = true
            end)
            local offerWait = 0
            while not tradeStarted and offerWait < 15 and State[stateRunningKey] do
                task.wait(0.5)
                offerWait = offerWait + 0.5
            end
            startConn:Disconnect()

            if not tradeStarted then
                endConn:Disconnect()
                compConn:Disconnect()
                failed = failed + 1
                isAddingItems = false
                isAddingItemsGlobal = false
                setStatus(string.format("Retry: %d | Success: %d | Failed: %d | Sent: %d", retryCount, success, failed, totalSent))
                task.wait(2.5)
                continue
            end

            task.wait(1.5)

            local itemsAddedCount = 0
            for _, itemData in ipairs(batchItems) do
                if tradeFinished or LocalPlayer:GetAttribute("IsTrading") ~= true then break end
                local okAdd, addResult = pcall(function()
                    return TradeData.Remotes.AddItem:InvokeServer(itemData.Category, itemData.UUID)
                end)
                if okAdd and addResult ~= false then
                    itemsAddedCount = itemsAddedCount + 1
                end
                task.wait(math.random(1, 3) / 8)
            end

            isAddingItems = false
            isAddingItemsGlobal = false

            local waitElapsed = 0
            while not tradeFinished and LocalPlayer:GetAttribute("IsTrading") == true and waitElapsed < 30 do
                task.wait(1)
                waitElapsed = waitElapsed + 1
            end

            endConn:Disconnect()
            compConn:Disconnect()

            if not tradeFinished and LocalPlayer:GetAttribute("IsTrading") == true then
                cancelActiveTrade()
            end

            if isSuccess then
                success   = success + 1
                totalSent = totalSent + itemsAddedCount
            else
                failed = failed + 1
            end

            setStatus(string.format("Retry: %d | Success: %d | Failed: %d | Sent: %d", retryCount, success, failed, totalSent))
            task.wait(3.5)
        end

        if State[stateRunningKey] and totalSent >= targetAmount then
            State[stateRunningKey] = false
            local tog = toggleRef.toggle
            if tog then
                isStopping = true
                tog:SetValue(false)
                isStopping = false
            end
            CustomLib:Notify("Trade Complete", string.format("Done! %d item(s) sent successfully.", totalSent), 5)
        end

        setStatus(string.format("Done -- Retry: %d | Success: %d | Failed: %d | Sent: %d", retryCount, success, failed, totalSent))
    end)

    return function() return isAddingItems end
end

-- ==========================================
-- SECTION 1 â€” SELECT PLAYER
-- ==========================================
local PlayerSection = Tabs.Trading:AddCollapsibleSection("Select Player", false)

local PlayerDropdown = PlayerSection:AddDropdown({
    Title = "Select Player for Trade",
    Values = {},
    DefaultValue = "Select Option",
    Callback = function(v)
        State.TargetPlayer = v
    end
})

PlayerSection:AddButton({
    Title = "Refresh Player",
    Icon = "10088146947",
    Callback = function()
        local list = refreshPlayerList()
        PlayerDropdown:SetValues(list)
        CustomLib:Notify("Player List", "Player list refreshed!", 3)
    end
})

-- ==========================================
-- SECTION 2 â€” TRADE BY NAME
-- ==========================================
local ByNameSection = Tabs.Trading:AddCollapsibleSection("Trade by Name", false)

local ByNameStatus = ByNameSection:AddParagraph({
    Title = "Trade Status",
    Content = "Waiting..."
})

local ByNameDropdown = ByNameSection:AddDropdown({
    Title = "Select Item",
    Values = {},
    DefaultValue = "Select Option",
    Callback = function(v)
        State.ByName_Item = v
    end
})

local ByNameAmountInput = ByNameSection:AddInput({
    Title = "Set Amount",
    Default = "1",
    Placeholder = "Enter amount",
    Callback = function(v)
        State.ByName_Amount = v
    end
})

ByNameSection:AddButton({
    Title = "Refresh Fish Name",
    Icon = "10088146947",
    Callback = function()
        local inventory = PlayerData:Get("Inventory") or PlayerData.Data.Inventory
        local nameCount = {}
        local nameOrder = {}
        if inventory then
            for categoryName, items in pairs(inventory) do
                if type(items) == "table" then
                    for _, item in ipairs(items) do
                        local itemData = ItemUtility.GetItemDataFromItemType(categoryName, item.Id)
                        if itemData and itemData.Data and itemData.Data.Type == "Fish" then
                            local name = itemData.Data.Name or tostring(item.Id)
                            if not nameCount[name] then
                                nameCount[name] = 0
                                table.insert(nameOrder, name)
                            end
                            nameCount[name] = nameCount[name] + 1
                        end
                    end
                end
            end
        end
        table.sort(nameOrder)
        local displayList = {}
        for _, name in ipairs(nameOrder) do
            table.insert(displayList, string.format("%s x%d", name, nameCount[name]))
        end
        ByNameDropdown:SetValues(displayList)
    end
})

local ByNameToggleRef = {}
local ByNameToggle = ByNameSection:AddToggle({
    Title = "Start Trade by Name",
    Default = false,
    Callback = function(state)
        State.ByName_Running = state
        if state then
            if State.TargetPlayer == "" or State.TargetPlayer == "Select Option" then
                CustomLib:Notify("Error", "Please select a player first!", 3)
                ByNameToggleRef.toggle:SetValue(false)
                return
            end
            if State.ByName_Item == "" or State.ByName_Item == "Select Option" then
                CustomLib:Notify("Error", "Please select an item first!", 3)
                ByNameToggleRef.toggle:SetValue(false)
                return
            end
            if State.ByName_Running then
                runTradeLoop({
                    getItemsFn      = function()
                        local cleanName = State.ByName_Item:match("^(.+) x%d+$") or State.ByName_Item
                        return getItemsByName(cleanName)
                    end,
                    statusPara      = ByNameStatus,
                    toggleRef       = ByNameToggleRef,
                    stateRunningKey = "ByName_Running",
                    amount          = State.ByName_Amount,
                    targetPlayer    = State.TargetPlayer,
                })
            end
        else
            if not ByNameToggleRef._isStopping then
                CustomLib:Notify("Trade Stopped", "Trade by Name stopped.", 3)
                cancelActiveTrade()
            end
            State.ByName_Running = false
        end
    end
})
ByNameToggleRef.toggle = ByNameToggle

-- ==========================================
-- SECTION 3 -- TRADE BY RARITIES
-- ==========================================
local ByRaritySection = Tabs.Trading:AddCollapsibleSection("Trade by Rarities", false)

local ByRarityStatus = ByRaritySection:AddParagraph({
    Title = "Trade Status",
    Content = "Waiting..."
})

local ByRarityDropdown = ByRaritySection:AddDropdown({
    Title = "Select Rarity",
    Values = {"Common","Uncommon","Rare","Epic","Legendary","Mythic","Secret","Forgotten"},
    DefaultValue = "Common",
    Callback = function(v)
        State.ByRarity_Rarity = v
    end
})

local ByRarityAmountInput = ByRaritySection:AddInput({
    Title = "Set Amount",
    Default = "1",
    Placeholder = "Enter amount",
    Callback = function(v)
        State.ByRarity_Amount = v
    end
})

local ByRarityToggleRef = {}
local ByRarityToggle = ByRaritySection:AddToggle({
    Title = "Start Trade by Rarities",
    Default = false,
    Callback = function(state)
        State.ByRarity_Running = state
        if state then
            if State.TargetPlayer == "" or State.TargetPlayer == "Select Option" then
                CustomLib:Notify("Error", "Please select a player first!", 3)
                ByRarityToggleRef.toggle:SetValue(false)
                return
            end
            if State.ByRarity_Running then
                runTradeLoop({
                    getItemsFn      = function() return getItemsByRarity(State.ByRarity_Rarity) end,
                    statusPara      = ByRarityStatus,
                    toggleRef       = ByRarityToggleRef,
                    stateRunningKey = "ByRarity_Running",
                    amount          = State.ByRarity_Amount,
                    targetPlayer    = State.TargetPlayer,
                })
            end
        else
            if not ByRarityToggleRef._isStopping then
                CustomLib:Notify("Trade Stopped", "Trade by Rarities stopped.", 3)
                cancelActiveTrade()
            end
            State.ByRarity_Running = false
        end
    end
})
ByRarityToggleRef.toggle = ByRarityToggle

-- ==========================================
-- SECTION 4 â€” TRADE BY ENCHANT STONE
-- ==========================================
local ByStoneSection = Tabs.Trading:AddCollapsibleSection("Trade Enchant Stone", false)

local ByStoneStatus = ByStoneSection:AddParagraph({
    Title = "Trade Status",
    Content = "Waiting..."
})

local ByStoneDropdown = ByStoneSection:AddDropdown({
    Title = "Select Stone",
    Values = {},
    DefaultValue = "Select Option",
    Callback = function(v)
        State.ByStone_Stone = v
    end
})

local ByStoneAmountInput = ByStoneSection:AddInput({
    Title = "Set Amount",
    Default = "1",
    Placeholder = "Enter amount",
    Callback = function(v)
        State.ByStone_Amount = v
    end
})

ByStoneSection:AddButton({
    Title = "Check Enchant Stones",
    Icon = "10088146947",
    Callback = function()
        local inventory = PlayerData:Get("Inventory") or PlayerData.Data.Inventory
        local stoneCount = {}
        local stoneOrder = {}
        if inventory then
            for categoryName, items in pairs(inventory) do
                if type(items) == "table" then
                    for _, item in ipairs(items) do
                        local itemData = ItemUtility.GetItemDataFromItemType(categoryName, item.Id)
                        if itemData and itemData.Data then
                            local id = tonumber(item.Id)
                            local dataName = (itemData.Data.Name or ""):lower()
                            local isStone = (id == 929) or (id == 558) or dataName:find("enchant stone", 1, true)
                            if isStone then
                                local baseName = itemData.Data.Name or tostring(item.Id)
                                if not stoneCount[baseName] then
                                    stoneCount[baseName] = 0
                                    table.insert(stoneOrder, baseName)
                                end
                                stoneCount[baseName] = stoneCount[baseName] + 1
                            end
                        end
                    end
                end
            end
        end
        table.sort(stoneOrder)
        local displayList = {}
        for _, name in ipairs(stoneOrder) do
            table.insert(displayList, string.format("%s x%d", name, stoneCount[name]))
        end
        ByStoneDropdown:SetValues(displayList)
    end
})

local ByStoneToggleRef = {}
local ByStoneToggle = ByStoneSection:AddToggle({
    Title = "Start Trade by Enchant Stone",
    Default = false,
    Callback = function(state)
        State.ByStone_Running = state
        if state then
            if State.TargetPlayer == "" or State.TargetPlayer == "Select Option" then
                CustomLib:Notify("Error", "Please select a player first!", 3)
                ByStoneToggleRef.toggle:SetValue(false)
                return
            end
            if State.ByStone_Stone == "" or State.ByStone_Stone == "Select Option" then
                CustomLib:Notify("Error", "Please select a stone first!", 3)
                ByStoneToggleRef.toggle:SetValue(false)
                return
            end
            if State.ByStone_Running then
                runTradeLoop({
                    getItemsFn      = function()
                        local cleanName = State.ByStone_Stone:match("^(.+) x%d+$") or State.ByStone_Stone
                        return getItemsByStone(cleanName)
                    end,
                    statusPara      = ByStoneStatus,
                    toggleRef       = ByStoneToggleRef,
                    stateRunningKey = "ByStone_Running",
                    amount          = State.ByStone_Amount,
                    targetPlayer    = State.TargetPlayer,
                })
            end
        else
            if not ByStoneToggleRef._isStopping then
                CustomLib:Notify("Trade Stopped", "Trade by Stone stopped.", 3)
                cancelActiveTrade()
            end
            State.ByStone_Running = false
        end
    end
})
ByStoneToggleRef.toggle = ByStoneToggle

-- ==========================================
-- AUTO ACCEPT -- Trading tab
-- ==========================================
local AutoAcceptSection = Tabs.Trading:AddCollapsibleSection("Auto Accept Trade", false)
local AutoAcceptToggleObj = AutoAcceptSection:AddToggle({
    Title = "Auto Accept & Confirm Trade",
    Default = false,
    Callback = function(state)
        State.AutoAccept = state
    end
})

-- ==========================================
-- AUTO ACCEPT LOGIC (event-driven)
-- ==========================================
local isAddingItemsGlobal = false

task.spawn(function()
    task.wait(3)
    if getconnections then
        pcall(function()
            local offerConnections = getconnections(TradeData.Remotes.TradeOfferReceived.OnClientEvent)
            for _, conn in pairs(offerConnections) do
                conn:Disable()
            end
        end)
    end

    TradeData.Remotes.TradeOfferReceived.OnClientEvent:Connect(function(sender)
        if State.AutoAccept then
            task.wait(0.2)
            pcall(function()
                TradeData.Remotes.AcceptTradeOffer:InvokeServer(sender)
            end)
        end
    end)
end)

local _watchRunning = false
local function watchTradingState()
    if _watchRunning then return end
    _watchRunning = true
    task.spawn(function()
        local timeStuck = 0
        while LocalPlayer:GetAttribute("IsTrading") == true do
            if not State.AutoAccept then break end
            if timeStuck >= 30 then
                pcall(function() TradeData.Remotes.CancelTrade:InvokeServer() end)
                task.wait(1)
                cancelActiveTrade()
                break
            end
            if not isAddingItemsGlobal then
                pcall(function()
                    TradeData.Remotes.SetReady:InvokeServer(true)
                    task.wait(0.2)
                    TradeData.Remotes.ConfirmTrade:InvokeServer()
                end)
            end
            task.wait(0.5)
            timeStuck = timeStuck + 0.5
        end
        _watchRunning = false
    end)
end

LocalPlayer:GetAttributeChangedSignal("IsTrading"):Connect(function()
    if LocalPlayer:GetAttribute("IsTrading") == true and State.AutoAccept then
        watchTradingState()
    end
end)

if LocalPlayer:GetAttribute("IsTrading") == true and State.AutoAccept then
    watchTradingState()
end

-- ==========================================
-- UTILITIES TAB
-- ==========================================

-- Ping Timer UI
local _pingGui = Instance.new("ScreenGui")
_pingGui.Name = "PingTimerUI"
_pingGui.Enabled = false
_pingGui.ResetOnSpawn = false
_pingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
_pingGui.Parent = (gethui and gethui()) or CoreGui

local _pingFrame = Instance.new("Frame", _pingGui)
_pingFrame.Size = UDim2.new(0, 220, 0, 40)
_pingFrame.Position = UDim2.new(0.015, 0, 0.165, 0)
_pingFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
_pingFrame.BackgroundTransparency = 0.15
_pingFrame.BorderSizePixel = 0
_pingFrame.Active = true

local _pingCorner = Instance.new("UICorner", _pingFrame)
_pingCorner.CornerRadius = UDim.new(1, 0)

local _pingLabel = Instance.new("TextLabel", _pingFrame)
_pingLabel.Size = UDim2.new(1, 0, 1, 0)
_pingLabel.BackgroundTransparency = 1
_pingLabel.Font = Enum.Font.GothamBold
_pingLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
_pingLabel.TextSize = 16
_pingLabel.Text = "Ping: 0 ms | 0:00:00"

local _pingStartTime = os.time()
task.spawn(function()
    local Stats = game:GetService("Stats")
    while task.wait(1) do
        local ping = 0
        pcall(function()
            ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        end)
        local elapsed = os.time() - _pingStartTime
        local h = math.floor(elapsed / 3600)
        local m = math.floor((elapsed % 3600) / 60)
        local s = elapsed % 60
        _pingLabel.Text = string.format("Ping: %d ms | %d:%02d:%02d", ping, h, m, s)
    end
end)

do
    local _pDragging, _pDragInput, _pDragStart, _pStartPos
    _pingFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            _pDragging = true
            _pDragStart = input.Position
            _pStartPos = _pingFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then _pDragging = false end
            end)
        end
    end)
    _pingFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            _pDragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == _pDragInput and _pDragging then
            local delta = input.Position - _pDragStart
            _pingFrame.Position = UDim2.new(_pStartPos.X.Scale, _pStartPos.X.Offset + delta.X, _pStartPos.Y.Scale, _pStartPos.Y.Offset + delta.Y)
        end
    end)
end

-- 1. Show Real Ping
Tabs.Utilities:AddToggle({
    Title = "Show Real Ping",
    Default = false,
    Callback = function(state)
        _pingGui.Enabled = state
    end
})

-- 2. Reduce Map (Potato Mode)
local _potatoConns = {}
local _potatoModeOn = false
local function disconnectPotato()
    for _, c in ipairs(_potatoConns) do
        pcall(function() c:Disconnect() end)
    end
    table.clear(_potatoConns)
end

local PotatoToggleObj
PotatoToggleObj = Tabs.Utilities:AddToggle({
    Title = "Reduce Map (Potato Mode)",
    Default = false,
    Callback = function(state)
        _potatoModeOn = state
        if not state then disconnectPotato() return end
        local l = game:GetService("Lighting")
        local w = game:GetService("Workspace")
        local p = game:GetService("Players")
        local t = w:FindFirstChildOfClass("Terrain")
        local c = w.CurrentCamera

        local function lockLighting()
            pcall(function()
                l.GlobalShadows = false
                l.Brightness = 2
                l.ClockTime = 0
                l.FogEnd = 100000
                l.OutdoorAmbient = Color3.fromRGB(150, 150, 150)
                l.Ambient = Color3.fromRGB(150, 150, 150)

                if sethiddenproperty then
                    sethiddenproperty(l, "Technology", 2)
                else
                    l.Technology = 2
                end

                for _, v in pairs(l:GetDescendants()) do
                    if v:IsA("Atmosphere") or v:IsA("PostEffect") or v:IsA("Clouds") then
                        v:Destroy()
                    elseif v:IsA("Sky") and v.Name ~= "BlackSkyNoStars" then
                        v:Destroy()
                    end
                end

                if not l:FindFirstChild("BlackSkyNoStars") then
                    local s = Instance.new("Sky")
                    s.Name = "BlackSkyNoStars"
                    s.StarCount = 0
                    s.MoonTextureId = ""
                    s.SunTextureId  = ""
                    s.SkyboxBk = "" s.SkyboxDn = "" s.SkyboxFt = ""
                    s.SkyboxLf = "" s.SkyboxRt = "" s.SkyboxUp = ""
                    s.Parent = l
                end
            end)
        end

        lockLighting()
        table.insert(_potatoConns, l:GetPropertyChangedSignal("ClockTime"):Connect(lockLighting))
        table.insert(_potatoConns, l:GetPropertyChangedSignal("TimeOfDay"):Connect(lockLighting))

        table.insert(_potatoConns, l.ChildAdded:Connect(function(child)
            task.wait()
            if child:IsA("Sky") and child.Name ~= "BlackSkyNoStars" then
                pcall(function() child:Destroy() end)
            elseif child:IsA("Atmosphere") or child:IsA("PostEffect") or child:IsA("Clouds") then
                pcall(function() child:Destroy() end)
            end
        end))

        local function disableWeatherVFX(v)
            pcall(function()
                local n = string.lower(v.Name)
                if v:IsA("ParticleEmitter") or string.find(n, "storm") or string.find(n, "wind")
                    or string.find(n, "snow") or string.find(n, "fog") or string.find(n, "radiant") then
                    v.Enabled = false
                    v:Destroy()
                end
            end)
        end

        if c then
            for _, v in pairs(c:GetDescendants()) do disableWeatherVFX(v) end
            table.insert(_potatoConns, c.DescendantAdded:Connect(disableWeatherVFX))
        end

        if t then
            pcall(function()
                t.WaterWaveSize = 0
                t.WaterTransparency = 1
                t.WaterWaveSpeed = 0
                t.WaterReflectance = 0
            end)
        end

        local function ig(o)
            if not o then return true end
            local n = string.lower(o.Name)
            local pa = o.Parent and string.lower(o.Parent.Name) or ""
            return string.find(n, "rod") or string.find(pa, "rod")
                or string.find(n, "bait") or string.find(pa, "bait")
                or string.find(n, "bobber") or string.find(pa, "bobber")
                or string.find(n, "lure") or string.find(pa, "lure")
        end

        local function opt(i)
            if ig(i) then return end
            pcall(function()
                if i:IsA("BasePart") then
                    i.Material = Enum.Material.SmoothPlastic
                    i.CastShadow = false
                elseif i:IsA("Decal") or i:IsA("Texture") then
                    i.Transparency = 1
                elseif i:IsA("ParticleEmitter") or i:IsA("Trail") or i:IsA("Fire")
                    or i:IsA("Smoke") or i:IsA("Sparkles") or i:IsA("Light") then
                    i.Enabled = false
                elseif i.Name == "DestinationBeam" then
                    pcall(function() i.Enabled = false end)
                    pcall(function() i.Transparency = 1 end)
                end
            end)
        end

        local function blk(ch)
            for _, o in pairs(ch:GetDescendants()) do
                if not ig(o) then
                    pcall(function()
                        if o:IsA("BasePart") then
                            o.Material = Enum.Material.SmoothPlastic
                            o.CastShadow = false
                        elseif o:IsA("SpecialMesh") or o:IsA("CharacterMesh") or o:IsA("Shirt")
                            or o:IsA("Pants") or o:IsA("ShirtGraphic") or o:IsA("Accessory") then
                            o:Destroy()
                        elseif o:IsA("Decal") and o.Name == "face" then
                            o.Transparency = 1
                        end
                    end)
                end
            end
        end

        for _, o in pairs(w:GetDescendants()) do opt(o) end
        table.insert(_potatoConns, w.DescendantAdded:Connect(opt))

        local function sp(pl)
            if pl.Character then blk(pl.Character) end
            table.insert(_potatoConns, pl.CharacterAdded:Connect(function(nc)
                task.wait(1)
                blk(nc)
            end))
        end

        for _, pl in pairs(p:GetPlayers()) do sp(pl) end
        table.insert(_potatoConns, p.PlayerAdded:Connect(sp))
    end
})

-- 3. Anti-AFK
local AntiAfkToggleObj = Tabs.Utilities:AddToggle({
    Title = "Anti-AFK",
    Default = false,
    Callback = function(state)
        State.AntiAfk = state
        pcall(function()
            if getconnections then
                for _, connection in pairs(getconnections(LocalPlayer.Idled)) do
                    if state then
                        connection:Disable()
                    else
                        connection:Enable()
                    end
                end
            end
        end)
    end
})

-- ==========================================
-- CONFIGURATION TAB (via library)
-- ==========================================
Window:AddConfigTab({
    TabName   = "Configuration",
    Folder    = "OrvionFishIt",
    SubFolder = "Config",
    Settings  = {
        {
            Key = "AutoAccept", Type = "toggle",
            Get = function() return State.AutoAccept end,
            Set = function(v) AutoAcceptToggleObj:SetValue(v) end,
        },
        {
            Key = "AntiAfk", Type = "toggle",
            Get = function() return State.AntiAfk end,
            Set = function(v) AntiAfkToggleObj:SetValue(v) end,
        },
        {
            Key = "PotatoMode", Type = "toggle",
            Get = function() return _potatoModeOn end,
            Set = function(v) PotatoToggleObj:SetValue(v) end,
        },
        {
            Key = "TargetPlayer", Type = "dropdown",
            Get = function() return State.TargetPlayer end,
            Set = function(v)
                State.TargetPlayer = v
                PlayerDropdown:SetValue(v)
            end,
        },
        {
            Key = "ByName_Amount", Type = "input",
            Get = function() return State.ByName_Amount end,
            Set = function(v)
                State.ByName_Amount = v
                ByNameAmountInput:SetValue(v)
            end,
        },
        {
            Key = "ByRarity_Rarity", Type = "dropdown",
            Get = function() return State.ByRarity_Rarity end,
            Set = function(v)
                State.ByRarity_Rarity = v
                ByRarityDropdown:SetValue(v)
            end,
        },
        {
            Key = "ByRarity_Amount", Type = "input",
            Get = function() return State.ByRarity_Amount end,
            Set = function(v)
                State.ByRarity_Amount = v
                ByRarityAmountInput:SetValue(v)
            end,
        },
        {
            Key = "ByStone_Stone", Type = "dropdown",
            Get = function() return State.ByStone_Stone end,
            Set = function(v)
                State.ByStone_Stone = v
                ByStoneDropdown:SetValue(v)
            end,
        },
        {
            Key = "ByStone_Amount", Type = "input",
            Get = function() return State.ByStone_Amount end,
            Set = function(v)
                State.ByStone_Amount = v
                ByStoneAmountInput:SetValue(v)
            end,
        },
    },
})