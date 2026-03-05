--[[
    Fish It - Object Eraser (Integrated Version)
    Target: Fish It (Roblox)
    Focus: Gabungan Visual Fix + Fishing (ELE, DM, CUSTOM)
--]]

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- NET PATH & REMOTES
local NetPath = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")
local FishStartID     = "f6064d19476415377eeb8539f7a20ca4d706901720fda6240c952b5a86c99d4f"
local FishCastID      = "b47871ff05d63a1d5a2e4a93861427df7360fdf7bd581404fbf8ce74685734dc"
local FishCatchID     = "e28d0cce33ead4ec77e1dd7b7b626e1e444eb87d8e45ce8add22533e74e5ce81"

local function getRemote(name)
    return NetPath:FindFirstChild("RF/" .. name)
end

-- Settings
local Settings = {
    DisableAnim = false,
    DisableCaught = false,
    DisableCutscene = false,
    DisableNotify = false
}

-- Fishing State
local FishingActive = false
local FishingMode = "NONE"

-- UI Menu
if PlayerGui:FindFirstChild("FishIt_FinalFix") then PlayerGui.FishIt_FinalFix:Destroy() end
local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.Name = "FishIt_FinalFix"
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 200, 0, 420) -- Ukuran diperbesar agar muat tombol pancing
Main.Position = UDim2.new(0.5, -100, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Main.Active = true
Main.Draggable = true

local Layout = Instance.new("UIListLayout", Main)
Layout.Padding = UDim.new(0, 5)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function MakeToggle(text, key)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(0, 180, 0, 40)
    btn.Text = text .. ": OFF"
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.MouseButton1Click:Connect(function()
        Settings[key] = not Settings[key]
        btn.Text = text .. ": " .. (Settings[key] and "ON" or "OFF")
        btn.BackgroundColor3 = Settings[key] and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(35, 35, 35)
    end)
end

-- RENDER VISUAL FIX BUTTONS
MakeToggle("Disable Animation", "DisableAnim")
MakeToggle("Disable Fish Caught", "DisableCaught")
MakeToggle("Disable Cutscene", "DisableCutscene")
MakeToggle("Disable Notification", "DisableNotify")

-- --- TAMBAHAN FITUR PANCING ---

local function MakeFishBtn(text, mode)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(0, 180, 0, 35)
    btn.Text = "START " .. text
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.MouseButton1Click:Connect(function()
        if FishingActive and FishingMode == mode then
            FishingActive = false
            FishingMode = "NONE"
            btn.Text = "START " .. text
            btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        else
            FishingActive = true
            FishingMode = mode
            btn.Text = "STOP " .. text
            btn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        end
    end)
end

local CustomInput = Instance.new("TextBox", Main)
CustomInput.Size = UDim2.new(0, 180, 0, 30)
CustomInput.Text = "0.5"
CustomInput.PlaceholderText = "Custom Delay..."
CustomInput.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
CustomInput.TextColor3 = Color3.new(1,1,1)

MakeFishBtn("ELE", "ELE")
MakeFishBtn("DM", "DM")
MakeFishBtn("CUSTOM", "CUSTOM")

-- --- FISHING ENGINE ---
task.spawn(function()
    while true do
        if FishingActive then
            pcall(function()
                getRemote(FishStartID):InvokeServer()
                task.wait(0.15)
                getRemote(FishCastID):InvokeServer(-1.233184814453125, 0.9193826941424107, tick())
                
                local delayTime = 0.5
                if FishingMode == "ELE" then delayTime = math.random(7,9)/10
                elseif FishingMode == "DM" then delayTime = math.random(3,6)/10
                elseif FishingMode == "CUSTOM" then delayTime = tonumber(CustomInput.Text) or 0.5 end
                
                task.wait(delayTime)
                local catch = getRemote(FishCatchID)
                catch:InvokeServer() catch:InvokeServer() catch:InvokeServer()
            end)
        end
        task.wait(0.1)
    end
end)

-- --- LOGIC PENGHANCUR ANIMASI (TETAP SAMA) ---
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
        for _, gui in pairs(PlayerGui:GetChildren()) do
            if gui.Name ~= "FishIt_FinalFix" then
                local vpf = gui:FindFirstChildWhichIsA("ViewportFrame", true)
                if vpf then gui.Enabled = false end
            end
        end
    end
    if Settings.DisableCutscene then
        local cam = Workspace.CurrentCamera
        cam.CameraType = Enum.CameraType.Custom
        cam.FieldOfView = 70 
    end
    if Settings.DisableNotify then
        for _, gui in pairs(PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and (gui.Name:lower():find("notif") or gui.Name:lower():find("msg")) then
                gui.Enabled = false
            end
        end
    end
end)
