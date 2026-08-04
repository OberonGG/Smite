local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- logic modul game
local TradeData = require(ReplicatedStorage.Shared.Trading.TradeData)
local Replion = require(ReplicatedStorage.Packages.Replion)
local ItemUtility = require(ReplicatedStorage.Shared.ItemUtility)
local PlayerData = Replion.Client:WaitReplion("Data")

-- logic fungsi utilitas bawaan
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

-- ==========================================
-- CUSTOM UI LIBRARY 
-- ==========================================
local CONFIG_FONT_SECTION = 14 
local CONFIG_FONT_GENERAL = 13  
local CONFIG_FONT_DROPDOWN = 12 
local CONFIG_ELEMENT_HEIGHT = 48

local COLOR_WHITE = Color3.fromRGB(255, 255, 255)       
local COLOR_DARK_GRAY = Color3.fromRGB(170, 170, 185)
local COLOR_SIDEBAR_LOG = Color3.fromRGB(200, 200, 215)

local COLOR_SECTION_BG = Color3.fromRGB(35, 35, 45)
local COLOR_INTERACTIVE_BG = Color3.fromRGB(25, 25, 32)

local CustomLib = {}
CustomLib.Assets = {
    Icons = {
        Minimize = "rbxassetid://9886659276",
        Close = "rbxassetid://9886659671",
        Arrow = "rbxassetid://16851841101"
    }
}

function CustomLib:CreateWindow(config)
    config = config or {}
    local titleText = config.Title or "Custom Hub"
    local size = UDim2.fromOffset(470, 270)

    if CoreGui:FindFirstChild("CustomLibGui") then
        CoreGui.CustomLibGui:Destroy()
    end
    if CoreGui:FindFirstChild("CustomLibDropdownOverlay") then
        CoreGui.CustomLibDropdownOverlay:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CustomLibGui"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local DropdownOverlayGui = Instance.new("ScreenGui")
    DropdownOverlayGui.Name = "CustomLibDropdownOverlay"
    DropdownOverlayGui.Parent = CoreGui
    DropdownOverlayGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    DropdownOverlayGui.DisplayOrder = 999

    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Name = "MainFrame"
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    MainFrame.BackgroundTransparency = 0.1
    MainFrame.Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2)
    MainFrame.Size = size
    MainFrame.BorderSizePixel = 0

    local MainCorner = Instance.new("UICorner", MainFrame)
    MainCorner.CornerRadius = UDim.new(0, 8)

    local MainStroke = Instance.new("UIStroke", MainFrame)
    MainStroke.Color = Color3.fromRGB(80, 80, 100)
    MainStroke.LineJoinMode = Enum.LineJoinMode.Round
    MainStroke.Thickness = 1.5
    MainStroke.Transparency = 0

    local ImageWrapper = Instance.new("Frame", MainFrame)
    ImageWrapper.Name = "ImageWrapper"
    ImageWrapper.Size = UDim2.new(1, 0, 1, 0)
    ImageWrapper.BackgroundTransparency = 1
    ImageWrapper.ClipsDescendants = true 
    ImageWrapper.ZIndex = 0
    
    local ImageCorner = Instance.new("UICorner", ImageWrapper)
    ImageCorner.CornerRadius = UDim.new(0, 8) 

    local ThemeImage = Instance.new("ImageLabel", ImageWrapper)
    ThemeImage.Name = "ThemeImage"
    ThemeImage.Size = UDim2.new(0, 305.5, 0, 256.5)
    ThemeImage.Position = UDim2.new(1, -305.5, 1, -256.5)
    ThemeImage.BackgroundTransparency = 1
    ThemeImage.Image = "rbxassetid://108370878353673"
    ThemeImage.ZIndex = 0
    
    local ThemeCorner = Instance.new("UICorner", ThemeImage)
    ThemeCorner.CornerRadius = UDim.new(0, 8)

    local UIGradient = Instance.new("UIGradient", ThemeImage)
    UIGradient.Rotation = 45
    UIGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.6, 0.95),
        NumberSequenceKeypoint.new(1, 0.4)
    })

    local dragging, dragInput, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    local Top = Instance.new("Frame", MainFrame)
    Top.Name = "Top"
    Top.Size = UDim2.new(1, 0, 0, 38)
    Top.BackgroundTransparency = 1
    Top.ZIndex = 2
    
    local DecideFrame = Instance.new("Frame", MainFrame)
    DecideFrame.Name = "DecideFrame"
    DecideFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    DecideFrame.BackgroundTransparency = 0.85
    DecideFrame.Position = UDim2.new(0, 0, 0, 38)
    DecideFrame.Size = UDim2.new(1, 0, 0, 1) 
    DecideFrame.BorderSizePixel = 0
    DecideFrame.ZIndex = 2

    local IconLabel = Instance.new("ImageLabel", Top)
    IconLabel.BackgroundTransparency = 1
    IconLabel.Size = UDim2.new(0, 16, 0, 16) 
    IconLabel.Position = UDim2.new(0, 6, 0.5, 0) 
    IconLabel.AnchorPoint = Vector2.new(0, 0.5)
    IconLabel.Image = "rbxassetid://88499385264699" 
    IconLabel.ScaleType = Enum.ScaleType.Fit
    
    local IconCorner = Instance.new("UICorner", IconLabel)
    IconCorner.CornerRadius = UDim.new(1, 0)

    local TitleLabel = Instance.new("TextLabel", Top)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Position = UDim2.new(0, 28, 0, 9) 
    TitleLabel.Size = UDim2.new(0, 250, 0, 20)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = titleText
    TitleLabel.TextColor3 = COLOR_WHITE
    TitleLabel.TextSize = 13
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local CloseBtn = Instance.new("ImageButton", Top)
    CloseBtn.Size = UDim2.new(0, 18, 0, 18)
    CloseBtn.AnchorPoint = Vector2.new(1, 0.5)
    CloseBtn.Position = UDim2.new(1, -15, 0.5, 0)
    CloseBtn.Image = CustomLib.Assets.Icons.Close
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
        if CoreGui:FindFirstChild("CustomLibDropdownOverlay") then CoreGui.CustomLibDropdownOverlay:Destroy() end
    end)

    local MinBtn = Instance.new("ImageButton", Top)
    MinBtn.Size = UDim2.new(0, 18, 0, 18)
    MinBtn.AnchorPoint = Vector2.new(1, 0.5)
    MinBtn.Position = UDim2.new(1, -45, 0.5, 0)
    MinBtn.Image = CustomLib.Assets.Icons.Minimize
    MinBtn.BackgroundTransparency = 1

    local minimized = false
    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        MainFrame:TweenSize(
            minimized and UDim2.new(0, 470, 0, 38) or size,
            Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.3, true
        )
        if CoreGui:FindFirstChild("CustomLibDropdownOverlay") then CoreGui.CustomLibDropdownOverlay:ClearAllChildren() end
        if MainFrame:FindFirstChild("ActiveDropdown") then MainFrame:FindFirstChild("ActiveDropdown"):Destroy() end
        if MainFrame:FindFirstChild("DropOutsideClick") then MainFrame:FindFirstChild("DropOutsideClick"):Destroy() end
    end)

    local LayersTab = Instance.new("Frame", MainFrame)
    LayersTab.Name = "LayersTab"
    LayersTab.BackgroundColor3 = Color3.fromRGB(13, 13, 20)
    LayersTab.BackgroundTransparency = 0.55
    LayersTab.Position = UDim2.new(0, 0, 0, 39) 
    LayersTab.Size = UDim2.new(0, 120, 1, -39)
    LayersTab.BorderSizePixel = 0
    LayersTab.ZIndex = 2
    local layersCorner = Instance.new("UICorner", LayersTab) 
    layersCorner.CornerRadius = UDim.new(0, 8)
    
    local LayersTabTopCover = Instance.new("Frame", LayersTab)
    LayersTabTopCover.Size = UDim2.new(1, 0, 0, 10)
    LayersTabTopCover.BackgroundColor3 = Color3.fromRGB(13, 13, 20)
    LayersTabTopCover.BackgroundTransparency = 0.55
    LayersTabTopCover.BorderSizePixel = 0
    LayersTabTopCover.ZIndex = 2

    -- [FIX] Diturunkan posisinya dari 8 menjadi 14 agar tidak terlalu mepet ke atas
    local SearchBarFrame = Instance.new("Frame", LayersTab)
    SearchBarFrame.Name = "SearchBarFrame"
    SearchBarFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
    SearchBarFrame.BackgroundTransparency = 0
    SearchBarFrame.Position = UDim2.new(0, 12, 0, 14) 
    SearchBarFrame.Size = UDim2.new(1, -24, 0, 26)
    SearchBarFrame.BorderSizePixel = 0
    local sc = Instance.new("UICorner", SearchBarFrame) sc.CornerRadius = UDim.new(0, 4)
    local sbs = Instance.new("UIStroke", SearchBarFrame) sbs.Color = Color3.fromRGB(60, 60, 75) sbs.Thickness = 1
    
    local SearchInput = Instance.new("TextBox", SearchBarFrame)
    SearchInput.BackgroundTransparency = 1
    SearchInput.Size = UDim2.new(1, 0, 1, 0)
    SearchInput.Position = UDim2.new(0, 0, 0, 0)
    SearchInput.Font = Enum.Font.Gotham
    SearchInput.PlaceholderText = "Search..."
    SearchInput.Text = ""
    SearchInput.TextColor3 = COLOR_WHITE
    SearchInput.TextSize = 12
    SearchInput.TextXAlignment = Enum.TextXAlignment.Center

    -- [FIX] Posisi Y ScrollTab disesuaikan turun menjadi 38 agar rapi di bawah search bar yang lebih kecil
    local ScrollTab = Instance.new("ScrollingFrame", LayersTab)
    ScrollTab.Name = "ScrollTab"
    ScrollTab.BackgroundTransparency = 1
    ScrollTab.Position = UDim2.new(0, 6, 0, 46)
    ScrollTab.Size = UDim2.new(1, -12, 1, -90)
    ScrollTab.CanvasSize = UDim2.new(0, 0, 0, 0)
    ScrollTab.ScrollBarThickness = 0

    
    local TabListLayout = Instance.new("UIListLayout", ScrollTab)
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, 2)
    TabListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ScrollTab.CanvasSize = UDim2.new(0, 0, 0, TabListLayout.AbsoluteContentSize.Y)
    end)

    local PlayerFooter = Instance.new("Frame", LayersTab)
    PlayerFooter.Name = "PlayerFooter"
    PlayerFooter.BackgroundTransparency = 1
    PlayerFooter.Position = UDim2.new(0, 6, 1, -42) 
    PlayerFooter.Size = UDim2.new(1, -12, 0, 38)
    PlayerFooter.BorderSizePixel = 0

    local AvatarContainer = Instance.new("Frame", PlayerFooter)
    AvatarContainer.BackgroundTransparency = 1
    AvatarContainer.Position = UDim2.new(0, 6, 0.5, -2) 
    AvatarContainer.AnchorPoint = Vector2.new(0, 0.5)
    AvatarContainer.Size = UDim2.new(0, 24, 0, 24)

    local AvatarImg = Instance.new("ImageLabel", AvatarContainer)
    AvatarImg.BackgroundTransparency = 1
    AvatarImg.Size = UDim2.new(1, 0, 1, 0)
    AvatarImg.Image = "rbxassetid://0"
    pcall(function()
        local content, isReady = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
        if isReady then AvatarImg.Image = content end
    end)
    local aic = Instance.new("UICorner", AvatarImg) aic.CornerRadius = UDim.new(1, 0)

    local AvatarStroke = Instance.new("UIStroke", AvatarImg)
    AvatarStroke.Color = Color3.fromRGB(120, 120, 135)
    AvatarStroke.Thickness = 1.5
    AvatarStroke.Transparency = 0.2

    local rawName = tostring(LocalPlayer.Name)
    local maskedName = string.sub(rawName, 1, 3) .. "***"

    local WelcomeLabel = Instance.new("TextLabel", PlayerFooter)
    WelcomeLabel.BackgroundTransparency = 1
    WelcomeLabel.Position = UDim2.new(0, 36, 0.5, -2) 
    WelcomeLabel.AnchorPoint = Vector2.new(0, 0.5)
    WelcomeLabel.Size = UDim2.new(1, -40, 0, 16)
    WelcomeLabel.Font = Enum.Font.Gotham
    WelcomeLabel.Text = "Welcome, " .. maskedName
    WelcomeLabel.TextColor3 = Color3.fromRGB(155, 155, 170) 
    WelcomeLabel.TextSize = 10
    WelcomeLabel.TextXAlignment = Enum.TextXAlignment.Left
    WelcomeLabel.TextWrapped = false
    WelcomeLabel.TextTruncate = Enum.TextTruncate.AtEnd

    local Container = Instance.new("Frame", MainFrame)
    Container.Name = "Layers"
    Container.BackgroundTransparency = 1 
    Container.Position = UDim2.new(0, 128, 0, 42)
    Container.Size = UDim2.new(0, 330, 0, 205)
    Container.BorderSizePixel = 0
    Container.ZIndex = 2

    local Window = {}
    local tabs = {}
    local firstTab = true

    function Window:AddTab(tabName)
        local TabButton = Instance.new("TextButton", ScrollTab)
        TabButton.BackgroundColor3 = COLOR_SECTION_BG
        TabButton.BackgroundTransparency = 1 
        TabButton.Size = UDim2.new(1, 0, 0, 26)
        TabButton.Font = Enum.Font.GothamBold
        TabButton.Text = "     " .. tabName
        TabButton.TextColor3 = Color3.fromRGB(160, 160, 175)
        TabButton.TextSize = CONFIG_FONT_GENERAL
        TabButton.TextXAlignment = Enum.TextXAlignment.Left
        TabButton.BorderSizePixel = 0
        local tabCorner = Instance.new("UICorner", TabButton)
        tabCorner.CornerRadius = UDim.new(0, 4)

        local Indicator = Instance.new("Frame", TabButton)
        Indicator.BackgroundColor3 = COLOR_DARK_GRAY 
        Indicator.Size = UDim2.new(0, 5, 0.7, 0) 
        Indicator.AnchorPoint = Vector2.new(0, 0.5)
        Indicator.Position = UDim2.new(0, 0, 0.5, 0)
        Indicator.BorderSizePixel = 0
        Indicator.Visible = false
        local indCorner = Instance.new("UICorner", Indicator) indCorner.CornerRadius = UDim.new(1, 0)

        local TabContent = Instance.new("ScrollingFrame", Container)
        TabContent.Name = "ScrollLayers"
        TabContent.BackgroundTransparency = 1
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabContent.ScrollBarThickness = 2
        TabContent.Visible = false

        TabContent:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
            if MainFrame:FindFirstChild("ActiveDropdown") then MainFrame:FindFirstChild("ActiveDropdown"):Destroy() end
            if MainFrame:FindFirstChild("DropOutsideClick") then MainFrame:FindFirstChild("DropOutsideClick"):Destroy() end
        end)

        local ContentLayout = Instance.new("UIListLayout", TabContent)
        ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ContentLayout.Padding = UDim.new(0, 5)
        ContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        local ContentPadding = Instance.new("UIPadding", TabContent)
        ContentPadding.PaddingLeft = UDim.new(0, 4)
        ContentPadding.PaddingRight = UDim.new(0, 4)
        ContentPadding.PaddingTop = UDim.new(0, 4)

        ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 10)
        end)

        if firstTab then
            TabContent.Visible = true
            TabButton.BackgroundTransparency = 0.4
            TabButton.TextColor3 = COLOR_WHITE
            Indicator.Visible = true
            firstTab = false
        end

        TabButton.MouseButton1Click:Connect(function()
            if MainFrame:FindFirstChild("ActiveDropdown") then MainFrame:FindFirstChild("ActiveDropdown"):Destroy() end
            if MainFrame:FindFirstChild("DropOutsideClick") then MainFrame:FindFirstChild("DropOutsideClick"):Destroy() end
            for _, t in pairs(tabs) do
                t.Content.Visible = false
                t.Button.BackgroundTransparency = 1
                t.Button.TextColor3 = Color3.fromRGB(160, 160, 175)
                t.Indicator.Visible = false
            end
            TabContent.Visible = true
            TabButton.BackgroundTransparency = 0.4
            TabButton.TextColor3 = COLOR_WHITE
            Indicator.Visible = true
        end)

        table.insert(tabs, {Button = TabButton, Indicator = Indicator, Content = TabContent})

        local TabAPI = {}

        local function createElementAPI(parentContainer)
            local ElementAPI = {}

            function ElementAPI:AddParagraph(config)
                config = config or {}
                local ParaFrame = Instance.new("Frame", parentContainer)
                ParaFrame.BackgroundColor3 = COLOR_SECTION_BG
                ParaFrame.BackgroundTransparency = 0.4
                ParaFrame.Size = UDim2.new(1, 0, 0, 0)
                ParaFrame.AutomaticSize = Enum.AutomaticSize.Y
                ParaFrame.BorderSizePixel = 0
                local paraCorner = Instance.new("UICorner", ParaFrame)
                paraCorner.CornerRadius = UDim.new(0, 6)
                local paraStroke = Instance.new("UIStroke", ParaFrame)
                paraStroke.Color = Color3.fromRGB(60, 60, 75)
                paraStroke.Thickness = 1
                paraStroke.Transparency = 0.5

                local paraPadding = Instance.new("UIPadding", ParaFrame)
                paraPadding.PaddingTop = UDim.new(0, 8)
                paraPadding.PaddingBottom = UDim.new(0, 8)
                paraPadding.PaddingLeft = UDim.new(0, 10)
                paraPadding.PaddingRight = UDim.new(0, 10)

                local paraLayout = Instance.new("UIListLayout", ParaFrame)
                paraLayout.SortOrder = Enum.SortOrder.LayoutOrder
                paraLayout.Padding = UDim.new(0, 4)
                paraLayout.FillDirection = Enum.FillDirection.Vertical

                local Title = Instance.new("TextLabel", ParaFrame)
                Title.LayoutOrder = 1
                Title.BackgroundTransparency = 1
                Title.Size = UDim2.new(1, 0, 0, 20)
                Title.Font = Enum.Font.GothamBold
                Title.Text = config.Title or "Title"
                Title.TextColor3 = COLOR_WHITE
                Title.TextSize = CONFIG_FONT_SECTION
                Title.TextXAlignment = Enum.TextXAlignment.Left

                local Desc = Instance.new("TextLabel", ParaFrame)
                Desc.LayoutOrder = 2
                Desc.BackgroundTransparency = 1
                Desc.Size = UDim2.new(1, 0, 0, 0)
                Desc.AutomaticSize = Enum.AutomaticSize.Y
                Desc.Font = Enum.Font.Gotham
                Desc.Text = config.Content or "Content"
                Desc.TextColor3 = COLOR_SIDEBAR_LOG
                Desc.TextSize = CONFIG_FONT_GENERAL
                Desc.TextXAlignment = Enum.TextXAlignment.Left
                Desc.TextYAlignment = Enum.TextYAlignment.Top
                Desc.TextWrapped = true

                local f = {}
                function f:SetDesc(txt) Desc.Text = txt end
                return f
            end

            function ElementAPI:AddButton(config)
                config = config or {}
                
                local Btn = Instance.new("TextButton", parentContainer)
                Btn.BackgroundColor3 = COLOR_SECTION_BG 
                Btn.BackgroundTransparency = 0.4        
                Btn.Size = UDim2.new(1, 0, 0, CONFIG_ELEMENT_HEIGHT)
                Btn.Text = ""                           
                Btn.AutoButtonColor = true              
                Btn.BorderSizePixel = 0
                local bc = Instance.new("UICorner", Btn) 
                bc.CornerRadius = UDim.new(0, 6)
                local bcs = Instance.new("UIStroke", Btn) bcs.Color = Color3.fromRGB(60, 60, 75) bcs.Thickness = 1 bcs.Transparency = 0.5

                local Title = Instance.new("TextLabel", Btn)
                Title.BackgroundTransparency = 1
                Title.Position = UDim2.new(0, 10, 0, 0) 
                Title.Size = UDim2.new(1, -40, 1, 0) 
                Title.Font = Enum.Font.GothamBold
                Title.Text = config.Title or "Button"
                Title.TextColor3 = COLOR_WHITE
                Title.TextSize = CONFIG_FONT_GENERAL
                Title.TextXAlignment = Enum.TextXAlignment.Left

                if config.Icon then
                    local iconId = config.Icon
                    if string.match(iconId, "rbxassetid://(%d+)") then
                        local extractedId = string.match(iconId, "rbxassetid://(%d+)")
                        iconId = "rbxthumb://type=Asset&id=" .. extractedId .. "&w=150&h=150"
                    elseif string.match(iconId, "^%d+$") then
                        iconId = "rbxthumb://type=Asset&id=" .. iconId .. "&w=150&h=150"
                    end

                    local BtnIcon = Instance.new("ImageLabel", Btn)
                    BtnIcon.BackgroundTransparency = 1
                    BtnIcon.AnchorPoint = Vector2.new(1, 0.5)
                    BtnIcon.Position = UDim2.new(1, -12, 0.5, 0)
                    BtnIcon.Size = UDim2.new(0, 15, 0, 15) 
                    BtnIcon.Image = iconId
                    BtnIcon.ScaleType = Enum.ScaleType.Fit
                end

                Btn.MouseButton1Click:Connect(function()
                    if config.Callback then pcall(config.Callback) end
                end)
            end

            function ElementAPI:AddToggle(config)
                config = config or {}
                local ToggleFrame = Instance.new("Frame", parentContainer)
                ToggleFrame.BackgroundColor3 = COLOR_SECTION_BG
                ToggleFrame.BackgroundTransparency = 0.4
                ToggleFrame.Size = UDim2.new(1, 0, 0, CONFIG_ELEMENT_HEIGHT)
                ToggleFrame.BorderSizePixel = 0
                local tfc = Instance.new("UICorner", ToggleFrame) tfc.CornerRadius = UDim.new(0, 6)
                local tfcs = Instance.new("UIStroke", ToggleFrame) tfcs.Color = Color3.fromRGB(60, 60, 75) tfcs.Thickness = 1 tfcs.Transparency = 0.5

                local Title = Instance.new("TextLabel", ToggleFrame)
                Title.BackgroundTransparency = 1
                Title.Position = UDim2.new(0, 10, 0, 0)
                Title.Size = UDim2.new(1, -55, 1, 0)
                Title.Font = Enum.Font.GothamBold
                Title.Text = config.Title or "Toggle"
                Title.TextColor3 = COLOR_WHITE
                Title.TextSize = CONFIG_FONT_GENERAL
                Title.TextXAlignment = Enum.TextXAlignment.Left

                local SwitchBg = Instance.new("Frame", ToggleFrame)
                SwitchBg.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
                SwitchBg.Position = UDim2.new(1, -38, 0.5, -9)
                SwitchBg.Size = UDim2.new(0, 32, 0, 18)
                local sbc = Instance.new("UICorner", SwitchBg) sbc.CornerRadius = UDim.new(1, 0)

                local Knob = Instance.new("Frame", SwitchBg)
                Knob.BackgroundColor3 = COLOR_WHITE
                Knob.Position = UDim2.new(0, 2, 0.5, -7)
                Knob.Size = UDim2.new(0, 14, 0, 14)
                local kc = Instance.new("UICorner", Knob) kc.CornerRadius = UDim.new(1, 0)

                local state = config.Default == true
                local function updateVisual(anim)
                    if state then
                        SwitchBg.BackgroundColor3 = COLOR_DARK_GRAY
                        Knob.BackgroundColor3 = COLOR_WHITE
                        if anim then TweenService:Create(Knob, TweenInfo.new(0.15), {Position = UDim2.new(1, -16, 0.5, -7)}):Play()
                        else Knob.Position = UDim2.new(1, -16, 0.5, -7) end
                    else
                        SwitchBg.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
                        Knob.BackgroundColor3 = COLOR_WHITE
                        if anim then TweenService:Create(Knob, TweenInfo.new(0.15), {Position = UDim2.new(0, 2, 0.5, -7)}):Play()
                        else Knob.Position = UDim2.new(0, 2, 0.5, -7) end
                    end
                end
                updateVisual(false)

                local btn = Instance.new("TextButton", ToggleFrame)
                btn.BackgroundTransparency = 1
                btn.Size = UDim2.new(1, 0, 1, 0)
                btn.Text = ""

                btn.MouseButton1Click:Connect(function()
                    state = not state
                    updateVisual(true)
                    if config.Callback then pcall(config.Callback, state) end
                end)

                local tAPI = {}
                function tAPI:SetValue(val)
                    state = val
                    updateVisual(true)
                    if config.Callback then pcall(config.Callback, state) end
                end
                return tAPI
            end

            function ElementAPI:AddInput(config)
                config = config or {}
                local InputFrame = Instance.new("Frame", parentContainer)
                InputFrame.BackgroundColor3 = COLOR_SECTION_BG
                InputFrame.BackgroundTransparency = 0.4
                InputFrame.Size = UDim2.new(1, 0, 0, 64)
                InputFrame.BorderSizePixel = 0
                local ifc = Instance.new("UICorner", InputFrame) ifc.CornerRadius = UDim.new(0, 6)
                local ifcs = Instance.new("UIStroke", InputFrame) ifcs.Color = Color3.fromRGB(60, 60, 75) ifcs.Thickness = 1 ifcs.Transparency = 0.5

                local Title = Instance.new("TextLabel", InputFrame)
                Title.BackgroundTransparency = 1
                Title.Position = UDim2.new(0, 10, 0, 6)
                Title.Size = UDim2.new(1, -20, 0, 20)
                Title.Font = Enum.Font.GothamBold
                Title.Text = config.Title or "Input"
                Title.TextColor3 = COLOR_WHITE
                Title.TextSize = CONFIG_FONT_GENERAL
                Title.TextXAlignment = Enum.TextXAlignment.Left

                local TextBoxBg = Instance.new("Frame", InputFrame)
                TextBoxBg.BackgroundColor3 = COLOR_INTERACTIVE_BG 
                TextBoxBg.BackgroundTransparency = 0.2
                TextBoxBg.Position = UDim2.new(0, 10, 0, 31)
                TextBoxBg.Size = UDim2.new(1, -20, 0, 26)
                TextBoxBg.BorderSizePixel = 0
                local tbc = Instance.new("UICorner", TextBoxBg) tbc.CornerRadius = UDim.new(0, 4)

                local TextBox = Instance.new("TextBox", TextBoxBg)
                TextBox.BackgroundTransparency = 1
                TextBox.Position = UDim2.new(0, 8, 0, 0)
                TextBox.Size = UDim2.new(1, -16, 1, 0)
                TextBox.Font = Enum.Font.GothamBold
                TextBox.Text = config.Default or ""
                TextBox.PlaceholderText = config.Placeholder or "Enter..."
                TextBox.TextColor3 = COLOR_WHITE
                TextBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 165)
                TextBox.TextSize = CONFIG_FONT_GENERAL
                TextBox.TextXAlignment = Enum.TextXAlignment.Left
                TextBox.BorderSizePixel = 0

                TextBox.FocusLost:Connect(function()
                    if config.Callback then pcall(config.Callback, TextBox.Text) end
                end)

                local iAPI = {}
                function iAPI:GetValue() return TextBox.Text end
                return iAPI
            end

            function ElementAPI:AddDropdown(config)
                config = config or {}
                local DropFrame = Instance.new("Frame", parentContainer)
                DropFrame.BackgroundColor3 = COLOR_SECTION_BG
                DropFrame.BackgroundTransparency = 0.4
                DropFrame.Size = UDim2.new(1, 0, 0, CONFIG_ELEMENT_HEIGHT)
                DropFrame.BorderSizePixel = 0
                local dfc = Instance.new("UICorner", DropFrame) dfc.CornerRadius = UDim.new(0, 6)
                local dfcs = Instance.new("UIStroke", DropFrame) dfcs.Color = Color3.fromRGB(60, 60, 75) dfcs.Thickness = 1 dfcs.Transparency = 0.5

                local Title = Instance.new("TextLabel", DropFrame)
                Title.BackgroundTransparency = 1
                Title.Position = UDim2.new(0, 10, 0, 10) 
                Title.Size = UDim2.new(0.45, 0, 1, 0) 
                Title.Font = Enum.Font.GothamBold
                Title.Text = config.Title or "Dropdown"
                Title.TextColor3 = COLOR_WHITE
                Title.TextSize = CONFIG_FONT_GENERAL
                Title.TextXAlignment = Enum.TextXAlignment.Left
                Title.TextYAlignment = Enum.TextYAlignment.Top 

                local SelectBox = Instance.new("Frame", DropFrame)
                SelectBox.BackgroundColor3 = COLOR_INTERACTIVE_BG
                SelectBox.BackgroundTransparency = 0.2
                SelectBox.Size = UDim2.new(0.48, 0, 0, 26)
                SelectBox.Position = UDim2.new(1, -4, 0.5, 0)
                SelectBox.AnchorPoint = Vector2.new(1, 0.5)
                SelectBox.BorderSizePixel = 0
                local sbc = Instance.new("UICorner", SelectBox) sbc.CornerRadius = UDim.new(0, 4)
                
                local selectedVal = config.DefaultValue or "Select Option"
                
                local SelectLabel = Instance.new("TextLabel", SelectBox)
                SelectLabel.BackgroundTransparency = 1
                SelectLabel.Size = UDim2.new(1, -26, 1, 0)
                SelectLabel.Position = UDim2.new(0, 8, 0, 0)
                SelectLabel.Font = Enum.Font.GothamBold
                SelectLabel.Text = tostring(selectedVal)
                SelectLabel.TextColor3 = COLOR_SIDEBAR_LOG 
                SelectLabel.TextSize = CONFIG_FONT_DROPDOWN
                SelectLabel.TextXAlignment = Enum.TextXAlignment.Left
                SelectLabel.BorderSizePixel = 0

                local DropArrow = Instance.new("ImageLabel", SelectBox)
                DropArrow.BackgroundTransparency = 1
                DropArrow.AnchorPoint = Vector2.new(1, 0.5)
                DropArrow.Position = UDim2.new(1, -4, 0.5, 0)
                DropArrow.Size = UDim2.new(0, 24, 0, 24)
                DropArrow.Image = CustomLib.Assets.Icons.Arrow
                DropArrow.ImageTransparency = 0.4
                DropArrow.Rotation = 0

                local SelectBtn = Instance.new("TextButton", SelectBox)
                SelectBtn.BackgroundTransparency = 1
                SelectBtn.Size = UDim2.new(1, 0, 1, 0)
                SelectBtn.Text = ""

                local function closeDropdown()
                    local existing = MainFrame:FindFirstChild("ActiveDropdown")
                    if existing then existing:Destroy() end
                    local oc = MainFrame:FindFirstChild("DropOutsideClick")
                    if oc then oc:Destroy() end
                end

                SelectBtn.MouseButton1Click:Connect(function()
                    if MainFrame:FindFirstChild("ActiveDropdown") then
                        closeDropdown()
                        return
                    end

                    local OutsideClick = Instance.new("TextButton", MainFrame)
                    OutsideClick.Name = "DropOutsideClick"
                    OutsideClick.Size = UDim2.new(1, 0, 1, 0)
                    OutsideClick.BackgroundTransparency = 1
                    OutsideClick.Text = ""
                    OutsideClick.ZIndex = 9
                    OutsideClick.MouseButton1Click:Connect(function()
                        closeDropdown()
                    end)

                    local popStartY = 42
                    local popHeight = MainFrame.AbsoluteSize.Y - popStartY - 4
                    local PopFrame = Instance.new("ScrollingFrame", MainFrame)
                    PopFrame.Name = "ActiveDropdown"
                    PopFrame.BackgroundColor3 = COLOR_INTERACTIVE_BG
                    PopFrame.BackgroundTransparency = 0.05
                    PopFrame.Position = UDim2.new(0, 296, 0, popStartY)
                    PopFrame.Size = UDim2.new(0, 162, 0, popHeight)
                    PopFrame.CanvasSize = UDim2.new(0, 0, 0, #(config.Values or {}) * 36)
                    PopFrame.ScrollBarThickness = 2
                    PopFrame.BorderSizePixel = 0
                    PopFrame.ZIndex = 10
                    local pfc = Instance.new("UICorner", PopFrame) pfc.CornerRadius = UDim.new(0, 6)
                    local pfs = Instance.new("UIStroke", PopFrame) pfs.Color = Color3.fromRGB(70, 70, 90) pfs.Thickness = 1.2

                    local popLayout = Instance.new("UIListLayout", PopFrame)
                    popLayout.SortOrder = Enum.SortOrder.LayoutOrder

                    local optionElements = {}

                    local function refreshHighlights()
                        for val, elements in pairs(optionElements) do
                            if val == selectedVal then
                                elements.Btn.BackgroundColor3 = COLOR_SECTION_BG
                                elements.Btn.BackgroundTransparency = 0.3
                                elements.Indicator.Visible = true
                            else
                                elements.Btn.BackgroundColor3 = COLOR_INTERACTIVE_BG
                                elements.Btn.BackgroundTransparency = 1
                                elements.Indicator.Visible = false
                            end
                        end
                    end

                    for _, val in ipairs(config.Values or {}) do
                        local optBtn = Instance.new("TextButton", PopFrame)
                        optBtn.BackgroundColor3 = COLOR_INTERACTIVE_BG
                        optBtn.BackgroundTransparency = 1
                        optBtn.Size = UDim2.new(1, 0, 0, 36)
                        optBtn.Text = ""
                        optBtn.AutoButtonColor = false
                        optBtn.BorderSizePixel = 0
                        optBtn.ZIndex = 11
                        local optCorner = Instance.new("UICorner", optBtn) optCorner.CornerRadius = UDim.new(0, 4)

                        local ind = Instance.new("Frame", optBtn)
                        ind.BackgroundColor3 = COLOR_DARK_GRAY
                        ind.Size = UDim2.new(0, 3, 0, 16)
                        ind.Position = UDim2.new(0, 2, 0.5, -8)
                        ind.BorderSizePixel = 0
                        ind.Visible = false
                        local indCorner = Instance.new("UICorner", ind) indCorner.CornerRadius = UDim.new(1, 0)

                        local lbl = Instance.new("TextLabel", optBtn)
                        lbl.BackgroundTransparency = 1
                        lbl.Position = UDim2.new(0, 12, 0, 0)
                        lbl.Size = UDim2.new(1, -12, 1, 0)
                        lbl.Font = Enum.Font.GothamBold
                        lbl.Text = tostring(val)
                        lbl.TextColor3 = COLOR_SIDEBAR_LOG 
                        lbl.TextSize = CONFIG_FONT_DROPDOWN
                        lbl.TextXAlignment = Enum.TextXAlignment.Left

                        optionElements[val] = {Btn = optBtn, Indicator = ind}

                        optBtn.MouseButton1Click:Connect(function()
                            selectedVal = val
                            SelectLabel.Text = tostring(val)
                            refreshHighlights() 
                            if config.Callback then pcall(config.Callback, val) end
                        end)
                    end
                    
                    refreshHighlights() 
                end)

                local dAPI = {}
                function dAPI:SetValue(val)
                    selectedVal = val
                    SelectLabel.Text = tostring(val)
                    if config.Callback then pcall(config.Callback, val) end
                end
                function dAPI:SetValues(newVals)
                    config.Values = newVals
                end
                return dAPI
            end

            function ElementAPI:AddCollapsibleSection(title, defaultOpen)
                defaultOpen = defaultOpen ~= false

                local SectionFrame = Instance.new("Frame", parentContainer)
                SectionFrame.BackgroundTransparency = 1 
                SectionFrame.Size = UDim2.new(1, 0, 0, 34)
                SectionFrame.BorderSizePixel = 0
                SectionFrame.ClipsDescendants = true

                local HeaderBtn = Instance.new("TextButton", SectionFrame)
                HeaderBtn.BackgroundTransparency = 1
                HeaderBtn.Size = UDim2.new(1, 0, 0, 34)
                HeaderBtn.Font = Enum.Font.GothamBold
                HeaderBtn.Text = "  " .. (title or "Section")
                HeaderBtn.TextColor3 = defaultOpen and COLOR_DARK_GRAY or COLOR_WHITE
                HeaderBtn.TextSize = CONFIG_FONT_SECTION
                HeaderBtn.TextXAlignment = Enum.TextXAlignment.Left

                local SectionArrow = Instance.new("ImageLabel", HeaderBtn)
                SectionArrow.BackgroundTransparency = 1
                SectionArrow.AnchorPoint = Vector2.new(1, 0.5)
                SectionArrow.Position = UDim2.new(1, -6, 0.5, 0)
                SectionArrow.Size = UDim2.new(0, 22, 0, 22)
                SectionArrow.Image = CustomLib.Assets.Icons.Arrow
                SectionArrow.ImageTransparency = 0.4
                SectionArrow.Rotation = defaultOpen and 0 or -90

                local InnerContainer = Instance.new("Frame", SectionFrame)
                InnerContainer.BackgroundTransparency = 1
                InnerContainer.Position = UDim2.new(0, 0, 0, 34)
                InnerContainer.Size = UDim2.new(1, 0, 0, 0)

                local TheInnerLayout = Instance.new("UIListLayout", InnerContainer)
                TheInnerLayout.SortOrder = Enum.SortOrder.LayoutOrder
                TheInnerLayout.Padding = UDim.new(0, 5)
                TheInnerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
                local InnerPadding = Instance.new("UIPadding", InnerContainer)
                InnerPadding.PaddingLeft = UDim.new(0, 0)
                InnerPadding.PaddingRight = UDim.new(0, 0)

                local isOpen = defaultOpen

                local function updateSize()
                    local contentHeight = TheInnerLayout.AbsoluteContentSize.Y + 8
                    if isOpen then
                        InnerContainer.Size = UDim2.new(1, 0, 0, contentHeight)
                        SectionFrame.Size = UDim2.new(1, 0, 0, 34 + contentHeight)
                        TweenService:Create(SectionArrow, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Rotation = 0}):Play()
                        TweenService:Create(HeaderBtn, TweenInfo.new(0.2), {TextColor3 = COLOR_DARK_GRAY}):Play()
                    else
                        InnerContainer.Size = UDim2.new(1, 0, 0, 0)
                        SectionFrame.Size = UDim2.new(1, 0, 0, 34)
                        TweenService:Create(SectionArrow, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Rotation = -90}):Play()
                        TweenService:Create(HeaderBtn, TweenInfo.new(0.2), {TextColor3 = COLOR_WHITE}):Play()
                    end
                end

                TheInnerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    if isOpen then updateSize() end
                end)

                HeaderBtn.MouseButton1Click:Connect(function()
                    if MainFrame:FindFirstChild("ActiveDropdown") then
                        MainFrame:FindFirstChild("ActiveDropdown"):Destroy()
                    end
                    if MainFrame:FindFirstChild("DropOutsideClick") then
                        MainFrame:FindFirstChild("DropOutsideClick"):Destroy()
                    end
                    isOpen = not isOpen
                    updateSize()
                end)

                updateSize()
                return createElementAPI(InnerContainer)
            end

            return ElementAPI
        end

        local mainTabAPI = createElementAPI(TabContent)
        for k, v in pairs(mainTabAPI) do TabAPI[k] = v end

        return TabAPI
    end

    return Window
end

-- ==========================================
-- INTEGRASI UI LOGIC TRADING (EVENT DRIVEN)
-- ==========================================
local Window = CustomLib:CreateWindow({
    Title = "Orvion | | Evolving Everyday"
})

-- LOGIC TOGGLE BUTTON DRAGGABLE
if CoreGui:FindFirstChild("OberonTradeToggle") then
    CoreGui.OberonTradeToggle:Destroy()
end

local ToggleGui = Instance.new("ScreenGui", CoreGui)
ToggleGui.Name = "OberonTradeToggle"
ToggleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local ToggleButton = Instance.new("ImageButton", ToggleGui)
ToggleButton.Size = UDim2.new(0, 45, 0, 45)
ToggleButton.Position = UDim2.new(0, 15, 0.5, -100) 
ToggleButton.BackgroundTransparency = 1
ToggleButton.BorderSizePixel = 0
ToggleButton.ScaleType = Enum.ScaleType.Fit
ToggleButton.Image = "rbxassetid://88499385264699"

local UICorner = Instance.new("UICorner", ToggleButton)
UICorner.CornerRadius = UDim.new(1, 0)

local dragging, dragInput, dragStart, startPos
ToggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = ToggleButton.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
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
        ToggleButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local isUiOpen = true
ToggleButton.MouseButton1Click:Connect(function()
    isUiOpen = not isUiOpen
    if CoreGui:FindFirstChild("CustomLibGui") then
        local mainFrame = CoreGui.CustomLibGui:FindFirstChild("MainFrame")
        if mainFrame then mainFrame.Visible = isUiOpen end
    end
end)

-- STATE MANAGEMENT
local State = {
    TargetPlayer = "Select Option",
    TargetItem = "Select Option",
    SendAmount = "1",
    StartTrade = false,
    AutoAccept = false,
    AntiAfk = false
}

-- MEMBUAT TABS & SECTION UI
local Tabs = {
    Info = Window:AddTab("Info"),
    Trading = Window:AddTab("Trading"),
    Utilities = Window:AddTab("Utilities")
    
}

local InfoSection = Tabs.Info:AddCollapsibleSection("About Orvion", true)

InfoSection:AddParagraph({
    Title = "What is Orvion?",
    Content = "Orvion is my first Lua scripting project. I made this hub to learn, improve, and try out new ideas. It might not be perfect, but I'll keep making it better with every update.\nAlso huge thanks to idan (Meng Hub) for the UI idea and inspiration, I really appreciate it.",
})

local InventoryStatus = Tabs.Trading:AddParagraph({
    Title = "Inventory Status",
    Content = "Waiting for check...\n(e.g., x0 Runic, x0 Evo, x0 Forgotten & Secret Fish)"
})

local TradeLog = Tabs.Trading:AddParagraph({
    Title = "Trade Log",
    Content = "Retry: 0 | Success: 0 | Failed: 0 | Sent: 0"
})

-- SECTION PLAYER
local PlayerSection = Tabs.Trading:AddCollapsibleSection("Select Player", false)
local PlayerDropdown = PlayerSection:AddDropdown({
    Title = "Select Player for Trade",
    Values = {"Select Option"}, 
    DefaultValue = "Select Option",
    Callback = function(v) 
        State.TargetPlayer = v 
    end
})

PlayerSection:AddButton({
    Title = "Refresh Player",
    Icon = "10088146947", 
    Callback = function()
        PlayerDropdown:SetValues(refreshPlayerList())
    end
})

-- SECTION TRADE SETTING
local TradeSection = Tabs.Trading:AddCollapsibleSection("Trade Settings", false)
TradeSection:AddDropdown({
    Title = "Select Item",
    Values = {"Runic Enchant Stone", "Evolved Enchant Stone", "Forgotten & Secret Fish"},
    DefaultValue = "Select Option",
    Callback = function(v) 
        State.TargetItem = v 
    end
})

TradeSection:AddInput({
    Title = "Set Amount",
    Default = "1",
    Placeholder = "Enter amount",
    Callback = function(v) 
        State.SendAmount = v 
    end
})

TradeSection:AddButton({
    Title = "Check Inventory",
    Icon = "10088146947", 
    Callback = function()
        local r, e, s = getInventoryItems()
        InventoryStatus:SetDesc(string.format("x%d Runic, x%d Evo, x%d Forgotten & Secret Fish", #r, #e, #s))
    end
})

-- LOGIC STATE TRADING GLOBAL
local TotalItemsSuccess = 0
local RetryCount = 0
local SuccessCount = 0
local FailedCount = 0
local isTradingProcess = false
local isAddingItems = false 

-- DEKLARASI START TOGGLE
local StartToggle 

StartToggle = TradeSection:AddToggle({
    Title = "Start Trade", 
    Default = false,
    Callback = function(state)
        State.StartTrade = state
        
        if state then
            if State.TargetPlayer == "Select Option" or State.TargetPlayer == "No Players Found" then
                StartToggle:SetValue(false)
                return
            end
            
            if isTradingProcess then return end
            isTradingProcess = true
            
            task.spawn(function()
                local targetAmount = tonumber(State.SendAmount) or 1
                local targetName = State.TargetPlayer
                local selectedItem = State.TargetItem
                
                TotalItemsSuccess = 0
                RetryCount = 0
                SuccessCount = 0
                FailedCount = 0
                TradeLog:SetDesc(string.format("Retry: %d | Success: %d | Failed: %d | Sent: %d", RetryCount, SuccessCount, FailedCount, TotalItemsSuccess))
                
                while State.StartTrade and TotalItemsSuccess < targetAmount do
                    local targetPlayer = Players:FindFirstChild(targetName)
                    if not targetPlayer then
                        StartToggle:SetValue(false)
                        break
                    end

                    local availableItems = getTargetItems(selectedItem)
                    if #availableItems == 0 then
                        StartToggle:SetValue(false)
                        break
                    end

                    local amountNeeded = targetAmount - TotalItemsSuccess
                    local batchSize = math.min(20, amountNeeded, #availableItems)
                    local batchItems = {}
                    for i = 1, batchSize do
                        table.insert(batchItems, availableItems[i])
                    end

                    -- [FIX 1]: Tunggu hingga status 'IsTrading' benar-benar clear dari trade sebelumnya
                    local waitClear = 0
                    while (targetPlayer:GetAttribute("IsTrading") == true or LocalPlayer:GetAttribute("IsTrading") == true) and waitClear < 10 do
                        task.wait(0.5)
                        waitClear = waitClear + 0.5
                    end
                    if not State.StartTrade then break end

                    RetryCount = RetryCount + 1
                    TradeLog:SetDesc(string.format("Retry: %d | Success: %d | Failed: %d | Sent: %d", RetryCount, SuccessCount, FailedCount, TotalItemsSuccess))
                    
                    -- [FIX 2]: Kunci status isAddingItems SEBELUM mengirim trade agar fungsi Auto-Confirm tidak menabrak
                    isAddingItems = true 
                    
                    -- [FIX 3]: Tangkap respon server. Jika tertolak (misal target cooldown), langsung hentikan dan coba lagi
                    local ok, sendSuccess = pcall(function() 
                        return TradeData.Remotes.SendTradeOffer:InvokeServer(targetPlayer) 
                    end)

                    if not ok or sendSuccess == false then
                        FailedCount = FailedCount + 1
                        TradeLog:SetDesc(string.format("Retry: %d | Success: %d | Failed: %d | Sent: %d", RetryCount, SuccessCount, FailedCount, TotalItemsSuccess))
                        isAddingItems = false
                        task.wait(2.5)
                        continue
                    end

                    -- [FIX 4]: Gunakan Event TradeStarted untuk mendeteksi trade, BUKAN mengandalkan Attribute IsTrading
                    local tradeStarted = false
                    local startConn = TradeData.Remotes.TradeStarted.OnClientEvent:Connect(function()
                        tradeStarted = true
                    end)
                    
                    local offerWaitTime = 0
                    while not tradeStarted and offerWaitTime < 15 and State.StartTrade do
                        task.wait(0.5)
                        offerWaitTime = offerWaitTime + 0.5
                    end
                    startConn:Disconnect()

                    if not tradeStarted then
                        FailedCount = FailedCount + 1
                        TradeLog:SetDesc(string.format("Retry: %d | Success: %d | Failed: %d | Sent: %d", RetryCount, SuccessCount, FailedCount, TotalItemsSuccess))
                        isAddingItems = false
                        task.wait(2.5)
                        continue 
                    end

                    -- KITA BERADA DI DALAM TRADE
                    local tradeFinished = false
                    local isSuccess = false
                    
                    local endConn = TradeData.Remotes.TradeEnded.OnClientEvent:Connect(function() tradeFinished = true end)
                    local compConn = TradeData.Remotes.TradeCompleted.OnClientEvent:Connect(function() 
                        tradeFinished = true
                        isSuccess = true 
                    end)

                    task.wait(1.5) -- Beri jeda agar UI/State game stabil seperti di controller asli

                    local itemsAddedCount = 0
                    for _, itemData in ipairs(batchItems) do
                        if tradeFinished or LocalPlayer:GetAttribute("IsTrading") ~= true then break end
                        
                        local okAdd, addSuccess = pcall(function()
                            return TradeData.Remotes.AddItem:InvokeServer(itemData.Category, itemData.UUID)
                        end)
                        
                        if okAdd and addSuccess ~= false then 
                            itemsAddedCount = itemsAddedCount + 1 
                        end
                        
                        -- Jeda aman dan acak agar tidak memicu deteksi rate limit server
                        task.wait(math.random(1, 3) / 8) 
                    end
                    
                    -- Fase penambahan item selesai, buka kunci agar Auto Confirm bisa menekan tombol Ready
                    isAddingItems = false 

                    -- Tunggu trade selesai (dengan timeout 30 detik untuk safety anti-stuck)
                    local waitElapsed = 0
                    while not tradeFinished and LocalPlayer:GetAttribute("IsTrading") == true and waitElapsed < 30 do
                        task.wait(1)
                        waitElapsed = waitElapsed + 1
                    end
                    
                    endConn:Disconnect()
                    compConn:Disconnect()

                    -- Handle jika nyangkut / stuck / di-troll
                    if not tradeFinished and LocalPlayer:GetAttribute("IsTrading") == true then
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

                    if isSuccess then
                        SuccessCount = SuccessCount + 1
                        TotalItemsSuccess = TotalItemsSuccess + itemsAddedCount 
                    else
                        FailedCount = FailedCount + 1
                    end
                    
                    TradeLog:SetDesc(string.format("Retry: %d | Success: %d | Failed: %d | Sent: %d", RetryCount, SuccessCount, FailedCount, TotalItemsSuccess))
                    task.wait(3.5) -- Cooldown aman sebelum mengirim trade berikutnya
                end
                
                isTradingProcess = false
                if TotalItemsSuccess >= targetAmount and StartToggle then
                    StartToggle:SetValue(false)
                end
            end)
        else
            isTradingProcess = false
        end
    end
})

-- ==========================================
-- LOGIC ANTI AFK & AUTO ACCEPT (EVENT DRIVEN)
-- ==========================================

-- 1. PISAHKAN DAN AMBIL KONEKSI GAME TERLEBIH DAHULU
-- Kita harus mengambil koneksi bawaan game SEBELUM membuat koneksi event kustom di bawahnya
-- agar skrip kita tidak men-disable dirinya sendiri.
local gameTradeConnections = {}
local afkConnections = {}

if getconnections then
    pcall(function()
        -- Ambil koneksi pop-up UI trade offer bawaan game
        for _, conn in pairs(getconnections(TradeData.Remotes.TradeOfferReceived.OnClientEvent)) do
            table.insert(gameTradeConnections, conn)
        end
        -- Ambil koneksi idle/AFK bawaan game
        for _, conn in pairs(getconnections(LocalPlayer.Idled)) do
            table.insert(afkConnections, conn)
        end
    end)
end

-- 2. SETUP TOGGLES
Tabs.Utilities:AddToggle({
    Title = "Auto Accept & Confirm Trade", 
    Default = false,
    Callback = function(state)
        State.AutoAccept = state
        pcall(function()
            for _, conn in pairs(gameTradeConnections) do
                if state then
                    conn:Disable() -- Bypass UI Pop-up Request bawaan game
                else
                    conn:Enable()
                end
            end
        end)
    end
})

Tabs.Utilities:AddToggle({
    Title = "Anti-AFK", 
    Default = false,
    Callback = function(state)
        State.AntiAfk = state
        pcall(function()
            for _, conn in pairs(afkConnections) do
                if state then
                    conn:Disable()
                else
                    conn:Enable()
                end
            end
        end)
    end
})

-- 3. LOGIC AUTO ACCEPT (Stand-alone & Terproteksi)
TradeData.Remotes.TradeOfferReceived.OnClientEvent:Connect(function(sender)
    if State.AutoAccept then
        task.wait(0.2)
        -- Otomatis menerima tanpa memicu pop-up visual di layar
        pcall(function() 
            TradeData.Remotes.AcceptTradeOffer:InvokeServer(sender) 
        end)
    end
end)

-- 4. LOGIC AUTO CONFIRM & ANTI-STUCK DI DALAM TRADE UI
local function watchTradingState()
    task.spawn(function()
        local timeStuck = 0
        
        while LocalPlayer:GetAttribute("IsTrading") == true do
            if not State.AutoAccept then break end
            
            -- Sistem Anti-Stuck: Batalkan trade jika pemain lawan AFK/Troll lebih dari 30 detik
            if timeStuck >= 30 then
                pcall(function() TradeData.Remotes.CancelTrade:InvokeServer() end)
                task.wait(1)
                
                -- Force hide UI Trade menggunakan controller bawaan jika tersangkut
                pcall(function()
                    local GuiControl = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("GuiControl"))
                    if LocalPlayer.PlayerGui:FindFirstChild("! Trading") then
                        LocalPlayer.PlayerGui["! Trading"].Enabled = false
                    end
                    GuiControl:Unlock()
                    GuiControl:Close()
                end)
                
                LocalPlayer:SetAttribute("IsTrading", false)
                break
            end
            
            -- Eksekusi Auto Ready dan Auto Confirm
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

-- Deteksi transisi masuk ke dalam Trade
LocalPlayer:GetAttributeChangedSignal("IsTrading"):Connect(function()
    if LocalPlayer:GetAttribute("IsTrading") == true and State.AutoAccept then
        watchTradingState()
    end
end)

-- Handle edge case jika toggle dinyalakan pada saat Player sudah terlanjur berada dalam state trading
if LocalPlayer:GetAttribute("IsTrading") == true and State.AutoAccept then
    watchTradingState()
end