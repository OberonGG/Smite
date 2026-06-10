local CoreGui = game:GetService("CoreGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoCloseStatus"
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 50)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BackgroundTransparency = 0.3
frame.BorderSizePixel = 0
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, 0, 1, 0)
label.BackgroundTransparency = 1
label.TextColor3 = Color3.fromRGB(255, 255, 0)
label.TextScaled = true
label.Font = Enum.Font.GothamBold
label.Text = "⏳ AutoClose: Waiting..."
label.Parent = frame

local function setStatus(text, color)
   label.Text = text
   label.TextColor3 = color
end

local function waitForReady()
   setStatus("⏳ AutoClose: Waiting...", Color3.fromRGB(255, 255, 0))
   while not CoreGui:FindFirstChild("MengHubGui") 
   or not CoreGui:FindFirstChild("ToggleUIButton")
   or not CoreGui:FindFirstChild("NotifyGui") do
       task.wait(30)
   end
end

local function waitForFullyLoaded()
   setStatus("⏳ AutoClose: Loading...", Color3.fromRGB(255, 165, 0))
   local lastCount = 0
   local stableCount = 0
   while stableCount < 3 do
       local mengHub = CoreGui:FindFirstChild("MengHubGui")
       if mengHub then
           local currentCount = #mengHub:GetDescendants()
           if currentCount == lastCount then
               stableCount = stableCount + 1
           else
               stableCount = 0
               lastCount = currentCount
           end
       end
       task.wait(5)
   end
end

waitForReady()
waitForFullyLoaded()

setStatus("⚙️ AutoClose: Closing...", Color3.fromRGB(255, 165, 0))

local whitelist = {
   "RobloxGui",
   "CoreScriptLocalization",
   "RobloxPromptGui",
   "TopBarApp",
   "ScreenshotsCarousel",
   "CaptureManager",
   "CaptureOverlay",
   "MomentsCreationFlow",
   "RobloxNetworkPauseNotification",
   "_FullscreenTestGui",
   "_DeviceTestGui",
   "SocialContextToast",
   "InExperienceInterventionApp",
   "PurchasePromptApp",
   "InExperienceDetailsPromptApp",
   "CallDialogScreen",
   "PlayerMenuScreen",
   "ContactList",
   "StyleSheet",
   "CursorContainer",
   "OnRootedListener",
   "FoundationCursorContainer",
   "AppChat",
   "ExperienceChat",
   "HeadsetDisconnectedDialog",
   "ShortcutBar",
   "PlayerList",
   "MengHubGui",
   "ToggleUIButton",
   "NotifyGui",
   "DevConsoleMaster",
   "RealPingDisplay",
   "AutoCloseStatus",
}

for _, v in ipairs(CoreGui:GetChildren()) do
   local allowed = false
   for _, w in ipairs(whitelist) do
       if v.Name == w then
           allowed = true
           break
       end
   end
   if not allowed then
       pcall(function() v:Destroy() end)
   end
end

local function tryToggle()
   for _, v in ipairs(CoreGui:GetChildren()) do
       if v.Name == "ToggleUIButton" then
           local btn = v:FindFirstChild("TextButton", true)
           if btn then
               pcall(function() firesignal(btn.MouseButton1Click) end)
               pcall(function() firesignal(btn.MouseButton1Down) end)
               pcall(function() firesignal(btn.Activated) end)
           end
       end
   end
end

for i = 1, 10 do
   local mengHub = CoreGui:FindFirstChild("MengHubGui")
   if mengHub and not mengHub.Enabled then
       break
   end
   tryToggle()
   task.wait(3)
end

local deltaStillOpen = false
for _, v in ipairs(CoreGui:GetChildren()) do
   local inWhitelist = false
   for _, w in ipairs(whitelist) do
       if v.Name == w then
           inWhitelist = true
           break
       end
   end
   if not inWhitelist then
       deltaStillOpen = true
       break
   end
end

local mengHubHidden = false
local mengHub = CoreGui:FindFirstChild("MengHubGui")
if mengHub and not mengHub.Enabled then
   mengHubHidden = true
end

if not deltaStillOpen and mengHubHidden then
   setStatus("✅ AutoClose: Done!", Color3.fromRGB(0, 255, 0))
else
   setStatus("⚠️ AutoClose: Check!", Color3.fromRGB(255, 0, 0))
end

task.wait(5)
screenGui:Destroy()