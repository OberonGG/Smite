local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Stats = game:GetService("Stats")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- [PENGATURAN REDUCE]
local WARNA_GELAP = Color3.fromRGB(50, 50, 50)
local RADIUS_STUDS = 600 -- Jarak sapuan area sekitarmu (600 studs cukup untuk 1 pulau)

-- ==========================================
-- UI PING & DRAG 
-- ==========================================
local GuiControl = pcall(function() return require(ReplicatedStorage.Modules.GuiControl) end)
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
-- LOGIKA PEMBANTAIAN & PELINDUNGAN
-- ==========================================
local TO_DESTROY = {
    ParticleEmitter = true, Smoke = true, Fire = true, Sparkles = true,
    Beam = true, Trail = true, Explosion = true, Discharge = true, Dust = true,
    PointLight = true, SpotLight = true, SurfaceLight = true,
    Accessory = true, SpecialMesh = true, CharacterMesh = true,
    Shirt = true, Pants = true, ShirtGraphic = true, BodyColors = true
}

local function lockLighting()
    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.Brightness = 1
        Lighting.Ambient = WARNA_GELAP
        Lighting.OutdoorAmbient = WARNA_GELAP
        Lighting.TimeOfDay = "00:00:00"
        Lighting.FogStart = 9999999
        Lighting.FogEnd = 9999999
        for _, obj in pairs(Lighting:GetChildren()) do
            if obj:IsA("Sky") then obj.CelestialBodiesShown = false end
        end
    end)
end

-- Fungsi inti untuk memproses 1 objek
local function processInstance(inst)
    if inst:IsDescendantOf(CoreGui) then return end
    
    local isProtected = false
    local name = inst.Name
    
    -- 1. Lindungi Totem, Pelampung, dan Sistem Joran agar game tidak error
    if string.find(name, "Totem") or string.find(name, "Bobber") then isProtected = true end
    if inst.Parent and (string.find(inst.Parent.Name, "Totem") or string.find(inst.Parent.Name, "Bobber")) then isProtected = true end
    
    -- 2. Lindungi Kepala agar avatar tetap BULAT (tidak berubah jadi lego kotak)
    if inst:IsA("SpecialMesh") and inst.Parent and inst.Parent.Name == "Head" then
        isProtected = true
    end
    
    -- Joran (Rod) TIDAK dilindungi Mesh-nya agar bentuknya "Ngotak", tapi BasePart-nya jangan dicat 50,50,50
    local isRodPart = false
    if string.find(name, "Rod") or (inst.Parent and string.find(inst.Parent.Name, "Rod")) then
        isRodPart = true
    end

    if not isProtected then
        local cName = inst.ClassName
        if TO_DESTROY[cName] then
            pcall(function() inst:Destroy() end)
        elseif inst:IsA("BasePart") then
            pcall(function()
                if not isRodPart and inst.Color ~= WARNA_GELAP then
                    inst.Color = WARNA_GELAP
                    inst.CastShadow = false
                end
            end)
        end
    end
end

-- ==========================================
-- SAPUAN 1 DETIK (HANYA AREA RADIUS STUDS)
-- ==========================================
local function sweepLocalRadius()
    lockLighting()
    pcall(function()
        if workspace:FindFirstChildOfClass("Terrain") then
            local t = workspace.Terrain
            t.WaterColor = WARNA_GELAP
            t.WaterWaveSize = 0; t.WaterWaveSpeed = 0; t.WaterReflectance = 0; t.WaterTransparency = 0
        end
    end)

    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    if root then
        -- Mengambil HANYA objek yang berada di radius 600 studs dari pemain (Sangat ringan untuk CPU)
        local partsInRadius = workspace:GetPartBoundsInRadius(root.Position, RADIUS_STUDS)
        
        for _, part in ipairs(partsInRadius) do
            processInstance(part)
            
            -- Proses juga anak-anak dari part tersebut (seperti Mesh, Particle, atau Textures di sekitarmu)
            for _, child in ipairs(part:GetChildren()) do
                processInstance(child)
            end
            
            -- Jika part itu adalah bagian dari Aksesoris atau Joran, proses juga induknya
            if part.Parent and (part.Parent:IsA("Accessory") or part.Parent:IsA("Tool")) then
                processInstance(part.Parent)
                for _, sibling in ipairs(part.Parent:GetChildren()) do
                    processInstance(sibling)
                end
            end
        end
    end
end

-- ==========================================
-- SAPUAN 1 JAM (SAPU JAGAT SELURUH MAP)
-- ==========================================
local function sweepGlobal()
    local descendants = workspace:GetDescendants()
    local processed = 0
    for i = 1, #descendants do
        processInstance(descendants[i])
        processed = processed + 1
        if processed % 500 == 0 then RunService.Heartbeat:Wait() end
    end
end

-- ==========================================
-- EKSEKUSI LOOPING
-- ==========================================
task.spawn(function()
    while true do
        sweepLocalRadius()
        task.wait(1) -- Membersihkan radius terdekat tiap 1 detik
    end
end)

task.spawn(function()
    while true do
        task.wait(3600) -- Menunggu 1 Jam
        sweepGlobal()   -- Membersihkan seluruh map setelah 1 jam
    end
end)

-- ==========================================
-- FPS CAP & DAILY LOGIN (LISTENER)
-- ==========================================
if setfpscap then
    setfpscap(30)
    task.spawn(function()
        while task.wait(10) do
            setfpscap(30)
        end
    end)
end

task.spawn(function()
    local dailyUI = PlayerGui:WaitForChild("!!! Daily Login", 10)
    if dailyUI then
        if dailyUI.Enabled == true then
            pcall(function() require(ReplicatedStorage.Modules.GuiControl):Close() end)
        end
        dailyUI:GetPropertyChangedSignal("Enabled"):Connect(function()
            if dailyUI.Enabled == true then
                pcall(function() require(ReplicatedStorage.Modules.GuiControl):Close() end)
            end
        end)
    end
end)