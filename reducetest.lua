--[[
    Fish It - Multi-Instance Ultra Reduce (Anti-Crash, NPC Wipe & AUDIO ERADICATOR)
    - Jeda waktu pengulangan diatur menjadi 1 jam sekali (3600 detik).
    - Memusnahkan (Destroy) setiap file audio di seluruh direktori game tanpa ampun.
    - Menghilangkan rendering Joran (Rod), Aura, efek pancingan, dan Pets.
    - Menghapus seluruh NPC (Pedagang, Quest, dll) di seluruh Map.
    - Latar belakang Dark Grey & Karakter Abu-abu Polos tetap aktif.
]]

local AUTO_REPEAT = true
local REPEAT_INTERVAL = 3600 
local BATCH_SIZE = 30        

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

local CORE_LIMBS = {
    ["Head"] = true, ["Torso"] = true, ["Left Arm"] = true, ["Right Arm"] = true, ["Left Leg"] = true, ["Right Leg"] = true,
    ["HumanoidRootPart"] = true, ["UpperTorso"] = true, ["LowerTorso"] = true, 
    ["LeftUpperArm"] = true, ["LeftLowerArm"] = true, ["LeftHand"] = true,
    ["RightUpperArm"] = true, ["RightLowerArm"] = true, ["RightHand"] = true,
    ["LeftUpperLeg"] = true, ["LeftLowerLeg"] = true, ["LeftFoot"] = true,
    ["RightUpperLeg"] = true, ["RightLowerLeg"] = true, ["RightFoot"] = true
}

-- ==========================================
-- FITUR BARU: AUDIO ERADICATOR (PEMUSNAH SUARA MUTLAK)
-- ==========================================
local function eradicateAudio(inst)
    if inst:IsA("Sound") then
        pcall(function()
            -- Hentikan paksa pemutaran dan hancurkan sumber suaranya
            inst.Volume = 0
            inst.Playing = false
            inst.SoundId = "" 
            inst:Destroy()
        end)
    end
end

-- Radar target untuk mencari audio yang disembunyikan developer
local audioTargets = {
    workspace,
    SoundService,
    game:GetService("ReplicatedStorage"),
    game:GetService("Lighting"),
    LocalPlayer -- Termasuk PlayerGui (tempat BGM sering disembunyikan)
}

for _, target in ipairs(audioTargets) do
    -- 1. Musnahkan semua suara yang sudah terlanjur berjalan saat script di-inject
    for _, inst in ipairs(target:GetDescendants()) do
        eradicateAudio(inst)
    end
    -- 2. Pasang jebakan untuk memusnahkan suara baru secara instan sebelum sempat berbunyi
    target.DescendantAdded:Connect(eradicateAudio)
end
-- ==========================================

local function cleanCharacterAndTools(char)
    if not char then return end
    
    for _, inst in ipairs(char:GetDescendants()) do
        if inst:IsA("Accessory") or inst:IsA("Shirt") or inst:IsA("Pants") 
        or inst:IsA("ShirtGraphic") or inst:IsA("BodyColors") or inst:IsA("CharacterMesh") then
            pcall(function() inst:Destroy() end)
        elseif inst:IsA("BasePart") then
            if not CORE_LIMBS[inst.Name] then
                inst.Transparency = 1
                inst.LocalTransparencyModifier = 1
            else
                inst.Color = Color3.fromRGB(150, 150, 150)
                inst.Material = Enum.Material.SmoothPlastic
                inst.Transparency = 0
            end
        elseif DECORATIVE_CLASSES[inst.ClassName] then
            pcall(function() inst:Destroy() end)
        end
    end
end

RunService.RenderStepped:Connect(function()
    Lighting.GlobalShadows = false
    Lighting.Brightness = 0 
    Lighting.Ambient = Color3.fromRGB(35, 35, 35) 
    Lighting.OutdoorAmbient = Color3.fromRGB(35, 35, 35) 
    Lighting.FogColor = Color3.fromRGB(35, 35, 35) 
    Lighting.FogStart = 0
    Lighting.FogEnd = 250 
    Lighting.TimeOfDay = "00:00:00" 
    
    if LocalPlayer.Character then
        cleanCharacterAndTools(LocalPlayer.Character)
    end
end)

local function runReduce()
    pcall(function()
        local sky = workspace:FindFirstChildOfClass("Sky") or Lighting:FindFirstChildOfClass("Sky")
        if sky then sky:Destroy() end
        local clouds = workspace:FindFirstChildOfClass("Clouds") or Lighting:FindFirstChildOfClass("Clouds")
        if clouds then clouds:Destroy() end
        workspace.Terrain:Clear()
    end)

    local objectsProcessed = 0

    for _, inst in ipairs(workspace:GetDescendants()) do
        if not inst:IsDescendantOf(LocalPlayer.Character) then
            
            if inst:IsA("Humanoid") then
                local model = inst.Parent
                if model and model:IsA("Model") then
                    if not Players:GetPlayerFromCharacter(model) then
                        pcall(function() model:Destroy() end)
                    end
                end
            end

            if DECORATIVE_CLASSES[inst.ClassName] or inst:IsA("PostEffect") or inst:IsA("RopeConstraint") then
                pcall(function() inst:Destroy() end)
            elseif inst:IsA("BasePart") then
                inst.Material = Enum.Material.SmoothPlastic
            end
            
            objectsProcessed = objectsProcessed + 1
            if objectsProcessed % BATCH_SIZE == 0 then
                RunService.Heartbeat:Wait()
            end
        end
    end
    print("[Reduce] Pembersihan map dan NPC selesai.")
end

LocalPlayer.CharacterAdded:Connect(function(newChar)
    RunService.Heartbeat:Wait()
    cleanCharacterAndTools(newChar)
end)

task.spawn(runReduce)

if AUTO_REPEAT then
    task.spawn(function()
        while true do
            task.wait(REPEAT_INTERVAL)
            runReduce()
        end
    end)
end