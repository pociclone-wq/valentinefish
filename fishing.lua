--[[
    Fish It - Object Eraser (Integrated Version)
    Target: Fish It (Roblox)
    Fungsi: ELE, DM, CUSTOM DELAY + Fix Animasi & UI Terpadu
--]]

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Net Objects Path
local NetPath = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")

-- REMOTE SERVER TARGETS (Updated)
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
    Mode = nil, -- "ELE", "DM", "CUSTOM"
    IsRunning = false
}

-- Helper Remote
local function getRemote(name)
    return NetPath:FindFirstChild("RF/" .. name)
end

-- UI Menu (Sesuai Ukuran Skrip Utama Pertama)
if PlayerGui:FindFirstChild("FishIt_FinalFix") then PlayerGui.FishIt_FinalFix:Destroy() end
local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.Name = "FishIt_FinalFix"
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 200, 0, 380) -- Ukuran disesuaikan agar muat tombol baru
Main.Position = UDim2.new(0.5, -100, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Main.Active = true
Main.Draggable = true

local Layout = Instance.new("UIListLayout", Main)
Layout.Padding = UDim.new(0, 5)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Helper Create Toggle/Button
local function MakeToggle(text, key)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(0, 180, 0, 35)
    btn.Text = text .. ": OFF"
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.MouseButton1Click:Connect(function()
        Settings[key] = not Settings[key]
        btn.Text = text .. ": " .. (Settings[key] and "ON" or "OFF")
        btn.BackgroundColor3 = Settings[key] and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(35, 35, 35)
    end)
end

local function MakeFishingBtn(text, mode)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(0, 180, 0, 35)
    btn.Text = "START " .. text
    btn.BackgroundColor3 = Color3.fromRGB(255, 105, 180) -- Pink sesuai tema Valentine
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    btn.MouseButton1Click:Connect(function()
        if FishingState.IsRunning and FishingState.Mode == mode then
            FishingState.IsRunning = false
            FishingState.Mode = nil
            btn.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
            btn.Text = "START " .. text
        else
            FishingState.IsRunning = true
            FishingState.Mode = mode
            btn.BackgroundColor3 = Color3.fromRGB(200, 0, 100)
            btn.Text = "STOP " .. text
        end
    end)
end

-- Custom Delay Input
local CustomInput = Instance.new("TextBox", Main)
CustomInput.Size = UDim2.new(0, 180, 0, 30)
CustomInput.PlaceholderText = "Delay (ex: 0.5)"
CustomInput.Text = "0.5"
CustomInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
CustomInput.TextColor3 = Color3.new(1,1,1)

-- Render UI Elements
MakeToggle("Disable Animation", "DisableAnim")
MakeToggle("Disable Fish Caught", "DisableCaught")
MakeToggle("Disable Cutscene", "DisableCutscene")
MakeToggle("Disable Notification", "DisableNotify")

local Line = Instance.new("Frame", Main)
Line.Size = UDim2.new(0, 180, 0, 2)
Line.BackgroundColor3 = Color3.fromRGB(100, 100, 100)

MakeFishingBtn("ELE", "ELE")
MakeFishingBtn("DM", "DM")
MakeFishingBtn("CUSTOM", "CUSTOM")

-- FISHING ENGINE
task.spawn(function()
    while true do
        if FishingState.IsRunning then
            pcall(function()
                -- Step 1: Start
                local RF1 = getRemote(FishStartID)
                if RF1 then RF1:InvokeServer() end
                task.wait(0.15)

                -- Step 2: Cast
                local RF2 = getRemote(FishCastID)
                if RF2 then
                    RF2:InvokeServer(-1.233184814453125, 0.9193826941424107, tick())
                end
                
                -- Step 3: Wait Delay
                local mode = FishingState.Mode
                local jeda = 0.5
                if mode == "ELE" then
                    jeda = math.random(7, 9) / 10
                elseif mode == "DM" then
                    jeda = math.random(3, 6) / 10
                elseif mode == "CUSTOM" then
                    jeda = tonumber(CustomInput.Text) or 0.5
                end
                task.wait(jeda)

                -- Step 4: Catch (Triple Invoke)
                local RF3 = getRemote(FishCatchID)
                if RF3 then
                    RF3:InvokeServer()
                    RF3:InvokeServer()
                    RF3:InvokeServer()
                end
            end)
        end
        task.wait(0.1)
    end
end)

-- GRAPHICS FIX ENGINE
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
            if gui.Name ~= "FishIt_FinalFix" then
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
