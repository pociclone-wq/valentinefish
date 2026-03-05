--[[ 
    TULISAN DI ATAS KERTAS (FishIt_FinalFix)
    Menambahkan tombol ELE, DM, CUSTOM ke dalam Main Frame yang sudah ada
--]]

local Main = game:GetService("PlayerGui"):WaitForChild("FishIt_FinalFix"):WaitForChild("Frame")
local NetPath = game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")

-- State Pancing
local FishingActive = false
local FishingMode = "NONE"

-- Remote Helper
local function getRF(id) return NetPath:FindFirstChild("RF/" .. id) end

-- 1. MENAMBAH TULISAN/TOMBOL PADA KERTAS (Ikuti ukuran skrip utama)
local function AddFishBtn(text, mode)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(0, 180, 0, 40) -- Ukuran sama dengan MakeToggle di skrip utama
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

-- Input Delay (Tetap di dalam kertas)
local CustomInput = Instance.new("TextBox", Main)
CustomInput.Size = UDim2.new(0, 180, 0, 30)
CustomInput.Text = "0.5"
CustomInput.PlaceholderText = "Delay..."
CustomInput.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
CustomInput.TextColor3 = Color3.new(1,1,1)

-- Tulis tombolnya
AddFishBtn("ELE", "ELE")
AddFishBtn("DM", "DM")
AddFishBtn("CUSTOM", "CUSTOM")

-- 2. LOGIKA JALAN DI BELAKANG KERTAS
task.spawn(function()
    while true do
        if FishingActive then
            pcall(function()
                getRF("f6064d19476415377eeb8539f7a20ca4d706901720fda6240c952b5a86c99d4f"):InvokeServer()
                task.wait(0.15)
                getRF("b47871ff05d63a1d5a2e4a93861427df7360fdf7bd581404fbf8ce74685734dc"):InvokeServer(-1.233184814453125, 0.9193826941424107, tick())
                
                local d = 0.5
                if FishingMode == "ELE" then d = math.random(7,9)/10
                elseif FishingMode == "DM" then d = math.random(3,6)/10
                elseif FishingMode == "CUSTOM" then d = tonumber(CustomInput.Text) or 0.5 end
                
                task.wait(d)
                local c = getRF("e28d0cce33ead4ec77e1dd7b7b626e1e444eb87d8e45ce8add22533e74e5ce81")
                c:InvokeServer() c:InvokeServer() c:InvokeServer()
            end)
        end
        task.wait(0.1)
    end
end)
