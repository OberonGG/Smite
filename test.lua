local CoreGui = game:GetService("CoreGui")

local function run()

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoCloseStatus"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999
screenGui.Parent = CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 240, 0, 60)
frame.Position = UDim2.new(0.5, -120, 0.2, -30)
frame.BackgroundColor3 = Color3.fromRGB(13, 13, 13)
frame.BackgroundTransparency = 0.05
frame.BorderSizePixel = 0
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 6)
corner.Parent = frame

local outerStroke = Instance.new("UIStroke")
outerStroke.Color = Color3.fromRGB(26, 26, 26)
outerStroke.Thickness = 1
outerStroke.Parent = frame

local accentBar = Instance.new("Frame")
accentBar.Size = UDim2.new(0, 3, 1, 0)
accentBar.Position = UDim2.new(0, 0, 0, 0)
accentBar.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
accentBar.BorderSizePixel = 0
accentBar.Parent = frame

local accentBarCorner = Instance.new("UICorner")
accentBarCorner.CornerRadius = UDim.new(0, 6)
accentBarCorner.Parent = accentBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -22, 0, 14)
titleLabel.Position = UDim2.new(0, 14, 0, 10)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.RobotoMono
titleLabel.Text = "AUTO CLOSE SYSTEM"
titleLabel.TextColor3 = Color3.fromRGB(142, 142, 143)
titleLabel.TextSize = 9
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = frame

local dot = Instance.new("Frame")
dot.Size = UDim2.new(0, 6, 0, 6)
dot.Position = UDim2.new(0, 14, 0, 35)
dot.BackgroundTransparency = 1
dot.BorderSizePixel = 0
dot.Parent = frame

local dotCorner = Instance.new("UICorner")
dotCorner.CornerRadius = UDim.new(1, 0)
dotCorner.Parent = dot

local dotStroke = Instance.new("UIStroke")
dotStroke.Color = Color3.fromRGB(200, 200, 200)
dotStroke.Thickness = 1.5
dotStroke.Parent = dot

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -38, 0, 18)
statusLabel.Position = UDim2.new(0, 26, 0, 32)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.Code
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.TextSize = 12
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Text = "INITIALIZING..."
statusLabel.Parent = frame

local function setStatus(text, color, dotColor)
    statusLabel.Text = text
    if text == "DONE" then
        statusLabel.TextColor3 = Color3.fromRGB(50, 255, 100)
        dotStroke.Color = Color3.fromRGB(50, 255, 100)
        accentBar.BackgroundColor3 = Color3.fromRGB(50, 255, 100)
    else
        statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        dotStroke.Color = Color3.fromRGB(200, 200, 200)
        accentBar.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    end
end

local function isMengHubVisible()
    local mengHub = CoreGui:FindFirstChild("MengHubGui")
    if not mengHub then return false end
    local dropShadow = mengHub:FindFirstChild("DropShadowHolder", true)
    if dropShadow then return dropShadow.Visible end
    return false
end

local function fireToggle()
    for _, v in ipairs(CoreGui:GetChildren()) do
        if v.Name == "ToggleUIButton" then
            local btn = v:FindFirstChild("TextButton", true)
            if btn then
                pcall(function() firesignal(btn.MouseButton1Click) end)
                pcall(function() firesignal(btn.Activated) end)
                pcall(function() btn.MouseButton1Click:Fire() end)
            end
        end
    end
end

local function minimizeReduce()
    setStatus("MINIMIZE REDUCE...", Color3.fromRGB(255, 165, 0), Color3.fromRGB(255, 165, 0))
    local Players = game:GetService("Players")
    local gui = Players.LocalPlayer:WaitForChild("PlayerGui", 10)
    if not gui then
        print("[AUTO CLOSE] PlayerGui not found")
        return
    end

    local monsfams, targetFrame, btn

    local lookupSuccess, lookupErr = pcall(function()
        monsfams = gui:WaitForChild("MONSFAMS", 10)
        targetFrame = monsfams:WaitForChild("Frame", 5)
        btn = targetFrame:WaitForChild("TextButton", 5)
    end)

    if not lookupSuccess or not btn then
        print("[AUTO CLOSE] REDUCE lookup failed:", lookupErr)
        return
    end

    local attempts = 0
    local minimized = false

    while attempts < 10 do
        attempts += 1

        print("[AUTO CLOSE]")
        print("[AUTO CLOSE] REDUCE Attempt:", attempts)
        print("[AUTO CLOSE] REDUCE Frame.Visible:", targetFrame.Visible)

        if not targetFrame.Visible then
            print("[AUTO CLOSE] REDUCE SUCCESS - already minimized")
            minimized = true
            break
        end

        pcall(function() firesignal(btn.MouseButton1Click) end)
        pcall(function() firesignal(btn.Activated) end)
        pcall(function() btn.MouseButton1Click:Fire() end)

        task.wait(1.5)

        print("[AUTO CLOSE] REDUCE After fire, Frame.Visible:", targetFrame.Visible)

        if not targetFrame.Visible then
            print("[AUTO CLOSE] REDUCE SUCCESS")
            minimized = true
            break
        end
    end

    if not minimized then
        print("[AUTO CLOSE] REDUCE FAILED after", attempts, "attempts - Frame.Visible still true")
    end
end

local function waitForMengHub()
    setStatus("WAITING DENG HUB...", Color3.fromRGB(255, 220, 50), Color3.fromRGB(255, 220, 50))
    while not CoreGui:FindFirstChild("MengHubGui") do
        task.wait(1)
    end
end

local function waitForDropShadow()
    setStatus("LOADING...", Color3.fromRGB(255, 165, 0), Color3.fromRGB(255, 165, 0))
    local mengHub = CoreGui:FindFirstChild("MengHubGui")
    local dropShadow
    while not dropShadow do
        dropShadow = mengHub:FindFirstChild("DropShadowHolder", true)
        task.wait(1)
    end
    while not dropShadow.Visible do
        task.wait(1)
    end
end

waitForMengHub()
waitForDropShadow()

setStatus("CLOSING DELTA...", Color3.fromRGB(255, 165, 0), Color3.fromRGB(255, 165, 0))

local whitelist = {
    "RobloxGui", "CoreScriptLocalization", "RobloxPromptGui", "TopBarApp",
    "ScreenshotsCarousel", "CaptureManager", "CaptureOverlay", "MomentsCreationFlow",
    "RobloxNetworkPauseNotification", "_FullscreenTestGui", "_DeviceTestGui",
    "SocialContextToast", "InExperienceInterventionApp", "PurchasePromptApp",
    "InExperienceDetailsPromptApp", "CallDialogScreen", "PlayerMenuScreen",
    "ContactList", "StyleSheet", "CursorContainer", "OnRootedListener",
    "FoundationCursorContainer", "AppChat", "ExperienceChat", "HeadsetDisconnectedDialog",
    "ShortcutBar", "PlayerList", "MengHubGui", "ToggleUIButton", "NotifyGui",
    "DevConsoleMaster", "RealPingDisplay", "AutoCloseStatus",
}

local deltaAttempts = 0
local deltaCleared = false

while deltaAttempts < 10 and not deltaCleared do
    deltaAttempts += 1

    for _, v in ipairs(CoreGui:GetChildren()) do
        local allowed = false
        for _, w in ipairs(whitelist) do
            if v.Name == w then allowed = true break end
        end
        if not allowed then
            pcall(function() v:Destroy() end)
        end
    end

    task.wait(0.3)

    local leftover = 0
    for _, v in ipairs(CoreGui:GetChildren()) do
        local allowed = false
        for _, w in ipairs(whitelist) do
            if v.Name == w then allowed = true break end
        end
        if not allowed then
            leftover += 1
        end
    end

    print("[AUTO CLOSE]")
    print("[AUTO CLOSE] DELTA Attempt:", deltaAttempts)
    print("[AUTO CLOSE] DELTA Leftover items:", leftover)

    if leftover == 0 then
        print("[AUTO CLOSE] DELTA SUCCESS")
        deltaCleared = true
    end
end

if not deltaCleared then
    print("[AUTO CLOSE] DELTA FINAL STATE: items may remain after", deltaAttempts, "attempts")
end

setStatus("CLOSING DENG HUB...", Color3.fromRGB(255, 165, 0), Color3.fromRGB(255, 165, 0))

local mengHub = CoreGui:FindFirstChild("MengHubGui")
local dropShadow = mengHub and mengHub:FindFirstChild("DropShadowHolder", true)

if dropShadow then

    local attempts = 0

    while attempts < 10 do

        attempts += 1

        print("[AUTO CLOSE]")
        print("[AUTO CLOSE] Attempt:", attempts)
        print("[AUTO CLOSE] DropShadow.Visible:", dropShadow.Visible)

        if not dropShadow.Visible then
            print("[AUTO CLOSE] SUCCESS")
            break
        end

        fireToggle()

        task.wait(1.5)

        if dropShadow.Visible then

            print("[AUTO CLOSE] Toggle failed")

            if attempts >= 5 then

                print("[AUTO CLOSE] Force Visible = false")

                pcall(function()
                    dropShadow.Visible = false
                end)

                task.wait(0.5)

if not dropShadow or not dropShadow.Parent then
    print("[AUTO CLOSE] DropShadow Destroyed")
    print("[AUTO CLOSE] FORCE SUCCESS")
    break
else
    print("[AUTO CLOSE] After Force:", dropShadow.Visible)

    if not dropShadow.Visible then
        print("[AUTO CLOSE] FORCE SUCCESS")
        break
    end
end
            end
        end
    end

if dropShadow and dropShadow.Parent and dropShadow.Visible then

    print("[AUTO CLOSE] FINAL FORCE")

    pcall(function()
        dropShadow.Visible = false
    end)

end

end

minimizeReduce()
task.wait(0.8)

setStatus("DONE", Color3.fromRGB(50, 255, 100), Color3.fromRGB(50, 255, 100))
task.wait(2)
screenGui:Destroy()

end

run()
