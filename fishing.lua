local Page = ... -- Menerima argument page dari script utama
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- [[ SETTINGS & REMOTES ]] --
local NetPath = game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")
local FishStartID = "f6064d19476415377eeb8539f7a20ca4d706901720fda6240c952b5a86c99d4f"
local FishCastID  = "b47871ff05d63a1d5a2e4a93861427df7360fdf7bd581404fbf8ce74685734dc"
local FishCatchID = "e28d0cce33ead4ec77e1dd7b7b626e1e444eb87d8e45ce8add22533e74e5ce81"

local Settings = {
    DisableAnim = false,
    DisableCaught = false,
    DisableCutscene = false,
    DisableNotify = false,
    FishingActive = false,
    FishingMode = "ELE",
    CustomDelay = 0.5
}

local function getRemote(name)
    return NetPath:FindFirstChild("RF/" .. name)
end

-- [[ UI COMPONENTS ]] --
local NeonBlue = Color3.fromRGB(0, 255, 255)
local CardColor = Color3.fromRGB(20, 22, 26)

local function CreateToggle(parent, text, key)
    local Frame = Instance.new("Frame", parent)
    Frame.Size = UDim2.new(1, -5, 0, 35)
    Frame.BackgroundColor3 = CardColor
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 4)
    
    local Label = Instance.new("TextLabel", Frame)
    Label.Text = text
    Label.Size = UDim2.new(1, -50, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
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
        Ball:TweenPosition(active and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7), "Out", "Quad", 0.15, true)
        
        -- Reset fishing state if changing fishing modes
        if key == "FishingActive" and active then StartFishingEngine() end
    end)
end

local function CreateInput(parent, title, placeholder, key)
    local Frame = Instance.new("Frame", parent)
    Frame.Size = UDim2.new(1, -5, 0, 50)
    Frame.BackgroundTransparency = 1
    
    local Label = Instance.new("TextLabel", Frame)
    Label.Text = title
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local Box = Instance.new("TextBox", Frame)
    Box.Size = UDim2.new(1, 0, 0, 28)
    Box.Position = UDim2.new(0, 0, 0, 22)
    Box.BackgroundColor3 = CardColor
    Box.TextColor3 = Color3.new(1, 1, 1)
    Box.PlaceholderText = placeholder
    Box.PlaceholderColor3 = Color3.fromRGB(80, 80, 80)
    Box.Text = ""
    Box.Font = Enum.Font.Gotham
    Box.TextSize = 10
    Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 4)
    
    Box.FocusLost:Connect(function()
        Settings[key] = tonumber(Box.Text) or Settings[key]
    end)
end

-- [[ LOGIC ENGINES ]] --

function StartFishingEngine()
    task.spawn(function()
        while Settings.FishingActive do
            pcall(function()
                local RF1 = getRemote(FishStartID)
                if RF1 then RF1:InvokeServer() end
                task.wait(0.15)

                local RF2 = getRemote(FishCastID)
                if RF2 then RF2:InvokeServer(-1.2331848, 0.919382, tick()) end
                
                local waitTime = (Settings.FishingMode == "ELE" and math.random(7,9)/10) or (Settings.FishingMode == "DM" and math.random(3,6)/10) or Settings.CustomDelay
                task.wait(waitTime)

                local RF3 = getRemote(FishCatchID)
                if RF3 then
                    RF3:InvokeServer() RF3:InvokeServer() RF3:InvokeServer()
                end
            end)
            task.wait()
        end
    end)
end

-- Optimizer Loop
RunService:BindToRenderStep("PociX_Optimizer", Enum.RenderPriority.Camera.Value + 1, function()
    if Settings.DisableAnim then
        local char = Player.Character
        if char and char:FindFirstChild("Humanoid") then
            for _, v in pairs(char.Humanoid:GetPlayingAnimationTracks()) do v:Stop() end
        end
    end

    if Settings.DisableCaught or Settings.DisableNotify then
        for _, gui in pairs(PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Name ~= "PociX_GUI" then
                for _, v in pairs(gui:GetDescendants()) do
                    if v:IsA("TextLabel") then
                        local txt = v.Text:lower()
                        if Settings.DisableCaught and (txt:find("in") or txt:find("lbs") or txt:find("kg")) then
                            v.Visible = false
                            if v.Parent:IsA("Frame") then v.Parent.Visible = false end
                        end
                        if Settings.DisableNotify and txt:find("you got:") then
                            v.Visible = false
                            if v.Parent:IsA("Frame") then v.Parent.Visible = false end
                        end
                    end
                end
            end
        end
    end

    if Settings.DisableCutscene then
        local cam = Workspace.CurrentCamera
        if cam.CameraType ~= Enum.CameraType.Custom then cam.CameraType = Enum.CameraType.Custom end
    end
end)

-- [[ BUILDING THE UI ]] --
local Layout = Instance.new("UIListLayout", Page)
Layout.Padding = UDim.new(0, 6)
Page.CanvasSize = UDim2.new(0, 0, 0, 420)

-- Group 1: Disables
CreateToggle(Page, "Disable Animation", "DisableAnim")
CreateToggle(Page, "Disable Fish Caught", "DisableCaught")
CreateToggle(Page, "Disable Cutscene", "DisableCutscene")
CreateToggle(Page, "Disable Notification", "DisableNotify")

-- Group 2: Fishing
CreateInput(Page, "Shake Delay", "Write you input there", "CustomDelay")

local EleBtn = Instance.new("TextButton", Page)
EleBtn.Size = UDim2.new(1, -5, 0, 35)
EleBtn.BackgroundColor3 = CardColor
EleBtn.Text = "Mode: ELE (Current)"
EleBtn.TextColor3 = NeonBlue
EleBtn.Font = Enum.Font.GothamBold
EleBtn.TextSize = 11
Instance.new("UICorner", EleBtn).CornerRadius = UDim.new(0, 4)

EleBtn.MouseButton1Click:Connect(function()
    if Settings.FishingMode == "ELE" then
        Settings.FishingMode = "DM"
        EleBtn.Text = "Mode: DM (Current)"
    elseif Settings.FishingMode == "DM" then
        Settings.FishingMode = "CUSTOM"
        EleBtn.Text = "Mode: CUSTOM (Current)"
    else
        Settings.FishingMode = "ELE"
        EleBtn.Text = "Mode: ELE (Current)"
    end
end)

CreateToggle(Page, "Auto Fishing", "FishingActive")

-- Footer Nav Style
local Nav = Instance.new("TextButton", Page)
Nav.Size = UDim2.new(1, -5, 0, 35)
Nav.BackgroundColor3 = CardColor
Nav.Text = "  Instant Features"
Nav.TextColor3 = Color3.fromRGB(200, 200, 200)
Nav.TextSize = 11
Nav.Font = Enum.Font.Gotham
Nav.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", Nav).CornerRadius = UDim.new(0, 4)
local Arr = Instance.new("TextLabel", Nav)
Arr.Text = ">"
Arr.Size = UDim2.new(0, 20, 1, 0)
Arr.Position = UDim2.new(1, -25, 0, 0)
Arr.BackgroundTransparency = 1
Arr.TextColor3 = Color3.fromRGB(150, 150, 150)
