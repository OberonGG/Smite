local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Stats = game:GetService("Stats")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local ABU_TARGET = Color3.fromRGB(30, 30, 30)
local WATCHED_REGISTRY = setmetatable({}, {__mode = "k"})

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

-- SISTEM DRAG
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
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
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
        if targetFrame then
            pcall(function() targetFrame.Visible = not targetFrame.Visible end)
        end
    end
end

LynxButton.MouseButton1Click:Connect(closeLynx)

local startTime = os.time()
task.spawn(function()
    for _, child in ipairs(CoreGui:GetChildren()) do
        if string.find(string.lower(child.Name), "lynx") then
            local targetFrame = child:FindFirstChild("MainFrame") or child:FindFirstChildOfClass("Frame")
            if targetFrame then pcall(function() targetFrame.Visible = false end) end
            break
        end
    end
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

-- DAFTAR OBJEK YANG AKAN DIHANCURKAN (Meniru log target)
-- Memasukkan SpecialMesh & CharacterMesh agar joran jadi kotak & pemain jadi bulat
local DELETED_CLASSES = {
    ParticleEmitter = true, Smoke = true, Fire = true, Sparkles = true,
    Beam = true, Trail = true, Explosion = true, Discharge = true,
    Dust = true, PointLight = true, SpotLight = true, SurfaceLight = true,
    Decal = true, Texture = true, SurfaceAppearance = true,
    Highlight = true, SelectionBox = true, RopeConstraint = true,
    BillboardGui = true, SurfaceGui = true,
    Accessory = true, Shirt = true, Pants = true, ShirtGraphic = true, BodyColors = true,
    SpecialMesh = true, CharacterMesh = true, WeldConstraint = true, Vector3Value = true
}

local TARGET_CLASSES = {
    Atmosphere = true, ColorCorrectionEffect = true, Sky = true,
    SunRaysEffect = true, BloomEffect = true, BlurEffect = true, Clouds = true
}

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

    if obj:IsA("ColorCorrectionEffect") or obj:IsA("SunRaysEffect") or obj:IsA("BloomEffect") or obj:IsA("BlurEffect") or obj:IsA("Clouds") then
        if obj.Enabled ~= false then obj.Enabled = false end
    elseif obj:IsA("Atmosphere") then
        if obj.Density ~= 0 then obj.Density = 0 end
        if obj.Glare ~= 0 then obj.Glare = 0 end
        if obj.Haze ~= 0 then obj.Haze = 0 end
    elseif obj:IsA("Sky") then
        if obj.CelestialBodiesShown ~= false then obj.CelestialBodiesShown = false end
        if obj.StarCount ~= 0 then obj.StarCount = 0 end
        if obj.SkyboxBk ~= "rbxassetid://0" then obj.SkyboxBk = "rbxassetid://0" end
        -- ... (clear skyboxes)
        obj.SkyboxDn = "rbxassetid://0"; obj.SkyboxFt = "rbxassetid://0"; 
        obj.SkyboxLf = "rbxassetid://0"; obj.SkyboxRt = "rbxassetid://0"; obj.SkyboxUp = "rbxassetid://0"
        if obj.SunTextureId ~= "rbxassetid://0" then obj.SunTextureId = "rbxassetid://0" end
        if obj.MoonTextureId ~= "rbxassetid://0" then obj.MoonTextureId = "rbxassetid://0" end
    end
end

-- LOGIKA INTI: Mengubah/Menghapus berdasarkan Class
local function handleDescendant(inst)
    if inst:IsDescendantOf(CoreGui) then return end

    if DELETED_CLASSES[inst.ClassName] or inst:IsA("PostEffect") then
        pcall(function() inst:Destroy() end)
        
    elseif inst:IsA("BasePart") then
        pcall(function()
            inst.Color = ABU_TARGET
            inst.Material = Enum.Material.SmoothPlastic
            inst.CastShadow = false
            inst.Transparency = 0
            if inst:IsA("MeshPart") then
                inst.TextureID = ""
            end
        end)
        
    elseif TARGET_CLASSES[inst.ClassName] then
        pcall(neutralizeTarget, inst)
        if not WATCHED_REGISTRY[inst] then
            WATCHED_REGISTRY[inst] = true
            inst.Changed:Connect(function()
                pcall(neutralizeTarget, inst)
            end)
        end
    end
end

-- SETUP PENGATURAN AIR (TERRAIN)
local function applyTerrainColor()
    pcall(function()
        if workspace:FindFirstChildOfClass("Terrain") then
            local t = workspace.Terrain
            t.WaterColor = ABU_TARGET
            t.WaterWaveSize = 0
            t.WaterWaveSpeed = 0
            t.WaterReflectance = 0
            t.WaterTransparency = 0
            -- Paksa warna material dasar ke abu-abu
            for _, mat in ipairs(Enum.Material:GetEnumItems()) do
                pcall(function() t:SetMaterialColor(mat, ABU_TARGET) end)
            end
        end
    end)
end

-- EVENT DRIVEN: Memproses objek yang baru muncul secara real-time
Lighting.DescendantAdded:Connect(handleDescendant)
workspace.DescendantAdded:Connect(handleDescendant)

-- INISIALISASI AWAL SECARA AMAN (Menggantikan runReduce loop)
task.spawn(function()
    applyTerrainColor()
    local descendants = workspace:GetDescendants()
    for i, inst in ipairs(descendants) do
        handleDescendant(inst)
        -- Beri jeda ke CPU setiap memproses 100 objek agar tidak crash saat pertama kali disuntikkan
        if i % 100 == 0 then RunService.Heartbeat:Wait() end
    end
    for _, obj in ipairs(Lighting:GetDescendants()) do handleDescendant(obj) end
end)

-- PENGATURAN LIGHTING BERDASARKAN LOG SPY LOGGER
local FORCED_LIGHTING = {
    GlobalShadows = false,
    Brightness = 1, -- Dari log target
    Ambient = ABU_TARGET,
    OutdoorAmbient = ABU_TARGET,
    ExposureCompensation = 0,
    EnvironmentDiffuseScale = 0,
    EnvironmentSpecularScale = 0,
    TimeOfDay = "00:00:00",
    FogStart = 8999999488, -- Dari log target
    FogEnd = 8999999488,   -- Dari log target
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

if setfpscap then
    setfpscap(30)
    task.spawn(function()
        while true do
           task.wait(10)
            setfpscap(30)
        end
    end)
end

-- AUTO CLOSE DAILY LOGIN
task.spawn(function()
    while task.wait(1) do
        local dailyUI = PlayerGui:FindFirstChild("!!! Daily Login")
        if dailyUI and dailyUI.Enabled == true then
            pcall(function() GuiControl:Close() end)
            task.wait(3)
        end
    end
end)