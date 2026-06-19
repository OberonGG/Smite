local CoreGui = game:GetService("CoreGui")

local function run()

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoCloseStatus"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999
screenGui.Parent = CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 285, 0, 88)
frame.Position = UDim2.new(0.5, -142, 0, 18)
frame.BackgroundColor3 = Color3.fromRGB(10,10,10)
frame.BackgroundTransparency = 0.08
frame.BorderSizePixel = 0
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0,16)
corner.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(212,175,55)
stroke.Thickness = 1.3
stroke.Parent = frame

local header = Instance.new("Frame")
header.Size = UDim2.new(1,0,0,26)
header.BackgroundColor3 = Color3.fromRGB(12,12,12)
header.BorderSizePixel = 0
header.Parent = frame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0,16)
headerCorner.Parent = header

local goldLine = Instance.new("Frame")
goldLine.Size = UDim2.new(1,0,0,2)
goldLine.BackgroundColor3 = Color3.fromRGB(212,175,55)
goldLine.BorderSizePixel = 0
goldLine.Parent = header

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1,-32,1,0)
titleLabel.Position = UDim2.new(0,12,0,0)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.SciFi
titleLabel.Text = "AUTO CLOSE SYSTEM"
titleLabel.TextColor3 = Color3.fromRGB(212,175,55)
titleLabel.TextSize = 15
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = header

local dot = Instance.new("Frame")
dot.Size = UDim2.new(0,8,0,8)
dot.Position = UDim2.new(1,-18,0,9)
dot.BackgroundColor3 = Color3.fromRGB(212,175,55)
dot.BorderSizePixel = 0
dot.Parent = header

local dotCorner = Instance.new("UICorner")
dotCorner.CornerRadius = UDim.new(1,0)
dotCorner.Parent = dot

local subLabel = Instance.new("TextLabel")
subLabel.Size = UDim2.new(1,-24,0,12)
subLabel.Position = UDim2.new(0,12,0,31)
subLabel.BackgroundTransparency = 1
subLabel.Font = Enum.Font.RobotoMono
subLabel.Text = "a useless tool."
subLabel.TextColor3 = Color3.fromRGB(150,150,150)
subLabel.TextSize = 10
subLabel.TextXAlignment = Enum.TextXAlignment.Left
subLabel.Parent = frame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1,-24,0,28)
statusLabel.Position = UDim2.new(0,12,0,49)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.Code
statusLabel.TextColor3 = Color3.fromRGB(255,255,255)
statusLabel.TextSize = 16
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Text = "▸ INITIALIZING..."
statusLabel.Parent = frame

local function setStatus(text, color, dotColor)
    statusLabel.Text = "> " .. text
    statusLabel.TextColor3 = color
    dot.BackgroundColor3 = dotColor or color
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
    setStatus("CLOSING REDUCE...", Color3.fromRGB(255, 165, 0), Color3.fromRGB(255, 165, 0))
    local Players = game:GetService("Players")
    local gui = Players.LocalPlayer:WaitForChild("PlayerGui", 10)
    if not gui then
        print("[AUTO CLOSE] PlayerGui not found")
        return
    end

    local attempts = 0
    local fired = false

    while attempts < 5 and not fired do
        attempts += 1
        print("[AUTO CLOSE] REDUCE Attempt:", attempts)

        local success, err = pcall(function()
            local monsfams = gui:WaitForChild("MONSFAMS", 5)
            local btn = monsfams.Frame:WaitForChild("TextButton", 5)
            pcall(function() firesignal(btn.MouseButton1Click) end)
            pcall(function() firesignal(btn.Activated) end)
            pcall(function() btn.MouseButton1Click:Fire() end)
            fired = true
        end)

        if not success then
            print("[AUTO CLOSE] REDUCE failed:", err)
            task.wait(2)
        end
    end

    if not fired then
        print("[AUTO CLOSE] REDUCE MONSFAMS not found after", attempts, "attempts")
    else
        print("[AUTO CLOSE] REDUCE SUCCESS")
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

for _, v in ipairs(CoreGui:GetChildren()) do
    local allowed = false
    for _, w in ipairs(whitelist) do
        if v.Name == w then allowed = true break end
    end
    if not allowed then
        pcall(function() v:Destroy() end)
    end
end

setStatus("CLOSING DENG HUB...", Color3.fromRGB(255, 165, 0), Color3.fromRGB(255, 165, 0))

local mengHub = CoreGui:FindFirstChild("MengHubGui")
local dropShadow = mengHub and mengHub:FindFirstChild("DropShadowHolder", true)

if dropShadow then

    local attempts = 0

    while attempts < 15 do

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
