local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Stats = game:GetService("Stats")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local GuiControl = require(ReplicatedStorage.Modules.GuiControl)

-- ==========================================
-- 1. SETUP UI
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

-- ==========================================
-- 2. SISTEM DRAG (Anti-Nyangkut) & KLIK LYNX
-- ==========================================
local function makeDraggable(obj, frameToDrag)
    local dragging, dragInput, dragStart, startPos
    
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frameToDrag.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
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

LynxButton.MouseButton1Click:Connect(function()
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
end)

task.spawn(function()
    for _, child in ipairs(CoreGui:GetChildren()) do
        if string.find(string.lower(child.Name), "lynx") then
            local targetFrame = child:FindFirstChild("MainFrame") or child:FindFirstChildOfClass("Frame")
            if targetFrame then pcall(function() targetFrame.Visible = false end) end
            break
        end
    end
end)

-- ==========================================
-- 3. PENCAHAYAAN (Kembali ke Hitam/Abu-abu Asli)
-- ==========================================
local ABU_GELAP = Color3.fromRGB(30, 30, 30)
Lighting.GlobalShadows = false
Lighting.Brightness = 0
Lighting.Ambient = ABU_GELAP
Lighting.OutdoorAmbient = ABU_GELAP
Lighting.ExposureCompensation = 0
Lighting.EnvironmentDiffuseScale = 0
Lighting.EnvironmentSpecularScale = 0
Lighting.TimeOfDay = "00:00:00"
Lighting.FogColor = Color3.fromRGB(0, 0, 0) -- Memastikan background kejauhan berwarna hitam pekat
Lighting.FogStart = 0
Lighting.FogEnd = 999999

-- Mengembalikan Skybox abu-abu gelap agar tidak terlihat putih menyilaukan
if not Lighting:FindFirstChild("BaseNormalSky") then
    local normalSky = Instance.new("Sky", Lighting)
    normalSky.Name = "BaseNormalSky"
    normalSky.CelestialBodiesShown = false
    normalSky.StarCount = 0
    normalSky.SkyboxBk = "rbxassetid://0"
    normalSky.SkyboxDn = "rbxassetid://0"
    normalSky.SkyboxFt = "rbxassetid://0"
    normalSky.SkyboxLf = "rbxassetid://0"
    normalSky.SkyboxRt = "rbxassetid://0"
    normalSky.SkyboxUp = "rbxassetid://0"
end

-- Mengembalikan ColorCorrection abu-abu bawaan script lamamu
if not Lighting:FindFirstChild("BaseGrayCC") then
    local grayCC = Instance.new("ColorCorrectionEffect", Lighting)
    grayCC.Name = "BaseGrayCC"
    grayCC.Brightness = 0.07843
    grayCC.Contrast = 0
    grayCC.Saturation = -1
end

-- ==========================================
-- 4. PEMBERSIHAN PASIF
-- ==========================================
local BATCH_SIZE = 30
local REPEAT_INTERVAL = 3600

local DECORATIVE = {
    ParticleEmitter = true, Smoke = true, Fire = true, Sparkles = true,
    Beam = true, Trail = true, Explosion = true, Discharge = true,
    Dust = true, PointLight = true, SpotLight = true, SurfaceLight = true,
    Decal = true, Texture = true, SurfaceAppearance = true,
    Highlight = true, SelectionBox = true, RopeConstraint = true,
    BillboardGui = true, SurfaceGui = true
}

local TARGET_CLASSES = {
    Atmosphere = true, ColorCorrectionEffect = true, Sky = true,
    SunRaysEffect = true, BloomEffect = true, BlurEffect = true, Clouds = true
}

local function neutralizeTarget(obj)
    if obj.Name == "BaseGrayCC" or obj.Name == "BaseNormalSky" then return end
    
    if obj:IsA("ColorCorrectionEffect") or obj:IsA("SunRaysEffect") or obj:IsA("BloomEffect") or obj:IsA("BlurEffect") or obj:IsA("Clouds") then
        if obj.Enabled ~= false then obj.Enabled = false end
    elseif obj:IsA("Atmosphere") then
        if obj.Density ~= 0 then obj.Density = 0 end
        if obj.Glare ~= 0 then obj.Glare = 0 end
        if obj.Haze ~= 0 then obj.Haze = 0 end
    elseif obj:IsA("Sky") then
        if obj.CelestialBodiesShown ~= false then obj.CelestialBodiesShown = false end
        if obj.StarCount ~= 0 then obj.StarCount = 0 end
    end
end

local function runReduce()
    pcall(function() workspace.Terrain:Clear() end)

    local objectsProcessed = 0
    for _, inst in ipairs(workspace:GetDescendants()) do
        if not inst:IsDescendantOf(LocalPlayer.Character) and not inst:IsDescendantOf(CoreGui) then
            
            if inst:IsA("BasePart") then
                pcall(function()
                    inst.Transparency = 1
                    inst.Color = Color3.fromRGB(0, 0, 0)
                    inst.CastShadow = false
                    inst.Material = Enum.Material.SmoothPlastic
                end)
            elseif DECORATIVE[inst.ClassName] or inst:IsA("PostEffect") then
                pcall(function() inst:Destroy() end)
            elseif TARGET_CLASSES[inst.ClassName] then
                pcall(neutralizeTarget, inst)
            end

            objectsProcessed = objectsProcessed + 1
            if objectsProcessed % BATCH_SIZE == 0 then
                RunService.Heartbeat:Wait()
            end
        end
    end
end

-- ==========================================
-- 5. LOOP (Real Ping 1 Detik & Daily Close 5 Detik)
-- ==========================================
if setfpscap then
    setfpscap(30)
end

local startTime = os.time()

task.spawn(function()
    while task.wait(1) do
        pcall(function()
            local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
            local elapsed = os.time() - startTime
            local h = math.floor(elapsed / 3600)
            local m = math.floor((elapsed % 3600) / 60)
            local s = elapsed % 60
            textLabel.Text = string.format("Ping: %d ms | %d:%02d:%02d", ping, h, m, s)
        end)
    end
end)

task.spawn(function()
    while task.wait(5) do
        local dailyUI = PlayerGui:FindFirstChild("!!! Daily Login")
        if dailyUI and dailyUI.Enabled == true then
            pcall(function() GuiControl:Close() end)
        end
    end
end)

task.spawn(runReduce)
task.spawn(function()
    while true do
        task.wait(REPEAT_INTERVAL)
        runReduce()
    end
end)