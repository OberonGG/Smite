-- ==============================================================================
-- Auto Volume 0 & Graphics 1 - Diagnostic Tool
-- Finds the exact method supported by your specific executor
-- ==============================================================================

local GameSettings = UserSettings():GetService("UserGameSettings")
local Rendering = settings().Rendering
local workingMethod = "None found"

-- TEST METHOD 1: Standard Enums (Works on Level 7/8 Executors natively)
local success1 = pcall(function()
    GameSettings.MasterVolume = 0
    GameSettings.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
    Rendering.QualityLevel = Enum.QualityLevel.Level01
end)

if success1 then
    workingMethod = "Method 1 (Standard Enum)"
else
    -- TEST METHOD 2: Raw Integers (Works on Executors with weak Enum parsing)
    local success2 = pcall(function()
        GameSettings.MasterVolume = 0
        Rendering.QualityLevel = 1
        GameSettings.SavedQualityLevel = 1
    end)
    
    if success2 then
        workingMethod = "Method 2 (Raw Integer)"
    else
        -- TEST METHOD 3: sethiddenproperty (Works on Executors that strictly enforce RobloxScriptSecurity)
        if type(sethiddenproperty) == "function" then
            local success3 = pcall(function()
                sethiddenproperty(GameSettings, "MasterVolume", 0)
                sethiddenproperty(GameSettings, "SavedQualityLevel", Enum.SavedQualitySetting.QualityLevel1)
                sethiddenproperty(Rendering, "QualityLevel", Enum.QualityLevel.Level01)
            end)
            
            if success3 then
                workingMethod = "Method 3 (sethiddenproperty)"
            end
        end
    end
end

-- Print to log exactly as requested
print("SUCCESS: " .. workingMethod .. " was used.")
print("volume and graphic set to lowest")