-- ==========================================
-- FISHING LOGIC (AKTIVASI TOMBOL UTAMA)
-- ==========================================

-- Hubungkan fungsi ke tombol ELE yang sudah ada di script utama
ELE.MouseButton1Click:Connect(function()
    if IsRunning then 
        resetFishing() 
    else
        resetFishing() 
        IsRunning = true 
        ELE.BackgroundTransparency = 0 -- Menandakan aktif
        StartFishing("ELE")
    end
end)

-- Hubungkan fungsi ke tombol DM yang sudah ada di script utama
DM.MouseButton1Click:Connect(function()
    if ManualRunning then 
        resetFishing() 
    else
        resetFishing() 
        ManualRunning = true 
        DM.BackgroundTransparency = 0 -- Menandakan aktif
        StartFishing("DM")
    end
end)

-- Hubungkan fungsi ke tombol CUSTOM yang sudah ada di script utama
CUSTOM.MouseButton1Click:Connect(function()
    if CustomRunning then 
        resetFishing() 
    else
        resetFishing() 
        CustomRunning = true 
        CUSTOM.BackgroundTransparency = 0 -- Menandakan aktif
        StartFishing("CUSTOM")
    end
end)

-- ENGINE UTAMA (Tanpa merubah fungsi)
function StartFishing(mode)
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
                    RF3:InvokeServer() 
                    RF3:InvokeServer() 
                    RF3:InvokeServer()
                end
            end)
            task.wait(0.05) 
        end
    end)
end
