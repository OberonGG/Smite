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
-- 1. UI SETUP (POSISI FIX, TANPA DRAGGABLE)
-- ==========================================
-- [PENTING] Fungsi makeDraggable DIHAPUS TOTAL untuk mencegah memory leak dari input.Changed
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
-- 2. LOGIC CLOSE LYNX & PING TIMER (TIDAK DIUBAH)
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
-- 3. LOCK LIGHTING (WARNA GELAP 50,50,50)
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
-- 4. REDUCE MAP & SPHERICAL OPTIMIZED (EVENT-DRIVEN)
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

-- [OPT] Fungsi pemrosesan instance dengan REDUNDANCY CHECK
-- Hanya mengubah properti jika nilainya BELUM sesuai. Ini mencegah CPU spike.
local function processInstance(inst)
    local cName = inst.ClassName
    
    -- Fast Exit: Abaikan 90% instance yang tidak relevan
    if not TO_DESTROY[cName] and not IS_BASEPART[cName] then return end

    local name = inst.Name
    local parent = inst.Parent
    local parentName = parent and parent.Name or ""

    -- Whitelist Totem, Bobber, dan Rod (Rod sekarang diproses jadi bulat, bukan di-skip total)
    if name:find("Totem") or name:find("Bobber") or name:find("Rod") or
       (parentName and (parentName:find("Totem") or parentName:find("Bobber") or parentName:find("Rod"))) then
        -- Lanjut ke proses pembulatan di bawah, jangan return
    end

    if IS_BASEPART[cName] then
        -- [OPT] REDUNDANCY CHECK: Hanya ubah jika belum bulat
        if cName == "Part" and inst.Shape ~= Enum.PartType.Ball then
            pcall(function() inst.Shape = Enum.PartType.Ball end)
        elseif cName == "MeshPart" and inst.MeshType ~= Enum.MeshType.Ball then
            pcall(function()
                inst.MeshType = Enum.MeshType.Ball
                inst.TextureID = ""
            end)
        end

        -- [OPT] REDUNDANCY CHECK untuk properti visual
        if inst.Color ~= WARNA_GELAP then inst.Color = WARNA_GELAP end
        if inst.Material ~= Enum.Material.SmoothPlastic then inst.Material = Enum.Material.SmoothPlastic end
        if inst.Reflectance ~= 0 then inst.Reflectance = 0 end
        if inst.CastShadow ~= false then inst.CastShadow = false end
    else
        -- TO_DESTROY path
        task.defer(safeDestroy, inst)
    end
end

-- Terapkan ke Terrain
pcall(function()
    local t = Workspace:FindFirstChildOfClass("Terrain")
    if t then
        if t.WaterColor ~= WARNA_GELAP then t.WaterColor = WARNA_GELAP end
        if t.WaterWaveSize ~= 0 then t.WaterWaveSize = 0 end
        if t.WaterWaveSpeed ~= 0 then t.WaterWaveSpeed = 0 end
        if t.WaterReflectance ~= 0 then t.WaterReflectance = 0 end
        if t.WaterTransparency ~= 0 then t.WaterTransparency = 0 end
    end
end)

-- Proses instance yang sudah ada saat script dijalankan (Dilakukan sekali saja)
for _, object in ipairs(Workspace:GetDescendants()) do
    processInstance(object)
end

-- [OPT] Batching DescendantAdded untuk mencegah spike CPU saat banyak part muncul sekaligus
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
-- 5. KARAKTER BULAT (EVENT-DRIVEN, BUKAN LOOPING)
-- ==========================================
-- [OPT] Mengganti while task.wait(2) dengan CharacterAdded & DescendantAdded
-- Ini menjamin pemrosesan HANYA terjadi SEKALI per part, mengeliminasi GC spike dan CPU waste.
local function processCharacterPart(inst)
    if not inst:IsA("BasePart") then
        if inst.ClassName == "SpecialMesh" then
            task.defer(safeDestroy, inst)
        end
        return
    end

    if inst.Name == "HumanoidRootPart" then
        inst.Transparency = 1
        return
    end

    -- Redundancy check: Hanya ubah jika belum bulat
    if inst.ClassName == "Part" and inst.Shape ~= Enum.PartType.Ball then
        pcall(function() inst.Shape = Enum.PartType.Ball end)
    elseif inst.ClassName == "MeshPart" and inst.MeshType ~= Enum.MeshType.Ball then
        pcall(function()
            inst.MeshType = Enum.MeshType.Ball
            inst.TextureID = ""
        end)
    end

    -- Redundancy check untuk properti lain
    if inst.Color ~= WARNA_GELAP then inst.Color = WARNA_GELAP end
    if inst.Material ~= Enum.Material.SmoothPlastic then inst.Material = Enum.Material.SmoothPlastic end
    if inst.Reflectance ~= 0 then inst.Reflectance = 0 end
    if inst.CastShadow ~= false then inst.CastShadow = false end
end

-- Pasang event listener untuk karakter saat ini dan di masa depan
local function onCharacterAdded(character)
    -- Proses part yang sudah ada saat spawn
    for _, child in ipairs(character:GetDescendants()) do
        processCharacterPart(child)
    end
    -- Pasang listener untuk part baru (misal: tool/equip)
    character.DescendantAdded:Connect(processCharacterPart)
end

LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
if LocalPlayer.Character then
    onCharacterAdded(LocalPlayer.Character)
end

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
