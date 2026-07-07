--[[
    Fish It - Multi-Instance Ultra Reduce (Anti-Crash & NPC Wipe Edition)
    - Jeda waktu pengulangan diatur menjadi 1 jam sekali (3600 detik).
    - Menghilangkan rendering Joran (Rod), Aura, efek pancingan, dan Pets.
    - Menghapus seluruh NPC (Pedagang, Quest, dll) di seluruh Map.
    - Latar belakang Dark Grey & Karakter Abu-abu Polos tetap aktif.
]]

local AUTO_REPEAT = true
local REPEAT_INTERVAL = 3600 -- Diubah menjadi 3600 detik (Tepat 1 Jam Sekali)
local BATCH_SIZE = 30        -- Mengolah 30 objek per frame (Sangat aman untuk 5 instance)

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
    SunRaysEffect = true, BlurEffect = true, DepthOfFieldEffect = true,
    Highlight = true, SelectionBox = true
}

-- Daftar bagian tubuh inti agar tidak ikut terhapus saat membersihkan joran/aksesoris
local CORE_LIMBS = {
    ["Head"] = true, ["Torso"] = true, ["Left Arm"] = true, ["Right Arm"] = true, ["Left Leg"] = true, ["Right Leg"] = true,
    ["HumanoidRootPart"] = true, ["UpperTorso"] = true, ["LowerTorso"] = true, 
    ["LeftUpperArm"] = true, ["LeftLowerArm"] = true, ["LeftHand"] = true,
    ["RightUpperArm"] = true, ["RightLowerArm"] = true, ["RightHand"] = true,
    ["LeftUpperLeg"] = true, ["LeftLowerLeg"] = true, ["LeftFoot"] = true,
    ["RightUpperLeg"] = true, ["RightLowerLeg"] = true, ["RightFoot"] = true
}

-- Fungsi super-clean untuk Karakter, Aksesoris, dan Joran (Rod)
local function cleanCharacterAndTools(char)
    if not char then return end
    
    for _, inst in ipairs(char:GetDescendants()) do
        if inst:IsA("Accessory") or inst:IsA("Shirt") or inst:IsA("Pants") 
        or inst:IsA("ShirtGraphic") or inst:IsA("BodyColors") or inst:IsA("CharacterMesh") then
            pcall(function() inst:Destroy() end)
        elseif inst:IsA("BasePart") then
            if not CORE_LIMBS[inst.Name] then
                -- Menghilangkan joran, aksesoris custom, aura, atau attachments pancingan
                inst.Transparency = 1
                inst.LocalTransparencyModifier = 1
            else
                -- Mengunci warna abu-abu polos pada tubuh asli karakter
                inst.Color = Color3.fromRGB(150, 150, 150)
                inst.Material = Enum.Material.SmoothPlastic
                inst.Transparency = 0
            end
        elseif DECORATIVE_CLASSES[inst.ClassName] then
            pcall(function() inst:Destroy() end)
        end
    end
end

-- Mengunci pencahayaan dunia (Dark Grey) secara konstan setiap frame
RunService.RenderStepped:Connect(function()
    Lighting.GlobalShadows = false
    Lighting.Brightness = 0 
    Lighting.Ambient = Color3.fromRGB(35, 35, 35) 
    Lighting.OutdoorAmbient = Color3.fromRGB(35, 35, 35) 
    Lighting.FogColor = Color3.fromRGB(35, 35, 35) 
    Lighting.FogStart = 0
    Lighting.FogEnd = 250 
    Lighting.TimeOfDay = "00:00:00" 
    
    -- Terus menerus memastikan joran/bobber baru yang dipegang langsung tersembunyi
    if LocalPlayer.Character then
        cleanCharacterAndTools(LocalPlayer.Character)
    end
end)

-- Fungsi utama pembersihan map, NPC, dan sisa aset game
local function runReduce()
    print("[Reduce] Memulai pembersihan berkala (1 Jam Sekali)...")
    
    -- Hapus Sky & Clouds
    pcall(function()
        local sky = workspace:FindFirstChildOfClass("Sky") or Lighting:FindFirstChildOfClass("Sky")
        if sky then sky:Destroy() end
        local clouds = workspace:FindFirstChildOfClass("Clouds") or Lighting:FindFirstChildOfClass("Clouds")
        if clouds then clouds:Destroy() end
        workspace.Terrain:Clear()
    end)

    local objectsProcessed = 0

    -- Scanning Workspace (Menghapus dekorasi map, mengubah material, dan menghapus NPC/Pets)
    for _, inst in ipairs(workspace:GetDescendants()) do
        if not inst:IsDescendantOf(LocalPlayer.Character) then
            
            -- LOGIKA DELETE ALL NPC & PETS: Cari model ber-humanoid yang bukan player asli
            if inst:IsA("Humanoid") then
                local model = inst.Parent
                if model and model:IsA("Model") then
                    if not Players:GetPlayerFromCharacter(model) then
                        pcall(function() model:Destroy() end)
                    end
                end
            end

            -- Eksekusi penghancuran efek visual map / sisa tali pancing di workspace
            if DECORATIVE_CLASSES[inst.ClassName] or inst:IsA("PostEffect") or inst:IsA("RopeConstraint") then
                pcall(function() inst:Destroy() end)
            elseif inst:IsA("BasePart") then
                inst.Material = Enum.Material.SmoothPlastic
            elseif inst:IsA("Sound") then
                pcall(function() inst.Volume = 0 end)
            end
            
            -- Pengaman Batch anti-crash multi-instance
            objectsProcessed = objectsProcessed + 1
            if objectsProcessed % BATCH_SIZE == 0 then
                RunService.Heartbeat:Wait()
            end
        end
    end

    -- Mute Audio global di SoundService
    for _, inst in ipairs(SoundService:GetDescendants()) do
        if inst:IsA("Sound") then
            pcall(function() inst.Volume = 0 end)
        end
    end
    print("[Reduce] Pembersihan selesai. Menunggu 1 jam untuk pembersihan berikutnya.")
end

-- Detektor otomatis jika karakter mati / respawn
LocalPlayer.CharacterAdded:Connect(function(newChar)
    RunService.Heartbeat:Wait()
    cleanCharacterAndTools(newChar)
end)

-- Jalankan eksekusi pertama saat script di-inject
task.spawn(runReduce)

-- Loop Countdown tepat 1 Jam Sekali (3600 detik)
if AUTO_REPEAT then
    task.spawn(function()
        while true do
            task.wait(REPEAT_INTERVAL)
            runReduce()
        end
    end)
end