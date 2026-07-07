--[[
    Fish It - Reduce Map (Dark Grey Fix & Progressive Delay)
    Mencegah sistem cuaca/siang-malam game menimpa settingan reduce map.
]]

local AUTO_REPEAT = true     -- Set ke false jika hanya ingin berjalan sekali
local REPEAT_INTERVAL = 60   -- Jeda waktu (detik) untuk pembersihan ulang otomatis
local BATCH_SIZE = 40        -- Jumlah objek yang diproses sebelum memberi jeda frame (mencegah lag)
local DELAY_STEP = 3         -- Jeda waktu (detik) antar proses sesuai permintaan

local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")

-- Daftar objek dekorasi, efek cuaca, dan post-processing yang akan dihapus
local DECORATIVE_CLASSES = {
    ParticleEmitter = true, Smoke = true, Fire = true, Sparkles = true,
    Beam = true, Trail = true, Explosion = true, Discharge = true,
    Dust = true, PointLight = true, SpotLight = true, SurfaceLight = true,
    Decal = true, Texture = true, SurfaceAppearance = true,
    Atmosphere = true, ColorCorrectionEffect = true, BloomEffect = true,
    SunRaysEffect = true, BlurEffect = true, DepthOfFieldEffect = true
}

-- [PENTING] Mengunci Lighting agar script Day/Night bawaan game tidak bisa mengembalikan cahaya map
RunService.RenderStepped:Connect(function()
    Lighting.GlobalShadows = false
    Lighting.Brightness = 0 
    Lighting.Ambient = Color3.fromRGB(30, 30, 30) 
    Lighting.OutdoorAmbient = Color3.fromRGB(30, 30, 30) 
    Lighting.FogColor = Color3.fromRGB(30, 30, 30) 
    
    -- Trik Kabut Instan: Memaksa seluruh objek di luar jangkauan 0 stud menjadi flat Dark Grey
    Lighting.FogStart = 0
    Lighting.FogEnd = 0 
    
    Lighting.TimeOfDay = "00:00:00" 
end)

-- Fungsi eksekusi reduce secara perlahan/bertahap
local function runReduce()
    print("[Reduce] Memulai pembersihan map...")

    -- Langkah 1: Hapus Sky dan Clouds bawaan biar langit flat
    pcall(function()
        local sky = workspace:FindFirstChildOfClass("Sky") or Lighting:FindFirstChildOfClass("Sky")
        if sky then sky:Destroy() end
        local clouds = workspace:FindFirstChildOfClass("Clouds") or Lighting:FindFirstChildOfClass("Clouds")
        if clouds then clouds:Destroy() end
    end)
    print("[Reduce] Langkah 1 Selesai: Sky & Clouds dihapus. Menunggu 3 detik...")
    task.wait(DELAY_STEP)

    -- Langkah 2: Hapus Terrain air/tanah voxels
    pcall(function()
        workspace.Terrain:Clear()
    end)
    print("[Reduce] Langkah 2 Selesai: Terrain dibersihkan. Menunggu 3 detik...")
    task.wait(DELAY_STEP)

    -- Langkah 3: Hapus partikel, dekorasi, efek pencahayaan, dan sisa post-processing
    local removed, processed = 0, 0
    for _, inst in ipairs(workspace:GetDescendants()) do
        if DECORATIVE_CLASSES[inst.ClassName] or inst:IsA("PostEffect") then
            if pcall(function() inst:Destroy() end) then
                removed += 1
            end
        elseif inst:IsA("Sound") then
            pcall(function() inst.Volume = 0 end)
        end
        
        processed += 1
        if processed % BATCH_SIZE == 0 then
            task.wait(0.05) -- Jeda mikro saat looping agar executor tidak crash/freeze
        end
    end
    print(("[Reduce] Langkah 3 Selesai: %d objek dekorasi dihancurkan. Menunggu 3 detik..."):format(removed))
    task.wait(DELAY_STEP)

    -- Langkah 4: Mematikan musik background di SoundService
    for _, inst in ipairs(SoundService:GetDescendants()) do
        if inst:IsA("Sound") then
            pcall(function() inst.Volume = 0 end)
        end
    end
    print("[Reduce] Langkah 4 Selesai: Seluruh suara berhasil dimatikan.")
end

-- Menjalankan fungsi reduce utama pertama kali
task.spawn(runReduce)

-- Perulangan berkala untuk membersihkan objek baru yang di-stream oleh game
if AUTO_REPEAT then
    task.spawn(function()
        while task.wait(REPEAT_INTERVAL) do
            runReduce()
        end
    end)
end