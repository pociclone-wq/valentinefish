local Page = ... -- Menerima argument dari script utama
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- [[ NEW REMOTE IDs UPDATE ]] --
local NetPath = game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")
local RF_Start = "2688df0b77e6a72960d933fee24d035fcc4e90d71645a6e4a97c22fc0e297d8b"
local RF_Cast  = "4cd9bdf89e37861669d0e5f221d1c028b76bca210162e02e5b5c2f5952f8f664"
local RF_Catch = "c809299d1966f1bb7fe1166ced3c2017cadae50d14d1fb1a2d45f6eb79fc7c03"

local Settings = {
    DisableAnim = false,
    DisableCaught = false,
    DisableCutscene = false,
    DisableNotify = false,
    FishingActive = false,
    FishingMode = "ELE",
    CustomDelay = 0.5
}

local function getRF(id)
    return NetPath:WaitForChild("RF/" .. id)
end

-- [[ UI HELPERS ]] --
local NeonBlue = Color3.fromRGB(0, 255, 255)
local CardColor = Color3.fromRGB(20, 22, 26)

-- Memastikan Page terlihat
if Page then
    Page.Size = UDim2.new(1, -120, 1, -50)
    Page.CanvasSize = UDim2.new(0, 0, 0, 450) -- Supaya bisa di-scroll
end

local function CreateToggle(text, key)
    local Frame = Instance.new("Frame", Page)
    Frame.Size = UDim2.new(1, -5, 0, 35)
    Frame.BackgroundColor3 = CardColor
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 4)
    
    local Label = Instance.new("TextLabel", Frame)
    Label.Text = "  " .. text
    Label.Size = UDim2.new(1, -50, 1, 0)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local TogBg = Instance.new("TextButton", Frame)
    TogBg.Size = UDim2.new(0, 32, 0, 18)
    TogBg.Position = UDim2.new(1, -40, 0.5, -9)
    TogBg.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    TogBg.Text = ""
    Instance.new("UICorner", TogBg).CornerRadius = UDim.new(1, 0)
    
    local Ball = Instance.new("Frame", TogBg)
    Ball.Size = UDim2.new(0, 14, 0, 14)
    Ball.Position = UDim2.new(0, 2, 0.5, -7)
    Ball.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", Ball).CornerRadius = UDim.new(1, 0)
    
    TogBg.MouseButton1Click:Connect(function()
        Settings[key] = not Settings[key]
        local active = Settings[key]
        TogBg.BackgroundColor3 = active and NeonBlue or Color3.fromRGB(45, 45, 45)
        Ball:TweenPosition(active and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7), "Out", "Quad", 0.1)
        if key == "FishingActive" and active then StartFishing() end
    end)
end

-- [[ LOGIC ]] --
function StartFishing()
    task.spawn(function()
        while Settings.FishingActive do
            pcall(function()
                getRF(RF_Start):InvokeServer()
                task.wait(0.15)
                
                local args = {-1.2331848, 0.9966384, tick()}
                getRF(RF_Cast):InvokeServer(unpack(args))
                
                local waitTime = (Settings.FishingMode == "ELE" and math.random(7,9)/10) 
                                or (Settings.FishingMode == "DM" and math.random(3,6)/10) 
                                or Settings.CustomDelay
                task.wait(waitTime)

                local catch = getRF(RF_Catch)
                catch:InvokeServer() catch:InvokeServer() catch:InvokeServer()
            end)
            task.wait()
        end
    end)
end

-- [[ RUNSERVICE LOOP ]] --
RunService.RenderStepped:Connect(function()
    if Settings.DisableAnim then
        local char = Player.Character
        if char and char:FindFirstChild("Humanoid") then
            for _, v in pairs(char.Humanoid:GetPlayingAnimationTracks()) do v:Stop() end
        end
    end
    if Settings.DisableCutscene then
        Workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
    end
    if Settings.DisableCaught or Settings.DisableNotify then
        for _, gui in pairs(PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Name ~= "PociX_GUI" then
                for _, v in pairs(gui:GetDescendants()) do
                    if v:IsA("TextLabel") and v.Visible then
                        local t = v.Text:lower()
                        if Settings.DisableCaught and (t:find("in") or t:find("lb") or t:find("kg")) then
                            v.Visible = false
                            if v.Parent:IsA("Frame") then v.Parent.Visible = false end
                        elseif Settings.DisableNotify and t:find("you got:") then
                            v.Visible = false
                            if v.Parent:IsA("Frame") then v.Parent.Visible = false end
                        end
                    end
                end
            end
        end
    end
end)

-- [[ BUILD UI ]] --
local UIList = Instance.new("UIListLayout", Page)
UIList.Padding = UDim.new(0, 5)

CreateToggle("Disable Animation", "DisableAnim")
CreateToggle("Disable Fish Caught", "DisableCaught")
CreateToggle("Disable Cutscene", "DisableCutscene")
CreateToggle("Disable Notification", "DisableNotify")

-- Input Delay
local Inp = Instance.new("TextBox", Page)
Inp.Size = UDim2.new(1, -5, 0, 30)
Inp.BackgroundColor3 = CardColor
Inp.PlaceholderText = "Shake Delay (Seconds)"
Inp.Text = ""
Inp.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", Inp)
Inp.FocusLost:Connect(function() Settings.CustomDelay = tonumber(Inp.Text) or 0.5 end)

-- Mode Switcher
local ModeBtn = Instance.new("TextButton", Page)
ModeBtn.Size = UDim2.new(1, -5, 0, 35)
ModeBtn.BackgroundColor3 = NeonBlue
ModeBtn.TextColor3 = Color3.new(0,0,0)
ModeBtn.Text = "Current Mode: ELE"
ModeBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", ModeBtn)
ModeBtn.MouseButton1Click:Connect(function()
    if Settings.FishingMode == "ELE" then Settings.FishingMode = "DM"
    elseif Settings.FishingMode == "DM" then Settings.FishingMode = "CUSTOM"
    else Settings.FishingMode = "ELE" end
    ModeBtn.Text = "Current Mode: " .. Settings.FishingMode
end)

CreateToggle("Auto Fishing", "FishingActive")
