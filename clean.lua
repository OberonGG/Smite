local CoreGui = game:GetService("CoreGui")

local function isReady()
    return CoreGui:FindFirstChild("MengHubGui") ~= nil
    and CoreGui:FindFirstChild("ToggleUIButton") ~= nil
    and CoreGui:FindFirstChild("NotifyGui") ~= nil
end

local function waitForReady()
    if not isReady() then
        task.wait(180)
    end
    while not isReady() do
        task.wait(5)
    end
end

local function waitForFullyLoaded()
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

for i = 1, 5 do
    local mengHub = CoreGui:FindFirstChild("MengHubGui")
    if mengHub and not mengHub.Enabled then
        break
    end
    for _, v in ipairs(CoreGui:GetChildren()) do
        if v.Name == "ToggleUIButton" then
            local btn = v:FindFirstChild("TextButton", true)
            if btn then
                firesignal(btn.MouseButton1Click)
            end
        end
    end
    task.wait(3)
end