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

for _, v in ipairs(CoreGui:GetChildren()) do
    if v.Name == "ToggleUIButton" then
        local btn = v:FindFirstChild("TextButton", true)
        if btn then
            firesignal(btn.MouseButton1Click)
        end
    end
end
