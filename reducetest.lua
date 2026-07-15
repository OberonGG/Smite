local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local HiddenGui = (gethui and gethui()) or CoreGui
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- [FIX] Semua warna dikunci ke 50,50,50 (Abu Gelap)
local WARNA_GELAP = Color3.fromRGB(50, 50, 50)
local ABU_GELAP = Color3.fromRGB(50, 50, 50)

-- ==========================================
-- 0. GARBAGE COLLECTION (72-HOUR STABILITY)
-- ==========================================
task.spawn(function()
    while task.wait(3600) do
        collectgarbage("collect")
    end
end)

-- ==========================================
-- 1. UI SETUP (POSISI FIX - TANPA DRAGGABLE)
-- ==========================================
local ui = Instance.new("ScreenGui")
ui.Name = "PingTimerUI"
ui.ResetOnSpawn = false
ui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ui.Parent = HiddenGui

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
-- 2. LOGIC CLOSE LYNX (TOGGLE ENABLED)
-- ==========================================
LynxButton.MouseButton1Click:Connect(function()
    pcall(function()
        local targetLynx = HiddenGui:FindFirstChild("LynxGui") or CoreGui:FindFirstChild("LynxGui")
        if targetLynx then
            targetLynx.Enabled = not targetLynx.Enabled
        end
    end)
end)

-- ==========================================
-- 3. REAL PING & TIMER
-- ==========================================
local startTime = os.time()
task.spawn(function()
    while task.wait(1) do
        local ping = 0
        pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
        local elapsed = os.time() - startTime
        local h = math.floor(elapsed / 3600)
        local m = math.floor((elapsed % 3600) / 60)
        local s = elapsed % 60
        textLabel.Text = string.format("Ping: %d ms | %d:%02d:%02d", ping, h, m, s)
    end
end)

-- ==========================================
-- 4. DICTIONARIES (O(1) LOOKUP)
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

local TARGET_CLASSES = {
    Atmosphere = true, ColorCorrectionEffect = true, Sky = true,
    SunRaysEffect = true, BloomEffect = true, BlurEffect = true, Clouds = true
}

local function safeDestroy(inst)
    pcall(inst.Destroy, inst)
end

-- ==========================================
-- 5. LIGHTING OPTIMIZATION (ANTI BRIGHT & ANTI LEAK)
-- ==========================================
local FORCED_LIGHTING = {
    GlobalShadows = false,
    Brightness = 0,
    Ambient = ABU_GELAP,
    OutdoorAmbient = ABU_GELAP,
    ExposureCompensation = 0,
    EnvironmentDiffuseScale = 0,
    EnvironmentSpecularScale = 0,
    TimeOfDay = "00:00:00",
    FogStart = 999999,
    FogEnd = 999999,
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

Lighting.Changed:Connect(applyLightingOverride)
Lighting.ChildRemoved:Connect(function(child)
    if child.Name == "BaseNormalSky" or child.Name == "BaseGrayCC" then
        ensureBaseEffects()
    end
end)

-- ==========================================
-- 6. WORLD OPTIMIZATION (ZERO LEAKS)
-- ==========================================
local function neutralizeTarget(obj)
    if obj.Name == "BaseGrayCC" then
        if obj.Brightness ~= 0.07843 then obj.Brightness = 0.07843 end
        if obj.Contrast ~= 0 then obj.Contrast = 0 end
        if obj.Saturation ~= -1 then obj.Saturation = -1 end
        if obj.Enabled ~= true then obj.Enabled = true end
        return
    end
    if obj.Name == "BaseNormalSky" then
        if obj.CelestialBodiesShown ~= false then obj.CelestialBodiesShown = false end
        if obj.StarCount ~= 0 then obj.StarCount = 0 end
        return
    end
    if obj:IsA("ColorCorrectionEffect") or obj:IsA("SunRaysEffect") or obj:IsA("BloomEffect") or
       obj:IsA("BlurEffect") or obj:IsA("Clouds") then
        if obj.Enabled ~= false then obj.Enabled = false end
    elseif obj:IsA("Atmosphere") then
        if obj.Density ~= 0 then obj.Density = 0 end
        if obj.Glare ~= 0 then obj.Glare = 0 end
        if obj.Haze ~= 0 then obj.Haze = 0 end
    elseif obj:IsA("Sky") then
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

-- [FIX] WATCHED_REGISTRY dengan inst.Destroying untuk mencegah Memory Leak & Visual Leak
local WATCHED_REGISTRY = {}

local function handleDescendant(inst)
    if inst:IsDescendantOf(LocalPlayer.Character) or inst:IsDescendantOf(CoreGui) then return end
    
    local cName = inst.ClassName
    
    if IS_BASEPART[cName] then
        pcall(function()
            inst.Transparency = 1
            inst.Color = ABU_GELAP
            inst.CastShadow = false
            inst.Material = Enum.Material.SmoothPlastic
        end)
    elseif DECORATIVE[cName] or cName == "PostEffect" then
        safeDestroy(inst)
    elseif TARGET_CLASSES[cName] then
        pcall(neutralizeTarget, inst)
        
        -- [SILVER BULLET] Pasang listener Changed, tapi putus otomatis saat Destroying
        if not WATCHED_REGISTRY[inst] then
            local conn
            conn = inst.Changed:Connect(function()
                pcall(neutralizeTarget, inst)
            end)
            WATCHED_REGISTRY[inst] = conn
            
            -- Putus koneksi tepat sebelum objek hancur = 0% Memory Leak
            inst.Destroying:Connect(function()
                if conn then conn:Disconnect() end
                WATCHED_REGISTRY[inst] = nil
            end)
        end
    end
end

Lighting.DescendantAdded:Connect(handleDescendant)
Workspace.DescendantAdded:Connect(handleDescendant)

for _, obj in ipairs(Lighting:GetDescendants()) do 
    handleDescendant(obj) 
end

-- ==========================================
-- 7. TERRAIN & INITIAL BATCH PROCESSING
-- ==========================================
task.spawn(function()
    pcall(function()
        local terrain = Workspace:FindFirstChildOfClass("Terrain")
        if terrain then
            terrain:Clear()
        end
    end)
end)

task.spawn(function()
    local objectsProcessed = 0
    for _, inst in ipairs(Workspace:GetDescendants()) do
        if not inst:IsDescendantOf(LocalPlayer.Character) and not inst:IsDescendantOf(CoreGui) then
            handleDescendant(inst)
            objectsProcessed = objectsProcessed + 1
            if objectsProcessed % 50 == 0 then
                RunService.Heartbeat:Wait()
            end
        end
    end
end)

-- ==========================================
-- 8. NPC FOLDER DELETION ONLY
-- ==========================================
task.spawn(function()
    local npcFolderDeleted = false
    local function deleteNPCFolder()
        local npcFolder = Workspace:FindFirstChild("NPC")
        if npcFolder and not npcFolderDeleted then
            task.defer(function()
                safeDestroy(npcFolder)
                npcFolderDeleted = true
            end)
        end
    end
    
    deleteNPCFolder()
    
    Workspace.ChildAdded:Connect(function(child)
        if child.Name == "NPC" and not npcFolderDeleted then
            task.defer(function()
                safeDestroy(child)
                npcFolderDeleted = true
            end)
        end
    end)
end)

-- ==========================================
-- 9. AUTO CLOSE DAILY LOGIN
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
-- 10. FPS CAP
-- ==========================================
if setfpscap then
    setfpscap(30)
end

-- ==========================================
-- 11. AUTO CLOSE DELTA (WHITELIST & ANTI-RE-ENTRANCY)
-- ==========================================
task.spawn(function()
    local deltaClosed = false
    local whitelist = {
        ["LynxGui"] = true,
        ["PingTimerUI"] = true,
        ["LynxCloseButton"] = true
    }
    
    while not deltaClosed and task.wait(3) do
        local targetGui = HiddenGui or CoreGui
        local foundDeltaUI = false
        
        for _, gui in ipairs(targetGui:GetChildren()) do
            if gui:IsA("ScreenGui") then
                if whitelist[gui.Name] then continue end
                
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
                                task.defer(function() pcall(function() obj:Destroy() end) end)
                            end
                        end
                        foundDeltaUI = true
                    else
                        task.defer(function() pcall(function() gui:Destroy() end) end)
                        foundDeltaUI = true
                    end
                end
            end
        end
        
        if foundDeltaUI then
            deltaClosed = true
        end
    end
end)