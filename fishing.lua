-- Cari baris "ELE = Instance.new("TextButton", MainFrame)" di skrip utama Anda
-- Lalu pastikan variabel di atas (local ELE, DM, dst) diisi seperti ini:

ELE = Instance.new("TextButton", MainFrame)
ELE.Size = UDim2.new(0.4, -5, 0, 30)
ELE.Position = UDim2.new(0.1, 0, 0, 105)
ELE.Text = "ELE"
styleBtn(ELE, 14)

DM = Instance.new("TextButton", MainFrame)
DM.Size = UDim2.new(0.4, -5, 0, 30)
DM.Position = UDim2.new(0.5, 5, 0, 105)
DM.Text = "DM"
styleBtn(DM, 14)

-- Tambahkan logika fishing ini di bagian bawah skrip utama Anda:

local function StartFishing(mode)
    task.spawn(function()
        while (mode == "ELE" and IsRunning) or (mode == "DM" and ManualRunning) or (mode == "CUSTOM" and CustomRunning) do
            pcall(function()
                local RF1 = getRemote(FishStartID)
                if RF1 then RF1:InvokeServer() end
                task.wait(0.15) 

                local RF2 = getRemote(FishCastID)
                if RF2 then
                    RF2:InvokeServer(-1.233184814453125, 0.9193826941424107, tick())
                end
                
                local jeda = (mode == "ELE" and math.random(7,9)/10) or (mode == "DM" and math.random(3,6)/10) or tonumber(CustomInput.Text) or 0.5
                task.wait(jeda) 

                local RF3 = getRemote(FishCatchID)
                if RF3 then
                    RF3:InvokeServer() RF3:InvokeServer() RF3:InvokeServer()
                end
            end)
            task.wait(0.05) 
        end
    end)
end

-- BUTTON EVENTS (Pastikan ini ada di paling bawah)
ELE.MouseButton1Click:Connect(function()
    if IsRunning then resetFishing() else
        resetFishing() 
        IsRunning = true 
        ELE.BackgroundTransparency = 0 
        StartFishing("ELE")
    end
end)

DM.MouseButton1Click:Connect(function()
    if ManualRunning then resetFishing() else
        resetFishing() 
        ManualRunning = true 
        DM.BackgroundTransparency = 0 
        StartFishing("DM")
    end
end)
