local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local GuiControl = require(ReplicatedStorage.Modules.GuiControl)

local gs = UserSettings():GetService("UserGameSettings")
local rs = settings().Rendering

local function applyAutoSettings()
    local success1 = pcall(function()
        gs.MasterVolume = 0
        gs.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
        rs.QualityLevel = Enum.QualityLevel.Level01
    end)
    if success1 then return end

    local success2 = pcall(function()
        gs.MasterVolume = 0
        gs.SavedQualityLevel = 1
        rs.QualityLevel = 1
    end)
    if success2 then return end

    if type(sethiddenproperty) == "function" then
        pcall(function()
            sethiddenproperty(gs, "MasterVolume", 0)
            sethiddenproperty(gs, "SavedQualityLevel", Enum.SavedQualitySetting.QualityLevel1)
            sethiddenproperty(rs, "QualityLevel", Enum.QualityLevel.Level01)
        end)
    end
end

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

LynxButton.MouseButton1Click:Connect(function()
    pcall(function()
        local targetLynx = CoreGui:FindFirstChild("LynxGui")
        if targetLynx then
            targetLynx.Enabled = not targetLynx.Enabled
        end
    end)
end)

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

if setfpscap then
    setfpscap(30)
    task.spawn(function()
        while true do
           task.wait(10)
            setfpscap(30)
        end
    end)
end

task.spawn(function()
    while task.wait(1) do
        local dailyUI = PlayerGui:FindFirstChild("!!! Daily Login")
        if dailyUI and dailyUI.Enabled == true then
            pcall(function()
                GuiControl:Close()
            end)
            task.wait(3)
        end
    end
end)

local HiddenGui = gethui and gethui()
local function safeDestroy(inst)
    pcall(function() inst:Destroy() end)
end

task.spawn(function()
    local whitelist = { ["LynxGui"] = true, ["PingTimerUI"] = true, ["LynxCloseButton"] = true, ["ToggleBtn"] = true }
    local closed = false
    
    while not closed and task.wait(3) do
        local target = HiddenGui or CoreGui
        local found = false
        
        for _, gui in ipairs(target:GetChildren()) do
            if gui:IsA("ScreenGui") and not whitelist[gui.Name] then
                local weird = false
                for i = 1, #gui.Name do
                    if not gui.Name:sub(i,i):match("[%w_]") then weird = true; break end
                end
                if weird then
                    if gui:FindFirstChild("Console", true) then
                        for _, obj in ipairs(gui:GetChildren()) do
                            if obj.Name ~= "Console" and obj.Name ~= "Network" then task.defer(safeDestroy, obj) end
                        end
                    else
                        task.defer(safeDestroy, gui)
                    end
                    found = true
                end
            end
        end
        if found then closed = true end
    end
end)

applyAutoSettings()
