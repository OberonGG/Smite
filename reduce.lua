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

local parentUI = (gethui and gethui()) or (CoreGui:FindFirstChild("RobloxGui") and CoreGui) or LocalPlayer:WaitForChild("PlayerGui")
ui.Parent = parentUI

local frame = Instance.new("Frame", ui)
frame.Size = UDim2.new(0, 220, 0, 40)
frame.Position = UDim2.new(0.02, 0, 0.1, 0)
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
LynxButton.AnchorPoint = Vector2.new(0, 0)
LynxButton.Position = UDim2.new(0.04, 0, 0.14, 0)
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

    if not LynxGui then
        print("Lynx UI tidak ditemukan")
        return
    end

local targetFrame = LynxGui:FindFirstChild("MainFrame") or LynxGui:FindFirstChildOfClass("Frame")
    
    if not targetFrame then
        -- Jika struktur berubah, cari Frame terbesar di dalam LynxGui
        for _, obj in ipairs(LynxGui:GetChildren()) do
            if obj:IsA("Frame") then
                targetFrame = obj
                break
            end
        end
    end

    if targetFrame then
        pcall(function()
            -- Ubah visibilitas frame menu utamanya saja (Toggle on/off)
            targetFrame.Visible = not targetFrame.Visible
        end)
    else
        print("[WARN] Gagal mendeteksi Frame utama Lynx.")
    end
end

LynxButton.MouseButton1Click:Connect(closeLynx)

local startTime = os.time()

task.spawn(function()
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
local BATCH_SIZE = 1000

local DECORATIVE_CLASSES = {
    ParticleEmitter = true, Smoke = true, Fire = true, Sparkles = true,
    Beam = true, Trail = true, Explosion = true, Discharge = true,
    Dust = true, PointLight = true, SpotLight = true, SurfaceLight = true,
    Decal = true, Texture = true, SurfaceAppearance = true,
    Atmosphere = true, ColorCorrectionEffect = true, BloomEffect = true,
    SunRaysEffect = true, BlurEffect = true, DepthOfFieldEffect = true,
    Highlight = true, SelectionBox = true
}

local CORE_LIMBS = {
    ["Head"] = true, ["Torso"] = true, ["Left Arm"] = true, ["Right Arm"] = true, ["Left Leg"] = true, ["Right Leg"] = true,
    ["HumanoidRootPart"] = true, ["UpperTorso"] = true, ["LowerTorso"] = true, 
    ["LeftUpperArm"] = true, ["LeftLowerArm"] = true, ["LeftHand"] = true,
    ["RightUpperArm"] = true, ["RightLowerArm"] = true, ["RightHand"] = true,
    ["LeftUpperLeg"] = true, ["LeftLowerLeg"] = true, ["LeftFoot"] = true,
    ["RightUpperLeg"] = true, ["RightLowerLeg"] = true, ["RightFoot"] = true
}

local function cleanCharacterAndTools(char)
    if not char then return end
    
    for _, inst in ipairs(char:GetDescendants()) do
        if inst:IsA("Accessory") or inst:IsA("Shirt") or inst:IsA("Pants") 
        or inst:IsA("ShirtGraphic") or inst:IsA("BodyColors") or inst:IsA("CharacterMesh") then
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
        elseif DECORATIVE_CLASSES[inst.ClassName] then
            pcall(function() inst:Destroy() end)
        end
    end
end

RunService.RenderStepped:Connect(function()
    Lighting.GlobalShadows = false
    Lighting.Brightness = 0 
    Lighting.Ambient = Color3.fromRGB(35, 35, 35) 
    Lighting.OutdoorAmbient = Color3.fromRGB(35, 35, 35) 
    Lighting.FogColor = Color3.fromRGB(35, 35, 35) 
    Lighting.FogStart = 0
    Lighting.FogEnd = 250 
    Lighting.TimeOfDay = "00:00:00" 
    
    if setfpscap then 
        setfpscap(30)
    end 
    
    if LocalPlayer.Character then
        cleanCharacterAndTools(LocalPlayer.Character)
    end
end)

local function runReduce()
    pcall(function()
        local sky = workspace:FindFirstChildOfClass("Sky") or Lighting:FindFirstChildOfClass("Sky")
        if sky then sky:Destroy() end
        local clouds = workspace:FindFirstChildOfClass("Clouds") or Lighting:FindFirstChildOfClass("Clouds")
        if clouds then clouds:Destroy() end
        workspace.Terrain:Clear()
    end)

    local objectsProcessed = 0

    for _, inst in ipairs(workspace:GetDescendants()) do
        if not inst:IsDescendantOf(LocalPlayer.Character) then
            if inst:IsA("Humanoid") then
                local model = inst.Parent
                if model and model:IsA("Model") then
                    if not Players:GetPlayerFromCharacter(model) then
                        pcall(function() model:Destroy() end)
                    end
                end
            end

            if not inst:IsDescendantOf(CoreGui) then
                if DECORATIVE_CLASSES[inst.ClassName] or inst:IsA("PostEffect") or inst:IsA("RopeConstraint") then
                    pcall(function() inst:Destroy() end)
                elseif inst:IsA("BasePart") then
                    inst.Material = Enum.Material.SmoothPlastic
                    inst.CastShadow = false
                end
            end
            
            objectsProcessed = objectsProcessed + 1
            if objectsProcessed % BATCH_SIZE == 0 then
                RunService.Heartbeat:Wait()
            end
        end
    end
end

LocalPlayer.CharacterAdded:Connect(function(newChar)
    RunService.Heartbeat:Wait()
    cleanCharacterAndTools(newChar)
end)

task.spawn(runReduce)

if AUTO_REPEAT then
    task.spawn(function()
        while true do
            task.wait(REPEAT_INTERVAL)
            runReduce()
        end
    end)
end