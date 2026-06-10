task.wait(10)

local CoreGui = game:GetService("CoreGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoCloseStatus"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999
screenGui.Parent = CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 260, 0, 80)
frame.Position = UDim2.new(0.5, -130, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 0
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 6)
corner.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(212, 175, 55)
stroke.Thickness = 1.5
stroke.Parent = frame

local topLine = Instance.new("Frame")
topLine.Size = UDim2.new(1, 0, 0, 2)
topLine.Position = UDim2.new(0, 0, 0, 0)
topLine.BackgroundColor3 = Color3.fromRGB(212, 175, 55)
topLine.BorderSizePixel = 0
topLine.Parent = frame

local topLineCorner = Instance.new("UICorner")
topLineCorner.CornerRadius = UDim.new(0, 6)
topLineCorner.Parent = topLine

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -10, 0, 22)
titleLabel.Position = UDim2.new(0, 10, 0, 6)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(212, 175, 55)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Text = "AUTO CLOSE  //  SYS"
titleLabel.Parent = frame

local divider = Instance.new("Frame")
divider.Size = UDim2.new(1, -20, 0, 1)
divider.Position = UDim2.new(0, 10, 0, 30)
divider.BackgroundColor3 = Color3.fromRGB(212, 175, 55)
divider.BackgroundTransparency = 0.7
divider.BorderSizePixel = 0
divider.Parent = frame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -10, 0, 30)
statusLabel.Position = UDim2.new(0, 10, 0, 38)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.TextScaled = true
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Text = "> INITIALIZING..."
statusLabel.Parent = frame

local dot = Instance.new("Frame")
dot.Size = UDim2.new(0, 8, 0, 8)
dot.Position = UDim2.new(1, -18, 0, 10)
dot.BackgroundColor3 = Color3.fromRGB(212, 175, 55)
dot.BorderSizePixel = 0
dot.Parent = frame

local dotCorner = Instance.new("UICorner")
dotCorner.CornerRadius = UDim.new(1, 0)
dotCorner.Parent = dot

local function setStatus(text, color, dotColor)
   statusLabel.Text = "> " .. text
   statusLabel.TextColor3 = color
   dot.BackgroundColor3 = dotColor or color
end

local function isMengHubVisible()
   local mengHub = CoreGui:FindFirstChild("MengHubGui")
   if not mengHub then return false end
   local dropShadow = mengHub:FindFirstChild("DropShadowHolder", true)
   if dropShadow then
       return dropShadow.Visible
   end
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

local function waitForMengHub()
   setStatus("WAITING DENG HUB...", Color3.fromRGB(255, 220, 50), Color3.fromRGB(255, 220, 50))
   while not CoreGui:FindFirstChild("MengHubGui") do
       task.wait(1)
   end
end

local function waitForDropShadow()
   setStatus("LOADING MODULES...", Color3.fromRGB(255, 165, 0), Color3.fromRGB(255, 165, 0))
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

-- Loop sampai berhasil
while isMengHubVisible() do
   fireToggle()
   task.wait(2)
end

setStatus("SYSTEM  //  DONE", Color3.fromRGB(50, 255, 100), Color3.fromRGB(50, 255, 100))
task.wait(2)
screenGui:Destroy()
