local CustomLib = {}
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- PENGATURAN FONT UTAMA (Section = 18, Isi = 12)
-- ==========================================
local FONT_SIZE_SECTION = 18 
local FONT_SIZE_CONTENT = 14 

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
    MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    MainFrame.Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2)
    MainFrame.Size = size
    MainFrame.BorderSizePixel = 0

    local MainCorner = Instance.new("UICorner", MainFrame)
    MainCorner.CornerRadius = UDim.new(0, 8)

    local MainStroke = Instance.new("UIStroke", MainFrame)
    MainStroke.Color = Color3.fromRGB(45, 45, 55)
    MainStroke.LineJoinMode = Enum.LineJoinMode.Round
    MainStroke.Thickness = 1.2
    MainStroke.Transparency = 0.6

    local ImageWrapper = Instance.new("Frame", MainFrame)
    ImageWrapper.Name = "ImageWrapper"
    ImageWrapper.Size = UDim2.new(1, 0, 1, 0)
    ImageWrapper.BackgroundTransparency = 1
    ImageWrapper.ZIndex = 0

    local ThemeImage = Instance.new("ImageLabel", ImageWrapper)
    ThemeImage.Name = "ThemeImage"
    ThemeImage.Size = UDim2.new(0, 305.5, 0, 256.5)
    ThemeImage.Position = UDim2.new(1, -305.5, 1, -256.5)
    ThemeImage.BackgroundTransparency = 1
    ThemeImage.Image = "rbxassetid://99142076352082"
    ThemeImage.ZIndex = 0

    local UIGradient = Instance.new("UIGradient", ThemeImage)
    UIGradient.Rotation = 45
    UIGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.6, 0.8),
        NumberSequenceKeypoint.new(1, 0)
    })

    -- Draggable
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

    -- Top
    local Top = Instance.new("Frame", MainFrame)
    Top.Name = "Top"
    Top.Size = UDim2.new(0, 470, 0, 38)
    Top.BackgroundTransparency = 1

    local TitleLabel = Instance.new("TextLabel", Top)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Position = UDim2.new(0, 15, 0, 9)
    TitleLabel.Size = UDim2.new(0, 250, 0, 20)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = titleText
    TitleLabel.TextColor3 = Color3.fromRGB(240, 240, 245)
    TitleLabel.TextSize = 13
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local CloseBtn = Instance.new("ImageButton", Top)
    CloseBtn.Size = UDim2.new(0, 20, 0, 20)
    CloseBtn.Position = UDim2.new(1, -28, 0, 9)
    CloseBtn.Image = CustomLib.Assets.Icons.Close
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
        if CoreGui:FindFirstChild("CustomLibDropdownOverlay") then CoreGui.CustomLibDropdownOverlay:Destroy() end
    end)

    local MinBtn = Instance.new("ImageButton", Top)
    MinBtn.Size = UDim2.new(0, 20, 0, 20)
    MinBtn.Position = UDim2.new(1, -54, 0, 9)
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
    end)

    -- LayersTab (Sidebar)
    local LayersTab = Instance.new("Frame", MainFrame)
    LayersTab.Name = "LayersTab"
    LayersTab.BackgroundTransparency = 1
    LayersTab.Position = UDim2.new(0, 8, 0, 45)
    LayersTab.Size = UDim2.new(0, 120, 0, 211)

    local SearchBarFrame = Instance.new("Frame", LayersTab)
    SearchBarFrame.Name = "SearchBarFrame"
    SearchBarFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    SearchBarFrame.BackgroundTransparency = 0.5
    SearchBarFrame.Position = UDim2.new(0, 4, 0, 0)
    SearchBarFrame.Size = UDim2.new(0, 112, 0, 26)
    SearchBarFrame.BorderSizePixel = 0
    local sc = Instance.new("UICorner", SearchBarFrame) sc.CornerRadius = UDim.new(0, 4)
    local sbs = Instance.new("UIStroke", SearchBarFrame) sbs.Color = Color3.fromRGB(45, 45, 55) sbs.Thickness = 1
    
    local SearchInput = Instance.new("TextBox", SearchBarFrame)
    SearchInput.BackgroundTransparency = 1
    SearchInput.Size = UDim2.new(1, -20, 1, 0)
    SearchInput.Position = UDim2.new(0, 20, 0, 0)
    SearchInput.Font = Enum.Font.Gotham
    SearchInput.PlaceholderText = "Search..."
    SearchInput.Text = ""
    SearchInput.TextColor3 = Color3.fromRGB(200, 200, 215)
    SearchInput.TextSize = 12
    SearchInput.TextXAlignment = Enum.TextXAlignment.Left

    local ScrollTab = Instance.new("ScrollingFrame", LayersTab)
    ScrollTab.Name = "ScrollTab"
    ScrollTab.BackgroundTransparency = 1
    ScrollTab.Position = UDim2.new(0, 4, 0, 32)
    ScrollTab.Size = UDim2.new(0, 112, 1, -78)
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
    PlayerFooter.Position = UDim2.new(0, 4, 1, -40)
    PlayerFooter.Size = UDim2.new(0, 102, 0, 40)
    PlayerFooter.BorderSizePixel = 0
    
    local AvatarImg = Instance.new("ImageLabel", PlayerFooter)
    AvatarImg.BackgroundTransparency = 1
    AvatarImg.Position = UDim2.new(0, 4, 0.5, -12)
    AvatarImg.Size = UDim2.new(0, 24, 0, 24)
    AvatarImg.Image = "rbxassetid://0"
    pcall(function()
        local content, isReady = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
        if isReady then AvatarImg.Image = content end
    end)
    local aic = Instance.new("UICorner", AvatarImg) aic.CornerRadius = UDim.new(1, 0)

    local WelcomeLabel = Instance.new("TextLabel", PlayerFooter)
    WelcomeLabel.BackgroundTransparency = 1
    WelcomeLabel.Position = UDim2.new(0, 32, 0, 2)
    WelcomeLabel.Size = UDim2.new(1, -34, 1, -4)
    WelcomeLabel.Font = Enum.Font.GothamBold
    WelcomeLabel.Text = "Welcome, " .. string.sub(tostring(LocalPlayer.DisplayName), 1, 8) .. ".."
    WelcomeLabel.TextColor3 = Color3.fromRGB(190, 190, 205)
    WelcomeLabel.TextSize = 10
    WelcomeLabel.TextXAlignment = Enum.TextXAlignment.Left
    WelcomeLabel.TextWrapped = true

    local Container = Instance.new("Frame", MainFrame)
    Container.Name = "Layers"
    Container.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Container.BackgroundTransparency = 0.999 
    Container.Position = UDim2.new(0, 135, 0, 45)
    Container.Size = UDim2.new(0, 323, 0, 211)
    Container.BorderSizePixel = 0
    local ContainerCorner = Instance.new("UICorner", Container) ContainerCorner.CornerRadius = UDim.new(0, 2)

    local Window = {}
    local tabs = {}
    local firstTab = true

    function Window:AddTab(tabName)
        local TabButton = Instance.new("TextButton", ScrollTab)
        TabButton.BackgroundTransparency = 1 
        TabButton.Size = UDim2.new(1, 0, 0, 26)
        TabButton.Font = Enum.Font.GothamBold
        TabButton.Text = "   " .. tabName
        TabButton.TextColor3 = Color3.fromRGB(150, 150, 165)
        TabButton.TextSize = FONT_SIZE_SECTION
        TabButton.TextXAlignment = Enum.TextXAlignment.Left
        TabButton.BorderSizePixel = 0

        -- Indikator Sidebar Diubah Menjadi Warna Abu-abu Elegan
        local Indicator = Instance.new("Frame", TabButton)
        Indicator.BackgroundColor3 = Color3.fromRGB(180, 180, 195)
        Indicator.Size = UDim2.new(0, 3, 0, 14)
        Indicator.Position = UDim2.new(0, 2, 0.5, -7)
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
            if DropdownOverlayGui:FindFirstChild("ActiveDropdown") then DropdownOverlayGui:ClearAllChildren() end
        end)

        local ContentLayout = Instance.new("UIListLayout", TabContent)
        ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ContentLayout.Padding = UDim.new(0, 5)
        ContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

        ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 10)
        end)

        if firstTab then
            TabContent.Visible = true
            TabButton.TextColor3 = Color3.fromRGB(240, 240, 250)
            Indicator.Visible = true
            firstTab = false
        end

        TabButton.MouseButton1Click:Connect(function()
            if DropdownOverlayGui:FindFirstChild("ActiveDropdown") then DropdownOverlayGui:ClearAllChildren() end
            for _, t in pairs(tabs) do
                t.Content.Visible = false
                t.Button.TextColor3 = Color3.fromRGB(150, 150, 165)
                t.Indicator.Visible = false
            end
            TabContent.Visible = true
            TabButton.TextColor3 = Color3.fromRGB(240, 240, 250)
            Indicator.Visible = true
        end)

        table.insert(tabs, {Button = TabButton, Indicator = Indicator, Content = TabContent})

        local TabAPI = {}

        local function createElementAPI(parentContainer)
            local ElementAPI = {}

            function ElementAPI:AddParagraph(config)
                local ParaFrame = Instance.new("Frame", parentContainer)
                ParaFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
                ParaFrame.BackgroundTransparency = 0.6
                ParaFrame.Size = UDim2.new(1, -6, 0, 56)
                ParaFrame.BorderSizePixel = 0
                local pfc = Instance.new("UICorner", ParaFrame) pfc.CornerRadius = UDim.new(0, 6)

                local Title = Instance.new("TextLabel", ParaFrame)
                Title.BackgroundTransparency = 1
                Title.Position = UDim2.new(0, 10, 0, 6)
                Title.Size = UDim2.new(1, -20, 0, 20)
                Title.Font = Enum.Font.GothamBold
                Title.Text = config.Title or "Title"
                Title.TextColor3 = Color3.fromRGB(230, 230, 240)
                Title.TextSize = FONT_SIZE_SECTION
                Title.TextXAlignment = Enum.TextXAlignment.Left

                local Desc = Instance.new("TextLabel", ParaFrame)
                Desc.BackgroundTransparency = 1
                Desc.Position = UDim2.new(0, 10, 0, 28)
                Desc.Size = UDim2.new(1, -20, 0, 22)
                Desc.Font = Enum.Font.GothamBold
                Desc.Text = config.Content or "Content"
                Desc.TextColor3 = Color3.fromRGB(160, 160, 175)
                Desc.TextSize = FONT_SIZE_CONTENT
                Desc.TextXAlignment = Enum.TextXAlignment.Left
                Desc.TextWrapped = true

                local f = {}
                function f:SetDesc(txt) Desc.Text = txt end
                return f
            end

            function ElementAPI:AddButton(config)
                local Btn = Instance.new("TextButton", parentContainer)
                Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
                Btn.BackgroundTransparency = 0.6
                Btn.Size = UDim2.new(1, -6, 0, 34)
                Btn.Font = Enum.Font.GothamBold
                Btn.Text = "  " .. (config.Title or "Button")
                Btn.TextColor3 = Color3.fromRGB(220, 220, 230)
                Btn.TextSize = FONT_SIZE_SECTION
                Btn.TextXAlignment = Enum.TextXAlignment.Left
                Btn.BorderSizePixel = 0
                local bc = Instance.new("UICorner", Btn) bc.CornerRadius = UDim.new(0, 6)

                Btn.MouseButton1Click:Connect(function()
                    if config.Callback then pcall(config.Callback) end
                end)
            end

            function ElementAPI:AddToggle(config)
                local ToggleFrame = Instance.new("Frame", parentContainer)
                ToggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
                ToggleFrame.BackgroundTransparency = 0.6
                ToggleFrame.Size = UDim2.new(1, -6, 0, 34)
                ToggleFrame.BorderSizePixel = 0
                local tfc = Instance.new("UICorner", ToggleFrame) tfc.CornerRadius = UDim.new(0, 6)

                local Title = Instance.new("TextLabel", ToggleFrame)
                Title.BackgroundTransparency = 1
                Title.Position = UDim2.new(0, 10, 0, 0)
                Title.Size = UDim2.new(1, -55, 1, 0)
                Title.Font = Enum.Font.GothamBold
                Title.Text = config.Title or "Toggle"
                Title.TextColor3 = Color3.fromRGB(210, 210, 220)
                Title.TextSize = FONT_SIZE_SECTION
                Title.TextXAlignment = Enum.TextXAlignment.Left

                local SwitchBg = Instance.new("Frame", ToggleFrame)
                SwitchBg.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
                SwitchBg.Position = UDim2.new(1, -38, 0.5, -9)
                SwitchBg.Size = UDim2.new(0, 32, 0, 18)
                local sbc = Instance.new("UICorner", SwitchBg) sbc.CornerRadius = UDim.new(1, 0)

                local Knob = Instance.new("Frame", SwitchBg)
                Knob.BackgroundColor3 = Color3.fromRGB(180, 180, 195)
                Knob.Position = UDim2.new(0, 2, 0.5, -7)
                Knob.Size = UDim2.new(0, 14, 0, 14)
                local kc = Instance.new("UICorner", Knob) kc.CornerRadius = UDim.new(1, 0)

                local state = config.Default == true
                local function updateVisual(anim)
                    if state then
                        SwitchBg.BackgroundColor3 = Color3.fromRGB(140, 140, 160)
                        Knob.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
                        if anim then TweenService:Create(Knob, TweenInfo.new(0.15), {Position = UDim2.new(1, -16, 0.5, -7)}):Play()
                        else Knob.Position = UDim2.new(1, -16, 0.5, -7) end
                    else
                        SwitchBg.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
                        Knob.BackgroundColor3 = Color3.fromRGB(180, 180, 195)
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
                local InputFrame = Instance.new("Frame", parentContainer)
                InputFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
                InputFrame.BackgroundTransparency = 0.6
                InputFrame.Size = UDim2.new(1, -6, 0, 34)
                InputFrame.BorderSizePixel = 0
                local ifc = Instance.new("UICorner", InputFrame) ifc.CornerRadius = UDim.new(0, 6)

                local Title = Instance.new("TextLabel", InputFrame)
                Title.BackgroundTransparency = 1
                Title.Position = UDim2.new(0, 10, 0, 0)
                Title.Size = UDim2.new(0.45, 0, 1, 0)
                Title.Font = Enum.Font.GothamBold
                Title.Text = config.Title or "Input"
                Title.TextColor3 = Color3.fromRGB(210, 210, 220)
                Title.TextSize = FONT_SIZE_SECTION
                Title.TextXAlignment = Enum.TextXAlignment.Left

                local TextBox = Instance.new("TextBox", InputFrame)
                TextBox.BackgroundTransparency = 1
                TextBox.AnchorPoint = Vector2.new(1, 0.5)
                TextBox.Position = UDim2.new(1, -10, 0.5, 0)
                TextBox.Size = UDim2.new(0.5, 0, 0, 24)
                TextBox.Font = Enum.Font.GothamBold
                TextBox.Text = config.Default or ""
                TextBox.PlaceholderText = config.Placeholder or "Enter..."
                TextBox.TextColor3 = Color3.fromRGB(230, 230, 240)
                TextBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 135)
                TextBox.TextSize = FONT_SIZE_CONTENT
                TextBox.TextXAlignment = Enum.TextXAlignment.Right
                TextBox.BorderSizePixel = 0

                TextBox.FocusLost:Connect(function()
                    if config.Callback then pcall(config.Callback, TextBox.Text) end
                end)

                local iAPI = {}
                function iAPI:GetValue() return TextBox.Text end
                return iAPI
            end

            function ElementAPI:AddDropdown(config)
                local DropFrame = Instance.new("Frame", parentContainer)
                DropFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
                DropFrame.BackgroundTransparency = 0.6
                DropFrame.Size = UDim2.new(1, -6, 0, 34)
                DropFrame.BorderSizePixel = 0
                local dfc = Instance.new("UICorner", DropFrame) dfc.CornerRadius = UDim.new(0, 6)

                local Title = Instance.new("TextLabel", DropFrame)
                Title.BackgroundTransparency = 1
                Title.Position = UDim2.new(0, 10, 0, 0)
                Title.Size = UDim2.new(0.45, 0, 1, 0)
                Title.Font = Enum.Font.GothamBold
                Title.Text = config.Title or "Dropdown"
                Title.TextColor3 = Color3.fromRGB(210, 210, 220)
                Title.TextSize = FONT_SIZE_SECTION
                Title.TextXAlignment = Enum.TextXAlignment.Left

                local SelectBtn = Instance.new("TextButton", DropFrame)
                SelectBtn.BackgroundTransparency = 1
                SelectBtn.AnchorPoint = Vector2.new(1, 0.5)
                SelectBtn.Position = UDim2.new(1, -24, 0.5, 0)
                SelectBtn.Size = UDim2.new(0.5, 0, 1, 0)
                SelectBtn.Font = Enum.Font.GothamBold
                
                local selectedVal = config.DefaultValue or "Select Option"
                SelectBtn.Text = tostring(selectedVal)
                SelectBtn.TextColor3 = Color3.fromRGB(210, 210, 220)
                SelectBtn.TextSize = FONT_SIZE_CONTENT
                SelectBtn.TextXAlignment = Enum.TextXAlignment.Right
                SelectBtn.BorderSizePixel = 0

                -- Dropdown Arrow: Statis menghadap ke bawah (v)
                local DropArrow = Instance.new("ImageLabel", DropFrame)
                DropArrow.BackgroundTransparency = 1
                DropArrow.AnchorPoint = Vector2.new(1, 0.5)
                DropArrow.Position = UDim2.new(1, -4, 0.5, 0)
                DropArrow.Size = UDim2.new(0, 22, 0, 22)
                DropArrow.Image = CustomLib.Assets.Icons.Arrow
                DropArrow.ImageTransparency = 0.4
                DropArrow.Rotation = 90

                SelectBtn.MouseButton1Click:Connect(function()
                    if DropdownOverlayGui:FindFirstChild("ActiveDropdown") then
                        DropdownOverlayGui:ClearAllChildren()
                        return
                    end

                    local OutsideClick = Instance.new("TextButton", DropdownOverlayGui)
                    OutsideClick.Name = "OutsideClick"
                    OutsideClick.Size = UDim2.new(1, 0, 1, 0)
                    OutsideClick.BackgroundTransparency = 1
                    OutsideClick.Text = ""
                    OutsideClick.ZIndex = 998
                    OutsideClick.MouseButton1Click:Connect(function()
                        DropdownOverlayGui:ClearAllChildren()
                    end)

                    local absPos = DropFrame.AbsolutePosition
                    local absSize = DropFrame.AbsoluteSize

                    local dropdownWidth = config.DropdownSize or 160

                    local PopFrame = Instance.new("ScrollingFrame", DropdownOverlayGui)
                    PopFrame.Name = "ActiveDropdown"
                    PopFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
                    PopFrame.Position = UDim2.new(0, absPos.X + (absSize.X - dropdownWidth), 0, absPos.Y + absSize.Y + 2)
                    PopFrame.Size = UDim2.new(0, dropdownWidth, 0, math.min(#(config.Values or {}) * 32, 130))
                    PopFrame.CanvasSize = UDim2.new(0, 0, 0, #(config.Values or {}) * 32)
                    PopFrame.ScrollBarThickness = 2
                    PopFrame.BorderSizePixel = 0
                    PopFrame.ZIndex = 999
                    local pfc = Instance.new("UICorner", PopFrame) pfc.CornerRadius = UDim.new(0, 6)
                    local pfs = Instance.new("UIStroke", PopFrame) pfs.Color = Color3.fromRGB(60, 60, 75) pfs.Thickness = 1.2

                    local popLayout = Instance.new("UIListLayout", PopFrame)
                    popLayout.SortOrder = Enum.SortOrder.LayoutOrder

                    for _, val in ipairs(config.Values or {}) do
                        local optBtn = Instance.new("TextButton", PopFrame)
                        optBtn.BackgroundTransparency = 1
                        optBtn.Size = UDim2.new(1, 0, 0, 32)
                        optBtn.Font = Enum.Font.GothamBold
                        optBtn.Text = tostring(val)
                        optBtn.TextColor3 = Color3.fromRGB(210, 210, 225)
                        optBtn.TextSize = FONT_SIZE_CONTENT
                        optBtn.TextXAlignment = Enum.TextXAlignment.Center
                        optBtn.BorderSizePixel = 0
                        optBtn.ZIndex = 1000

                        optBtn.MouseButton1Click:Connect(function()
                            selectedVal = val
                            SelectBtn.Text = tostring(val)
                            DropdownOverlayGui:ClearAllChildren()
                            if config.Callback then pcall(config.Callback, val) end
                        end)
                    end
                end)

                local dAPI = {}
                function dAPI:SetValue(val)
                    selectedVal = val
                    SelectBtn.Text = tostring(val)
                    if config.Callback then pcall(config.Callback, val) end
                end
                function dAPI:SetValues(newVals)
                    config.Values = newVals
                end
                return dAPI
            end

            -- Collapsible Section (Accordion)
            function ElementAPI:AddCollapsibleSection(title, defaultOpen)
                defaultOpen = defaultOpen ~= false

                local SectionFrame = Instance.new("Frame", parentContainer)
                SectionFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
                SectionFrame.BackgroundTransparency = 0.6
                SectionFrame.Size = UDim2.new(1, -6, 0, 34)
                SectionFrame.BorderSizePixel = 0
                SectionFrame.ClipsDescendants = true
                local sfc = Instance.new("UICorner", SectionFrame) sfc.CornerRadius = UDim.new(0, 6)

                local HeaderBtn = Instance.new("TextButton", SectionFrame)
                HeaderBtn.BackgroundTransparency = 1
                HeaderBtn.Size = UDim2.new(1, 0, 0, 34)
                HeaderBtn.Font = Enum.Font.GothamBold
                HeaderBtn.Text = "  " .. (title or "Section")
                HeaderBtn.TextColor3 = Color3.fromRGB(210, 210, 225)
                HeaderBtn.TextSize = FONT_SIZE_SECTION
                HeaderBtn.TextXAlignment = Enum.TextXAlignment.Left

                -- Section Arrow: Tertutup = Menghadap ke kanan (> / rotasi 0), Terbuka = Menghadap ke bawah (v / rotasi 90)
                local SectionArrow = Instance.new("ImageLabel", HeaderBtn)
                SectionArrow.BackgroundTransparency = 1
                SectionArrow.AnchorPoint = Vector2.new(1, 0.5)
                SectionArrow.Position = UDim2.new(1, -6, 0.5, 0)
                SectionArrow.Size = UDim2.new(0, 22, 0, 22)
                SectionArrow.Image = CustomLib.Assets.Icons.Arrow
                SectionArrow.ImageTransparency = 0.4
                SectionArrow.Rotation = defaultOpen and 90 or 0

                -- InnerContainer tempat masuknya elemen-elemen isi di dalam Section
                local InnerContainer = Instance.new("Frame", SectionFrame)
                InnerContainer.BackgroundTransparency = 1
                InnerContainer.Position = UDim2.new(0, 0, 0, 34)
                InnerContainer.Size = UDim2.new(1, 0, 0, 0)

                local TheInnerLayout = Instance.new("UIListLayout", InnerContainer)
                TheInnerLayout.SortOrder = Enum.SortOrder.LayoutOrder
                TheInnerLayout.Padding = UDim.new(0, 5)
                TheInnerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

                local isOpen = defaultOpen

                local function updateSize()
                    local contentHeight = TheInnerLayout.AbsoluteContentSize.Y + 8
                    if isOpen then
                        InnerContainer.Size = UDim2.new(1, 0, 0, contentHeight)
                        SectionFrame.Size = UDim2.new(1, 0, 0, 34 + contentHeight)
                        TweenService:Create(SectionArrow, TweenInfo.new(0.2), {Rotation = 90}):Play() -- Terbuka (v)
                    else
                        InnerContainer.Size = UDim2.new(1, 0, 0, 0)
                        SectionFrame.Size = UDim2.new(1, 0, 0, 34)
                        TweenService:Create(SectionArrow, TweenInfo.new(0.2), {Rotation = 0}):Play() -- Tertutup (>)
                    end
                end

                TheInnerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    if isOpen then updateSize() end
                end)

                HeaderBtn.MouseButton1Click:Connect(function()
                    if DropdownOverlayGui:FindFirstChild("ActiveDropdown") then
                        DropdownOverlayGui:ClearAllChildren()
                    end
                    isOpen = not isOpen
                    updateSize()
                end)

                updateSize()

                -- PENTING: Mengembalikan createElementAPI dengan parent InnerContainer 
                -- sehingga elemen seperti Dropdown & Button masuk ke dalam logika isi section.
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

return CustomLib
