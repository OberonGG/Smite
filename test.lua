local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Stats = game:GetService("Stats")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local C_50 = Color3.fromRGB(50, 50, 50)
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
Instance.new("UICorner", frame).CornerRadius = UDim.new(1, 0)

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
        local h = math.floor(elapsed / 3600); local m = math.floor((elapsed % 3600) / 60); local s = elapsed % 60
        textLabel.Text = string.format("Ping: %d ms | %d:%02d:%02d", ping, h, m, s)
    end
end)

local TO_DESTROY = {
    ParticleEmitter = true, Smoke = true, Fire = true, Sparkles = true, Beam = true, Trail = true,
    Explosion = true, Discharge = true, Dust = true, PointLight = true, SpotLight = true,
    SurfaceLight = true, Decal = true, Texture = true, SurfaceAppearance = true, Highlight = true,
    SelectionBox = true, RopeConstraint = true, Atmosphere = true, ColorCorrectionEffect = true,
    SunRaysEffect = true, BloomEffect = true, BlurEffect = true, Clouds = true, PostEffect = true
}

local function annihilate(inst)
    pcall(inst.Destroy, inst)
end

local function handleWorkspaceDescendant(inst)
    if inst:IsDescendantOf(CoreGui) then return end
    
    if LocalPlayer.Character and inst:IsDescendantOf(LocalPlayer.Character) then
        if not inst:FindFirstAncestorWhichIsA("Tool") then return end
    end
    
    local cName = inst.ClassName
    if TO_DESTROY[cName] then
        annihilate(inst)
    elseif inst:IsA("BasePart") and not inst:IsA("Terrain") then
        inst.Color = C_50
        inst.Material = Enum.Material.SmoothPlastic
        inst.Reflectance = 0
        inst.CastShadow = false
        if cName == "MeshPart" then inst.TextureID = "" end
    end
end

local function forceLighting()
    Lighting.GlobalShadows = false
    Lighting.Brightness = 0
    Lighting.Ambient = C_50
    Lighting.OutdoorAmbient = C_50
    Lighting.FogStart = 9999999
    Lighting.FogEnd = 9999999
end

local function cleanSkyboxes(obj)
    if obj:IsA("Sky") then
        obj.SkyboxBk = "rbxassetid://0"
        obj.SkyboxDn = "rbxassetid://0"
        obj.SkyboxFt = "rbxassetid://0"
        obj.SkyboxLf = "rbxassetid://0"
        obj.SkyboxRt = "rbxassetid://0"
        obj.SkyboxUp = "rbxassetid://0"
        obj.SunTextureId = "rbxassetid://0"
        obj.MoonTextureId = "rbxassetid://0"
        obj.CelestialBodiesShown = false
        obj.StarCount = 0
    elseif TO_DESTROY[obj.ClassName] then
        annihilate(obj)
    end
end

Lighting:GetPropertyChangedSignal("Ambient"):Connect(forceLighting)
Lighting:GetPropertyChangedSignal("Brightness"):Connect(forceLighting)
Lighting.ChildAdded:Connect(cleanSkyboxes)

forceLighting()
for _, obj in ipairs(Lighting:GetChildren()) do cleanSkyboxes(obj) end

pcall(function()
    local t = workspace:FindFirstChildOfClass("Terrain")
    if t then
        t.WaterColor = C_50
        t.WaterWaveSize = 0
        t.WaterWaveSpeed = 0
        t.WaterReflectance = 0
        t.WaterTransparency = 0
    end
end)

local descendants = workspace:GetDescendants()
for i = 1, #descendants do
    handleWorkspaceDescendant(descendants[i])
end

workspace.DescendantAdded:Connect(handleWorkspaceDescendant)

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