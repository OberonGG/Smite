-- ==============================================================================
-- Brute-Force Auto Volume 0 & Graphics 1 for Mobile/Delta Executors
-- ==============================================================================

local GameSettings = UserSettings():GetService("UserGameSettings")
local Rendering = settings().Rendering

local function forceLowestSettings()
    -- METHOD 1: Standard Enum Assignment
    pcall(function()
        GameSettings.MasterVolume = 0
        GameSettings.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
        Rendering.QualityLevel = Enum.QualityLevel.Level01
    end)

    -- METHOD 2: Raw Integer Assignment (Crucial for Delta Lite on Android)
    pcall(function()
        Rendering.QualityLevel = 1
        GameSettings.SavedQualityLevel = 1
    end)

    -- METHOD 3: sethiddenproperty fallback (if Delta is running at a lower identity)
    if type(sethiddenproperty) == "function" then
        pcall(function() sethiddenproperty(GameSettings, "MasterVolume", 0) end)
        pcall(function() sethiddenproperty(GameSettings, "SavedQualityLevel", Enum.SavedQualitySetting.QualityLevel1) end)
        pcall(function() sethiddenproperty(Rendering, "QualityLevel", Enum.QualityLevel.Level01) end)
    end
end

-- Execute the brute-force function
forceLowestSettings()

-- Exact output requested
print("volume and graphic set to lowest")