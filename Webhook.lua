--// =========================================
--// WEBHOOK CONTROL + FILTER SYSTEM (FULL)
--// =========================================

local HttpService = game:GetService("HttpService")
local TextChatService = game:GetService("TextChatService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

-- =========================================
-- CONFIG
-- =========================================

local GLOBAL_WEBHOOK = "https://discord.com/api/webhooks/1471473387120361573/OJN4BmXmdHbf89_fJ6oV-QRp7j0XVeQVR4mxYR_aIIZTwmaoHYxU9oYqsGK8OQRecxY4"
local PRIVATE_WEBHOOK = nil

local MODE = "Global Only"
-- "Global Only"
-- "Private Only"
-- "Global + Private"
-- "OFF"

local GLOBAL_FILTER = "All"
-- "All"
-- "Secret Only"
-- "Mythic Only"

local PRIVATE_FILTER = "All"
-- "All"
-- "Secret Only"
-- "Mythic Only"

-- =========================================
-- DATA LIST (DARI SCRIPT KAMU)
-- =========================================

local list_ruby = {"Gemstone Ruby"}
local list_evo = {"Evolved Enchant Stone"}

local list_mythic = {
"Bioluminescent Manta Ray","Abyr Squid","Armor Catfish",
"Blob Fish","Sea Crustacean","Ancient Squid",
"Primordial Octopus","Flatheaded Whale Shark",
"Heart Dolphin","Rose Swordfish"
}

local list_secret = {
"Cursed Kraken","Queen Crab","King Crab",
"Megalodon","Ancient Lochness Monster",
"Zombie Shark","Ghost Shark","Bloodmoon Whale"
}

-- =========================================
-- RUNTIME COUNTER
-- =========================================

local startTime = os.time()
local count = {ruby=0,evo=0,mythic=0,secret=0}

-- =========================================
-- WEBHOOK SEND FUNCTION
-- =========================================

local function sendWebhook(url, message, category)

    if not url or url == "" then return end

    if category and count[category] then
        count[category] += 1
    end

    local runtimeSec = os.time() - startTime
    local runtime = string.format("%02d:%02d:%02d",
        math.floor(runtimeSec/3600),
        math.floor((runtimeSec%3600)/60),
        runtimeSec%60
    )

    local data = {
        content = "🎣 Fish Alert",
        embeds = {{
            description =
                message ..
                "\n\nRuntime: "..runtime..
                "\nRuby: "..count.ruby..
                " | Evo: "..count.evo..
                " | Mythic: "..count.mythic..
                " | Secret: "..count.secret,
            color = (category=="secret" and 65280)
                 or (category=="mythic" and 16753920)
                 or 16711680
        }}
    }

    pcall(function()
        HttpService:PostAsync(
            url,
            HttpService:JSONEncode(data),
            Enum.HttpContentType.ApplicationJson
        )
    end)
end

-- =========================================
-- CATEGORY DETECTION
-- =========================================

local function detectCategory(text)
    local txt = text:lower()

    for _,v in pairs(list_ruby) do
        if txt:find(v:lower()) then return "ruby" end
    end

    for _,v in pairs(list_evo) do
        if txt:find(v:lower()) then return "evo" end
    end

    for _,v in pairs(list_mythic) do
        if txt:find(v:lower()) then return "mythic" end
    end

    for _,v in pairs(list_secret) do
        if txt:find(v:lower()) then return "secret" end
    end

    return nil
end

-- =========================================
-- CHAT LISTENER
-- =========================================

TextChatService.OnIncomingMessage = function(message)

    local text = message.Text
    local category = detectCategory(text)
    local containsName = text:lower():find(player.Name:lower())

    -- =============================
    -- GLOBAL SYSTEM
    -- =============================
    if MODE == "Global Only" or MODE == "Global + Private" then
        if category then
            if GLOBAL_FILTER == "All"
            or (GLOBAL_FILTER=="Secret Only" and category=="secret")
            or (GLOBAL_FILTER=="Mythic Only" and category=="mythic") then

                sendWebhook(GLOBAL_WEBHOOK,text,category)
            end
        end
    end

    -- =============================
    -- PRIVATE SYSTEM
    -- =============================
    if MODE == "Private Only" or MODE == "Global + Private" then
        if containsName then
            if PRIVATE_FILTER == "All"
            or (PRIVATE_FILTER=="Secret Only" and category=="secret")
            or (PRIVATE_FILTER=="Mythic Only" and category=="mythic") then

                sendWebhook(PRIVATE_WEBHOOK,"[MENTION] "..text,category)
            end
        end
    end
end

-- =========================================
-- UI DROPDOWN SYSTEM
-- =========================================

local gui = Instance.new("ScreenGui",player.PlayerGui)
gui.Name="WebhookControl"

local frame = Instance.new("Frame",gui)
frame.Size=UDim2.new(0,360,0,280)
frame.Position=UDim2.new(0.5,-180,0.5,-140)
frame.BackgroundColor3=Color3.fromRGB(30,30,30)
frame.Active=true
frame.Draggable=true

local function createButton(text,posY,callback)
    local btn=Instance.new("TextButton",frame)
    btn.Size=UDim2.new(0.9,0,0,32)
    btn.Position=UDim2.new(0.05,0,posY,0)
    btn.Text=text
    btn.BackgroundColor3=Color3.fromRGB(60,60,60)
    btn.TextColor3=Color3.new(1,1,1)
    btn.MouseButton1Click:Connect(function()
        callback(btn)
    end)
    return btn
end

-- MODE
local modes={"Global Only","Private Only","Global + Private","OFF"}
createButton("Mode: "..MODE,0.1,function(btn)
    local index=table.find(modes,MODE)+1
    if index>#modes then index=1 end
    MODE=modes[index]
    btn.Text="Mode: "..MODE
end)

-- GLOBAL FILTER
local gFilters={"All","Secret Only","Mythic Only"}
createButton("Global Filter: "..GLOBAL_FILTER,0.25,function(btn)
    local index=table.find(gFilters,GLOBAL_FILTER)+1
    if index>#gFilters then index=1 end
    GLOBAL_FILTER=gFilters[index]
    btn.Text="Global Filter: "..GLOBAL_FILTER
end)

-- PRIVATE FILTER
local pFilters={"All","Secret Only","Mythic Only"}
createButton("Private Filter: "..PRIVATE_FILTER,0.4,function(btn)
    local index=table.find(pFilters,PRIVATE_FILTER)+1
    if index>#pFilters then index=1 end
    PRIVATE_FILTER=pFilters[index]
    btn.Text="Private Filter: "..PRIVATE_FILTER
end)

-- PRIVATE WEBHOOK INPUT
local box=Instance.new("TextBox",frame)
box.Size=UDim2.new(0.9,0,0,35)
box.Position=UDim2.new(0.05,0,0.6,0)
box.PlaceholderText="Masukkan Private Webhook..."
box.BackgroundColor3=Color3.fromRGB(50,50,50)
box.TextColor3=Color3.new(1,1,1)
box.ClearTextOnFocus=false

createButton("Save Private Webhook",0.8,function()
    if box.Text~="" and box.Text:find("https://") then
        PRIVATE_WEBHOOK=box.Text
        box.Text="Saved!"
    else
        box.Text="Invalid Webhook!"
    end
end)
