--[[
    Fish It - Reduce Map (Dark Grey & Slowed Down Version)
    No UI, no FPS cap, no external loadstring calls - this is the whole script.
]]

local AUTO_REPEAT = true     -- set to false to run once and stop
local REPEAT_INTERVAL = 60   -- seconds between automatic re-runs
local BATCH_SIZE = 50        -- instances processed before yielding a frame
local DELAY_STEP = 3         -- Jeda waktu (dalam detik) antar proses reduce

local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")

-- Instance classes treated as purely decorative / render-heavy
local DECORATIVE_CLASSES = {
    ParticleEmitter = true,
    Smoke = true,
    Fire = true,
    Sparkles = true,
    Beam = true,
    Trail = true,
    Explosion = true,
    Discharge = true,
    Dust = true,
    PointLight = true,
    SpotLight = true,
    SurfaceLight = true,
    Decal = true,
    Texture = true,
    SurfaceAppearance = true,
}

local function reduceLighting()
    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.Brightness = 0 
        Lighting.Ambient = Color3.fromRGB(30, 30, 30) 
        Lighting.OutdoorAmbient = Color3.fromRGB(30, 30, 30) 
        Lighting.FogColor = Color3.fromRGB(30, 30, 30) 
        Lighting.TimeOfDay = "00:00:00" 
    end)
    pcall(function()
        UserSettings():GetService("UserGameSettings").SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
    end)
end

local function removeSkyAndClouds()
    pcall(function()
        local sky = workspace:FindFirstChildOfClass("Sky")
        if sky then sky:Destroy() end
    end)
    pcall(function()
        local clouds = workspace:FindFirstChildOfClass("Clouds")
        if clouds then clouds:Destroy() end
    end)
end

local function clearTerrain()
    pcall(function()
        workspace.Terrain:Clear()
    end)
end

local function cleanWorkspace()
    local removed, processed = 0, 0
    for _, inst in ipairs(workspace:GetDescendants()) do
        if DECORATIVE_CLASSES[inst.ClassName] then
            if pcall(function() inst:Destroy() end) then
                removed += 1
            end
        elseif inst:IsA("Sound") then
            pcall(function() inst.Volume = 0 end)
        end
        processed += 1
        if processed % BATCH_SIZE == 0 then
            task.wait(0.1) -- Sedikit delay ekstra saat menghapus tumpukan part agar tidak lag/instant
        end
    end
    return removed
end

local function muteBackgroundMusic()
    for _, inst in ipairs(SoundService:GetDescendants()) do
        if inst:IsA("Sound") then
            pcall(function() inst.Volume = 0 end)
        end
    end
end

local function runReduce()
    reduceLighting()
    task.wait(DELAY_STEP) -- Nunggu 3 detik setelah ubah cahaya
    
    removeSkyAndClouds()
    task.wait(DELAY_STEP) -- Nunggu 3 detik setelah hapus langit
    
    clearTerrain()
    task.wait(DELAY_STEP) -- Nunggu 3 detik setelah hapus terrain
    
    local removed = cleanWorkspace()
    task.wait(DELAY_STEP) -- Nunggu 3 detik setelah bersihin part
    
    muteBackgroundMusic()
    print(("[Reduce] done - %d decorative instances removed"):format(removed))
end

runReduce()

if AUTO_REPEAT then
    task.spawn(function()
        while task.wait(REPEAT_INTERVAL) do
            runReduce()
        end
    end)
end