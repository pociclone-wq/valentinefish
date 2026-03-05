return {
    ["Disable Animation"] = function()
        local Settings = _G.PociXSettings or {}
        Settings.DisableAnim = not Settings.DisableAnim
        if Settings.DisableAnim then
            local char = game.Players.LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                for _, v in pairs(char.Humanoid:GetPlayingAnimationTracks()) do v:Stop() end
            end
        end
    end,
    
    ["Disable Fish Caught"] = function()
        _G.PociXSettings.DisableCaught = not _G.PociXSettings.DisableCaught
    end,

    ["Disable Cutscene"] = function()
        _G.PociXSettings.DisableCutscene = not _G.PociXSettings.DisableCutscene
        if _G.PociXSettings.DisableCutscene then
            game.Workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
        end
    end,

    ["Disable Notification"] = function()
        _G.PociXSettings.DisableNotify = not _G.PociXSettings.DisableNotify
    end,

    ["--- FISHING MODES ---"] = function() print("Header Only") end,

    ["Mode: ELE"] = function() _G.FishingMode = "ELE" end,
    ["Mode: DM"] = function() _G.FishingMode = "DM" end,
    ["Mode: CUSTOM"] = function() _G.FishingMode = "CUSTOM" end,

    ["START AUTO FISHING"] = function()
        _G.FishingActive = not _G.FishingActive
        if _G.FishingActive then
            task.spawn(function()
                local Net = game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")
                while _G.FishingActive do
                    pcall(function()
                        Net:WaitForChild("RF/2688df0b77e6a72960d933fee24d035fcc4e90d71645a6e4a97c22fc0e297d8b"):InvokeServer()
                        task.wait(0.15)
                        Net:WaitForChild("RF/4cd9bdf89e37861669d0e5f221d1c028b76bca210162e02e5b5c2f5952f8f664"):InvokeServer(-1.2331848, 0.9966384, tick())
                        
                        local waitTime = (_G.FishingMode == "ELE" and 0.8) or (_G.FishingMode == "DM" and 0.4) or 0.5
                        task.wait(waitTime)
                        
                        local catch = Net:WaitForChild("RF/c809299d1966f1bb7fe1166ced3c2017cadae50d14d1fb1a2d45f6eb79fc7c03")
                        catch:InvokeServer() catch:InvokeServer() catch:InvokeServer()
                    end)
                    task.wait()
                end
            end)
        end
    end
}
