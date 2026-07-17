local userGameSettings = UserSettings():GetService("UserGameSettings")
local renderSettings = settings().Rendering

local function applyLowestSettings()
    -- 1. Set the Escape Menu Graphics setting to lowest (1)
    -- Note: Uses Enum.SavedQualitySetting
    userGameSettings.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
    
    -- 2. Set the Escape Menu Volume to muted (0)
    userGameSettings.MasterVolume = 0
    
    -- 3. Force the active Rendering engine quality to lowest
    -- Note: Uses Enum.QualityLevel (different Enum than the Escape menu!)
    renderSettings.QualityLevel = Enum.QualityLevel.Level01
end

-- Try applying the settings directly (works natively on most high-identity executors)
local success, err = pcall(applyLowestSettings)

-- Fallback for executors that strictly enforce RobloxScriptSecurity 
-- but provide the 'sethiddenproperty' function.
if not success and type(sethiddenproperty) == "function" then
    local fallbackSuccess = pcall(function()
        sethiddenproperty(userGameSettings, "SavedQualityLevel", Enum.SavedQualitySetting.QualityLevel1)
        sethiddenproperty(userGameSettings, "MasterVolume", 0)
        sethiddenproperty(renderSettings, "QualityLevel", Enum.QualityLevel.Level01)
    end)
    
    if fallbackSuccess then
        success = true
    end
end

-- Output requested by user
if success then
    print("volume and graphic set to lowest")
else
    warn("Failed to set settings. Your executor might not support modifying RobloxScriptSecurity properties. Error: " .. tostring(err))
end