--[[
    Fish It - Ultra Reduce Map & Grey Character (Strict Sequential Edition)
    - Mengubah karakter menjadi abu-abu polos tanpa aksesoris/baju.
    - Menutup layar game (3D View) menjadi hitam pekat seperti foto pertama.
    - Menggunakan logika tunggu destroy selesai (tanpa hardcoded task.wait delay).
    - Memaksa material seluruh part menjadi SmoothPlastic agar semakin low-end friendly.
]]

local AUTO_REPEAT = true
local REPEAT_INTERVAL = 45

local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Daftar objek dekorasi berat yang wajib dimusnahkan
local DECORATIVE_CLASSES = {
    ParticleEmitter = true, Smoke = true, Fire = true, Sparkles = true,
    Beam = true, Trail = true, Explosion = true, Discharge = true,
    Dust = true, PointLight = true, SpotLight = true, SurfaceLight = true,
    Decal = true, Texture = true, SurfaceAppearance = true,
    Atmosphere = true, ColorCorrectionEffect = true, BloomEffect = true,
    SunRaysEffect = true, BlurEffect = true, DepthOfFieldEffect = true
}

-- Logika Utama: Tunggu part benar-benar selesai ke-destroy baru lanjut
local function safeDestroy(inst)
    if not inst or not inst.Parent then return end
    
    pcall(function()
        inst:Destroy()
    end)
    
    -- Loop penahan: Jika part belum benar-benar terhapus (parent bukan nil), tunggu frame berikutnya
    local frameTimeout = 0
    while inst.Parent ~= nil and frameTimeout < 10 do 
        RunService.Heartbeat:Wait()
        frameTimeout = frameTimeout + 1
    end
end

-- Fungsi mengubah karakter menjadi abu-abu polos & hapus semua aksesoris
local function cleanCharacter(char)
    if not char then return end
    
    -- 1. Hapus aksesoris, baju, celana, dan kustomisasi tubuh secara berurutan
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Accessory") or child:IsA("Shirt") or child:IsA("Pants") 
        or child:IsA("CharacterMesh") or child:IsA("ShirtGraphic") or child:IsA("BodyColors") then
            safeDestroy(child)
        end
    end
    
    -- 2. Ubah warna tubuh part demi part menjadi abu-abu polos & hapus tekstur wajah
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Color = Color3.fromRGB(120, 120, 120) -- Warna abu-abu delta lite
            part.Material = Enum.Material.SmoothPlastic
            
            -- Cari dan hapus stiker wajah (face decal)
            local face = part:FindFirstChildOfClass("Decal")
            if face then safeDestroy(face) end
        end
    end
end

-- Mengunci background layar/3D world agar hitam pekat secara konstan
RunService.RenderStepped:Connect(function()
    Lighting.GlobalShadows = false
    Lighting.Brightness = 0 
    Lighting.Ambient = Color3.fromRGB(0, 0, 0) -- Hitam pekat sesuai foto pertama
    Lighting.OutdoorAmbient = Color3.fromRGB(0, 0, 0) 
    Lighting.FogColor = Color3.fromRGB(0, 0, 0) 
    Lighting.FogStart = 0
    Lighting.FogEnd = 0 -- Mengunci pandangan dunia 3D agar tertutup hitam flat
    Lighting.TimeOfDay = "00:00:00" 
end)

-- Eksekusi penghancuran map secara sekuensial (berurutan dan logis)
local function runReduce()
    -- Langkah 1: Bersihkan objek langit
    local sky = workspace:FindFirstChildOfClass("Sky") or Lighting:FindFirstChildOfClass("Sky")
    if sky then safeDestroy(sky) end
    
    local clouds = workspace:FindFirstChildOfClass("Clouds") or Lighting:FindFirstChildOfClass("Clouds")
    if clouds then safeDestroy(clouds) end

    -- Langkah 2: Bersihkan Terrain Voxel
    pcall(function()
        workspace.Terrain:Clear()
    end)

    -- Langkah 3: Bersihkan dekorasi & turunkan material part map secara berurutan
    for _, inst in ipairs(workspace:GetDescendants()) do
        -- Pastikan tidak menghapus part dari karakter kita sendiri saat pembersihan map
        if not inst:IsDescendantOf(LocalPlayer.Character) then
            if DECORATIVE_CLASSES[inst.ClassName] or inst:IsA("PostEffect") then
                safeDestroy(inst)
            elseif inst:IsA("BasePart") then
                -- Mengubah struktur objek game menjadi SmoothPlastic agar super ringan (semakin low)
                inst.Material = Enum.Material.SmoothPlastic
            elseif inst:IsA("Sound") then
                pcall(function() inst.Volume = 0 end)
            end
        end
    end

    -- Langkah 4: Bersihkan karakter lokal
    if LocalPlayer.Character then
        cleanCharacter(LocalPlayer.Character)
    end
    
    -- Langkah 5: Mute Audio global
    for _, inst in ipairs(SoundService:GetDescendants()) do
        if inst:IsA("Sound") then
            pcall(function() inst.Volume = 0 end)
        end
    end
end

-- Mengamankan karakter jika respawn/mati agar otomatis kembali abu-abu polos
LocalPlayer.CharacterAdded:Connect(function(newChar)
    RunService.Heartbeat:Wait() -- Beri jeda 1 frame agar karakter ter-load sempurna
    cleanCharacter(newChar)
end)

-- Jalankan performa pertama
task.spawn(runReduce)

-- Otomatisasi pembersihan berkala untuk part baru yang masuk (streaming-in)
if AUTO_REPEAT then
    task.spawn(function()
        while task.wait(REPEAT_INTERVAL) do
            runReduce()
        end
    end)
end