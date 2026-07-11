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

-- [WARNA TEMA: Abu-abu Gelap (Tetap 50, 50, 50)]
local WARNA_GELAP = Color3.fromRGB(50, 50, 50)

-- ==========================================
-- UI PING & DRAG (Dipertahankan Utuh)
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
-- PENJAGA CUACA (INSTAN GELAP TANPA BOCOR CAHAYA)
-- ==========================================
local function lockLighting()
    pcall(function()
        -- Kita cek dulu agar tidak terjadi infinite loop
        if Lighting.GlobalShadows ~= false then Lighting.GlobalShadows = false end
        if Lighting.Brightness ~= 1 then Lighting.Brightness = 1 end
        if Lighting.Ambient ~= WARNA_GELAP then Lighting.Ambient = WARNA_GELAP end
        if Lighting.OutdoorAmbient ~= WARNA_GELAP then Lighting.OutdoorAmbient = WARNA_GELAP end
        if Lighting.TimeOfDay ~= "00:00:00" then Lighting.TimeOfDay = "00:00:00" end
        if Lighting.FogStart ~= 9999999 then Lighting.FogStart = 9999999 end
        if Lighting.FogEnd ~= 9999999 then Lighting.FogEnd = 9999999 end
    end)
end

local function destroyLightingChildren(obj)
    if obj:IsA("Sky") or obj:IsA("Atmosphere") or obj:IsA("BloomEffect") or obj:IsA("SunRaysEffect") or obj:IsA("ColorCorrectionEffect") or obj:IsA("BlurEffect") then
        pcall(function() obj:Destroy() end)
    end
end

-- Kunci di detik pertama
lockLighting()
for _, obj in pairs(Lighting:GetChildren()) do destroyLightingChildren(obj) end

-- Kunci INSTAN setiap kali ada yang coba ubah cahaya (Totem/Cuaca)
Lighting.Changed:Connect(lockLighting)
Lighting.ChildAdded:Connect(function(child)
    task.spawn(function() destroyLightingChildren(child) end)
end)


-- ==========================================
-- LOGIKA PEMBANTAIAN & PELINDUNGAN PIJAKAN
-- ==========================================
-- Sama dengan daftar Ookami, TAPI tanpa menghancurkan pondasi pijakan
local TO_DESTROY = {
    ParticleEmitter = true, Smoke = true, Fire = true, Sparkles = true,
    Beam = true, Trail = true, Explosion = true, Discharge = true, Dust = true,
    PointLight = true, SpotLight = true, SurfaceLight = true, Light = true,
    Accessory = true, CharacterMesh = true,
    Shirt = true, Pants = true, ShirtGraphic = true, Clothing = true, BodyColors = true,
    PostEffect = true, SelectionBox = true, Decal = true, Texture = true,
    SurfaceAppearance = true
}

local function processInstance(inst)
    if inst:IsDescendantOf(CoreGui) then return end
    
    local isProtected = false
    local name = inst.Name
    
    -- 1. Pertahankan logika Totem & Pelampung punyamu (Aman dari spam error)
    if string.find(name, "Totem") or string.find(name, "Bobber") then isProtected = true end
    if inst.Parent and (string.find(inst.Parent.Name, "Totem") or string.find(inst.Parent.Name, "Bobber")) then isProtected = true end
    
    -- 2. Pertahankan kepala bulat
    if inst:IsA("SpecialMesh") and inst.Parent and inst.Parent.Name == "Head" then
        isProtected = true
    end
    
    -- 3. Joran (Rod) Ngotak tapi warna aslinya aman
    local isRodPart = false
    if string.find(name, "Rod") or (inst.Parent and string.find(inst.Parent.Name, "Rod")) then
        isRodPart = true
        if inst:IsA("BasePart") then
            isProtected = true 
        end
    end

    if not isProtected then
        local cName = inst.ClassName
        
        if TO_DESTROY[cName] or cName == "SpecialMesh" then
            pcall(function() inst:Destroy() end)
            
        -- LOGIKA ANTI-TENGGELAM: BasePart (termasuk MeshPart & Union) BUKAN dihancurkan, tapi dikotakkan!
        elseif inst:IsA("BasePart") and not inst:IsA("Terrain") then
            pcall(function()
                if not isRodPart then
                    if inst.Color ~= WARNA_GELAP then inst.Color = WARNA_GELAP end
                    if inst.Material ~= Enum.Material.SmoothPlastic then inst.Material = Enum.Material.SmoothPlastic end
                    if inst.Reflectance ~= 0 then inst.Reflectance = 0 end
                    if inst.CastShadow ~= false then inst.CastShadow = false end
                    -- Cabut tekstur 3D bawaan MeshPart agar ringan seperti Ookami
                    if cName == "MeshPart" and inst.TextureID ~= "" then inst.TextureID = "" end
                end
            end)
        end
    end
end


-- ==========================================
-- EKSEKUSI OOKAMI-STYLE (INSTAN LISTENER)
-- ==========================================
-- Setting Terrain Air
pcall(function()
    if Workspace:FindFirstChildOfClass("Terrain") then
        local t = Workspace.Terrain
        t.WaterColor = WARNA_GELAP
        t.WaterWaveSize = 0; t.WaterWaveSpeed = 0; t.WaterReflectance = 0; t.WaterTransparency = 0
    end
end)

-- Fungsi Pemicu Instan yang dibungkus Task Spawn (Gaya Ookami)
local function musnahkan(v)
    task.spawn(function()
        processInstance(v)
    end)
end

-- Listener instan setiap milidetik (0 detik bocor partikel)
Workspace.DescendantAdded:Connect(musnahkan)

-- Eksekusi awal satu kali ke seluruh map
task.spawn(function()
    for _, object in pairs(Workspace:GetDescendants()) do
        musnahkan(object)
    end
end)


-- ==========================================
-- FPS CAP & DAILY LOGIN (LOGIC ASLI MILIKMU)
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
    while task.wait(3) do
        local dailyUI = PlayerGui:FindFirstChild("!!! Daily Login")
        if dailyUI and dailyUI.Enabled == true then
            pcall(function() require(ReplicatedStorage.Modules.GuiControl):Close() end)
        end
    end
end)