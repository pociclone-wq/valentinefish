-- [[ TEST UI ONLY - NO FUNCTION ]] --
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- MENCARI FRAME FISHING DI DALAM UI ANDA
local MainGui = PlayerGui:FindFirstChild("PociX_GUI") or game:GetService("CoreGui"):FindFirstChild("PociX_GUI")
local Page = MainGui and MainGui:FindFirstChild("Fishing", true)

if not Page then return end

-- [[ CLEANUP & LAYOUT ]] --
for _, v in pairs(Page:GetChildren()) do if not v:IsA("UIListLayout") then v:Destroy() end end
local Layout = Page:FindFirstChildWhichIsA("UIListLayout") or Instance.new("UIListLayout", Page)
Layout.Padding = UDim.new(0, 6)
Page.CanvasSize = UDim2.new(0, 0, 0, 400)

local NeonBlue = Color3.fromRGB(0, 255, 255)
local CardColor = Color3.fromRGB(25, 27, 31)

-- [[ UI TOGGLE GENERATOR ]] --
local function CreateToggle(text, order)
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
    
    local active = false
    TogBg.MouseButton1Click:Connect(function()
        active = not active
        TogBg.BackgroundColor3 = active and NeonBlue or Color3.fromRGB(45, 45, 45)
        Ball:TweenPosition(active and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6), "Out", "Quad", 0.1, true)
    end)
end

-- [[ INJEKSI NAMA DAN TOMBOL ]] --
CreateToggle("Disable Animation", 1)
CreateToggle("Disable Fish Caught", 2)
CreateToggle("Disable Cutscene", 3)
CreateToggle("Disable Notification", 4)

local Inp = Instance.new("TextBox", Page)
Inp.LayoutOrder = 5
Inp.Size = UDim2.new(1, -10, 0, 30)
Inp.BackgroundColor3 = CardColor
Inp.PlaceholderText = "Shake Delay (Seconds)"
Inp.Text = "0.5"
Inp.TextColor3 = Color3.new(1,1,1)
Inp.Font = Enum.Font.Gotham
Inp.TextSize = 10
Instance.new("UICorner", Inp).CornerRadius = UDim.new(0, 4)

local ModeBtn = Instance.new("TextButton", Page)
ModeBtn.LayoutOrder = 6
ModeBtn.Size = UDim2.new(1, -10, 0, 32)
ModeBtn.BackgroundColor3 = NeonBlue
ModeBtn.Text = "Mode: ELE"
ModeBtn.Font = Enum.Font.GothamBold
ModeBtn.TextSize = 11
ModeBtn.TextColor3 = Color3.new(0,0,0)
Instance.new("UICorner", ModeBtn).CornerRadius = UDim.new(0, 4)

CreateToggle("Auto Fishing", 7)
