local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Mengambil modul TradeData seperti di controller asli
local TradeData = require(ReplicatedStorage.Shared.Trading.TradeData)

-- ==========================================
-- 1. AUTO ACCEPT OFFER (Bypass UI Pop-up)
-- ==========================================
TradeData.Remotes.TradeOfferReceived.OnClientEvent:Connect(function(playerYangMengirim)
    print("[RECEIVER] Menerima ajakan trade instan dari: " .. tostring(playerYangMengirim))
    
    -- Menjeda sangat sebentar agar server tidak kaget
    task.wait(0.2)
    
    -- Langsung membalas Accept tanpa harus melihat UI Pop-up
    TradeData.Remotes.AcceptTradeOffer:InvokeServer(playerYangMengirim)
end)

-- ==========================================
-- 2. AUTO READY & CONFIRM (Di dalam UI Trade)
-- ==========================================
-- Kita manfaatkan sistem bawaan game: atribut "IsTrading" 
LocalPlayer:GetAttributeChangedSignal("IsTrading"):Connect(function()
    local sedangTrade = LocalPlayer:GetAttribute("IsTrading")
    
    if sedangTrade then
        print("[RECEIVER] Berhasil masuk ke meja trade. Menunggu barang...")
        
        -- Menjalankan looping di latar belakang (task.spawn) agar game tidak freeze
        task.spawn(function()
            while LocalPlayer:GetAttribute("IsTrading") == true do
                -- Otomatis menekan ceklis "Ready"
                TradeData.Remotes.SetReady:InvokeServer(true)
                
                -- Otomatis mencoba menekan "Confirm"
                -- (Server game otomatis menahannya sampai cooldown 5 detik selesai dan pihak lawan ready)
                TradeData.Remotes.ConfirmTrade:InvokeServer()
                
                -- Jeda 1 detik setiap putaran agar aman dari Anti-Cheat (BAC)
                task.wait(1)
            end
            
            print("[RECEIVER] Trade sukses terselesaikan dan UI tertutup.")
        end)
    end
end)