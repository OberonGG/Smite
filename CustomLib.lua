local CustomLib = {}
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Assets Configuration Table (Hanya untuk Minimize dan Close pada Top Bar)
CustomLib.Assets = {
    Icons = {
        Minimize = "rbxassetid://9886659276",
        Close = "rbxassetid://9886659671",
        Arrow = "rbxassetid://16851841101" -- Masih disimpan jika diperlukan bagian lain
    }
}

function CustomLib:CreateWindow(config)
    config = config or {}
    local titleText = config.Title or "Custom Hub"
    local size = config.Size or UDim2.fromOffset(500, 320)

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

    -- ScreenGui khusus overlay dropdown agar berada di layer paling atas
    local DropdownOverlayGui = Instance.new("ScreenGui")
    DropdownOverlayGui.Name = "CustomLibDropdownOverlay"
    DropdownOverlayGui.Parent = CoreGui
    DropdownOverlayGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    DropdownOverlayGui.DisplayOrder = 999

    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Name = "MainFrame"
    MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    MainFrame.Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2)
    MainFrame.Size = size
    MainFrame.BorderSizePixel = 0

    local MainCorner = Instance.new("UICorner", MainFrame)
    MainCorner.CornerRadius = UDim.new(0, 8)

    local MainStroke = Instance.new("UIStroke", MainFrame)
    MainStroke.Color = Color3.fromRGB(45, 45, 55)
    MainStroke.Thickness = 1.2

    -- Draggable Logic
    local dragging, dragInput, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Title Bar
    local TitleLabel = Instance.new("TextLabel", MainFrame)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Position = UDim2.new(0, 15, 0, 12)
    TitleLabel.Size = UDim2.new(0, 300, 0, 24)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = titleText
    TitleLabel.TextColor3 = Color3.fromRGB(240, 240, 245)
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Close Button
    local CloseBtn = Instance.new("ImageButton", MainFrame)
    CloseBtn.Name = "CloseButton"
    CloseBtn.Size = UDim2.new(0, 20, 0, 20)
    CloseBtn.Position = UDim2.new(1, -28, 0, 14)
    CloseBtn.Image = CustomLib.Assets.Icons.Close
    CloseBtn.BackgroundTransparency = 1

    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
        if CoreGui:FindFirstChild("CustomLibDropdownOverlay") then
            CoreGui.CustomLibDropdownOverlay:Destroy()
        end
    end)

    -- Minimize Button
    local MinBtn = Instance.new("ImageButton", MainFrame)
    MinBtn.Name = "MinimizeButton"
    MinBtn.Size = UDim2.new(0, 20, 0, 20)
    MinBtn.Position = UDim2.new(1, -54, 0, 14)
    MinBtn.Image = CustomLib.Assets.Icons.Minimize
    MinBtn.BackgroundTransparency = 1

    local minimized = false
    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        MainFrame:TweenSize(
            minimized and UDim2.new(0, size.X.Offset, 0, 45) or size,
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Quart,
            0.3,
            true
        )
    end)

    -- Container Tab Content
    local Container = Instance.new("Frame", MainFrame)
    Container.BackgroundTransparency = 1
    Container.Position = UDim2.new(0, 140, 0, 45)
    Container.Size = UDim2.new(1, -155, 1, -55)

    -- Sidebar Tab List
    local Sidebar = Instance.new("ScrollingFrame", MainFrame)
    Sidebar.BackgroundTransparency = 1
    Sidebar.Position = UDim2.new(0, 10, 0, 45)
    Sidebar.Size = UDim2.new(0, 120, 1, -100)
    Sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
    Sidebar.ScrollBarThickness = 0

    local UIListLayout = Instance.new("UIListLayout", Sidebar)
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 5)

    UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Sidebar.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
    end)

    -- User Info Card
    local UserCard = Instance.new("Frame", MainFrame)
    UserCard.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
    UserCard.Position = UDim2.new(0, 10, 1, -45)
    UserCard.Size = UDim2.new(0, 120, 0, 35)
    UserCard.BorderSizePixel = 0
    local ucc = Instance.new("UICorner", UserCard) ucc.CornerRadius = UDim.new(0, 6)

    local AvatarImg = Instance.new("ImageLabel", UserCard)
    AvatarImg.BackgroundTransparency = 1
    AvatarImg.Position = UDim2.new(0, 5, 0.5, -12)
    AvatarImg.Size = UDim2.new(0, 24, 0, 24)
    AvatarImg.Image = "rbxassetid://0"
    pcall(function()
        local content, isReady = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
        if isReady then AvatarImg.Image = content end
    end)
    local aic = Instance.new("UICorner", AvatarImg) aic.CornerRadius = UDim.new(1, 0)

    local WelcomeLabel = Instance.new("TextLabel", UserCard)
    WelcomeLabel.BackgroundTransparency = 1
    WelcomeLabel.Position = UDim2.new(0, 33, 0, 2)
    WelcomeLabel.Size = UDim2.new(1, -36, 1, -4)
    WelcomeLabel.Font = Enum.Font.GothamBold
    WelcomeLabel.Text = "Welcome, " .. tostring(LocalPlayer.DisplayName)
    WelcomeLabel.TextColor3 = Color3.fromRGB(190, 190, 205)
    WelcomeLabel.TextSize = 9
    WelcomeLabel.TextXAlignment = Enum.TextXAlignment.Left
    WelcomeLabel.TextWrapped = true

    local Window = {}
    local tabs = {}
    local firstTab = true

    function Window:AddTab(tabName)
        local TabButton = Instance.new("TextButton", Sidebar)
        TabButton.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
        TabButton.Size = UDim2.new(1, 0, 0, 30)
        TabButton.Font = Enum.Font.GothamBold
        TabButton.Text = "  " .. tabName
        TabButton.TextColor3 = Color3.fromRGB(150, 150, 165)
        TabButton.TextSize = 12
        TabButton.TextXAlignment = Enum.TextXAlignment.Left
        TabButton.BorderSizePixel = 0
        local BtnCorner = Instance.new("UICorner", TabButton) BtnCorner.CornerRadius = UDim.new(0, 6)

        -- Ikon panah pada sidebar telah dihapus sesuai permintaan (tanda hijau)

        local TabContent = Instance.new("ScrollingFrame", Container)
        TabContent.BackgroundTransparency = 1
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabContent.ScrollBarThickness = 3
        TabContent.Visible = false

        local ContentLayout = Instance.new("UIListLayout", TabContent)
        ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ContentLayout.Padding = UDim.new(0, 8)

        ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 10)
        end)

        if firstTab then
            TabContent.Visible = true
            TabButton.TextColor3 = Color3.fromRGB(240, 240, 250)
            TabButton.BackgroundColor3 = Color3.fromRGB(38, 38, 48)
            firstTab = false
        end

        TabButton.MouseButton1Click:Connect(function()
            for _, t in pairs(tabs) do
                t.Content.Visible = false
                t.Button.TextColor3 = Color3.fromRGB(150, 150, 165)
                t.Button.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
            end
            TabContent.Visible = true
            TabButton.TextColor3 = Color3.fromRGB(240, 240, 250)
            TabButton.BackgroundColor3 = Color3.fromRGB(38, 38, 48)
        end)

        table.insert(tabs, {Button = TabButton, Content = TabContent})

        local TabAPI = {}

        local function createElementAPI(parentContainer)
            local ElementAPI = {}

            function ElementAPI:AddParagraph(config)
                local ParaFrame = Instance.new("Frame", parentContainer)
                ParaFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
                ParaFrame.Size = UDim2.new(1, -10, 0, 65)
                ParaFrame.BorderSizePixel = 0
                local pbc = Instance.new("UICorner", ParaFrame) pbc.CornerRadius = UDim.new(0, 6)

                local Title = Instance.new("TextLabel", ParaFrame)
                Title.BackgroundTransparency = 1
                Title.Position = UDim2.new(0, 12, 0, 8)
                Title.Size = UDim2.new(1, -24, 0, 20)
                Title.Font = Enum.Font.GothamBold
                Title.Text = config.Title or "Title"
                Title.TextColor3 = Color3.fromRGB(230, 230, 240)
                Title.TextSize = 13
                Title.TextXAlignment = Enum.TextXAlignment.Left

                local Desc = Instance.new("TextLabel", ParaFrame)
                Desc.BackgroundTransparency = 1
                Desc.Position = UDim2.new(0, 12, 0, 28)
                Desc.Size = UDim2.new(1, -24, 0, 30)
                Desc.Font = Enum.Font.GothamBold
                Desc.Text = config.Content or "Content"
                Desc.TextColor3 = Color3.fromRGB(160, 160, 175)
                Desc.TextSize = 12
                Desc.TextXAlignment = Enum.TextXAlignment.Left
                Desc.TextWrapped = true

                local f = {}
                function f:SetDesc(txt) Desc.Text = txt end
                return f
            end

            function ElementAPI:AddButton(config)
                local Btn = Instance.new("TextButton", parentContainer)
                Btn.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
                Btn.Size = UDim2.new(1, -10, 0, 35)
                Btn.Font = Enum.Font.GothamBold
                Btn.Text = config.Title or "Button"
                Btn.TextColor3 = Color3.fromRGB(210, 210, 220)
                Btn.TextSize = 13
                Btn.TextXAlignment = Enum.TextXAlignment.Center
                Btn.BorderSizePixel = 0
                local bc = Instance.new("UICorner", Btn) bc.CornerRadius = UDim.new(0, 6)

                Btn.MouseButton1Click:Connect(function()
                    if config.Callback then pcall(config.Callback) end
                end)
            end

            function ElementAPI:AddToggle(config)
                local ToggleFrame = Instance.new("Frame", parentContainer)
                ToggleFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
                ToggleFrame.Size = UDim2.new(1, -10, 0, 35)
                ToggleFrame.BorderSizePixel = 0
                local tc = Instance.new("UICorner", ToggleFrame) tc.CornerRadius = UDim.new(0, 6)

                local Title = Instance.new("TextLabel", ToggleFrame)
                Title.BackgroundTransparency = 1
                Title.Position = UDim2.new(0, 12, 0, 0)
                Title.Size = UDim2.new(1, -60, 1, 0)
                Title.Font = Enum.Font.GothamBold
                Title.Text = config.Title or "Toggle"
                Title.TextColor3 = Color3.fromRGB(210, 210, 220)
                Title.TextSize = 13
                Title.TextXAlignment = Enum.TextXAlignment.Left

                local SwitchBg = Instance.new("Frame", ToggleFrame)
                SwitchBg.BackgroundColor3 = Color3.fromRGB(38, 38, 48)
                SwitchBg.Position = UDim2.new(1, -45, 0.5, -10)
                SwitchBg.Size = UDim2.new(0, 36, 0, 20)
                local sbc = Instance.new("UICorner", SwitchBg) sbc.CornerRadius = UDim.new(1, 0)

                local Knob = Instance.new("Frame", SwitchBg)
                Knob.BackgroundColor3 = Color3.fromRGB(180, 180, 195)
                Knob.Position = UDim2.new(0, 2, 0.5, -8)
                Knob.Size = UDim2.new(0, 16, 0, 16)
                local kc = Instance.new("UICorner", Knob) kc.CornerRadius = UDim.new(1, 0)

                local state = config.Default == true
                local function updateVisual(anim)
                    if state then
                        SwitchBg.BackgroundColor3 = Color3.fromRGB(140, 140, 160)
                        Knob.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
                        if anim then TweenService:Create(Knob, TweenInfo.new(0.15), {Position = UDim2.new(1, -18, 0.5, -8)}):Play()
                        else Knob.Position = UDim2.new(1, -18, 0.5, -8) end
                    else
                        SwitchBg.BackgroundColor3 = Color3.fromRGB(38, 38, 48)
                        Knob.BackgroundColor3 = Color3.fromRGB(180, 180, 195)
                        if anim then TweenService:Create(Knob, TweenInfo.new(0.15), {Position = UDim2.new(0, 2, 0.5, -8)}):Play()
                        else Knob.Position = UDim2.new(0, 2, 0.5, -8) end
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
                InputFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
                InputFrame.Size = UDim2.new(1, -10, 0, 35)
                InputFrame.BorderSizePixel = 0
                local ic = Instance.new("UICorner", InputFrame) ic.CornerRadius = UDim.new(0, 6)

                local Title = Instance.new("TextLabel", InputFrame)
                Title.BackgroundTransparency = 1
                Title.Position = UDim2.new(0, 12, 0, 0)
                Title.Size = UDim2.new(0.5, -12, 1, 0)
                Title.Font = Enum.Font.GothamBold
                Title.Text = config.Title or "Input"
                Title.TextColor3 = Color3.fromRGB(210, 210, 220)
                Title.TextSize = 13
                Title.TextXAlignment = Enum.TextXAlignment.Left

                -- Warna diselaraskan seragam (Color3.fromRGB(26, 26, 34))
                local TextBox = Instance.new("TextBox", InputFrame)
                TextBox.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
                TextBox.Position = UDim2.new(0.5, 0, 0.5, -11)
                TextBox.Size = UDim2.new(0.5, -12, 0, 22)
                TextBox.Font = Enum.Font.GothamBold
                TextBox.Text = config.Default or ""
                TextBox.PlaceholderText = config.Placeholder or "Select Option"
                TextBox.TextColor3 = Color3.fromRGB(230, 230, 240)
                TextBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 135)
                TextBox.TextSize = 12
                TextBox.TextXAlignment = Enum.TextXAlignment.Center
                TextBox.BorderSizePixel = 0
                local tbc = Instance.new("UICorner", TextBox) tbc.CornerRadius = UDim.new(0, 4)

                TextBox.FocusLost:Connect(function()
                    if config.Callback then pcall(config.Callback, TextBox.Text) end
                end)

                local iAPI = {}
                function iAPI:GetValue() return TextBox.Text end
                return iAPI
            end

            function ElementAPI:AddDropdown(config)
                local DropFrame = Instance.new("Frame", parentContainer)
                DropFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
                DropFrame.Size = UDim2.new(1, -10, 0, 35)
                DropFrame.BorderSizePixel = 0
                local dc = Instance.new("UICorner", DropFrame) dc.CornerRadius = UDim.new(0, 6)

                local Title = Instance.new("TextLabel", DropFrame)
                Title.BackgroundTransparency = 1
                Title.Position = UDim2.new(0, 12, 0, 0)
                Title.Size = UDim2.new(0.5, -12, 1, 0)
                Title.Font = Enum.Font.GothamBold
                Title.Text = config.Title or "Dropdown"
                Title.TextColor3 = Color3.fromRGB(210, 210, 220)
                Title.TextSize = 13
                Title.TextXAlignment = Enum.TextXAlignment.Left

                -- Warna diselaraskan seragam (Color3.fromRGB(26, 26, 34))
                local SelectBtn = Instance.new("TextButton", DropFrame)
                SelectBtn.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
                SelectBtn.Position = UDim2.new(0.5, 0, 0.5, -11)
                SelectBtn.Size = UDim2.new(0.5, -12, 0, 22)
                SelectBtn.Font = Enum.Font.GothamBold
                
                local selectedVal = config.DefaultValue or "Select Option"
                SelectBtn.Text = tostring(selectedVal)
                SelectBtn.TextColor3 = Color3.fromRGB(210, 210, 220)
                SelectBtn.TextSize = 12
                SelectBtn.TextXAlignment = Enum.TextXAlignment.Center
                SelectBtn.BorderSizePixel = 0
                local sbc = Instance.new("UICorner", SelectBtn) sbc.CornerRadius = UDim.new(0, 4)

                local DropArrow = Instance.new("ImageLabel", SelectBtn)
                DropArrow.BackgroundTransparency = 1
                DropArrow.Position = UDim2.new(1, -18, 0.5, -6)
                DropArrow.Size = UDim2.new(0, 12, 0, 12)
                DropArrow.Image = CustomLib.Assets.Icons.Arrow
                DropArrow.ImageTransparency = 0.4

                SelectBtn.MouseButton1Click:Connect(function()
                    if DropdownOverlayGui:FindFirstChild("ActiveDropdown") then
                        DropdownOverlayGui.ActiveDropdown:Destroy()
                        return
                    end

                    local absPos = SelectBtn.AbsolutePosition
                    local absSize = SelectBtn.AbsoluteSize

                    -- Warna background popup dropdown disamakan persis (Color3.fromRGB(26, 26, 34))
                    local PopFrame = Instance.new("ScrollingFrame", DropdownOverlayGui)
                    PopFrame.Name = "ActiveDropdown"
                    PopFrame.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
                    PopFrame.Position = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y + 4)
                    PopFrame.Size = UDim2.new(0, absSize.X, 0, math.min(#(config.Values or {}) * 26, 130))
                    PopFrame.CanvasSize = UDim2.new(0, 0, 0, #(config.Values or {}) * 26)
                    PopFrame.ScrollBarThickness = 2
                    PopFrame.BorderSizePixel = 0
                    local pfc = Instance.new("UICorner", PopFrame) pfc.CornerRadius = UDim.new(0, 4)
                    local pfs = Instance.new("UIStroke", PopFrame) pfs.Color = Color3.fromRGB(50, 50, 65) pfs.Thickness = 1

                    local popLayout = Instance.new("UIListLayout", PopFrame)
                    popLayout.SortOrder = Enum.SortOrder.LayoutOrder

                    for _, val in ipairs(config.Values or {}) do
                        local optBtn = Instance.new("TextButton", PopFrame)
                        optBtn.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
                        optBtn.Size = UDim2.new(1, 0, 0, 26)
                        optBtn.Font = Enum.Font.GothamBold
                        optBtn.Text = tostring(val)
                        optBtn.TextColor3 = Color3.fromRGB(200, 200, 215)
                        optBtn.TextSize = 12
                        optBtn.TextXAlignment = Enum.TextXAlignment.Center
                        optBtn.BorderSizePixel = 0

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

            function ElementAPI:AddCollapsibleSection(title, defaultOpen)
                defaultOpen = defaultOpen ~= false

                local SectionFrame = Instance.new("Frame", parentContainer)
                SectionFrame.BackgroundColor3 = Color3.fromRGB(19, 19, 25)
                SectionFrame.Size = UDim2.new(1, -10, 0, 35)
                SectionFrame.BorderSizePixel = 0
                SectionFrame.ClipsDescendants = true
                local sc = Instance.new("UICorner", SectionFrame) sc.CornerRadius = UDim.new(0, 6)

                local HeaderBtn = Instance.new("TextButton", SectionFrame)
                HeaderBtn.BackgroundTransparency = 1
                HeaderBtn.Size = UDim2.new(1, 0, 0, 35)
                HeaderBtn.Font = Enum.Font.GothamBold
                HeaderBtn.Text = "  " .. (title or "Section")
                HeaderBtn.TextColor3 = Color3.fromRGB(210, 210, 225)
                HeaderBtn.TextSize = 13
                HeaderBtn.TextXAlignment = Enum.TextXAlignment.Left

                local SectionArrow = Instance.new("ImageLabel", HeaderBtn)
                SectionArrow.BackgroundTransparency = 1
                SectionArrow.Position = UDim2.new(1, -26, 0.5, -7)
                SectionArrow.Size = UDim2.new(0, 14, 0, 14)
                SectionArrow.Image = CustomLib.Assets.Icons.Arrow
                SectionArrow.ImageTransparency = 0.4
                SectionArrow.Rotation = defaultOpen and 90 or 0

                local InnerContainer = Instance.new("Frame", SectionFrame)
                InnerContainer.BackgroundTransparency = 1
                InnerContainer.Position = UDim2.new(0, 0, 0, 35)
                InnerContainer.Size = UDim2.new(1, 0, 0, 0)

                local TheInnerLayout = Instance.new("UIListLayout", InnerContainer)
                TheInnerLayout.SortOrder = Enum.SortOrder.LayoutOrder
                TheInnerLayout.Padding = UDim.new(0, 6)

                local isOpen = defaultOpen

                local function updateSize()
                    local contentHeight = TheInnerLayout.AbsoluteContentSize.Y + 10
                    if isOpen then
                        InnerContainer.Size = UDim2.new(1, 0, 0, contentHeight)
                        SectionFrame.Size = UDim2.new(1, -10, 0, 35 + contentHeight)
                        TweenService:Create(SectionArrow, TweenInfo.new(0.2), {Rotation = 90}):Play()
                    else
                        InnerContainer.Size = UDim2.new(1, 0, 0, 0)
                        SectionFrame.Size = UDim2.new(1, -10, 0, 35)
                        TweenService:Create(SectionArrow, TweenInfo.new(0.2), {Rotation = 0}):Play()
                    end
                end

                TheInnerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    if isOpen then updateSize() end
                end)

                HeaderBtn.MouseButton1Click:Connect(function()
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

return CustomLib
