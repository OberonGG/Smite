local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Stats = game:GetService("Stats")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- [WARNA TEMA MUTLAK]
local WARNA_GELAP = Color3.fromRGB(50, 50, 50)

-- ==========================================
-- UI PING, TIMER & DRAG (Asli Milikmu)
-- ==========================================
local ui = Instance.new("ScreenGui")
ui.Name = "PingTimerUI"
ui.ResetOnSpawn = false
ui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ui.Parent = (gethui and gethui()) or CoreGui

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

local function makeDraggable(obj, frameToDrag)
    local dragging, dragInput, dragStart, startPos
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = frameToDrag.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    obj.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frameToDrag.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end
makeDraggable(frame, frame)
makeDraggable(LynxButton, LynxButton)

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
        local h = math.floor(elapsed / 3600); local m = math.floor((elapsed % 3600) / 60); local s = elapsed % 60
        textLabel.Text = string.format("Ping: %d ms | %d:%02d:%02d", ping, h, m, s)
    end
end)

-- ==========================================
-- SISTEM SATPAM LIGHTING (Hard-Kill Mutlak)
-- ==========================================
local function lockLighting()
    -- Bypass semua interupsi cuaca secara brutal
    if Lighting.Ambient ~= WARNA_GELAP then Lighting.Ambient = WARNA_GELAP end
    if Lighting.OutdoorAmbient ~= WARNA_GELAP then Lighting.OutdoorAmbient = WARNA_GELAP end
    if Lighting.TimeOfDay ~= "00:00:00" then Lighting.TimeOfDay = "00:00:00" end
    if Lighting.Brightness ~= 1 then Lighting.Brightness = 1 end
    if Lighting.GlobalShadows ~= false then Lighting.GlobalShadows = false end
    if Lighting.FogStart ~= 9999999 then Lighting.FogStart = 9999999 end
    if Lighting.FogEnd ~= 9999999 then Lighting.FogEnd = 9999999 end
end

local function killLightingChild(child)
    if child:IsA("Sky") or child:IsA("Atmosphere") or child:IsA("BloomEffect") or child:IsA("SunRaysEffect") or child:IsA("ColorCorrectionEffect") or child:IsA("BlurEffect") then
        task.defer(function() pcall(function() child:Destroy() end) end)
    end
end

-- Eksekusi awal
lockLighting()
for _, obj in ipairs(Lighting:GetChildren()) do killLightingChild(obj) end

-- Listener Aktif Tanpa Loop
Lighting.Changed:Connect(lockLighting)
Lighting.ChildAdded:Connect(killLightingChild)

-- ==========================================
-- LOGIKA PEMBANTAIAN & PELINDUNG 70+ JAM
-- ==========================================
-- Menggunakan Dictionary agar lookup jauh lebih cepat daripada if-elseif
local TO_DESTROY = {
    ParticleEmitter = true, Smoke = true, Fire = true, Sparkles = true,
    Beam = true, Trail = true, Explosion = true, Discharge = true, Dust = true,
    PointLight = true, SpotLight = true, SurfaceLight = true, Light = true,
    Accessory = true, CharacterMesh = true,
    Shirt = true, Pants = true, ShirtGraphic = true, Clothing = true, BodyColors = true,
    PostEffect = true, SelectionBox = true, Decal = true, Texture = true,
    SurfaceAppearance = true, SpecialMesh = true
}

-- Pengecekan tanpa closure (Dibuat se-ringan mungkin untuk GC)
local function processInstance(inst)
    if inst:IsDescendantOf(CoreGui) then return end
    
    local name = inst.Name
    local parent = inst.Parent
    local cName = inst.ClassName
    local parentName = parent and parent.Name or ""
    
    -- Filter Proteksi (Tidak pakai string.lower agar tidak membuang memori)
    if string.find(name, "Totem") or string.find(name, "Bobber") or 
       string.find(parentName, "Totem") or string.find(parentName, "Bobber") then
        return
    end
    
    if cName == "SpecialMesh" and parentName == "Head" then return end
    
    local isRodPart = false
    if string.find(name, "Rod") or string.find(parentName, "Rod") then
        isRodPart = true
        if inst:IsA("BasePart") then return end
    end

    -- Eksekusi Utama
    if TO_DESTROY[cName] then
        -- task.defer sangat ringan, menghindari error lock hierarchy dari Engine Roblox
        task.defer(function() pcall(function() inst:Destroy() end) end)
    
    elseif inst:IsA("BasePart") and not inst:IsA("Terrain") then
        if not isRodPart then
            inst.Color = WARNA_GELAP
            inst.Material = Enum.Material.SmoothPlastic
            inst.Reflectance = 0
            inst.CastShadow = false
            if cName == "MeshPart" then inst.TextureID = "" end
        end
    end
end

-- ==========================================
-- INISIALISASI & LISTENER INSTAN (Murni Agresif)
-- ==========================================
pcall(function()
    local t = Workspace:FindFirstChildOfClass("Terrain")
    if t then
        t.WaterColor = WARNA_GELAP
        t.WaterWaveSize = 0; t.WaterWaveSpeed = 0; t.WaterReflectance = 0; t.WaterTransparency = 0
    end
end)

-- Melakukan Pass Pertama Tanpa Jeda
for _, object in ipairs(Workspace:GetDescendants()) do
    processInstance(object)
end

-- LISTENER BRUTAL: Dihubungkan langsung ke fungsi tanpa perantara closure () 
-- Ini adalah rahasia utama mencegah memory leak pada DescendantAdded
Workspace.DescendantAdded:Connect(processInstance)

-- ==========================================
-- DAILY LOGIN & FPS CAP (Loop Asli Milikmu)
-- ==========================================
if setfpscap then
    setfpscap(30)
    task.defer(function()
        while task.wait(10) do
            setfpscap(30)
        end
    end)
end

-- Dibiarkan menggunakan loop murni sesuai permintaan
task.defer(function()
    while task.wait(3) do
        local dailyUI = PlayerGui:FindFirstChild("!!! Daily Login")
        if dailyUI and dailyUI.Enabled == true then
            pcall(function() require(ReplicatedStorage.Modules.GuiControl):Close() end)
        end
    end
end)