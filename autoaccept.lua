local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Mengambil modul TradeData sesuai struktur asli game
local TradeData = require(ReplicatedStorage.Shared.Trading.TradeData)

print("[RECEIVER] Script Auto-Accept (Remote Only Mode) Aktif!")

-- ==========================================
-- 1. AUTO ACCEPT OFFER (Murni Panggil Remote)
-- ==========================================
TradeData.Remotes.TradeOfferReceived.OnClientEvent:Connect(function(playerYangMengirim)
    print("[RECEIVER] Menerima ajakan trade dari: " .. tostring(playerYangMengirim))
    
    -- Jeda singkat agar tidak terlalu instan di mata server
    task.wait(0.2)
    
    print("[RECEIVER] Menembak Remote AcceptTradeOffer...")
    
    -- Memanggil remote secara langsung
    local sukses, errorMsg = pcall(function()
        TradeData.Remotes.AcceptTradeOffer:InvokeServer(playerYangMengirim)
    end)
    
    if sukses then
        print("[RECEIVER] Berhasil mengirim persetujuan ke server!")
    else
        warn("[RECEIVER] Error saat memanggil remote: " .. tostring(errorMsg))
    end
end)

-- ==========================================
-- 2. AUTO READY & CONFIRM (Di dalam UI Trade)
-- ==========================================
LocalPlayer:GetAttributeChangedSignal("IsTrading"):Connect(function()
    local sedangTrade = LocalPlayer:GetAttribute("IsTrading")
    
    if sedangTrade then
        print("[RECEIVER] Masuk ke sesi trade (IsTrading = true). Menunggu barang...")
        
        task.spawn(function()
            -- Looping selama status trade masih aktif
            while LocalPlayer:GetAttribute("IsTrading") == true do
                -- Gunakan pcall agar tidak error jika remote gagal ditembak
                pcall(function()
                    TradeData.Remotes.SetReady:InvokeServer(true)
                    TradeData.Remotes.ConfirmTrade:InvokeServer()
                end)
                
                -- Jeda 1 detik per putaran loop
                task.wait(1)
            end
            print("[RECEIVER] Sesi trade selesai. Loop Auto-Confirm berhenti.")
        end)
    end
end)