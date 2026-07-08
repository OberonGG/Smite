local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Stats = game:GetService("Stats")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

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

local function closeLynx()
    local LynxGui = CoreGui:FindFirstChild("LynxGui") or CoreGui:FindFirstChild("LynxHub")
    if LynxGui then
        local targetFrame = LynxGui:FindFirstChild("MainFrame") or LynxGui:FindFirstChildOfClass("Frame")
        if targetFrame then targetFrame.Visible = not targetFrame.Visible end
    end
end

LynxButton.MouseButton1Click:Connect(closeLynx)

local startTime = os.time()
task.spawn(function()
    while task.wait(1) do
        local ping = 0
        pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
        local elapsed = os.time() - startTime
        textLabel.Text = string.format("Ping: %d ms | %d:%02d:%02d", ping, math.floor(elapsed/3600), math.floor((elapsed%3600)/60), elapsed%60)
    end
end)

local DECORATIVE = {ParticleEmitter=1, Smoke=1, Fire=1, Sparkles=1, Beam=1, Trail=1, Explosion=1, Discharge=1, Dust=1, PointLight=1, SpotLight=1, SurfaceLight=1, Decal=1, Texture=1, SurfaceAppearance=1, Atmosphere=1, ColorCorrectionEffect=1, BloomEffect=1, SunRaysEffect=1, BlurEffect=1, DepthOfFieldEffect=1, Highlight=1, SelectionBox=1}

local function setupWorld()
    Lighting.GlobalShadows = false
    Lighting.Brightness = 0
    Lighting.Ambient = Color3.fromRGB(35, 35, 35)
    Lighting.OutdoorAmbient = Color3.fromRGB(35, 35, 35)
    Lighting.FogColor = Color3.fromRGB(35, 35, 35)
    Lighting.FogStart = 0
    Lighting.FogEnd = 250
    Lighting.TimeOfDay = "00:00:00"
    if setfpscap then setfpscap(30) end
end

local function cleanChar(char)
    if not char then return end
    for _, inst in ipairs(char:GetDescendants()) do
        if inst:IsA("Accessory") or inst:IsA("Shirt") or inst:IsA("Pants") then pcall(function() inst:Destroy() end)
        elseif inst:IsA("BasePart") then
            inst.Color = Color3.fromRGB(150, 150, 150)
            inst.Material = Enum.Material.SmoothPlastic
        end
    end
end

local function runReduce()
    pcall(function()
        workspace.Terrain:Clear()
        for _, obj in ipairs(workspace:GetChildren()) do
            if obj:IsA("Sky") or obj:IsA("Clouds") then obj:Destroy() end
        end
    end)
    for _, inst in ipairs(workspace:GetDescendants()) do
        if not inst:IsDescendantOf(LocalPlayer.Character) and not inst:IsDescendantOf(CoreGui) then
            if inst:IsA("Humanoid") and not Players:GetPlayerFromCharacter(inst.Parent) then pcall(function() inst.Parent:Destroy() end)
            elseif DECORATIVE[inst.ClassName] then pcall(function() inst:Destroy() end)
            elseif inst:IsA("BasePart") then
                inst.Material = Enum.Material.SmoothPlastic
                inst.CastShadow = false
            end
        end
        if RunService.Heartbeat:Wait() then end
    end
end

setupWorld()
LocalPlayer.CharacterAdded:Connect(cleanChar)
if LocalPlayer.Character then cleanChar(LocalPlayer.Character) end

task.spawn(function()
    while true do
        runReduce()
        task.wait(3600)
    end
end)