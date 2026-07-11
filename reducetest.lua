local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Stats = game:GetService("Stats")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- [WARNA TEMA: Hitam Keabu-abuan]
local WARNA_GELAP = Color3.fromRGB(30, 30, 30)

-- ==========================================
-- UI PING & DRAG (Tetap Dipertahankan)
-- ==========================================
local GuiControl = require(ReplicatedStorage.Modules.GuiControl)
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

local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(1, 0)

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
            dragging = true
            dragStart = input.Position
            startPos = frameToDrag.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
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
        local h = math.floor(elapsed / 3600)
        local m = math.floor((elapsed % 3600) / 60)
        local s = elapsed % 60
        textLabel.Text = string.format("Ping: %d ms | %d:%02d:%02d", ping, h, m, s)
    end
end)

-- ==========================================
-- LOGIKA HYBRID: HANCURKAN vs SEMBUNYIKAN
-- ==========================================

-- Kategori 1: PEMBANTAIAN (Objek sampah yang terus spawn dan bikin RAM bocor)
local TO_DESTROY = {
    ParticleEmitter = true, Smoke = true, Fire = true, Sparkles = true,
    Beam = true, Trail = true, Explosion = true, Discharge = true, Dust = true,
    PointLight = true, SpotLight = true, SurfaceLight = true, RopeConstraint = true
}

-- Kategori 2: PELUMPUHAN (Sembunyikan agar engine tidak error mencari objek yang hilang)
local TO_HIDE = {
    Accessory = true, SpecialMesh = true, CharacterMesh = true,
    Shirt = true, Pants = true, ShirtGraphic = true, BodyColors = true,
    Decal = true, Texture = true, SurfaceAppearance = true,
    Highlight = true, SelectionBox = true, BillboardGui = true, SurfaceGui = true
}

local TARGET_CLASSES = {
    Atmosphere = true, ColorCorrectionEffect = true, Sky = true,
    SunRaysEffect = true, BloomEffect = true, BlurEffect = true, Clouds = true
}

local function neutralizeLighting(obj)
    if obj.Name == "BaseGrayCC" or obj.Name == "BaseNormalSky" then return end
    if obj:IsA("PostEffect") or obj:IsA("Clouds") then
        if obj.Enabled ~= false then obj.Enabled = false end
    elseif obj:IsA("Atmosphere") then
        if obj.Density ~= 0 then obj.Density = 0 end
    elseif obj:IsA("Sky") then
        if obj.CelestialBodiesShown ~= false then obj.CelestialBodiesShown = false end
        obj.SkyboxBk = ""; obj.SkyboxDn = ""; obj.SkyboxFt = ""; obj.SkyboxLf = ""; obj.SkyboxRt = ""; obj.SkyboxUp = ""
    end
end

-- ==========================================
-- FUNGSI SAPUAN (BATCHING AGAR TIDAK SPIKE)
-- ==========================================
local function executeSweep()
    pcall(function()
        -- 1. Warna Air (Tetap aman tanpa menghapus)
        if workspace:FindFirstChildOfClass("Terrain") then
            local t = workspace.Terrain
            t.WaterColor = WARNA_GELAP
            t.WaterWaveSize = 0
            t.WaterWaveSpeed = 0
            t.WaterReflectance = 0
            t.WaterTransparency = 0
        end
    end)

    local descendants = workspace:GetDescendants()
    local processed = 0

    for i = 1, #descendants do
        local inst = descendants[i]
        
        -- Bypass UI dan Karakter Lokal (jika diperlukan)
        if not inst:IsDescendantOf(CoreGui) then
            local cName = inst.ClassName

            if TO_DESTROY[cName] then
                pcall(function() inst:Destroy() end)
                
            elseif TO_HIDE[cName] then
                pcall(function()
                    if inst:IsA("Accessory") or inst:IsA("Shirt") or inst:IsA("Pants") or inst:IsA("ShirtGraphic") or inst:IsA("BodyColors") then
                        -- Untuk accessory/baju, kita tidak destroy, tapi disable efek visualnya jika memungkinkan, 
                        -- namun cara teraman adalah membiarkannya tapi membuat Mesh di dalamnya transparan
                    elseif inst:IsA("SpecialMesh") or inst:IsA("CharacterMesh") then
                        inst.Scale = Vector3.new(0,0,0) -- Jadikan tak terlihat tanpa menghancurkannya
                    else
                        inst.Transparency = 1
                        if inst:IsA("Decal") or inst:IsA("Texture") then inst.Transparency = 1 end
                    end
                end)
                
            elseif inst:IsA("BasePart") then
                pcall(function()
                    inst.Color = WARNA_GELAP
                    inst.Material = Enum.Material.SmoothPlastic
                    inst.CastShadow = false
                    -- Jangan set Transparency = 1 di BasePart bangunan agar tidak pusing fisika
                    if inst:IsA("MeshPart") then
                        inst.TextureID = ""
                    end
                end)
            end
        end

        -- [KUNCI ANTI-CPU SPIKE]: Beri napas CPU tiap 500 objek
        processed = processed + 1
        if processed % 500 == 0 then
            RunService.Heartbeat:Wait()
        end
    end

    -- Sapuan Lighting
    for _, obj in ipairs(Lighting:GetDescendants()) do
        if TARGET_CLASSES[obj.ClassName] then pcall(neutralizeLighting, obj) end
    end
end

-- ==========================================
-- LIGHTING OVERRIDE (Set & Forget)
-- ==========================================
Lighting.GlobalShadows = false
Lighting.Brightness = 1
Lighting.Ambient = WARNA_GELAP
Lighting.OutdoorAmbient = WARNA_GELAP
Lighting.TimeOfDay = "00:00:00"
Lighting.FogStart = 9999999
Lighting.FogEnd = 9999999

if not Lighting:FindFirstChild("BaseNormalSky") then
    local sky = Instance.new("Sky", Lighting)
    sky.Name = "BaseNormalSky"
    sky.CelestialBodiesShown = false
end

-- ==========================================
-- LOOPING UTAMA (Sapuan 5 Detik)
-- ==========================================
task.spawn(function()
    while true do
        executeSweep()
        task.wait(5) -- Beristirahat penuh selama 5 detik
    end
end)

-- ==========================================
-- FPS CAP & DAILY LOGIN
-- ==========================================
if setfpscap then
    setfpscap(30)
    task.spawn(function()
        while true do
            task.wait(10)
            setfpscap(30)
        end
    end)
end

task.spawn(function()
    while task.wait(3) do
        local dailyUI = PlayerGui:FindFirstChild("!!! Daily Login")
        if dailyUI and dailyUI.Enabled == true then
            pcall(function() GuiControl:Close() end)
        end
    end
end)