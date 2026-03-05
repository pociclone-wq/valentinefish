--[[ 
    PENYATUAN KE MENU UTAMA 
    Menggunakan MainFrame yang sudah ada, tanpa membuat UI baru.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NetPath = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")

-- REMOTE IDs
local FishStartID     = "f6064d19476415377eeb8539f7a20ca4d706901720fda6240c952b5a86c99d4f"
local FishCastID      = "b47871ff05d63a1d5a2e4a93861427df7360fdf7bd581404fbf8ce74685734dc"
local FishCatchID     = "e28d0cce33ead4ec77e1dd7b7b626e1e444eb87d8e45ce8add22533e74e5ce81"

local function getRemote(name)
    return NetPath:FindFirstChild("RF/" .. name)
end

-- MENGGUNAKAN MAIN FRAME DARI SCRIPT UTAMA
-- (Asumsi skrip utama sudah jalan dan memiliki frame bernama "HeartfeltMain")
local MainFrame = game:GetService("CoreGui"):WaitForChild("HeartfeltValentineUI"):WaitForChild("HeartfeltMain")

-- STATE
local FishingMode = "NONE"
local IsFishing = false

-- BARIS BARU: ELE & DM (Mengikuti gaya Baris 1: Teleport)
local RowFishing = Instance.new("Frame", MainFrame)
RowFishing.Size = UDim2.new(1, 0, 0, 25)
RowFishing.Position = UDim2.new(0, 0, 0, 225) -- Di bawah tombol Start Custom asli
RowFishing.BackgroundTransparency = 1
local RowLayout = Instance.new("UIListLayout", RowFishing)
RowLayout.FillDirection = Enum.FillDirection.Horizontal
RowLayout.Padding = UDim.new(0, 5)
RowLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function MakeBtn(txt, mode)
    local b = Instance.new("TextButton", RowFishing)
    b.Size = UDim2.new(0.4, 0, 1, 0)
    b.Text = txt
    -- Mengikuti styleBtn dari skrip utama
    b.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
    b.BackgroundTransparency = 0.4
    b.TextColor3 = Color3.new(1,1,1)
    b.TextSize = 12
    b.Font = Enum.Font.GothamBold
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)

    b.MouseButton1Click:Connect(function()
        if IsFishing and FishingMode == mode then
            IsFishing = false
            FishingMode = "NONE"
            b.BackgroundTransparency = 0.4
        else
            IsFishing = true
            FishingMode = mode
            b.BackgroundTransparency = 0
        end
    end)
end

MakeBtn("ELE", "ELE")
MakeBtn("DM", "DM")

-- ENGINE JALAN DI BELAKANG
task.spawn(function()
    while true do
        if IsFishing then
            pcall(function()
                getRemote(FishStartID):InvokeServer()
                task.wait(0.15)
                getRemote(FishCastID):InvokeServer(-1.233184814453125, 0.9193826941424107, tick())
                
                local jeda = 0.5
                if FishingMode == "ELE" then
                    jeda = math.random(7,9)/10
                elseif FishingMode == "DM" then
                    jeda = math.random(3,6)/10
                end
                task.wait(jeda)

                local RF3 = getRemote(FishCatchID)
                RF3:InvokeServer() RF3:InvokeServer() RF3:InvokeServer()
            end)
        end
        task.wait(0.1)
    end
end)
