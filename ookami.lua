local Players = game:GetService("Players")
local Stats = game:GetService("Stats")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local WARNA_GELAP = Color3.fromRGB(50, 50, 50)

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
-- 2. LOGIC CLOSE LYNX (TIDAK DIUBAH)
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
-- 3. REAL PING & TIMER (TIDAK DIUBAH)
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
-- 4. LOCK LIGHTING (TETAP 50,50,50 SESUAI PERMINTAAN)
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
-- 5. LOGIC "MUSNAHKAN" (MENGIKUTI SCRIPT TEMANMU, TAPI DI-OPTIMASI)
-- ==========================================
-- [OPT] Menggunakan Dictionary O(1) agar tidak membebani CPU seperti rantai IsA() pada script temanmu
local TO_DESTROY = {
    SpecialMesh = true, ParticleEmitter = true, Trail = true, Beam = true,
    Sparkles = true, Fire = true, Smoke = true, Explosion = true,
    PostEffect = true, Light = true, SelectionBox = true, Decal = true,
    Texture = true, Clothing = true, ShirtGraphic = true
}

local IS_BASEPART = {
    Part = true, MeshPart = true, UnionOperation = true, WedgePart = true,
    CornerWedgePart = true, TrussPart = true, Seat = true, VehicleSeat = true,
    SpawnLocation = true, Platform = true
}

local function processInstance(inst)
    local cName = inst.ClassName
    
    -- Fast Exit: Abaikan 90% instance yang tidak relevan (Script, Value, Model, dll)
    if not TO_DESTROY[cName] and not IS_BASEPART[cName] and cName ~= "BillboardGui" and cName ~= "SurfaceGui" then 
        return 
    end

    local name = inst.Name
    local parent = inst.Parent
    local parentName = parent and parent.Name or ""

    -- [PENTING] Whitelist agar game "Fish It" tidak rusak total
    if string.find(name, "Totem") or string.find(name, "Bobber") or string.find(name, "Rod") or
       (parentName and (string.find(parentName, "Totem") or string.find(parentName, "Bobber") or string.find(parentName, "Rod"))) then
        -- Jika BasePart, tetap diberi treatment SmoothPlastic agar sesuai request "pake smooth plastic"
        if IS_BASEPART[cName] then
            inst.Color = WARNA_GELAP
            inst.Material = Enum.Material.SmoothPlastic
            inst.Reflectance = 0
            inst.CastShadow = false
            if cName == "MeshPart" then inst.TextureID = "" end
        end
        return
    end

    -- Proteksi SpecialMesh pada Head (agar wajah karakter tidak error)
    if cName == "SpecialMesh" and parentName == "Head" then return end

    -- Logic Penghancuran GUI yang bukan milik Player (sesuai script temanmu)
    if cName == "BillboardGui" or cName == "SurfaceGui" then
        local isPlayerOwned = inst:FindFirstAncestorOfClass("Player") ~= nil
        if not isPlayerOwned then
            task.defer(safeDestroy, inst)
        end
        return
    end

    -- Logic Penghancuran Massal (SpecialMesh, Efek, dll)
    if TO_DESTROY[cName] then
        task.defer(safeDestroy, inst)
        return
    end

    -- Logic BasePart: Smooth Plastic, Reflectance 0, CastShadow false, Warna Gelap
    if IS_BASEPART[cName] then
        inst.Color = WARNA_GELAP
        inst.Material = Enum.Material.SmoothPlastic
        inst.Reflectance = 0
        inst.CastShadow = false
        if cName == "MeshPart" then inst.TextureID = "" end
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

-- Proses instance yang sudah ada saat script dijalankan
for _, object in ipairs(Workspace:GetDescendants()) do
    processInstance(object)
end

-- Batching DescendantAdded untuk mencegah CPU Spike
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
-- 6. AUTO CLOSE DAILY LOGIN (DIPERAMAN)
-- ==========================================
task.spawn(function()
    while task.wait(3) do
        local dailyUI = PlayerGui:FindFirstChild("!!! Daily Login")
        if dailyUI and dailyUI.Enabled then
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
end)

-- ==========================================
-- 7. FPS CAP (DIPERTAHANKAN)
-- ==========================================
if setfpscap then 
    setfpscap(30) 
end
