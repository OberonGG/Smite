if not game:IsLoaded() then 
    game.Loaded:Wait() 
end

local WORKER_URL = "https://tracker.ursoffboy5.workers.dev/"
local Player = game.Players.LocalPlayer
local ITEM_NAME = "Runic Enchant Stone"
local lastCount = -1 -- Nilai awal agar deteksi pertama kali selalu berjalan

local function getRunicCount()
    local leaderstats = Player:FindFirstChild("leaderstats")
    if leaderstats and leaderstats:FindFirstChild(ITEM_NAME) then
        return leaderstats[ITEM_NAME].Value
    end
    -- Tambahkan logic Data/Backpack jika perlu...
    return 0
end

local function sendDataToBackend()
    local currentRunic = getRunicCount()
    
    -- LOGIKA HYBRID: Cuma kirim kalau jumlah berubah
    if currentRunic ~= lastCount then
        lastCount = currentRunic -- Update nilai terakhir
        
        local payload = {
            userId = Player.UserId,
            username = Player.Name,
            runicCount = currentRunic
        }
        
        local requestFunction = syn and syn.request or http and http.request or request
        if requestFunction then
            pcall(function()
                requestFunction({
                    Url = WORKER_URL,
                    Method = "POST",
                    Headers = { ["Content-Type"] = "application/json" },
                    Body = game:GetService("HttpService"):JSONEncode(payload)
                })
            end)
            print("Tracker: Data terkirim (Perubahan terdeteksi: " .. currentRunic .. ")")
        end
    end
end

-- LOOPING MONITORING (Tetap dipasang untuk deteksi perubahan)
-- Interval 60 detik sudah sangat ringan karena tidak akan kirim data kecuali angka berubah
-- Tambahkan delay awal agar tidak bentrok saat loading game
task.wait(math.random(5, 15)) 

task.spawn(function()
    -- BERI DELAY AWAL YANG SANGAT BESAR DAN ACAK (1 hingga 300 detik)
    -- Ini memastikan 140 akunmu tidak akan 'menyerang' server di waktu yang sama saat baru login
    task.wait(math.random(1, 300))
    
    while true do
        sendDataToBackend()
        -- Perpanjang interval menjadi 5-10 menit per akun
        task.wait(math.random(300, 600)) 
    end
end)