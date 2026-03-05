--[[
    Fish It - Integrated Baris Version
    Target: Fish It (Roblox)
    Focus: ELE, DM, CUSTOM dalam Baris (seperti Teleport)
--]]

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Net Objects Path
local NetPath = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")

-- REMOTE SERVER TARGETS
local FishStartID     = "f6064d19476415377eeb8539f7a20ca4d706901720fda6240c952b5a86c99d4f"
local FishCastID      = "b47871ff05d63a1d5a2e4a93861427df7360fdf7bd581404fbf8ce74685734dc"
local FishCatchID     = "e28d0cce33ead4ec77e1dd7b7b626e1e444eb87d8e45ce8add22533e74e5ce81"

-- Settings & States
local Settings = {
    DisableAnim = false,
    DisableCaught = false,
    DisableCutscene = false,
    DisableNotify = false
}

local FishingState = {
    IsRunning = false,
    Mode = nil
}

-- Helper Remote
local function getRemote(name)
    return NetPath:FindFirstChild("RF/" .. name)
end

-- --- SETUP UI (MENU UTAMA) ---
if PlayerGui:FindFirstChild("FishIt_Integrated") then PlayerGui.FishIt_Integrated:Destroy() end
local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.Name = "FishIt_Integrated"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 220, 0, 320)
Main.Position = UDim2.new(0.5, -110, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

local Layout = Instance.new("UIListLayout", Main)
Layout.Padding = UDim.new(0, 6)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- --- HELPER UI ---

-- 1. Toggle Full Width (Untuk Eraser)
local function MakeToggle(text, key)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(0, 200, 0, 30)
    btn.Text = text .. ": OFF"
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    
    btn.MouseButton1Click:Connect(function()
        Settings[key] = not Settings[key]
        btn.Text = text .. ": " .. (Settings[key] and "ON" or "OFF")
        btn.BackgroundColor3 = Settings[key] and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(30, 30, 30)
    end)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
end

-- 2. Baris Container (Untuk Tombol Sejajar seperti Teleport)
local function CreateRow()
    local row = Instance.new("Frame", Main)
    row.Size = UDim2.new(0, 200, 0, 30)
    row.BackgroundTransparency = 1
    local rowLayout = Instance.new("UIListLayout", row)
    rowLayout.FillDirection = Enum.FillDirection.Horizontal
    rowLayout.Padding = UDim.new(0, 5)
    rowLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    return row
end

-- --- RENDER UI ---

-- Eraser Section
MakeToggle("Disable Animation", "DisableAnim")
MakeToggle("Disable Fish Caught", "DisableCaught")
MakeToggle("Disable Cutscene", "DisableCutscene")
MakeToggle("Disable Notification", "DisableNotify")

local Line = Instance.new("Frame", Main)
Line.Size = UDim2.new(0, 190, 0, 1)
Line.BackgroundColor3 = Color3.fromRGB(50, 50, 50)

-- Fishing Mode Section (Baris 1: ELE & DM)
local Row1 = CreateRow()
local function MakeSmallBtn(parent, text, mode)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(0.48, 0, 1, 0)
    b.Text = text
    b.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
    b.BackgroundTransparency = 0.4
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamBold
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)

    b.MouseButton1Click:Connect(function()
        if FishingState.IsRunning and FishingState.Mode == mode then
            FishingState.IsRunning = false
            FishingState.Mode = nil
            b.BackgroundTransparency = 0.4
        else
            FishingState.IsRunning = true
            FishingState.Mode = mode
            b.BackgroundTransparency = 0
        end
    end)
end
MakeSmallBtn(Row1, "ELE", "ELE")
MakeSmallBtn(Row1, "DM", "DM")

-- Custom Delay Section (Baris 2)
local CustomInput = Instance.new("TextBox", Main)
CustomInput.Size = UDim2.new(0, 200, 0, 25)
CustomInput.Text = "0.5"
CustomInput.PlaceholderText = "Delay..."
CustomInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
CustomInput.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", CustomInput)

local Row2 = CreateRow()
local CustomBtn = Instance.new("TextButton", Row2)
CustomBtn.Size = UDim2.new(1, 0, 1, 0)
CustomBtn.Text = "START CUSTOM"
CustomBtn.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
CustomBtn.BackgroundTransparency = 0.4
CustomBtn.TextColor3 = Color3.new(1,1,1)
CustomBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", CustomBtn)

CustomBtn.MouseButton1Click:Connect(function()
    if FishingState.IsRunning and FishingState.Mode == "CUSTOM" then
        FishingState.IsRunning = false
        FishingState.Mode = nil
        CustomBtn.BackgroundTransparency = 0.4
    else
        FishingState.IsRunning = true
        FishingState.Mode = "CUSTOM"
        CustomBtn.BackgroundTransparency = 0
    end
end)

-- --- FISHING ENGINE ---
task.spawn(function()
    while true do
        if FishingState.IsRunning then
            pcall(function()
                getRemote(FishStartID):InvokeServer()
                task.wait(0.15)
                getRemote(FishCastID):InvokeServer(-1.233184814453125, 0.9193826941424107, tick())
                
                local jeda = 0.5
                if FishingState.Mode == "ELE" then jeda = math.random(7,9)/10
                elseif FishingState.Mode == "DM" then jeda = math.random(3,6)/10
                elseif FishingState.Mode == "CUSTOM" then jeda = tonumber(CustomInput.Text) or 0.5 end
                task.wait(jeda)

                local RF3 = getRemote(FishCatchID)
                RF3:InvokeServer() RF3:InvokeServer() RF3:InvokeServer()
            end)
        end
        task.wait(0.1)
    end
end)

-- --- VISUAL ERASER ENGINE ---
RunService.RenderStepped:Connect(function()
    if Settings.DisableAnim then
        local char = Player.Character
        if char and char:FindFirstChild("Humanoid") then
            for _, v in pairs(char.Humanoid:GetPlayingAnimationTracks()) do v:Stop() end
        end
    end
    if Settings.DisableCaught then
        local cam = Workspace.CurrentCamera
        for _, obj in pairs(cam:GetChildren()) do
            if obj:IsA("Model") or obj:IsA("BasePart") or obj:IsA("ViewportFrame") then obj:Destroy() end
        end
    end
    -- (Logic eraser lainnya tetap aktif di sini)
end)
