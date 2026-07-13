local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TradeData = require(ReplicatedStorage.Shared.Trading.TradeData)

print("[RECEIVER] Auto-Accept (Virtual Click) Aktif!")

TradeData.Remotes.TradeOfferReceived.OnClientEvent:Connect(function()
    print("[RECEIVER] Offer masuk! Menunggu Prompt UI muncul...")
    
    -- Jeda 0.5 detik sangat WAJIB agar PromptController selesai membuat tombol "Yes" di layar
    task.wait(0.5)
    
    local tombolYesDitemukan = false
    
    -- Mencari tombol "Yes" di seluruh layar pemain
    for _, gui in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
        if gui:IsA("TextButton") and gui.Text == "Yes" then
            tombolYesDitemukan = true
            print("[RECEIVER] Tombol 'Yes' ditemukan. Mengeklik otomatis...")
            
            -- Menipu game agar merasa tombol ini diklik oleh manusia
            if getconnections then
                for _, conn in pairs(getconnections(gui.MouseButton1Click)) do
                    pcall(function() conn:Fire() end)
                    pcall(function() conn.Function() end)
                end
            elseif firesignal then
                pcall(function() firesignal(gui.MouseButton1Click) end)
            else
                warn("[RECEIVER] Eksekutor tidak mendukung getconnections/firesignal!")
            end
            break
        end
    end
    
    if not tombolYesDitemukan then
        warn("[RECEIVER] Gagal menemukan tombol 'Yes'.")
    end
end)

-- (Jangan lupa gabungkan dengan fungsi Auto-Ready/Confirm IsTrading di sini seperti sebelumnya)