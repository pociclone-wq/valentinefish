--[[
    Fish It - Integrated Script
    Target: Fish It (Roblox)
    Fitur: Object Eraser + Fishing (ELE, DM, CUSTOM) dalam SATU MENU
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
    Mode = nil -- "ELE", "DM", "CUSTOM"
}

-- Helper Remote
local function getRemote(name)
    return NetPath:FindFirstChild("RF/" .. name)
end

-- UI Menu (Satu Frame Utama)
if PlayerGui:FindFirstChild("FishIt_Integrated") then PlayerGui.FishIt_Integrated:Destroy() end
local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.Name = "FishIt_Integrated"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 200, 0, 420) -- Ukuran diperpanjang agar muat semua
Main.Position = UDim2.new(0.5, -100, 0.3, 0)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Main.Active = true
Main.Draggable = true

local Layout = Instance.new("UIListLayout", Main)
Layout.Padding = UDim.new(0, 5)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Helper Toggle (Object Eraser)
local function MakeToggle(text, key)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(0, 180, 0, 35)
    btn.Text = text .. ": OFF"
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    
    btn.MouseButton1Click:Connect(function()
        Settings[key] = not Settings[key]
        btn.Text = text .. ": " .. (Settings[key] and "ON" or "OFF")
        btn.BackgroundColor3 = Settings[key] and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(35, 35, 35)
    end)
end

-- Input Delay untuk Custom
local CustomInput = Instance.new("TextBox", Main)
CustomInput.Size = UDim2.new(0, 180, 0, 30)
CustomInput.PlaceholderText = "Custom Delay (sec)"
CustomInput.Text = "0.5"
CustomInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
CustomInput.TextColor3 = Color3.new(1,1,1)
CustomInput.Font = Enum.Font.GothamBold

-- Helper Fishing Button
local function MakeFishingBtn(text, mode)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(0, 180, 0, 35)
    btn.Text = "START " .. text
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.TextColor3 = Color3.fromRGB(255, 105, 180) -- Warna pink untuk membedakan
    btn.Font = Enum.Font.GothamBold
    
    btn.MouseButton1Click:Connect(function()
        if FishingState.IsRunning and FishingState.Mode == mode then
            FishingState.IsRunning = false
            FishingState.Mode = nil
            btn.Text = "START " .. text
            btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        else
            FishingState.IsRunning = true
            FishingState.Mode = mode
            btn.Text = "STOP " .. text
            btn.BackgroundColor3 = Color3.fromRGB(150, 0, 70)
        end
    end)
end

-- Render Elements
MakeToggle("Disable Animation", "DisableAnim")
MakeToggle("Disable Fish Caught", "DisableCaught")
MakeToggle("Disable Cutscene", "DisableCutscene")
MakeToggle("Disable Notification", "DisableNotify")

local Sep = Instance.new("Frame", Main)
Sep.Size = UDim2.new(0, 180, 0, 2)
Sep.BackgroundColor3 = Color3.fromRGB(60, 60, 60)

MakeFishingBtn("ELE", "ELE")
MakeFishingBtn("DM", "DM")
MakeFishingBtn("CUSTOM", "CUSTOM")

-- --- FISHING ENGINE ---
task.spawn(function()
    while true do
        if FishingState.IsRunning then
            pcall(function()
                local RF1 = getRemote(FishStartID)
                if RF1 then RF1:InvokeServer() end
                task.wait(0.15)

                local RF2 = getRemote(FishCastID)
                if RF2 then
                    RF2:InvokeServer(-1.233184814453125, 0.9193826941424107, tick())
                end
                
                local jeda = 0.5
                if FishingState.Mode == "ELE" then
                    jeda = math.random(7, 9) / 10
                elseif FishingState.Mode == "DM" then
                    jeda = math.random(3, 6) / 10
                elseif FishingState.Mode == "CUSTOM" then
                    jeda = tonumber(CustomInput.Text) or 0.5
                end
                task.wait(jeda)

                local RF3 = getRemote(FishCatchID)
                if RF3 then
                    RF3:InvokeServer()
                    RF3:InvokeServer()
                    RF3:InvokeServer()
                end
            end)
        end
        task.wait(0.05)
    end
end)

-- --- ERASER ENGINE ---
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
            if obj:IsA("Model") or obj:IsA("BasePart") or obj:IsA("ViewportFrame") then
                obj:Destroy()
            end
        end
        for _, gui in pairs(PlayerGui:GetChildren()) do
            if gui.Name ~= "FishIt_Integrated" then
                local vpf = gui:FindFirstChildWhichIsA("ViewportFrame", true)
                if vpf then gui.Enabled = false end
            end
        end
    end

    if Settings.DisableCutscene then
        local cam = Workspace.CurrentCamera
        if cam.CameraType ~= Enum.CameraType.Custom then
            cam.CameraType = Enum.CameraType.Custom
        end
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
