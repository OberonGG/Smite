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

local WARNA_GELAP = Color3.fromRGB(50, 50, 50)

-- Matikan Streaming untuk mencegah Memory Fragmentation saat AFK
pcall(function()
    Workspace.StreamingEnabled = false
end)

-- ==========================================
-- 1. UI SETUP
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
LynxButton.Active = true
LynxButton.Image = "rbxassetid://118176705805619"
LynxButton.ScaleType = Enum.ScaleType.Fit
LynxButton.ZIndex = 2147483647

-- ==========================================
-- 2. LOGIC LYNX & PING
-- ==========================================
LynxButton.MouseButton1Click:Connect(function()
    pcall(function()
        local targetLynx = HiddenGui:FindFirstChild("LynxGui") or CoreGui:FindFirstChild("LynxGui")
        if targetLynx then targetLynx.Enabled = not targetLynx.Enabled end
    end)
end)

local startTime = os.time()
task.spawn(function()
    while task.wait(1) do
        local ping = 0
        pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
        local elapsed = os.time() - startTime
        textLabel.Text = string.format("Ping: %d ms | %d:%02d:%02d", ping, math.floor(elapsed/3600), math.floor((elapsed%3600)/60), elapsed%60)
    end
end)

-- ==========================================
-- 3. DICTIONARIES (O(1) LOOKUP)
-- ==========================================
local TO_DESTROY = {
    ParticleEmitter = true, Smoke = true, Fire = true, Sparkles = true,
    Beam = true, Trail = true, Explosion = true, Discharge = true, Dust = true,
    PointLight = true, SpotLight = true, SurfaceLight = true, Light = true,
    Accessory = true, CharacterMesh = true,
    Shirt = true, Pants = true, ShirtGraphic = true, Clothing = true, BodyColors = true,
    PostEffect = true, SelectionBox = true, Decal = true, Texture = true,
    SurfaceAppearance = true, SpecialMesh = true,
    BillboardGui = true, SurfaceGui = true -- Penting untuk whitelist Totem
}

local IS_BASEPART = {
    Part = true, MeshPart = true, WedgePart = true, CornerWedgePart = true,
    TrussPart = true, UnionOperation = true, Seat = true, VehicleSeat = true,
    SpawnLocation = true, Platform = true
}

local KILL_LIGHTING = {
    Sky = true, Atmosphere = true, BloomEffect = true,
    SunRaysEffect = true, ColorCorrectionEffect = true, BlurEffect = true, Clouds = true
}

local LOCK_PROPS = {
    Ambient = true, OutdoorAmbient = true, TimeOfDay = true,
    Brightness = true, GlobalShadows = true, FogStart = true, FogEnd = true
}

local FORCED_LIGHTING = {
    GlobalShadows = false, Brightness = 0,
    Ambient = WARNA_GELAP, OutdoorAmbient = WARNA_GELAP,
    ExposureCompensation = 0, EnvironmentDiffuseScale = 0, EnvironmentSpecularScale = 0,
    TimeOfDay = "00:00:00", FogStart = 999999, FogEnd = 999999,
}

-- ==========================================
-- 4. LIGHTING OPTIMIZATION (ULTRA LIGHT)
-- ==========================================
local function applyLightingOverride()
    for prop, val in pairs(FORCED_LIGHTING) do
        if Lighting[prop] ~= val then Lighting[prop] = val end
    end
end

local function ensureBaseEffects()
    if not Lighting:FindFirstChild("BaseNormalSky") then
        local s = Instance.new("Sky"); s.Name = "BaseNormalSky"; s.CelestialBodiesShown = false; s.StarCount = 0; s.Parent = Lighting
    end
    if not Lighting:FindFirstChild("BaseGrayCC") then
        local c = Instance.new("ColorCorrectionEffect"); c.Name = "BaseGrayCC"; c.Brightness = 0.07843; c.Saturation = -1; c.Parent = Lighting
    end
end

applyLightingOverride()
ensureBaseEffects()

Lighting.Changed:Connect(function(prop)
    if LOCK_PROPS[prop] then applyLightingOverride() end
end)

Lighting.ChildRemoved:Connect(function(child)
    if child.Name == "BaseNormalSky" or child.Name == "BaseGrayCC" then ensureBaseEffects() end
end)

local function safeDestroy(inst) pcall(inst.Destroy, inst) end

local function killLightingChild(child)
    if KILL_LIGHTING[child.ClassName] then task.defer(safeDestroy, child) end
end

for _, obj in ipairs(Lighting:GetChildren()) do killLightingChild(obj) end
Lighting.ChildAdded:Connect(killLightingChild)

-- ==========================================
-- 5. WORLD OPTIMIZATION (NO SPAM CHECKS)
-- ==========================================
local function processInstance(inst)
    -- [OPT] Hanya cek Character. Workspace event tidak akan memicu ReplicatedStorage/CoreGui
    if inst:IsDescendantOf(LocalPlayer.Character) then return end
    
    local cName = inst.ClassName
    
    -- [OPT] Fast Exit: Jika bukan target, langsung keluar. Hemat 90% CPU.
    if not TO_DESTROY[cName] and not IS_BASEPART[cName] then return end

    -- [OPT] String check HANYA jika objek berpotensi dihancurkan
    local name = inst.Name
    if name:find("Totem") or name:find("Bobber") or name:find("Luck") then return end
    
    local parent = inst.Parent
    if parent then
        local pName = parent.Name
        if pName:find("Totem") or pName:find("Bobber") or pName:find("Luck") then return end
    end

    if IS_BASEPART[cName] then
        if name:find("Rod") or (parent and parent.Name:find("Rod")) then return end
        pcall(function()
            inst.Color = WARNA_GELAP
            inst.Material = Enum.Material.SmoothPlastic
            inst.Reflectance = 0
            inst.CastShadow = false
            if cName == "MeshPart" then inst.TextureID = "" end
        end)
    else
        task.defer(safeDestroy, inst)
    end
end

-- Initial Processing dengan Batching Heartbeat (Lebih stabil dari task.defer queue)
task.spawn(function()
    pcall(function() Workspace.Terrain:Clear() end)
    
    local count = 0
    for _, inst in ipairs(Workspace:GetDescendants()) do
        processInstance(inst)
        count = count + 1
        if count % 50 == 0 then RunService.Heartbeat:Wait() end
    end
end)

-- Event Listener
Workspace.DescendantAdded:Connect(processInstance)

-- ==========================================
-- 6. NPC & DAILY LOGIN
-- ==========================================
task.spawn(function()
    local deleted = false
    local function del()
        local f = Workspace:FindFirstChild("NPC")
        if f and not deleted then task.defer(safeDestroy, f); deleted = true end
    end
    del()
    Workspace.ChildAdded:Connect(function(c) if c.Name == "NPC" then del() end end)
end)

task.spawn(function()
    local last = 0
    local function closeDaily(gui)
        if gui and gui.Enabled and tick() - last > 5 then
            last = tick()
            pcall(function()
                local m = ReplicatedStorage:FindFirstChild("Modules")
                if m then
                    local gc = m:FindFirstChild("GuiControl")
                    if gc then require(gc):Close() end
                end
            end)
        end
    end
    local ex = PlayerGui:FindFirstChild("!!! Daily Login")
    if ex then task.wait(0.1); closeDaily(ex) end
    PlayerGui.ChildAdded:Connect(function(c) if c.Name == "!!! Daily Login" then task.wait(0.1); closeDaily(c) end end)
end)

-- ==========================================
-- 7. FPS CAP & AUTO CLOSE DELTA
-- ==========================================
if setfpscap then setfpscap(20) end -- Turunkan ke 20 untuk AFK 72 jam

task.spawn(function()
    local whitelist = { ["LynxGui"] = true, ["PingTimerUI"] = true, ["LynxCloseButton"] = true }
    local closed = false
    
    while not closed and task.wait(3) do
        local target = HiddenGui or CoreGui
        local found = false
        
        for _, gui in ipairs(target:GetChildren()) do
            if gui:IsA("ScreenGui") and not whitelist[gui.Name] then
                local weird = false
                for i = 1, #gui.Name do
                    if not gui.Name:sub(i,i):match("[%w_]") then weird = true; break end
                end
                if weird then
                    if gui:FindFirstChild("Console", true) then
                        for _, obj in ipairs(gui:GetChildren()) do
                            if obj.Name ~= "Console" and obj.Name ~= "Network" then task.defer(safeDestroy, obj) end
                        end
                    else
                        task.defer(safeDestroy, gui)
                    end
                    found = true
                end
            end
        end
        if found then closed = true end
    end
end)

-- Garbage Collection
task.spawn(function()
    while task.wait(3600) do collectgarbage("collect") end
end)