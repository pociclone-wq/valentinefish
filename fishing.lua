--[[ 
    FISHING.LUA (PENULIS DI ATAS KERTAS UTAMA)
--]]

local Player = game:GetService("Players").LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- 1. TUNGGU KERTASNYA MUNCUL (Sesuai nama di script utama)
local ScreenGui = PlayerGui:WaitForChild("FishIt_FinalFix", 10)
if not ScreenGui then return end
local Main = ScreenGui:WaitForChild("Frame", 10)

-- 2. PERPANJANG KERTAS (Agar muat tombol baru)
Main.Size = UDim2.new(0, 200, 0, 480) 

-- Konfigurasi
local NetPath = game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")
local FishingActive = false
local FishingMode = "NONE"

local function getRF(id) return NetPath:FindFirstChild("RF/" .. id) end

-- 3. TULIS TOMBOL (Ikuti gaya script utama)
local function AddFishBtn(text, mode)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(0, 180, 0, 40)
    btn.Text = "START " .. text
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    btn.MouseButton1Click:Connect(function()
        if FishingActive and FishingMode == mode then
            FishingActive = false
            FishingMode = "NONE"
            btn.Text = "START " .. text
            btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        else
            FishingActive = true
            FishingMode = mode
            btn.Text = "STOP " .. text
            btn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        end
    end)
end

-- Input Delay
local CustomInput = Instance.new("TextBox", Main)
CustomInput.Size = UDim2.new(0, 180, 0, 35)
CustomInput.Text = "0.5"
CustomInput.PlaceholderText = "Delay (detik)"
CustomInput.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
CustomInput.TextColor3 = Color3.new(1,1,1)

-- Tulis di kertas
AddFishBtn("ELE", "ELE")
AddFishBtn("DM", "DM")
AddFishBtn("CUSTOM", "CUSTOM")

-- 4. LOGIKA PANCING
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
        task.wait(0.05)
    end
end)
