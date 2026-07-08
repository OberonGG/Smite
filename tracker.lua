-- KONDISI AWAL
if not game:IsLoaded() then 
    game.Loaded:Wait() 
end

-- KONFIGURASI API (Ganti URL di bawah dengan URL Worker Anda)
local WORKER_URL = "https://URL_WORKER_KAMU_DI_SINI.workers.dev"
local Player = game.Players.LocalPlayer
local ITEM_NAME = "Runic Enchant Stone"

-- Fungsi untuk mengambil jumlah Runic Enchant Stone dari dalam game
local function getRunicCount()
    -- Cek Jalur 1: Di dalam leaderstats
    local leaderstats = Player:FindFirstChild("leaderstats")
    if leaderstats and leaderstats:FindFirstChild(ITEM_NAME) then
        return leaderstats[ITEM_NAME].Value
    end
    
    -- Cek Jalur 2: Di dalam folder Data pemain
    local data = Player:FindFirstChild("Data")
    if data and data:FindFirstChild(ITEM_NAME) then
        return data[ITEM_NAME].Value
    end

    -- Cek Jalur 3: Di dalam Backpack (Jika item masuk ke inventory biasa)
    local backpack = Player:FindFirstChild("Backpack")
    if backpack then
        local itemValue = backpack:FindFirstChild(ITEM_NAME)
        if itemValue and itemValue:IsA("ValueBase") then
            return itemValue.Value
        elseif backpack:FindFirstChild(ITEM_NAME) then
            -- Jika item berupa Tool bertumpuk, hitung jumlah objeknya
            local count = 0
            for _, obj in pairs(backpack:GetChildren()) do
                if obj.Name == ITEM_NAME then
                    count = count + 1
                end
            end
            return count
        end
    end
    
    return 0 -- Kembalikan 0 jika item belum ditemukan
end

-- FUNGSI KIRIM DATA KE BACKEND CLOUDFLARE
local function sendDataToBackend()
    local currentRunic = getRunicCount()
    
    local payload = {
        userId = Player.UserId,
        username = Player.Name,
        runicCount = currentRunic
    }
    
    -- Menggunakan fungsi request universal milik Delta Executor
    local requestFunction = syn and syn.request or http and http.request or request
    
    if requestFunction then
        local success, response = pcall(function()
            return requestFunction({
                Url = WORKER_URL,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = game:GetService("HttpService"):JSONEncode(payload)
            })
        end)
        
        if success then
            print("Tracker: Data berhasil dikirim! " .. ITEM_NAME .. ": " .. tostring(currentRunic))
        else
            warn("Tracker: Gagal mengirim data ke API.")
        end
    else
        warn("Tracker: Executor tidak mendukung fungsi HTTP Request.")
    end
end

-- LOOPING OTOMATIS (Mengirim laporan berkala setiap 5 menit)
task.spawn(function()
    while task.wait(300) do 
        sendDataToBackend()
    end
end)

-- Jalankan pengiriman data pertama kali saat skrip baru dinyalakan
sendDataToBackend()