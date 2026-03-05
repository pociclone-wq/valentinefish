-- [[ FISHING.LUA REPAIR VERSION ]] --
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- MENCARI PAGE SECARA OTOMATIS JIKA VARIABEL '...' GAGAL
local Page = ... 
if not Page then
    local Gui = PlayerGui:FindFirstChild("PociX_GUI") or game:GetService("CoreGui"):FindFirstChild("PociX_GUI")
    if Gui then
        Page = Gui:FindFirstChild("Fishing", true)
    end
end

if not Page then return end

-- [[ REMOTE IDs ]] --
local NetPath = game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")
local RF_Start = "2688df0b77e6a72960d933fee24d035fcc4e90d71645a6e4a97c22fc0e297d8b"
local RF_Cast  = "4cd9bdf89e37861669d0e5f221d1c028b76bca210162e02e5b5c2f5952f8f664"
local RF_Catch = "c809299d1966f1bb7fe1166ced3c2017cadae50d14d1fb1a2d45f6eb79fc7c03"

local Settings = {
    DisableAnim = false, DisableCaught = false, DisableCutscene = false, DisableNotify = false,
    FishingActive = false, FishingMode = "ELE", CustomDelay = 0.5
}

-- [[ UI SETUP ]] --
for _, v in pairs(Page:GetChildren()) do if not v:IsA("UIListLayout") then v:Destroy() end end

local UIList = Page:FindFirstChildWhichIsA("UIListLayout") or Instance.new("UIListLayout", Page)
UIList.Padding = UDim.new(0, 5)
UIList.SortOrder = Enum.SortOrder.LayoutOrder

Page.CanvasSize = UDim2.new(0, 0, 0, 400)
Page.ScrollBarThickness = 2

local NeonBlue = Color3.fromRGB(0, 255, 255)
local CardColor = Color3.fromRGB(25, 27, 31)

local function CreateToggle(text, key, order)
    local Frame = Instance.new("Frame", Page)
    Frame.LayoutOrder = order
    Frame.Size = UDim2.new(1, -10, 0, 32)
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
    TogBg.Size = UDim2.new(0, 30, 0, 16)
    TogBg.Position = UDim2.new(1, -38, 0.5, -8)
    TogBg.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    TogBg.Text = ""
    Instance.new("UICorner", TogBg).CornerRadius = UDim.new(1, 0)
    
    local Ball = Instance.new("Frame", TogBg)
    Ball.Size = UDim2.new(0, 12, 0, 12)
    Ball.Position = UDim2.new(0, 2, 0.5, -6)
    Ball.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", Ball).CornerRadius = UDim.new(1, 0)
    
    TogBg.MouseButton1Click:Connect(function()
        Settings[key] = not Settings[key]
        TogBg.BackgroundColor3 = Settings[key] and NeonBlue or Color3.fromRGB(45, 45, 45)
        Ball:TweenPosition(Settings[key] and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6), "Out", "Quad", 0.1, true)
        
        if key == "FishingActive" and Settings[key] then
            task.spawn(function()
                while Settings.FishingActive do
                    pcall(function()
                        NetPath:WaitForChild("RF/"..RF_Start):InvokeServer()
                        task.wait(0.15)
                        NetPath:WaitForChild("RF/"..RF_Cast):InvokeServer(-1.2331848, 0.9966384, tick())
                        
                        local waitTime = (Settings.FishingMode == "ELE" and math.random(7,9)/10) 
                                        or (Settings.FishingMode == "DM" and math.random(3,6)/10) 
                                        or Settings.CustomDelay
                        task.wait(waitTime)
                        
                        local catch = NetPath:WaitForChild("RF/"..RF_Catch)
                        catch:InvokeServer() catch:InvokeServer() catch:InvokeServer()
                    end)
                    task.wait()
                end
            end)
        end
    end)
end

-- [[ INJEKSI ELEMEN ]] --
CreateToggle("Disable Animation", "DisableAnim", 1)
CreateToggle("Disable Fish Caught", "DisableCaught", 2)
CreateToggle("Disable Cutscene", "DisableCutscene", 3)
CreateToggle("Disable Notification", "DisableNotify", 4)

local Inp = Instance.new("TextBox", Page)
Inp.LayoutOrder = 5
Inp.Size = UDim2.new(1, -10, 0, 30)
Inp.BackgroundColor3 = CardColor
Inp.PlaceholderText = "  Shake Delay (Seconds)"
Inp.Text = ""
Inp.TextColor3 = Color3.new(1,1,1)
Inp.Font = Enum.Font.Gotham
Inp.TextSize = 10
Instance.new("UICorner", Inp).CornerRadius = UDim.new(0,4)
Inp.FocusLost:Connect(function() Settings.CustomDelay = tonumber(Inp.Text) or 0.5 end)

local ModeBtn = Instance.new("TextButton", Page)
ModeBtn.LayoutOrder = 6
ModeBtn.Size = UDim2.new(1, -10, 0, 32)
ModeBtn.BackgroundColor3 = NeonBlue
ModeBtn.TextColor3 = Color3.new(0,0,0)
ModeBtn.Text = "Current Mode: ELE"
ModeBtn.Font = Enum.Font.GothamBold
ModeBtn.TextSize = 11
Instance.new("UICorner", ModeBtn).CornerRadius = UDim.new(0, 4)
ModeBtn.MouseButton1Click:Connect(function()
    if Settings.FishingMode == "ELE" then Settings.FishingMode = "DM"
    elseif Settings.FishingMode == "DM" then Settings.FishingMode = "CUSTOM"
    else Settings.FishingMode = "ELE" end
    ModeBtn.Text = "Current Mode: " .. Settings.FishingMode
end)

CreateToggle("Auto Fishing", "FishingActive", 7)

-- [[ LOOP OPTIMIZER ]] --
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
            if gui:IsA("ScreenGui") and gui.Name ~= "PociX_GUI" and gui.Name ~= "HeartfeltValentineUI" then
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
