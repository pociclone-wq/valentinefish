--[[ 
    FISHING.LUA (PENULIS DI ATAS KERTAS UTAMA)
    Menyambung langsung ke Parent: FishIt_FinalFix
--]]

local PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- 1. SAMBUNG KE KERTAS (Mencari Parent yang dikecualikan oleh Object Eraser)
local Screen = PlayerGui:WaitForChild("FishIt_FinalFix")
local Main = Screen:WaitForChild("Frame")

-- 2. SESUAIKAN UKURAN FRAME (Agar Tombol Pancing Terlihat)
-- Ukuran asli 250 tidak muat, kita tambah ruang di kertas yang sama
Main.Size = UDim2.new(0, 200, 0, 450) 

-- Konfigurasi Remote
local Net = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")
local Fishing = { Active = false, Mode = "NONE" }

-- 3. TULIS TOMBOL (Gaya & Ukuran identik dengan script utama)
local function AddFishBtn(text, mode)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(0, 180, 0, 40) -- Sama dengan ukuran MakeToggle di script utama
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = "START " .. text
    btn.Name = "Btn_" .. text -- Memastikan nama aman

    btn.MouseButton1Click:Connect(function()
        if Fishing.Active and Fishing.Mode == mode then
            Fishing.Active = false
            btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            btn.Text = "START " .. text
        else
            Fishing.Active = true
            Fishing.Mode = mode
            btn.BackgroundColor3 = Color3.fromRGB(0, 200, 0) -- Hijau saat ON seperti Toggle
            btn.Text = "STOP " .. text
        end
    end)
end

-- Input Delay (TextBox di dalam kertas)
local CustomInput = Instance.new("TextBox", Main)
CustomInput.Size = UDim2.new(0, 180, 0, 30)
CustomInput.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
CustomInput.TextColor3 = Color3.new(1,1,1)
CustomInput.Text = "0.5"

AddFishBtn("ELE", "ELE")
AddFishBtn("DM", "DM")
AddFishBtn("CUSTOM", "CUSTOM")

-- 4. LOGIKA PANCING (ENGINE)
task.spawn(function()
    while true do
        if Fishing.Active then
            pcall(function()
                local RF = function(id) return Net:FindFirstChild("RF/"..id) end
                RF("f6064d19476415377eeb8539f7a20ca4d706901720fda6240c952b5a86c99d4f"):InvokeServer()
                task.wait(0.15)
                RF("b47871ff05d63a1d5a2e4a93861427df7360fdf7bd581404fbf8ce74685734dc"):InvokeServer(-1.233184814453125, 0.9193826941424107, tick())
                
                local d = 0.5
                if Fishing.Mode == "ELE" then d = math.random(7,9)/10
                elseif Fishing.Mode == "DM" then d = math.random(3,6)/10
                else d = tonumber(CustomInput.Text) or 0.5 end
                
                task.wait(d)
                local catch = RF("e28d0cce33ead4ec77e1dd7b7b626e1e444eb87d8e45ce8add22533e74e5ce81")
                catch:InvokeServer() catch:InvokeServer() catch:InvokeServer()
            end)
        end
        task.wait(0.05)
    end
end)
