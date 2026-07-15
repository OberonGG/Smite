local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local HiddenGui = (gethui and gethui()) or CoreGui
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local WARNA_GELAP = Color3.fromRGB(50, 50, 50)

task.spawn(function()
    while task.wait(3600) do
        collectgarbage("collect")
    end
end)

local ui = Instance.new("ScreenGui")
ui.Name = "PingTimerUI"
ui.ResetOnSpawn = false
ui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ui.Parent = HiddenGui

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

LynxButton.MouseButton1Click:Connect(function()
    pcall(function()
        local targetLynx = HiddenGui:FindFirstChild("LynxGui") or CoreGui:FindFirstChild("LynxGui")
        if targetLynx then
            targetLynx.Enabled = not targetLynx.Enabled
        end
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

local function safeDestroy(inst)
    pcall(inst.Destroy, inst)
end

local KILL_LIGHTING = {
    Sky = true, Atmosphere = true, BloomEffect = true,
    SunRaysEffect = true, ColorCorrectionEffect = true, BlurEffect = true, Clouds = true
}

local FORCED_LIGHTING = {
    GlobalShadows = false,
    Brightness = 0,
    Ambient = WARNA_GELAP,
    OutdoorAmbient = WARNA_GELAP,
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

applyLightingOverride()

local LOCK_PROPS = {
    Ambient = true, OutdoorAmbient = true, TimeOfDay = true,
    Brightness = true, GlobalShadows = true, FogStart = true, FogEnd = true,
    ExposureCompensation = true, EnvironmentDiffuseScale = true, EnvironmentSpecularScale = true
}

Lighting.Changed:Connect(function(prop)
    if LOCK_PROPS[prop] then applyLightingOverride() end
end)

local function killLightingChild(child)
    if KILL_LIGHTING[child.ClassName] then
        task.defer(safeDestroy, child)
    end
end

for _, obj in ipairs(Lighting:GetChildren()) do killLightingChild(obj) end
Lighting.ChildAdded:Connect(killLightingChild)

local DECORATIVE = {
    ParticleEmitter = true, Smoke = true, Fire = true, Sparkles = true,
    Beam = true, Trail = true, Explosion = true, Discharge = true,
    Dust = true, PointLight = true, SpotLight = true, SurfaceLight = true,
    Decal = true, Texture = true, SurfaceAppearance = true,
    Highlight = true, SelectionBox = true, RopeConstraint = true,
    BillboardGui = true, SurfaceGui = true, Light = true,
    Accessory = true, CharacterMesh = true,
    Shirt = true, Pants = true, ShirtGraphic = true, Clothing = true, BodyColors = true,
    PostEffect = true, SpecialMesh = true
}

local IS_BASEPART = {
    Part = true, MeshPart = true, WedgePart = true, CornerWedgePart = true,
    TrussPart = true, UnionOperation = true, Seat = true, VehicleSeat = true,
    SpawnLocation = true, Platform = true
}

local function processInstance(inst)
    local cName = inst.ClassName
    if not TO_DESTROY[cName] and not IS_BASEPART[cName] then return end
    if inst:IsDescendantOf(CoreGui) or inst:IsDescendantOf(HiddenGui) then return end
    
    local name = inst.Name
    local parent = inst.Parent
    local parentName = parent and parent.Name or ""
    
    if string.find(name, "Totem") or string.find(name, "Bobber") or
       string.find(parentName, "Totem") or string.find(parentName, "Bobber") then
        return
    end
    
    if cName == "SpecialMesh" and parentName == "Head" then return end
    
    if IS_BASEPART[cName] then
        if string.find(name, "Rod") or string.find(parentName, "Rod") then return end
        pcall(function()
            inst.Color = WARNA_GELAP
            inst.Material = Enum.Material.SmoothPlastic
            inst.Reflectance = 0
            inst.CastShadow = false
            if cName == "MeshPart" then inst.TextureID = "" end
        end)
    else
        task.defer(safeDestroy, inst)
    end
end

local TO_DESTROY = DECORATIVE

pcall(function()
    local t = Workspace:FindFirstChildOfClass("Terrain")
    if t then
        t.WaterColor = WARNA_GELAP
        t.WaterWaveSize = 0
        t.WaterWaveSpeed = 0
        t.WaterReflectance = 0
        t.WaterTransparency = 0
    end
end)

for _, object in ipairs(Workspace:GetDescendants()) do
    processInstance(object)
end

local pendingInstances = {}
local batchActive = false

local function processBatch()
    batchActive = false
    local batch = pendingInstances
    pendingInstances = {}
    for i = 1, #batch do
        local inst = batch[i]
        if inst.Parent ~= nil then
            processInstance(inst)
        end
    end
end

Workspace.DescendantAdded:Connect(function(inst)
    pendingInstances[#pendingInstances + 1] = inst
    if not batchActive then
        batchActive = true
        task.defer(processBatch)
    end
end)

task.spawn(function()
    local npcFolderDeleted = false
    local function deleteNPCFolder()
        local npcFolder = Workspace:FindFirstChild("NPC")
        if npcFolder and not npcFolderDeleted then
            task.defer(function()
                safeDestroy(npcFolder)
                npcFolderDeleted = true
            end)
        end
    end
    deleteNPCFolder()
    Workspace.ChildAdded:Connect(function(child)
        if child.Name == "NPC" and not npcFolderDeleted then
            task.defer(function()
                safeDestroy(child)
                npcFolderDeleted = true
            end)
        end
    end)
end)

task.spawn(function()
    local lastClose = 0
    local CLOSE_COOLDOWN = 5
    local function tryCloseDaily(gui)
        if gui and gui.Enabled then
            local now = tick()
            if now - lastClose > CLOSE_COOLDOWN then
                lastClose = now
                pcall(function()
                    local modules = ReplicatedStorage:FindFirstChild("Modules")
                    if modules then
                        local guiControl = modules:FindFirstChild("GuiControl")
                        if guiControl then
                            require(guiControl):Close()
                        end
                    end
                end)
            end
        end
    end
    local existingDaily = PlayerGui:FindFirstChild("!!! Daily Login")
    if existingDaily then
        task.wait(0.1)
        tryCloseDaily(existingDaily)
    end
    PlayerGui.ChildAdded:Connect(function(child)
        if child.Name == "!!! Daily Login" then
            task.wait(0.1)
            tryCloseDaily(child)
        end
    end)
end)

if setfpscap then
    setfpscap(30)
end

task.spawn(function()
    local deltaClosed = false
    local whitelist = {
        ["LynxGui"] = true,
        ["PingTimerUI"] = true,
        ["LynxCloseButton"] = true
    }
    while not deltaClosed and task.wait(3) do
        local targetGui = HiddenGui or CoreGui
        local foundDeltaUI = false
        for _, gui in ipairs(targetGui:GetChildren()) do
            if gui:IsA("ScreenGui") then
                if whitelist[gui.Name] then continue end
                local isWeird = false
                local name = gui.Name
                for i = 1, #name do
                    local c = name:sub(i, i)
                    if not c:match("[%w_]") then
                        isWeird = true
                        break
                    end
                end
                if isWeird then
                    local hasConsole = false
                    for _, obj in ipairs(gui:GetDescendants()) do
                        if obj:IsA("GuiObject") and string.find(obj.Name, "Console") then
                            hasConsole = true
                            break
                        end
                    end
                    if hasConsole then
                        for _, obj in ipairs(gui:GetChildren()) do
                            if not (obj.Name == "Console" or obj.Name == "Network") then
                                task.defer(function() pcall(function() obj:Destroy() end) end)
                            end
                        end
                        foundDeltaUI = true
                    else
                        task.defer(function() pcall(function() gui:Destroy() end) end)
                        foundDeltaUI = true
                    end
                end
            end
        end
        if foundDeltaUI then
            deltaClosed = true
        end
    end
end)
