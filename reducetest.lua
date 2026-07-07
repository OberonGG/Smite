--[[
    Fish It - Multi-Instance Ultra Reduce (Anti-Crash Edition)
    - Sangat aman untuk dijalankan di 5+ instance sekaligus.
    - Menggunakan sistem Batch Processing agar CPU emulator tidak overload.
    - Latar belakang Dark Grey & Karakter Abu-abu Polos tetap aktif.
]]

local AUTO_REPEAT = true
local REPEAT_INTERVAL = 60
local BATCH_SIZE = 30 -- Mengolah 30 objek per frame (angka paling aman untuk multi-instance)

local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local DECORATIVE_CLASSES = {
    ParticleEmitter = true, Smoke = true, Fire = true, Sparkles = true,
    Beam = true, Trail = true, Explosion = true, Discharge = true,
    Dust = true, PointLight = true, SpotLight = true, SurfaceLight = true,
    Decal = true, Texture = true, SurfaceAppearance = true,
    Atmosphere = true, ColorCorrectionEffect = true, BloomEffect = true,
    SunRaysEffect = true, BlurEffect = true, DepthOfFieldEffect = true
}

-- Fungsi bersihkan karakter (dibuat seefisien mungkin)
local function cleanCharacter(char)
    if not char then return end
    
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Accessory") or child:IsA("Shirt") or child:IsA("Pants") 
        or child:IsA("CharacterMesh") or child:IsA("ShirtGraphic") or child:IsA("BodyColors") then
            pcall(function() child:Destroy() end)
        end
    end
    
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Color = Color3.fromRGB(150, 150, 150)
            part.Material = Enum.Material.SmoothPlastic
            local face = part:FindFirstChildOfClass("Decal")
            if face then pcall(function() face:Destroy() end) end
        end
    end
end

-- Mengunci pencahayaan dunia (Dark Grey) secara konstan
RunService.RenderStepped:Connect(function()
    Lighting.GlobalShadows = false
    Lighting.Brightness = 0 
    Lighting.Ambient = Color3.fromRGB(35, 35, 35) 
    Lighting.OutdoorAmbient = Color3.fromRGB(35, 35, 35) 
    Lighting.FogColor = Color3.fromRGB(35, 35, 35) 
    Lighting.FogStart = 0
    Lighting.FogEnd = 250 
    Lighting.TimeOfDay = "00:00:00" 
end)

-- Fungsi utama reduce map dengan pengaman Batch
local function runReduce()
    -- Hapus Sky & Clouds
    pcall(function()
        local sky = workspace:FindFirstChildOfClass("Sky") or Lighting:FindFirstChildOfClass("Sky")
        if sky then sky:Destroy() end
        local clouds = workspace:FindFirstChildOfClass("Clouds") or Lighting:FindFirstChildOfClass("Clouds")
        if clouds then clouds:Destroy() end
        workspace.Terrain:Clear()
    end)

    local objectsProcessed = 0

    -- Scanning seluruh workspace secara berkala (tidak bikin freeze)
    for _, inst in ipairs(workspace:GetDescendants()) do
        if not inst:IsDescendantOf(LocalPlayer.Character) then
            
            -- Eksekusi penghancuran atau perubahan material
            if DECORATIVE_CLASSES[inst.ClassName] or inst:IsA("PostEffect") then
                pcall(function() inst:Destroy() end)
            elseif inst:IsA("BasePart") then
                inst.Material = Enum.Material.SmoothPlastic
            elseif inst:IsA("Sound") then
                pcall(function() inst.Volume = 0 end)
            end
            
            -- REM UTAMA: Setiap memproses 30 objek, istirahatkan script selama 1 frame
            objectsProcessed = objectsProcessed + 1
            if objectsProcessed % BATCH_SIZE == 0 then
                RunService.Heartbeat:Wait()
            end
        end
    end

    -- Bersihkan karakter lokal
    if LocalPlayer.Character then
        cleanCharacter(LocalPlayer.Character)
    end
    
    -- Mute Audio global
    for _, inst in ipairs(SoundService:GetDescendants()) do
        if inst:IsA("Sound") then
            pcall(function() inst.Volume = 0 end)
        end
    end
end

-- Proteksi otomatis saat karakter respawn
LocalPlayer.CharacterAdded:Connect(function(newChar)
    RunService.Heartbeat:Wait()
    cleanCharacter(newChar)
end)

-- Jalankan eksekusi pertama
task.spawn(runReduce)

-- Pembersihan otomatis berkala
if AUTO_REPEAT then
    task.spawn(function()
        while task.wait(REPEAT_INTERVAL) do
            runReduce()
        end
    end)
end