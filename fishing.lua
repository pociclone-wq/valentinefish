local Page = ... -- Menerima parent dari script utama

-- [[ VARIABLES & COLORS ]] --
local NeonBlue = Color3.fromRGB(0, 255, 255)
local IsRunning = false
local ManualRunning = false
local CustomRunning = false

local NetPath = game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")
local RF_Folder = NetPath:WaitForChild("RF")

-- Variabel penampung Remote (Otomatis terisi saat Scan)
local FoundStart, FoundCast, FoundCatch

-- [[ REMOTE SCANNER ENGINE ]] --
-- Fungsi ini mencari remote yang benar tanpa menggunakan ID statis
local function ScanRemotes()
    local allRF = RF_Folder:GetChildren()
    -- Logika urutan remote pada game ini biasanya konsisten meski ID berubah
    for _, rf in pairs(allRF) do
        if rf:IsA("RemoteFunction") then
            -- Scan sederhana berdasarkan urutan/pola (Update jika diperlukan)
            -- Di server baru, kita ambil yang paling sesuai dengan struktur Fishing
            if not FoundStart then FoundStart = rf 
            elseif not FoundCast then FoundCast = rf
            elseif not FoundCatch then FoundCatch = rf end
        end
    end
end

local function resetFishing()
    IsRunning = false
    ManualRunning = false
    CustomRunning = false
end

-- [[ UI ELEMENTS (TELEPORT STYLE) ]] --
local function CreateButton(txt, y, x, sizeX)
    local b = Instance.new("TextButton", Page)
    b.Text = txt
    b.Size = UDim2.new(sizeX or 0.45, -5, 0, 28)
    b.Position = UDim2.new(x or 0.05, 0, 0, y)
    b.BackgroundColor3 = NeonBlue
    b.TextColor3 = Color3.new(0, 0, 0)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 11
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    return b
end

local ELE = CreateButton("START ELE", 10, 0.05, 0.45)
local DM = CreateButton("START DM", 10, 0.52, 0.45)

local Lbl = Instance.new("TextLabel", Page)
Lbl.Text = "Custom Delay (Seconds)"
Lbl.Position = UDim2.new(0.05, 0, 0, 45)
Lbl.Size = UDim2.new(0.4, 0, 0, 20)
Lbl.TextColor3 = Color3.new(1, 1, 1)
Lbl.Font = Enum.Font.GothamBold
Lbl.TextSize = 10
Lbl.BackgroundTransparency = 1
Lbl.TextXAlignment = Enum.TextXAlignment.Left

local CustomInput = Instance.new("TextBox", Page)
CustomInput.Size = UDim2.new(0.5, 0, 0, 25)
CustomInput.Position = UDim2.new(0.45, 0, 0, 43)
CustomInput.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
CustomInput.Text = "0.5"
CustomInput.TextColor3 = Color3.new(1, 1, 1)
CustomInput.Font = Enum.Font.Gotham
CustomInput.TextSize = 11
Instance.new("UICorner", CustomInput).CornerRadius = UDim.new(0, 4)

local CUSTOM = CreateButton("START CUSTOM DELAY", 75, 0.05, 0.92)

-- [[ FISHING ENGINE ]] --
local function StartFishing(mode)
    if not FoundStart or not FoundCast or not FoundCatch then ScanRemotes() end
    
    task.spawn(function()
        while (mode == "ELE" and IsRunning) or (mode == "DM" and ManualRunning) or (mode == "CUSTOM" and CustomRunning) do
            pcall(function()
                -- Step 1: Start
                if FoundStart then FoundStart:InvokeServer() end
                task.wait(0.15) 

                -- Step 2: Cast (Menggunakan koordinat default yang fix)
                if FoundCast then
                    FoundCast:InvokeServer(-1.233184814453125, 0.9193826941424107, tick())
                end
                
                local jeda = (mode == "ELE" and math.random(7,9)/10) or (mode == "DM" and math.random(3,6)/10) or tonumber(CustomInput.Text) or 0.5
                task.wait(jeda) 

                -- Step 3: Catch (Triple Invoke sesuai instruksi)
                if FoundCatch then
                    FoundCatch:InvokeServer() 
                    FoundCatch:InvokeServer() 
                    FoundCatch:InvokeServer()
                end
            end)
            task.wait() 
        end
    end)
end

-- [[ BUTTON EVENTS ]] --
ELE.MouseButton1Click:Connect(function()
    if IsRunning then 
        resetFishing()
        ELE.Text = "START ELE"
    else
        resetFishing() 
        IsRunning = true 
        ELE.Text = "STOP ELE"
        DM.Text = "START DM"
        CUSTOM.Text = "START CUSTOM DELAY"
        StartFishing("ELE")
    end
end)

DM.MouseButton1Click:Connect(function()
    if ManualRunning then 
        resetFishing()
        DM.Text = "START DM"
    else
        resetFishing() 
        ManualRunning = true 
        DM.Text = "STOP DM"
        ELE.Text = "START ELE"
        CUSTOM.Text = "START CUSTOM DELAY"
        StartFishing("DM")
    end
end)

CUSTOM.MouseButton1Click:Connect(function()
    if CustomRunning then 
        resetFishing()
        CUSTOM.Text = "START CUSTOM DELAY"
    else
        resetFishing() 
        CustomRunning = true 
        CUSTOM.Text = "STOP CUSTOM DELAY"
        ELE.Text = "START ELE"
        DM.Text = "START DM"
        StartFishing("CUSTOM")
    end
end)
