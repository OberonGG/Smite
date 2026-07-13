local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TradeData = require(ReplicatedStorage.Shared.Trading.TradeData)

print("[RECEIVER] Sistem BYPASS TOTAL Aktif!")

-- ==========================================
-- 1. MENCEGAT DAN MEMBUNUH UI BAWAAN GAME
-- ==========================================
-- Kita cari semua fungsi bawaan game yang mendengarkan Remote ini...
local koneksiBawaan = getconnections(TradeData.Remotes.TradeOfferReceived.OnClientEvent)

for _, conn in pairs(koneksiBawaan) do
    -- ...lalu kita matikan fungsinya!
    -- Dengan ini, TradeOfferController tidak akan pernah tahu ada trade masuk,
    -- sehingga PromptController tidak akan pernah memunculkan UI Pop-Up.
    conn:Disable() 
end
print("[RECEIVER] Berhasil mematikan sistem pop-up bawaan game.")

-- ==========================================
-- 2. DIAM-DIAM MENERIMA TRADE
-- ==========================================
-- Sekarang kita buat koneksi baru yang HANYA bereaksi menembak server
TradeData.Remotes.TradeOfferReceived.OnClientEvent:Connect(function(playerYangMengirim)
    print("[RECEIVER] Trade masuk dari " .. tostring(playerYangMengirim) .. ". Langsung menyetujui tanpa UI!")
    
    -- Menjeda sangat sebentar
    task.wait(0.2)
    
    -- Tembak server langsung (Karena UI bawaan sudah dimatikan, tidak akan ada yang nyangkut)
    pcall(function()
        TradeData.Remotes.AcceptTradeOffer:InvokeServer(playerYangMengirim)
    end)
end)

-- ==========================================
-- 3. AUTO READY & CONFIRM DI MEJA TRADE
-- ==========================================
-- Saat server merespons "AcceptTradeOffer" kita, server otomatis mengatur status IsTrading jadi true.
-- Sistem meja trade (TradeController) akan merespons ini dengan normal karena kita tidak merusaknya.
LocalPlayer:GetAttributeChangedSignal("IsTrading"):Connect(function()
    if LocalPlayer:GetAttribute("IsTrading") == true then
        print("[RECEIVER] Masuk ke meja trade. Menjalankan Auto-Confirm...")
        
        task.spawn(function()
            while LocalPlayer:GetAttribute("IsTrading") == true do
                pcall(function()
                    TradeData.Remotes.SetReady:InvokeServer(true)
                    TradeData.Remotes.ConfirmTrade:InvokeServer()
                end)
                task.wait(1)
            end
            print("[RECEIVER] Trade selesai dengan sempurna.")
        end)
    end
end)