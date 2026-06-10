local CoreGui = game:GetService("CoreGui")

local function waitForReady()
    while not CoreGui:FindFirstChild("MengHubGui") 
    or not CoreGui:FindFirstChild("ToggleUIButton") do
        task.wait(2)
    end
end

waitForReady()
task.wait(3)

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

-- Retry toggle
local maxRetry = 5
local attempt = 0

local function tryToggle()
    for _, v in ipairs(CoreGui:GetChildren()) do
        if v.Name == "ToggleUIButton" then
            local btn = v:FindFirstChild("TextButton", true)
            if btn then
                firesignal(btn.MouseButton1Click)
                return true
            end
        end
    end
    return false
end

while attempt < maxRetry do
    task.wait(2)
    local mengHub = CoreGui:FindFirstChild("MengHubGui")
    if mengHub and mengHub.Enabled then
        tryToggle()
        attempt = attempt + 1
    else
        break
    end
end
