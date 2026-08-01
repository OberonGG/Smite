local CustomLib = {}
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

function CustomLib:CreateWindow(config)
    config = config or {}
    local titleText = config.Title or "Custom Hub"
    local size = config.Size or UDim2.fromOffset(500, 320)

    -- Hapus UI lama jika ada
    if CoreGui:FindFirstChild("CustomLibGui") then
        CoreGui.CustomLibGui:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CustomLibGui"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Main Window Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    MainFrame.Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2)
    MainFrame.Size = size
    MainFrame.BorderSizePixel = 0

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 8)
    MainCorner.Parent = MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Parent = MainFrame
    MainStroke.Color = Color3.fromRGB(45, 45, 55)
    MainStroke.Thickness = 1.5

    -- Draggable Window Logic
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
            MainFrame.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X, 
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    -- Title Bar
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Parent = MainFrame
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Position = UDim2.new(0, 15, 0, 12)
    TitleLabel.Size = UDim2.new(0, 300, 0, 24)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = titleText
    TitleLabel.TextColor3 = Color3.fromRGB(240, 240, 245)
    TitleLabel.TextSize = 15
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Container Tab Content
    local Container = Instance.new("Frame")
    Container.Parent = MainFrame
    Container.BackgroundTransparency = 1
    Container.Position = UDim2.new(0, 140, 0, 50)
    Container.Size = UDim2.new(1, -155, 1, -65)

    -- Sidebar Tab List
    local Sidebar = Instance.new("ScrollingFrame")
    Sidebar.Parent = MainFrame
    Sidebar.BackgroundTransparency = 1
    Sidebar.Position = UDim2.new(0, 10, 0, 50)
    Sidebar.Size = UDim2.new(0, 120, 1, -65)
    Sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
    Sidebar.ScrollBarThickness = 0

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Parent = Sidebar
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 6)

    UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Sidebar.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
    end)

    local Window = {}
    local tabs = {}
    local firstTab = true

    function Window:AddTab(tabName)
        local TabButton = Instance.new("TextButton")
        TabButton.Parent = Sidebar
        TabButton.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
        TabButton.Size = UDim2.new(1, 0, 0, 32)
        TabButton.Font = Enum.Font.GothamBold
        TabButton.Text = "  " .. tabName
        TabButton.TextColor3 = Color3.fromRGB(160, 160, 175)
        TabButton.TextSize = 13
        TabButton.TextXAlignment = Enum.TextXAlignment.Left
        TabButton.BorderSizePixel = 0

        local BtnCorner = Instance.new("UICorner")
        BtnCorner.CornerRadius = UDim.new(0, 6)
        BtnCorner.Parent = TabButton

        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Parent = Container
        TabContent.BackgroundTransparency = 1
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabContent.ScrollBarThickness = 3
        TabContent.Visible = false

        local ContentLayout = Instance.new("UIListLayout")
        ContentLayout.Parent = TabContent
        ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ContentLayout.Padding = UDim.new(0, 8)

        ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 10)
        end)

        if firstTab then
            TabContent.Visible = true
            TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            TabButton.BackgroundColor3 = Color3.fromRGB(50, 40, 80)
            firstTab = false
        end

        TabButton.MouseButton1Click:Connect(function()
            for _, t in pairs(tabs) do
                t.Content.Visible = false
                t.Button.TextColor3 = Color3.fromRGB(160, 160, 175)
                t.Button.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
            end
            TabContent.Visible = true
            TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            TabButton.BackgroundColor3 = Color3.fromRGB(50, 40, 80)
        end)

        table.insert(tabs, {Button = TabButton, Content = TabContent})

        local TabAPI = {}

        -- Helper untuk membuat elemen di dalam Tab atau di dalam Accordion Section
        local function createElementAPI(parentContainer)
            local ElementAPI = {}

            function ElementAPI:AddParagraph(config)
                local ParaFrame = Instance.new("Frame")
                ParaFrame.Parent = parentContainer
                ParaFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
                ParaFrame.Size = UDim2.new(1, -10, 0, 65)
                ParaFrame.BorderSizePixel = 0

                local ParaCorner = Instance.new("UICorner")
                ParaCorner.CornerRadius = UDim.new(0, 6)
                ParaCorner.Parent = ParaFrame

                local Title = Instance.new("TextLabel")
                Title.Parent = ParaFrame
                Title.BackgroundTransparency = 1
                Title.Position = UDim2.new(0, 12, 0, 8)
                Title.Size = UDim2.new(1, -24, 0, 20)
                Title.Font = Enum.Font.GothamBold
                Title.Text = config.Title or "Title"
                Title.TextColor3 = Color3.fromRGB(230, 230, 240)
                Title.TextSize = 13
                Title.TextXAlignment = Enum.TextXAlignment.Left

                local Desc = Instance.new("TextLabel")
                Desc.Parent = ParaFrame
                Desc.BackgroundTransparency = 1
                Desc.Position = UDim2.new(0, 12, 0, 28)
                Desc.Size = UDim2.new(1, -24, 0, 30)
                Desc.Font = Enum.Font.GothamBold
                Desc.Text = config.Content or "Content"
                Desc.TextColor3 = Color3.fromRGB(180, 180, 195)
                Desc.TextSize = 12
                Desc.TextXAlignment = Enum.TextXAlignment.Left
                Desc.TextWrapped = true

                local funciones = {}
                function funciones:SetDesc(newText)
                    Desc.Text = newText
                end
                return funciones
            end

            function ElementAPI:AddButton(config)
                local Btn = Instance.new("TextButton")
                Btn.Parent = parentContainer
                Btn.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
                Btn.Size = UDim2.new(1, -10, 0, 35)
                Btn.Font = Enum.Font.GothamBold
                Btn.Text = "  " .. (config.Title or "Button")
                Btn.TextColor3 = Color3.fromRGB(220, 220, 230)
                Btn.TextSize = 13
                Btn.TextXAlignment = Enum.TextXAlignment.Left
                Btn.BorderSizePixel = 0

                local BtnCorner = Instance.new("UICorner")
                BtnCorner.CornerRadius = UDim.new(0, 6)
                BtnCorner.Parent = Btn

                Btn.MouseButton1Click:Connect(function()
                    if config.Callback then
                        pcall(config.Callback)
                    end
                end)
            end

            function ElementAPI:AddCollapsibleSection(title, defaultOpen)
                defaultOpen = defaultOpen ~= false

                local SectionFrame = Instance.new("Frame")
                SectionFrame.Parent = parentContainer
                SectionFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
                SectionFrame.Size = UDim2.new(1, -10, 0, 35)
                SectionFrame.BorderSizePixel = 0
                SectionFrame.ClipsDescendants = true

                local SecCorner = Instance.new("UICorner")
                SecCorner.CornerRadius = UDim.new(0, 6)
                SecCorner.Parent = SectionFrame

                local HeaderBtn = Instance.new("TextButton")
                HeaderBtn.Parent = SectionFrame
                HeaderBtn.BackgroundTransparency = 1
                HeaderBtn.Size = UDim2.new(1, 0, 0, 35)
                HeaderBtn.Font = Enum.Font.GothamBold
                HeaderBtn.Text = "  " .. (title or "Section")
                HeaderBtn.TextColor3 = Color3.fromRGB(220, 220, 235)
                HeaderBtn.TextSize = 13
                HeaderBtn.TextXAlignment = Enum.TextXAlignment.Left

                local Arrow = Instance.new("TextLabel")
                Arrow.Parent = HeaderBtn
                Arrow.BackgroundTransparency = 1
                Arrow.Position = UDim2.new(1, -30, 0, 0)
                Arrow.Size = UDim2.new(0, 20, 0, 35)
                Arrow.Font = Enum.Font.GothamBold
                Arrow.Text = defaultOpen and "v" or ">"
                Arrow.TextColor3 = Color3.fromRGB(160, 160, 175)
                Arrow.TextSize = 12

                local InnerContainer = Instance.new("Frame")
                InnerContainer.Parent = SectionFrame
                InnerContainer.BackgroundTransparency = 1
                InnerContainer.Position = UDim2.new(0, 0, 0, 35)
                InnerContainer.Size = UDim2.new(1, 0, 0, 0)

                local InnerLayout = Instance.new("UIListLayout")
                InnerLayout.Parent = InnerContainer
                InnerLayout.SortOrder = Enum.SortOrder.LayoutOrder
                InnerLayout.Padding = UDim.new(0, 6)

                local isOpen = defaultOpen

                local function updateSize()
                    local contentHeight = InnerLayout.AbsoluteContentSize.Y + 10
                    if isOpen then
                        InnerContainer.Size = UDim2.new(1, 0, 0, contentHeight)
                        SectionFrame.Size = UDim2.new(1, -10, 0, 35 + contentHeight)
                        Arrow.Text = "v"
                    else
                        InnerContainer.Size = UDim2.new(1, 0, 0, 0)
                        SectionFrame.Size = UDim2.new(1, -10, 0, 35)
                        Arrow.Text = ">"
                    end
                end

                InnerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    if isOpen then
                        updateSize()
                    end
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
        for k, v in pairs(mainTabAPI) do
            TabAPI[k] = v
        end

        return TabAPI
    end

    return Window
end

return CustomLib
