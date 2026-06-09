task.wait(60)

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
    "MengHubGui",  -- exclude, jangan di-destroy
    "ToggleUIButton",
    "NotifyGui",
    "DevConsoleMaster",
}

for _, v in ipairs(game:GetService("CoreGui"):GetChildren()) do
    local allowed = false
    for _, w in ipairs(whitelist) do
        if v.Name == w then
            allowed = true
            break
        end
    end
    if not allowed then
        pcall(function() v:Destroy() end)
        print("Destroyed: " .. v.Name)
    end
end
