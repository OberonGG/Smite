local Players = game:GetService("Players")
local Stats = game:GetService("Stats")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local WARNA_GELAP = Color3.fromRGB(50, 50, 50)

-- ==========================================
-- 0. GARBAGE COLLECTION (72-HOUR STABILITY)
-- ==========================================
task.spawn(function()
    while task.wait(3600) do  -- Every hour
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
ui.Parent = (gethui and gethui()) or CoreGui

local frame = Instance.new("Frame", ui)
frame.Size = UDim2.new(0, 220, 0, 40)
frame.Position = UDim2.new(0.015, 0, 0.165, 0) -- Posisi FIX
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
LynxButton.Position = UDim2.new(0.015, 0, 0.1, 0) -- Posisi FIX
LynxButton.BackgroundTransparency = 1
LynxButton.BorderSizePixel = 0
LynxButton.AutoButtonColor = true
LynxButton.Active = true
LynxButton.Image = "rbxassetid://118176705805619"
LynxButton.ImageTransparency = 0
LynxButton.ScaleType = Enum.ScaleType.Fit
LynxButton.ZIndex = 2147483647

-- ==========================================
-- 2. LOGIC CLOSE LYNX
-- ==========================================
local function closeLynx()
    local LynxGui = CoreGui:FindFirstChild("LynxGui") or CoreGui:FindFirstChild("LynxHub")
    if not LynxGui then
        for _, child in ipairs(CoreGui:GetChildren()) do
            if string.find(string.lower(child.Name), "lynx") then LynxGui = child break end
        end
    end
    if LynxGui then
        local targetFrame = LynxGui:FindFirstChild("MainFrame") or LynxGui:FindFirstChildOfClass("Frame")
        if not targetFrame then
            for _, obj in ipairs(CoreGui:GetChildren()) do
                if obj:IsA("Frame") then targetFrame = obj break end
            end
        end
        if targetFrame then pcall(function() targetFrame.Visible = not targetFrame.Visible end) end
    end
end
LynxButton.MouseButton1Click:Connect(closeLynx)

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
-- 4. LOCK LIGHTING (TETAP 50,50,50)
-- ==========================================
local function lockLighting()
    if Lighting.Ambient ~= WARNA_GELAP then Lighting.Ambient = WARNA_GELAP end
    if Lighting.OutdoorAmbient ~= WARNA_GELAP then Lighting.OutdoorAmbient = WARNA_GELAP end
    if Lighting.TimeOfDay ~= "00:00:00" then Lighting.TimeOfDay = "00:00:00" end
    if Lighting.Brightness ~= 1 then Lighting.Brightness = 1 end
    if Lighting.GlobalShadows ~= false then Lighting.GlobalShadows = false end
    if Lighting.FogStart ~= 9999999 then Lighting.FogStart = 9999999 end
    if Lighting.FogEnd ~= 9999999 then Lighting.FogEnd = 9999999 end
end

local KILL_LIGHTING = {
    Sky = true, Atmosphere = true, BloomEffect = true,
    SunRaysEffect = true, ColorCorrectionEffect = true, BlurEffect = true
}

local function safeDestroy(inst)
    pcall(inst.Destroy, inst)
end

local function killLightingChild(child)
    if KILL_LIGHTING[child.ClassName] then
        task.defer(safeDestroy, child)
    end
end

lockLighting()
for _, obj in ipairs(Lighting:GetChildren()) do killLightingChild(obj) end

local LOCK_PROPS = {
    Ambient = true, OutdoorAmbient = true, TimeOfDay = true,
    Brightness = true, GlobalShadows = true, FogStart = true, FogEnd = true
}
Lighting.Changed:Connect(function(prop)
    if LOCK_PROPS[prop] then lockLighting() end
end)
Lighting.ChildAdded:Connect(killLightingChild)

-- ==========================================
-- 5. LOGIC "MUSNAHKAN" (OPTIMASI DICTIONARY)
-- ==========================================
local TO_DESTROY = {
    ParticleEmitter = true, Smoke = true, Fire = true, Sparkles = true,
    Beam = true, Trail = true, Explosion = true, Discharge = true, Dust = true,
    PointLight = true, SpotLight = true, SurfaceLight = true, Light = true,
    Accessory = true, CharacterMesh = true,
    Shirt = true, Pants = true, ShirtGraphic = true, Clothing = true, BodyColors = true,
    PostEffect = true, SelectionBox = true, Decal = true, Texture = true,
    SurfaceAppearance = true, SpecialMesh = true
}

local IS_BASEPART = {
    Part = true, MeshPart = true, WedgePart = true, CornerWedgePart = true,
    TrussPart = true, UnionOperation = true, Seat = true, VehicleSeat = true,
    SpawnLocation = true, Platform = true
}

local function processInstance(inst)
    local cName = inst.ClassName
    
    -- Fast Exit
    if not TO_DESTROY[cName] and not IS_BASEPART[cName] then return end
    if inst:IsDescendantOf(CoreGui) then return end
    
    local name = inst.Name
    local parent = inst.Parent
    local parentName = parent and parent.Name or ""
    
    -- [OPT] Cache string.find results
    local isTotem = string.find(name, "Totem") or string.find(parentName, "Totem")
    if isTotem then
        return
    end
    
    if IS_BASEPART[cName] then
        inst.Color = WARNA_GELAP
        inst.Material = Enum.Material.SmoothPlastic
        inst.Reflectance = 0
        inst.CastShadow = false
        if cName == "MeshPart" then inst.TextureID = "" end
    else
        task.defer(safeDestroy, inst)
    end
end

-- Terapkan ke Terrain
pcall(function()
    local t = Workspace:FindFirstChildOfClass("Terrain")
    if t then
        t.WaterColor = WARNA_GELAP
        t.WaterWaveSize = 0
        t.WaterWaveSpeed = 0
        t.WaterReflectance = 0
        t.WaterTransparency = 0
    end
end)

-- Proses instance yang sudah ada (deferred untuk tidak blocking)
task.defer(function()
    for _, object in ipairs(Workspace:GetDescendants()) do
        processInstance(object)
    end
end)

-- ==========================================
-- 6. BATCHING WITH RATE LIMITING (72-HOUR FIX)
-- ==========================================
local pendingInstances = {}
local batchActive = false

local function processBatch()
    batchActive = false
    local batch = pendingInstances
    pendingInstances = {}
    
    for i = 1, #batch do
        local inst = batch[i]
        if inst.Parent ~= nil then
            processInstance(inst)
        end
        
        -- Rate limiting: Wait every 10 objects to prevent CPU spikes
        if i % 10 == 0 then
            RunService.Heartbeat:Wait()
        end
    end
end

Workspace.DescendantAdded:Connect(function(inst)
    pendingInstances[#pendingInstances + 1] = inst
    if not batchActive then
        batchActive = true
        task.defer(processBatch)
    end
end)

-- ==========================================
-- 7. DELETE NPC FOLDER PERMANENTLY (NEVER COMEBACK)
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
    
    -- Delete existing NPC folder immediately
    deleteNPCFolder()
    
    -- If NPC folder gets re-created, delete it immediately
    Workspace.ChildAdded:Connect(function(child)
        if child.Name == "NPC" and not npcFolderDeleted then
            task.defer(function()
                safeDestroy(child)
                npcFolderDeleted = true
            end)
        end
    end)
    
    -- Fail-safe: Check every 30 seconds if NPC folder somehow reappeared
    task.spawn(function()
        while task.wait(30) do
            if Workspace:FindFirstChild("NPC") then
                local npcFolder = Workspace:FindFirstChild("NPC")
                if npcFolder then
                    safeDestroy(npcFolder)
                end
            end
        end
    end)
end)

-- ==========================================
-- 8. AUTO CLOSE DAILY LOGIN (DEBOUNCED & EVENT-DRIVEN)
-- ==========================================
task.spawn(function()
    local lastClose = 0
    local CLOSE_COOLDOWN = 5  -- Max once per 5 seconds
    
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
    
    -- Check jika UI sudah ada saat script start
    local existingDaily = PlayerGui:FindFirstChild("!!! Daily Login")
    if existingDaily then
        task.wait(0.1)
        tryCloseDaily(existingDaily)
    end
    
    -- [FIX] Debounced listener to prevent event spam accumulation
    PlayerGui.ChildAdded:Connect(function(child)
        if child.Name == "!!! Daily Login" then
            task.wait(0.1)
            tryCloseDaily(child)
        end
    end)
end)

-- ==========================================
-- 9. FPS CAP (SET ONCE)
-- ==========================================
if setfpscap then 
    setfpscap(30) 
end
