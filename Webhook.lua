local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- Fungsi request yang kompatibel dengan Delta / Executor lain
local requestFunc = http_request or request or HttpPost or syn.request

-- Validasi Executor
if not requestFunc then
    warn("Executor Anda tidak mendukung HTTP Requests (Webhook).")
    return
end

-- Setup Tracker Variables Global (Supaya tidak reset kalau di-load ulang)
if not _G.PociX_StartTime then
    _G.PociX_StartTime = os.time()
    _G.PociX_TotalPrice = 0
    _G.PociX_TierCounts = {0, 0, 0, 0, 0, 0, 0, 0}
end

local TierNames = {
    [1] = "Common", [2] = "Uncommon", [3] = "Rare", [4] = "Epic",
    [5] = "Legendary", [6] = "Mythic", [7] = "Secret", [8] = "Forgotten"
}

-- Fungsi Kirim Pesan ke Discord
local function SendToDiscord(data)
    requestFunc({
        Url = _G.PociX_WebhookURL,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode(data)
    })
end

-- Notifikasi Awal Saat Diaktifkan
SendToDiscord({
    ["content"] = "✅ **Webhook Fishit Aktif!**\nScript running di akun: **" .. LocalPlayer.Name .. "**\nMenunggu kabar dari server..."
})

-- Format Waktu Runtime
local function formatTime(seconds)
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = seconds % 60
    return string.format("%02d:%02d:%02d", h, m, s)
end

-- Pembersih Nama Ikan (Menghilangkan FROZEN, SHINY, dll agar bisa cari harga)
local function getBaseFishName(fullName)
    local itemsFolder = ReplicatedStorage:FindFirstChild("Items")
    if not itemsFolder then return fullName end

    -- Coba cari nama full dulu
    if itemsFolder:FindFirstChild(fullName) then return fullName end

    -- Coba hilangkan 1 kata di depan (Mutasi)
    local splitName = string.split(fullName, " ")
    if #splitName > 1 then
        table.remove(splitName, 1)
        local baseName = table.concat(splitName, " ")
        if itemsFolder:FindFirstChild(baseName) then
            return baseName
        end
    end
    return fullName
end

-- Observer: Mendengarkan Notifikasi yang Muncul di UI Layar
local NotificationConnection
NotificationConnection = LocalPlayer.PlayerGui.DescendantAdded:Connect(function(descendant)
    -- Jika tombol "Stop" ditekan di UI, matikan fungsi pencarian ini
    if not _G.PociX_WebhookActive then
        NotificationConnection:Disconnect()
        return
    end

    if descendant:IsA("TextLabel") or descendant:IsA("RichText") then
        task.delay(0.1, function() -- Jeda 0.1 detik memastikan text sudah load penuh
            local rawText = descendant.Text
            if not rawText then return end
            
            -- Membersihkan tag rich text seperti <font color="..."> kalau ada
            local cleanText = string.gsub(rawText, "<[^>]+>", "")
            
            -- Format Notif: "[Player] obtained a [Nama Ikan] ([Berat]kg) with a [Chance] chance!"
            local fishName, weight, chance = string.match(cleanText, "obtained a (.-) %((.-)[kK]?[gG]?%) with a (.-) chance!")

            if fishName and weight and chance then
                -- Anti Spam/Duplikat Notifikasi
                if descendant:GetAttribute("WebhookSent") then return end
                descendant:SetAttribute("WebhookSent", true)

                -- Cari data harga dari ReplicatedStorage
                local baseName = getBaseFishName(fishName)
                local sellPrice = 0
                local tier = 1

                local itemMod = ReplicatedStorage:FindFirstChild("Items") and ReplicatedStorage.Items:FindFirstChild(baseName)
                if itemMod and itemMod:IsA("ModuleScript") then
                    local success, data = pcall(require, itemMod)
                    if success and type(data) == "table" then
                        sellPrice = data.SellPrice or 0
                        tier = (data.Data and data.Data.Tier) or 1
                    end
                end

                -- Jika Tier lolos filter, kirim ke Discord
                if tier >= (_G.PociX_MinTier or 1) then
                    _G.PociX_TotalPrice = _G.PociX_TotalPrice + sellPrice
                    _G.PociX_TierCounts[tier] = _G.PociX_TierCounts[tier] + 1
                    
                    local currentRuntime = formatTime(os.time() - _G.PociX_StartTime)
                    local tierStr = TierNames[tier] or "Unknown"

                    -- Build Tampilan Discord persis seperti instruksi
                    local embedData = {
                        ["content"] = string.format("Congratulations!! **%s** You have obtained a new **%s** fish!", LocalPlayer.Name, tierStr),
                        ["embeds"] = {{
                            ["color"] = 65280,
                            ["description"] = string.format("Fish: ❄️ %s\nWeight: %skg\nChance: %s\nSell Price: $%s (Auto-fetched)\n\n** %s Fishing Runtime:** %s", 
                                fishName, weight, chance, tostring(sellPrice), LocalPlayer.Name, currentRuntime),
                            ["fields"] = {
                                {
                                    ["name"] = "Total Price",
                                    ["value"] = string.format("$%s", tostring(_G.PociX_TotalPrice)),
                                    ["inline"] = false
                                },
                                {
                                    ["name"] = "Tier Counters",
                                    ["value"] = string.format("| T1: %d | T2: %d | T3: %d | T4: %d | T5: %d | T6: %d | T7: %d | T8: %d |",
                                        _G.PociX_TierCounts[1], _G.PociX_TierCounts[2], _G.PociX_TierCounts[3], _G.PociX_TierCounts[4],
                                        _G.PociX_TierCounts[5], _G.PociX_TierCounts[6], _G.PociX_TierCounts[7], _G.PociX_TierCounts[8]),
                                    ["inline"] = false
                                }
                            }
                        }}
                    }
                    SendToDiscord(embedData)
                end
            end
        end)
    end
end)
