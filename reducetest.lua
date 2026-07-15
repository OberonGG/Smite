-- ==========================================
-- OPTIMIZED REDUCE MAP SCRIPT
-- Anti Memory Leak | CPU Optimized | 72+ Hour AFK Stable
-- ==========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local Lighting = game:GetService("Lighting")
local CoreGui = gethui and gethui() or game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Warna gelap yang diminta (50,50,50)
local WARNA_GELAP = Color3.fromRGB(50, 50, 50)

-- ==========================================
-- 1. UI SETUP (POSISI FIX - TANPA DRAGGABLE)
-- ==========================================
local ui = Instance.new("ScreenGui")
ui.Name = "PingTimerUI"
ui.ResetOnSpawn = false
ui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ui.Parent = CoreGui

local frame = Instance.new("Frame", ui)
frame.Size = UDim2.new(0, 220, 0, 40)
frame.Position = UDim2.new(0.015, 0, 0.165, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BackgroundTransparency = 0.15
frame.BorderSizePixel = 0
frame.Active = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(1, 0)

local textLabel = Instance.new("TextLabel", frame)
textLabel.Size = UDim2.new(1, 0, 1, 0)
textLabel.BackgroundTransparency = 1
textLabel.Font = Enum.Font.GothamBold
textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
textLabel.TextSize = 16
textLabel.Text = "Ping: 0 ms | 0:00:00"

local LynxButton = Instance.new("ImageButton", ui)
LynxButton.Name = "LynxCloseButton"
LynxButton.Size = UDim2.new(0, 40, 0, 40)
LynxButton.Position = UDim2.new(0.015, 0, 0.1, 0)
LynxButton.BackgroundTransparency = 1
LynxButton.BorderSizePixel = 0
LynxButton.AutoButtonColor = true
LynxButton.Active = true
LynxButton.Image = "rbxassetid://118176705805619"
LynxButton.ImageTransparency = 0
LynxButton.ScaleType = Enum.ScaleType.Fit
LynxButton.ZIndex = 2147483647

-- ==========================================
-- 2. LOGIC CLOSE LYNX (TIDAK DIUBAH)
-- ==========================================
local function closeLynx()
    local LynxGui = CoreGui:FindFirstChild("LynxGui") or CoreGui:FindFirstChild("LynxHub")
    if not LynxGui then
        for _, child in ipairs(CoreGui:GetChildren()) do
            if string.find(string.lower(child.Name), "lynx") then
                LynxGui = child
                break
            end
        end
    end
    if LynxGui then
        local targetFrame = LynxGui:FindFirstChild("MainFrame") or LynxGui:FindFirstChildOfClass("Frame")
        if not targetFrame then
            for _, obj in ipairs(CoreGui:GetChildren()) do
                if obj:IsA("Frame") then
                    targetFrame = obj
                    break
                end
            end
        end
        if targetFrame then
            pcall(function() targetFrame.Visible = not targetFrame.Visible end)
        end
    end
end
LynxButton.MouseButton1Click:Connect(closeLynx)

-- ==========================================
-- 3. REAL PING & TIMER (OPTIMIZED)
-- ==========================================
local startTime = os.time()
local pingText = "Ping: %d ms | %d:%02d:%02d"
task.spawn(function()
    while task.wait(1) do
        local ping = 0
        pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
        local elapsed = os.time() - startTime
        local h = math.floor(elapsed / 3600)
        local m = math.floor((elapsed % 3600) / 60)
        local s = elapsed % 60
        textLabel.Text = string.format(pingText, ping, h, m, s)
    end
end)

-- ==========================================
-- 4. OPTIMIZED CLASS DICTIONARIES
-- ==========================================
local DECORATIVE = {
    ParticleEmitter = true, Smoke = true, Fire = true, Sparkles = true,
    Beam = true, Trail = true, Explosion = true, Discharge = true,
    Dust = true, PointLight = true, SpotLight = true, SurfaceLight = true,
    Decal = true, Texture = true, SurfaceAppearance = true,
    Highlight = true, SelectionBox = true, RopeConstraint = true,
    BillboardGui = true, SurfaceGui = true, Light = true,
    Accessory = true, CharacterMesh = true,
    Shirt = true, Pants = true, ShirtGraphic = true, Clothing = true, BodyColors = true,
    PostEffect = true, SpecialMesh = true
}

local IS_BASEPART = {
    Part = true, MeshPart = true, WedgePart = true, CornerWedgePart = true,
    TrussPart = true, UnionOperation = true, Seat = true, VehicleSeat = true,
    SpawnLocation = true, Platform = true
}

local CORE_LIMBS = {
    Head = true, Torso = true, ["Left Arm"] = true, ["Right Arm"] = true,
    ["Left Leg"] = true, ["Right Leg"] = true, HumanoidRootPart = true,
    UpperTorso = true, LowerTorso = true,
    LeftUpperArm = true, LeftLowerArm = true, LeftHand = true,
    RightUpperArm = true, RightLowerArm = true, RightHand = true,
    LeftUpperLeg = true, LeftLowerLeg = true, LeftFoot = true,
    RightUpperLeg = true, RightLowerLeg = true, RightFoot = true
}

local TARGET_CLASSES = {
    Atmosphere = true, ColorCorrectionEffect = true, Sky = true,
    SunRaysEffect = true, BloomEffect = true, BlurEffect = true, Clouds = true
}

-- ==========================================
-- 5. LIGHTING OPTIMIZATION (ANTI-LEAK)
-- ==========================================
local FORCED_LIGHTING = {
    GlobalShadows = false,
    Brightness = 0,
    Ambient = WARNA_GELAP,
    OutdoorAmbient = WARNA_GELAP,
    ExposureCompensation = 0,
    EnvironmentDiffuseScale = 0,
    EnvironmentSpecularScale = 0,
    TimeOfDay = "00:00:00",
    FogStart = 999999,
    FogEnd = 999999,
}

-- Hanya respond ke properti yang benar-benar penting
local LOCK_PROPS = {
    Ambient = true, OutdoorAmbient = true, TimeOfDay = true,
    Brightness = true, GlobalShadows = true, FogStart = true, FogEnd = true,
    ExposureCompensation = true, EnvironmentDiffuseScale = true, EnvironmentSpecularScale = true
}

local function applyLightingOverride()
    for property, value in pairs(FORCED_LIGHTING) do
        if Lighting[property] ~= value then
            Lighting[property] = value
        end
    end
end

local function ensureBaseEffects()
    if not Lighting:FindFirstChild("BaseNormalSky") then
        local normalSky = Instance.new("Sky")
        normalSky.Name = "BaseNormalSky"
        normalSky.CelestialBodiesShown = false
        normalSky.StarCount = 0
        normalSky.Parent = Lighting
    end
    if not Lighting:FindFirstChild("BaseGrayCC") then
        local grayCC = Instance.new("ColorCorrectionEffect")
        grayCC.Name = "BaseGrayCC"
        grayCC.Brightness = 0.07843
        grayCC.Contrast = 0
        grayCC.Saturation = -1
        grayCC.Parent = Lighting
    end
end

applyLightingOverride()
ensureBaseEffects()

-- FILTERED: Hanya respond ke properti yang dikunci
Lighting.Changed:Connect(function(prop)
    if LOCK_PROPS[prop] then
        applyLightingOverride()
    end
end)

Lighting.ChildRemoved:Connect(function(child)
    if child.Name == "BaseNormalSky" or child.Name == "BaseGrayCC" then
        ensureBaseEffects()
    end
end)

-- ==========================================
-- 6. WORLD OPTIMIZATION (CPU OPTIMIZED)
-- ==========================================
local function safeDestroy(inst)
    if inst and inst.Parent then
        inst:Destroy()
    end
end

local function neutralizeTarget(obj)
    if not obj or not obj.Parent then return end
    
    local objName = obj.Name
    local className = obj.ClassName
    
    if objName == "BaseGrayCC" then
        if obj.Brightness ~= 0.07843 then obj.Brightness = 0.07843 end
        if obj.Contrast ~= 0 then obj.Contrast = 0 end
        if obj.Saturation ~= -1 then obj.Saturation = -1 end
        if obj.Enabled ~= true then obj.Enabled = true end
        return
    end
    
    if objName == "BaseNormalSky" then
        if obj.CelestialBodiesShown ~= false then obj.CelestialBodiesShown = false end
        if obj.StarCount ~= 0 then obj.StarCount = 0 end
        return
    end
    
    if className == "ColorCorrectionEffect" or className == "SunRaysEffect" or 
       className == "BloomEffect" or className == "BlurEffect" or className == "Clouds" then
        if obj.Enabled ~= false then obj.Enabled = false end
    elseif className == "Atmosphere" then
        if obj.Density ~= 0 then obj.Density = 0 end
        if obj.Glare ~= 0 then obj.Glare = 0 end
        if obj.Haze ~= 0 then obj.Haze = 0 end
    elseif className == "Sky" then
        if obj.CelestialBodiesShown ~= false then obj.CelestialBodiesShown = false end
        if obj.StarCount ~= 0 then obj.StarCount = 0 end
        if obj.SkyboxBk ~= "rbxassetid://0" then obj.SkyboxBk = "rbxassetid://0" end
        if obj.SkyboxDn ~= "rbxassetid://0" then obj.SkyboxDn = "rbxassetid://0" end
        if obj.SkyboxFt ~= "rbxassetid://0" then obj.SkyboxFt = "rbxassetid://0" end
        if obj.SkyboxLf ~= "rbxassetid://0" then obj.SkyboxLf = "rbxassetid://0" end
        if obj.SkyboxRt ~= "rbxassetid://0" then obj.SkyboxRt = "rbxassetid://0" end
        if obj.SkyboxUp ~= "rbxassetid://0" then obj.SkyboxUp = "rbxassetid://0" end
        if obj.SunTextureId ~= "rbxassetid://0" then obj.SunTextureId = "rbxassetid://0" end
        if obj.MoonTextureId ~= "rbxassetid://0" then obj.MoonTextureId = "rbxassetid://0" end
    end
end

local function handleDescendant(inst)
    if not inst or not inst.Parent then return end
    
    -- Skip player character dan CoreGui
    local parent = inst.Parent
    if parent == LocalPlayer.Character or parent == CoreGui then return end
    
    -- Cek apakah ancestor adalah character atau CoreGui
    local current = parent
    local depth = 0
    while current and depth < 10 do
        if current == LocalPlayer.Character or current == CoreGui then return end
        current = current.Parent
        depth = depth + 1
    end
    
    local className = inst.ClassName
    
    if IS_BASEPART[className] then
        inst.Transparency = 1
        inst.Color = WARNA_GELAP
        inst.CastShadow = false
        inst.Material = Enum.Material.SmoothPlastic
    elseif DECORATIVE[className] or className == "PostEffect" then
        safeDestroy(inst)
    elseif TARGET_CLASSES[className] then
        neutralizeTarget(inst)
    elseif className == "Humanoid" then
        local model = inst.Parent
        if model and model:IsA("Model") and not Players:GetPlayerFromCharacter(model) then
            safeDestroy(model)
        end
    end
end

-- Lighting descendants
Lighting.DescendantAdded:Connect(handleDescendant)
for _, obj in ipairs(Lighting:GetDescendants()) do
    handleDescendant(obj)
end

-- Workspace descendants dengan batching
Workspace.DescendantAdded:Connect(handleDescendant)

-- ==========================================
-- 7. INITIAL WORLD PROCESSING (OPTIMIZED BATCH)
-- ==========================================
task.spawn(function()
    local descendants = Workspace:GetDescendants()
    local total = #descendants
    local batchSize = 50
    local processed = 0
    
    for i = 1, total do
        local inst = descendants[i]
        if inst and inst.Parent then
            handleDescendant(inst)
        end
        processed = processed + 1
        if processed % batchSize == 0 then
            RunService.Heartbeat:Wait()
        end
    end
end)

-- ==========================================
-- 8. TERRAIN CLEARING
-- ==========================================
task.spawn(function()
    pcall(function()
        local terrain = Workspace:FindFirstChildOfClass("Terrain")
        if terrain then
            terrain:Clear()
        end
    end)
end)

-- ==========================================
-- 9. NPC FOLDER DELETION (EVENT-DRIVEN, NO POLLING)
-- ==========================================
local function deleteNPCFolder()
    local npcFolder = Workspace:FindFirstChild("NPC")
    if npcFolder then
        safeDestroy(npcFolder)
    end
end

deleteNPCFolder()

Workspace.ChildAdded:Connect(function(child)
    if child.Name == "NPC" then
        safeDestroy(child)
    end
end)

-- ==========================================
-- 10. AUTO CLOSE DAILY LOGIN (TIDAK DIUBAH)
-- ==========================================
task.spawn(function()
    local lastClose = 0
    local CLOSE_COOLDOWN = 5
    
    local function tryCloseDaily(gui)
        if gui and gui.Enabled then
            local now = tick()
            if now - lastClose > CLOSE_COOLDOWN then
                lastClose = now
                pcall(function()
                    local modules = ReplicatedStorage:FindFirstChild("Modules")
                    if modules then
                        local guiControl = modules:FindFirstChild("GuiControl")
                        if guiControl then
                            require(guiControl):Close()
                        end
                    end
                end)
            end
        end
    end
    
    local existingDaily = PlayerGui:FindFirstChild("!!! Daily Login")
    if existingDaily then
        task.wait(0.1)
        tryCloseDaily(existingDaily)
    end
    
    PlayerGui.ChildAdded:Connect(function(child)
        if child.Name == "!!! Daily Login" then
            task.wait(0.1)
            tryCloseDaily(child)
        end
    end)
end)

-- ==========================================
-- 11. CHARACTER CLEANING
-- ==========================================
local function cleanChar(char)
    if not char then return end
    for _, inst in ipairs(char:GetDescendants()) do
        local className = inst.ClassName
        if className == "Accessory" or className == "Shirt" or className == "Pants" or
           className == "ShirtGraphic" or className == "BodyColors" or className == "CharacterMesh" then
            safeDestroy(inst)
        elseif IS_BASEPART[className] then
            if not CORE_LIMBS[inst.Name] then
                inst.Transparency = 1
                inst.LocalTransparencyModifier = 1
            else
                inst.Color = Color3.fromRGB(150, 150, 150)
                inst.Material = Enum.Material.SmoothPlastic
                inst.Transparency = 0
            end
        elseif DECORATIVE[className] then
            safeDestroy(inst)
        end
    end
end

LocalPlayer.CharacterAdded:Connect(cleanChar)
if LocalPlayer.Character then
    cleanChar(LocalPlayer.Character)
end

-- ==========================================
-- 12. FPS CAP
-- ==========================================
if setfpscap then
    setfpscap(30)
end

-- ==========================================
-- 13. AUTO CLOSE DELTA UI (TIDAK DIUBAH)
-- ==========================================
for _, gui in ipairs(CoreGui:GetChildren()) do
    if gui:IsA("ScreenGui") then
        local isWeird = false
        local name = gui.Name
        for i = 1, #name do
            local c = name:sub(i, i)
            if not c:match("[%w_]") then
                isWeird = true
                break
            end
        end
        if isWeird then
            local hasConsole = false
            for _, obj in ipairs(gui:GetDescendants()) do
                if obj:IsA("GuiObject") and string.find(obj.Name, "Console") then
                    hasConsole = true
                    break
                end
            end
            if hasConsole then
                for _, obj in ipairs(gui:GetChildren()) do
                    if not (obj.Name == "Console" or obj.Name == "Network") then
                        safeDestroy(obj)
                    end
                end
            else
                safeDestroy(gui)
            end
        end
    end
end

-- ==========================================
-- 14. MEMORY CLEANUP (HOURLY)
-- ==========================================
task.spawn(function()
    while task.wait(3600) do
        collectgarbage("collect")
    end
end)
