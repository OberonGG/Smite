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
LynxButton.Size = UDim2.new(0, 35, 0, 35)
LynxButton.Position = UDim2.new(0.015, 0, 0.1, 0)
LynxButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
LynxButton.BackgroundTransparency = 0.15
LynxButton.BorderSizePixel = 0
LynxButton.AutoButtonColor = true
LynxButton.Active = true

local LynxCorner = Instance.new("UICorner", LynxButton)
LynxCorner.CornerRadius = UDim.new(1, 0)

local LynxXLabel = Instance.new("TextLabel", LynxButton)
LynxXLabel.Size = UDim2.new(1, 0, 1, 0)
LynxXLabel.BackgroundTransparency = 1
LynxXLabel.Text = "❌"
LynxXLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
LynxXLabel.TextSize = 16
LynxXLabel.Font = Enum.Font.SourceSansBold

local dragging
local dragInput
local dragStart
local startPos

local function update(input)
    local delta = input.Position - dragStart
    frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

local dragging2
local dragInput2
local dragStart2
local startPos2

local function update2(input)
    local delta = input.Position - dragStart2
    LynxButton.Position = UDim2.new(startPos2.X.Scale, startPos2.X.Offset + delta.X, startPos2.Y.Scale, startPos2.Y.Offset + delta.Y)
end

LynxButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging2 = true
        dragStart2 = input.Position
        startPos2 = LynxButton.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging2 = false
            end
        end)
    end
end)

LynxButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput2 = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput2 and dragging2 then
        update2(input)
    end
end)

local function closeLynx()
    local LynxGui = CoreGui:FindFirstChild("LynxGui") or CoreGui:FindFirstChild("LynxHub")
    if not LynxGui then
        for _, child in ipairs(CoreGui:GetChildren()) do
            if string.find(string.lower(child.Name), "lynx") then
                LynxGui = child
                break
            end
        end
    end
    if LynxGui then
        local targetFrame = LynxGui:FindFirstChild("MainFrame") or LynxGui:FindFirstChildOfClass("Frame")
        if not targetFrame then
            for _, obj in ipairs(CoreGui:GetChildren()) do
                if obj:IsA("Frame") then
                    targetFrame = obj
                    break
                end
            end
        end
        if targetFrame then
            pcall(function()
                targetFrame.Visible = not targetFrame.Visible
            end)
        end
    end
end

LynxButton.MouseButton1Click:Connect(closeLynx)

local startTime = os.time()
task.spawn(function()
    for _, child in ipairs(CoreGui:GetChildren()) do
        if string.find(string.lower(child.Name), "lynx") then
            local targetFrame = child:FindFirstChild("MainFrame") or child:FindFirstChildOfClass("Frame")
            if targetFrame then
                pcall(function() targetFrame.Visible = false end)
            end
            break
        end
    end
    while task.wait(1) do
        local ping = 0
        pcall(function()
            ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        end)
        local elapsed = os.time() - startTime
        local h = math.floor(elapsed / 3600)
        local m = math.floor((elapsed % 3600) / 60)
        local s = elapsed % 60
        textLabel.Text = string.format("Ping: %d ms | %d:%02d:%02d", ping, h, m, s)
    end
end)

local AUTO_REPEAT = true
local REPEAT_INTERVAL = 3600
local BATCH_SIZE = 30

local DECORATIVE = {
    ParticleEmitter = true, Smoke = true, Fire = true, Sparkles = true,
    Beam = true, Trail = true, Explosion = true, Discharge = true,
    Dust = true, PointLight = true, SpotLight = true, SurfaceLight = true,
    Decal = true, Texture = true, SurfaceAppearance = true,
    Highlight = true, SelectionBox = true, RopeConstraint = true,
    BillboardGui = true, SurfaceGui = true
}

local CORE_LIMBS = {
    ["Head"] = true, ["Torso"] = true, ["Left Arm"] = true, ["Right Arm"] = true, ["Left Leg"] = true, ["Right Leg"] = true,
    ["HumanoidRootPart"] = true, ["UpperTorso"] = true, ["LowerTorso"] = true, 
    ["LeftUpperArm"] = true, ["LeftLowerArm"] = true, ["LeftHand"] = true,
    ["RightUpperArm"] = true, ["RightLowerArm"] = true, ["RightHand"] = true,
    ["LeftUpperLeg"] = true, ["LeftLowerLeg"] = true, ["LeftFoot"] = true,
    ["RightUpperLeg"] = true, ["RightLowerLeg"] = true, ["RightFoot"] = true
}

local function cleanChar(char)
    if not char then return end
    for _, inst in ipairs(char:GetDescendants()) do
        if inst:IsA("Accessory") or inst:IsA("Shirt") or inst:IsA("Pants") or inst:IsA("ShirtGraphic") or inst:IsA("BodyColors") or inst:IsA("CharacterMesh") then
            pcall(function() inst:Destroy() end)
        elseif inst:IsA("BasePart") then
            if not CORE_LIMBS[inst.Name] then
                inst.Transparency = 1
                inst.LocalTransparencyModifier = 1
            else
                inst.Color = Color3.fromRGB(150, 150, 150)
                inst.Material = Enum.Material.SmoothPlastic
                inst.Transparency = 0
            end
        elseif DECORATIVE[inst.ClassName] then
            pcall(function() inst:Destroy() end)
        end
    end
end

local function neutralizeTarget(obj)
    if obj.Name == "BaseGrayCC" then
        obj.Brightness = 0.07843
        obj.Contrast = 0
        obj.Saturation = -1
        obj.Enabled = true
        return
    end
    if obj:IsA("Sky") and obj.Name ~= "BaseNormalSky" then
        task.defer(function() pcall(function() obj:Destroy() end) end)
        return
    end
    if obj:IsA("ColorCorrectionEffect") or obj:IsA("SunRaysEffect") or obj:IsA("BloomEffect") or obj:IsA("BlurEffect") or obj:IsA("Clouds") then
        obj.Enabled = false
    elseif obj:IsA("Atmosphere") then
        obj.Density = 0
        obj.Glare = 0
        obj.Haze = 0
    end
end

local function handleDescendant(inst)
    if inst:IsDescendantOf(LocalPlayer.Character) or inst:IsDescendantOf(CoreGui) then return end

    if inst:IsA("BasePart") then
        pcall(function()
            inst.Transparency = 1
            inst.Color = Color3.fromRGB(0, 0, 0)
            inst.CastShadow = false
            inst.Material = Enum.Material.SmoothPlastic
        end)
    elseif DECORATIVE[inst.ClassName] or inst:IsA("PostEffect") then
        pcall(function() inst:Destroy() end)
    elseif inst:IsA("Sky") or inst:IsA("Atmosphere") or inst:IsA("ColorCorrectionEffect") or inst:IsA("SunRaysEffect") or inst:IsA("BloomEffect") or inst:IsA("BlurEffect") or inst:IsA("Clouds") then
        pcall(neutralizeTarget, inst)
    elseif inst:IsA("Humanoid") then
        local model = inst.Parent
        if model and model:IsA("Model") and not Players:GetPlayerFromCharacter(model) then
            task.defer(function() pcall(function() model:Destroy() end) end)
        end
    end
end

Lighting.DescendantAdded:Connect(handleDescendant)
workspace.DescendantAdded:Connect(handleDescendant)

for _, obj in ipairs(Lighting:GetDescendants()) do handleDescendant(obj) end

local FORCED_LIGHTING = {
    GlobalShadows = false,
    Brightness = 0,
    Ambient = ABU_GELAP,
    OutdoorAmbient = ABU_GELAP,
    ExposureCompensation = 0,
    EnvironmentDiffuseScale = 0,
    EnvironmentSpecularScale = 0,
    TimeOfDay = "00:00:00",
    FogStart = 999999,
    FogEnd = 999999,
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

local function runReduce()
    pcall(function()
        workspace.Terrain:Clear()
    end)

    local objectsProcessed = 0
    for _, inst in ipairs(workspace:GetDescendants()) do
        if not inst:IsDescendantOf(LocalPlayer.Character) and not inst:IsDescendantOf(CoreGui) then
            handleDescendant(inst)

            objectsProcessed = objectsProcessed + 1
            if objectsProcessed % BATCH_SIZE == 0 then
                RunService.Heartbeat:Wait()
            end
        end
    end
end

LocalPlayer.CharacterAdded:Connect(cleanChar)
if LocalPlayer.Character then
    cleanChar(LocalPlayer.Character)
end

task.spawn(runReduce)

if AUTO_REPEAT then
    task.spawn(function()
        while true do
            task.wait(REPEAT_INTERVAL)
            runReduce()
        end
    end)
end

task.spawn(function()
    while task.wait(1) do
        if GuiControl and GuiControl:IsOpen("!!! Daily Login") then
            pcall(function() 
                GuiControl:Close() 
            end)
        end
    end
end)