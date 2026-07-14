local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Stats = game:GetService("Stats")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local ABU_GELAP = Color3.fromRGB(0, 0, 0)
local GuiControl = require(ReplicatedStorage.Modules.GuiControl)

-- ==========================================
-- 1. UI PING, TIMER & LYNX TOGGLE
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
LynxButton.Name = "ToggleBtn"
LynxButton.Size = UDim2.new(0, 45, 0, 45)
LynxButton.Position = UDim2.new(0.015, 0, 0.1, 0)
LynxButton.BackgroundTransparency = 1
LynxButton.Image = "rbxassetid://118176705805619"
LynxButton.Active = true
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

LynxButton.MouseButton1Click:Connect(function()
    pcall(function()
        local targetLynx = CoreGui:FindFirstChild("LynxGui")
        if targetLynx then targetLynx.Enabled = not targetLynx.Enabled end
    end)
end)

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
-- 2. REGISTRI PEMBANTAIAN & LOGIKA KARAKTER
-- ==========================================
-- Dictionary Lookup: O(1) Jauh lebih cepat dari array atau if-else berantai
local TO_DESTROY = {
    ParticleEmitter = true, Smoke = true, Fire = true, Sparkles = true, Beam = true, Trail = true, 
    Explosion = true, Discharge = true, Dust = true, PointLight = true, SpotLight = true, 
    SurfaceLight = true, Decal = true, Texture = true, SurfaceAppearance = true, Highlight = true, 
    SelectionBox = true, RopeConstraint = true, BillboardGui = true, SurfaceGui = true, 
    Atmosphere = true, ColorCorrectionEffect = true, Sky = true, SunRaysEffect = true, 
    BloomEffect = true, BlurEffect = true, Clouds = true, SpecialMesh = true,
    Accessory = true, Shirt = true, Pants = true, ShirtGraphic = true, BodyColors = true, CharacterMesh = true
}

local CORE_LIMBS = {
    ["Head"] = true, ["Torso"] = true, ["Left Arm"] = true, ["Right Arm"] = true, ["Left Leg"] = true, ["Right Leg"] = true,
    ["HumanoidRootPart"] = true, ["UpperTorso"] = true, ["LowerTorso"] = true, 
    ["LeftUpperArm"] = true, ["LeftLowerArm"] = true, ["LeftHand"] = true,
    ["RightUpperArm"] = true, ["RightLowerArm"] = true, ["RightHand"] = true,
    ["LeftUpperLeg"] = true, ["LeftLowerLeg"] = true, ["LeftFoot"] = true,
    ["RightUpperLeg"] = true, ["RightLowerLeg"] = true, ["RightFoot"] = true
}

-- Menghancurkan tanpa membuat fungsi anonim di memori (Mencegah Memory Leak)
local function annihilate(inst)
    pcall(inst.Destroy, inst)
end

local function cleanCharacterDescendant(inst)
    local cName = inst.ClassName
    if TO_DESTROY[cName] then
        annihilate(inst)
    elseif inst:IsA("BasePart") then
        if CORE_LIMBS[inst.Name] then
            inst.Color = Color3.fromRGB(150, 150, 150)
            inst.Material = Enum.Material.SmoothPlastic
            inst.Transparency = 0
        else
            -- Semua part tambahan (termasuk Joran, Reel, Bobber) langsung jadi tembus pandang
            inst.Transparency = 1
            inst.CastShadow = false
            inst.CanCollide = false
            if cName == "MeshPart" then inst.TextureID = "" end
        end
    end
end

local function setupCharacter(char)
    if not char then return end
    for _, inst in ipairs(char:GetDescendants()) do cleanCharacterDescendant(inst) end
    -- Listener krusial agar Joran yang baru di-equip langsung dieksekusi
    char.DescendantAdded:Connect(cleanCharacterDescendant)
end

local function handleWorkspaceDescendant(inst)
    if inst:IsDescendantOf(CoreGui) or inst:IsDescendantOf(LocalPlayer.Character) then return end
    local cName = inst.ClassName
    if TO_DESTROY[cName] then
        annihilate(inst)
    elseif inst:IsA("BasePart") then
        inst.Transparency = 1
        inst.Color = ABU_GELAP
        inst.Material = Enum.Material.SmoothPlastic
        inst.CastShadow = false
    end
end

-- ==========================================
-- 3. HARD-LOCK LIGHTING (Bebas CPU Spike)
-- ==========================================
local function forceLighting()
    Lighting.GlobalShadows = false
    Lighting.Brightness = 0
    Lighting.Ambient = ABU_GELAP
    Lighting.OutdoorAmbient = ABU_GELAP
    Lighting.FogStart = 999999
    Lighting.FogEnd = 999999
end

-- Hanya merespons jika 'Ambient' berubah, bukan bereaksi pada pergerakan jam 'ClockTime'
Lighting:GetPropertyChangedSignal("Ambient"):Connect(forceLighting)
Lighting.ChildAdded:Connect(annihilate)

forceLighting()
for _, obj in ipairs(Lighting:GetChildren()) do annihilate(obj) end

-- ==========================================
-- 4. EKSEKUSI PEMBANTAIAN INSTAN (Tanpa Batch)
-- ==========================================
workspace.Terrain:Clear()

-- Melakukan sapuan satu frame penuh (Game akan freeze 1-2 detik, tapi koneksi aman)
local descendants = workspace:GetDescendants()
for i = 1, #descendants do
    handleWorkspaceDescendant(descendants[i])
end

-- ==========================================
-- 5. LISTENER REAL-TIME & UTILITAS
-- ==========================================
workspace.DescendantAdded:Connect(handleWorkspaceDescendant)
LocalPlayer.CharacterAdded:Connect(setupCharacter)

if LocalPlayer.Character then setupCharacter(LocalPlayer.Character) end

if setfpscap then
    setfpscap(30)
    task.spawn(function()
        while task.wait(10) do setfpscap(30) end
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