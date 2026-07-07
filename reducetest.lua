local Env = getfenv();
local w = {};
local v1 = {...};
local r1 = true;
local r2 = string.gmatch;
local function r3(...)
    error("Tamper Detected!");
    return; 
end;
local r4 = false;
local v2 = pcall(function(...)
    r4 = true;
    return; 
end) and r4;
local r5 = math.random;
local v3 = table.concat;
local function v4(...)
    while true do
        l1 = l2;
        l2 = l1;
        r3(); 
    end;
    return; 
end;
local v5 = table;
if v5 then
    H = table.unpack;
end;
local r6 = v5 or unpack;
local r7 = r5(3, 65);
local v6 = ({
    pcall(function(...)
        return "uZ" / (11577282 - "TnaUFtZrJs6r4" ^ 9342935); 
    end)
})[2];
local r8 = tonumber(r2(tostring(v6), ":(%d*):")());
for R = 1, r7 do
    r9 = R;
    r10 = math.random(1, 100);
    r11 = r5(0, 255);
    r12 = r5(1, r10);
    r13 = r5(1, 2) == 1;
    r14 = v6.gsub(v6, ":(%d*):", ":" .. tostring(r5(0, 10000)) .. ":");
    a = {
        pcall(function(...)
            if r5(1, 2) == 1 or r9 == r7 then
                r1 = r1 and r8 == tonumber(r2(tostring(({
                    pcall(function(...)
                        return "uQ2MRIwmS59Hq" / (2025368 - "MSfMmvXKVynDP" ^ 13063035); 
                    end)
                })[2]), ":(%d*):")());
            end;
            if r13 then
                error(r14, 0);
            end;
            v1 = {};
            for m = 1, r10 do
                v1[m] = r5(0, 255); 
            end;
            v1[r12] = r11;
            return r6(v1); 
        end)
    };
    if r13 then
        r1 = r1 and (pcall(function(...)
            if r5(1, 2) == 1 or r9 == r7 then
                r1 = r1 and r8 == tonumber(r2(tostring(({
                    pcall(function(...)
                        return "uQ2MRIwmS59Hq" / (2025368 - "MSfMmvXKVynDP" ^ 13063035); 
                    end)
                })[2]), ":(%d*):")());
            end;
            if r13 then
                error(r14, 0);
            end;
            v1 = {};
            for m = 1, r10 do
                v1[m] = r5(0, 255); 
            end;
            v1[r12] = r11;
            return r6(v1); 
        end) == false and a[2] == r14);
    end; 
end;
r1 = r1 and 0 == 0;
if r1 then
    r17 = math.floor;
    r18 = 0;
    r19 = 2;
    v4 = {};
    L = {};
    r20 = {};
    v5 = 0;
    for b = 1, 256 do
        L[b] = b; 
    end;
    v6 = #L == 0;
    b = table.remove(L, math.random(1, #L));
    r20[b] = string.char(b - 1);
    if #L == 0 then
        r21 = {};
        r23 = {};
        r15 = setmetatable({}, {
            ["__index"] = r23,
            ["__metatable"] = nil
        });
        m = game;
        r24 = m.GetService(m, "Players");
        J = game;
        r25 = J.GetService(J, "Lighting");
        v2 = game;
        r26 = v2.GetService(v2, "SoundService");
        X = game;
        r27 = X.GetService(X, "RunService");
        r28 = r24.LocalPlayer;
        yt[8] = "\x14\xce\xc9s\xcf\x18\xc19\xbch<LN";
        v4 = {
            ["BG"] = Color3.fromRGB(20, 20, 20),
            ["Accent"] = Color3.fromRGB(255, 255, 255),
            ["White"] = Color3.fromRGB(255, 255, 255)
        };
        r29 = 50;
        r30 = .016;
        L = Instance.new("ScreenGui");
        L.Name = "MONSFAMS";
        r31 = Instance.new("Frame");
        r31.Size = UDim2.new(0, 160, 0, 145);
        yt[4] = "\x97P\xac\xda\x8b\xfa\xe8\x1f\x81#";
        r31.Position = UDim2.new(0, 10, 0.5, -35);
        r31.BackgroundColor3 = v4.BG;
        r31.BorderSizePixel = 0;
        r31.Parent = L;
        yt[5] = 19941297906757;
        Instance.new("UIStroke", r31).Color = v4.Accent;
        Instance.new("UIStroke", r31).Thickness = 1;
        Instance.new("UICorner", r31).CornerRadius = UDim.new(0, 8);
        r32 = Instance.new("Frame");
        yt[15] = 25407832960567;
        r32.Size = UDim2.new(1, -30, 0, 28);
        r32.Position = UDim2.new(0, 8, 0, 0);
        r32.BackgroundTransparency = 1;
        r32.Parent = r31;
        r33 = Instance.new("TextLabel");
        r33.Size = UDim2.new(1, 0, 1, 0);
        r33.BackgroundTransparency = 1;
        r33.Text = "MONSFAMS";
        yt[7] = 18215824974114;
        r33.TextColor3 = v4.White;
        r33.TextSize = 16;
        r33.Font = Enum.Font.SourceSans;
        yt[2] = "j\xcbK";
        r33.TextXAlignment = Enum.TextXAlignment.Left;
        r33.Parent = r32;
        r34 = Instance.new("TextButton");
        r34.Size = UDim2.new(0, 20, 0, 20);
        yt[1] = 10984744539131;
        r34.Position = UDim2.new(1, -26, 0.5, -10);
        yt[3] = 31392123762970;
        yt[14] = "h\x9c\x02Q\r`\xa2\x15s`";
        r34.BackgroundColor3 = Color3.fromRGB(40, 40, 40);
        r34.BackgroundTransparency = 0;
        r34.Text = "\xe2\x88\x92";
        r34.TextColor3 = v4.White;
        r34.TextSize = 16;
        r34.Font = Enum.Font.SourceSans;
        r34.Parent = r31;
        Instance.new("UICorner", r34).CornerRadius = UDim.new(0, 4);
        Instance.new("UIStroke", r34).Color = v4.Accent;
        yt[6] = "\xc6\x13`\x11\xbfP\xb4\xf7\xd413\xe9\xeaU\xd9%\r\x83\x9b\x88a";
        r35 = Instance.new("Frame");
        r35.Size = UDim2.new(1, -16, 0, 105);
        r35.Position = UDim2.new(0, 8, 0, 32);
        r35.BackgroundTransparency = 1;
        r35.Parent = r31;
        r36 = false;
        N = r34.MouseButton1Click;
        N.Connect(N, function(...)
            r36 = not r36;
            if r36 then
                r31.Size = UDim2.new(0, 160, 0, 30);
                r35.Visible = false;
                r34.Text = "+";
                r33.TextXAlignment = Enum.TextXAlignment.Left;
                r32.Size = UDim2.new(1, -30, 1, 0);
                r32.Position = UDim2.new(0, 8, 0, 0);
            else
                r31.Size = UDim2.new(0, 160, 0, 145);
                r35.Visible = true;
                r34.Text = "\xe2\x88\x92";
                r33.TextXAlignment = Enum.TextXAlignment.Left;
                r32.Size = UDim2.new(1, -30, 0, 28);
                r32.Position = UDim2.new(0, 8, 0, 0);
            end;
            return; 
        end);
        r37 = false;
        N = r32.InputBegan;
        N.Connect(N, function(arg1_2, ...)
            r40 = arg1_2;
            m = r40.UserInputType;
            if m == Enum.UserInputType.MouseButton1 or r40.UserInputType == Enum.UserInputType.Touch then
                r37 = true;
                r38 = r40.Position;
                r39 = r31.Position;
                m = r40.Changed;
                m.Connect(m, function(...)
                    if r40.UserInputState == Enum.UserInputState.End then
                        r37 = false;
                    end;
                    return; 
                end);
            end;
            return; 
        end);
        N = r32.InputChanged;
        N.Connect(N, function(arg1_3, ...)
            v1 = arg1_3;
            if v1.UserInputType == Enum.UserInputType.MouseMovement or v1.UserInputType == Enum.UserInputType.Touch then
                Y = arg1_3;
            end;
            return; 
        end);
        u = game;
        N = u.GetService(u, "UserInputService").InputChanged;
        N.Connect(N, function(arg1_4, ...)
            if r37 then
                Y = arg1_4.Position - r38;
                r31.Position = UDim2.new(r39.X.Scale, r39.X.Offset + Y.X, r39.Y.Scale, r39.Y.Offset + Y.Y);
            end;
            return; 
        end);
        yt[13] = 25681084526262;
        r41 = Instance.new("TextButton");
        r41.Size = UDim2.new(.9, 0, 0, 26);
        r41.Position = UDim2.new(0.5, -72, 0.5, -82);
        r41.BackgroundColor3 = v4.BG;
        r41.BackgroundTransparency = .3;
        r41.Text = "Web/Apk Track";
        r41.TextColor3 = v4.White;
        r41.TextSize = 14;
        r41.Font = Enum.Font.SourceSans;
        r41.Parent = r35;
        Instance.new("UICorner", r41).CornerRadius = UDim.new(0, 6);
        Instance.new("UIStroke", r41).Color = v4.Accent;
        u = r41.MouseButton1Click;
        u.Connect(u, function(...)
            r41.Text = "Loading...";
            Y = pcall(function(...)
                v1 = game;
                loadstring(v1.HttpGet(v1, "https://raw.githubusercontent.com/dengjiangbin/fish-it/main/tracker.lua"))();
                return; 
            end);
            if Y then
                r41.Text = "Loaded!";
            else
                r41.Text = "Error";
                warn("Web/Apk Track Error: " .. tostring(m[2]));
            end;
            task.wait(1);
            r41.Text = "Web/Apk Track";
            return; 
        end);
        r42 = Instance.new("TextButton");
        r42.Size = UDim2.new(.9, 0, 0, 26);
        yt[9] = 12080492877305;
        r42.Position = UDim2.new(0.5, -72, 0.5, -22);
        r42.BackgroundColor3 = v4.BG;
        r42.BackgroundTransparency = .3;
        r42.Text = "Reduce";
        r42.TextColor3 = v4.White;
        r42.TextSize = 14;
        r42.Font = Enum.Font.SourceSans;
        r42.Parent = r35;
        Instance.new("UICorner", r42).CornerRadius = UDim.new(0, 6);
        Instance.new("UIStroke", r42).Color = v4.Accent;
        r43 = Instance.new("TextButton");
        r43.Size = UDim2.new(.9, 0, 0, 26);
        r43.Position = UDim2.new(0.5, -72, 0.5, -52);
        r43.BackgroundColor3 = v4.BG;
        r43.BackgroundTransparency = .3;
        r43.Text = "DENG.lua";
        r43.TextColor3 = v4.White;
        r43.TextSize = 14;
        r43.Font = Enum.Font.SourceSans;
        r43.Parent = r35;
        Instance.new("UICorner", r43).CornerRadius = UDim.new(0, 6);
        Instance.new("UIStroke", r43).Color = v4.Accent;
        S = r43.MouseButton1Click;
        S.Connect(S, function(...)
            r43.Text = "Loading...";
            if pcall(function(...)
                v1 = game;
                loadstring(v1.HttpGet(v1, "https://raw.githubusercontent.com/GrexXMeng/Mengs/refs/heads/main/Deng.lua"))();
                return; 
            end) then
                r43.Text = "Loaded!";
            else
                r43.Text = "Error";
                warn("DENG.lua Error: " .. tostring(m[2]));
            end;
            task.wait(1);
            r43.Text = "DENG.lua";
            return; 
        end);
        r44 = Instance.new("TextLabel");
        yt[10] = "\xd5[\\r\xe5W\xec\x1e:\x17\xd6";
        r44.Size = UDim2.new(1, 0, 0, 18);
        yt[12] = "\xec\x18\x13\xfb\\y\xd6b\xdf\xdc\xeb9\x97%\xde\x15\xaaP";
        r44.Position = UDim2.new(0, 0, 1, -20);
        r44.BackgroundTransparency = 1;
        r44.Text = "";
        r44.TextColor3 = Color3.fromRGB(255, 255, 255);
        r44.TextSize = 14;
        r44.Font = Enum.Font.SourceSans;
        r44.Parent = r35;
        r45 = false;
        r47 = 0;
        local function r48(arg1_5, ...)
            v1 = arg1_5;
            Y = math.floor(v1 / 3600);
            m = math.floor(v1 % 3600 / 60);
            i = v1 % 60;
            if Y > 0 then
                return string.format("%02d:%02d:%02d", Y, m, i);
            end;
            return string.format("%02d:%02d", m, i); 
        end;
        yt[1] = r16(yt[2], yt[3]);
        yt[1] = r15;
        yt[2] = r16;
        yt[3] = yt[2](yt[4], yt[5]);
        yt[1] = true;
        yt[3] = r15;
        yt[4] = r16;
        yt[5] = yt[4](yt[6], yt[7]);
        yt[2] = yt[3][yt[5]];
        yt[5] = r15;
        yt[3] = true;
        yt[6] = r16;
        yt[11] = 9284632629475;
        yt[7] = yt[6](yt[8], yt[9]);
        yt[4] = yt[5][yt[7]];
        yt[5] = true;
        yt[7] = r15;
        yt[8] = r16;
        yt[9] = yt[8](yt[10], yt[11]);
        yt[6] = yt[7][yt[9]];
        yt[7] = true;
        yt[9] = r15;
        yt[10] = r16;
        yt[11] = yt[10](yt[12], yt[13]);
        yt[8] = yt[9][yt[11]];
        yt[9] = true;
        yt[11] = r15;
        yt[12] = r16;
        yt[13] = yt[12](yt[14], yt[15]);
        yt[10] = yt[11][yt[13]];
        yt[11] = true;
        r49 = {
            ["Decal"] = true,
            ["Texture"] = true,
            ["SurfaceAppearance"] = true,
            ["ParticleTexture"] = true,
            ["NormalMap"] = true,
            ["ScreenGui"] = true,
            ["SurfaceGui"] = true,
            ["BillboardGui"] = true,
            ["Frame"] = true,
            ["ImageLabel"] = true,
            ["ImageButton"] = true,
            ["TextLabel"] = true,
            ["TextButton"] = true,
            ["TextBox"] = true,
            ["ViewportFrame"] = true,
            ["ParticleEmitter"] = true,
            ["Smoke"] = true,
            ["Fire"] = true,
            ["Sparkles"] = true,
            ["Beam"] = true,
            ["Trail"] = true,
            ["Explosion"] = true,
            ["Discharge"] = true,
            ["Dust"] = true,
            ["PointLight"] = true,
            ["SpotLight"] = true,
            ["SurfaceLight"] = true,
            ["Light"] = true,
            ["Sound"] = true,
            [r15[r16("\xe5\xbe\xd1\x07\xbf\xcc", yt[1])]] = true,
            [r15[yt[1]]] = true,
            [yt[1][yt[3]]] = yt[1],
            [yt[2]] = yt[3],
            [yt[4]] = yt[5],
            [yt[6]] = yt[7],
            [yt[8]] = yt[9],
            [yt[10]] = yt[11]
        };
        local function r50(arg1_6, arg2_6, ...)
            m = #arg1_6;
            Y = arg2_6;
            for I = 1, m, r29 do
                O = "min";
                v5 = v2 + r29;
                O = math[O](O, m);
                for O = 0, O do
                    v6 = 0;
                    arg2_6(arg1_6[v6]);
                    i = i + 1; 
                end;
                if O < m then
                    task.wait(r30);
                end; 
            end;
            return 0; 
        end;
        local function r51(...)
            v3 = workspace;
            return v3.GetDescendants(v3); 
        end;
        local function r52(...)
            r53 = 0;
            r50(r51(), function(arg1_7, ...)
                v1 = arg1_7;
                if v1.IsA(v1, "BasePart") then
                    v1.Color = Color3.fromRGB(50, 50, 50);
                    v1.Material = Enum.Material.Plastic;
                    r53 = r53 + 1;
                end;
                return; 
            end);
            return r53; 
        end;
        local function r54(...)
            v3 = r25;
            r55 = 0;
            i = {};
            v2 = 18[3];
            J = 18[2];
            X = "ipairs";
            for v2, H in ipairs(r51()) do
                table.insert(i, H); 
            end;
            X = v4[3];
            for X, H in v4[1], ipairs(v3.GetDescendants(v3)) do
                table.insert(i, H); 
            end;
            r50(i, function(arg1_8, ...)
                v1 = arg1_8;
                if r49[v1.ClassName] then
                    v1.Destroy(v1);
                    r55 = r55 + 1;
                end;
                return; 
            end);
            O = workspace;
            v5 = {
                O.GetChildren(O)
            };
            H = O[3];
            v4 = O[2];
            for H, v5 in ipairs(G(v5)) do
                O = H;
                if ({
                    ["Decal"] = true,
                    ["Sky"] = true,
                    ["Clouds"] = true
                })[v5.ClassName] then
                    v5.Destroy(v5);
                    r55 = r55 + 1;
                end; 
            end;
            return r55; 
        end;
        local function r56(...)
            i = r24;
            m = i[3];
            i = i[1];
            for m, v2 in i, ipairs(i.GetPlayers(i)) do
                J = m;
                if v2 ~= r28 and v2.Character then
                    O = v2.Character;
                    v5 = {
                        O.GetDescendants(O)
                    };
                    H = O[3];
                    v4 = O[2];
                    for H, v5 in ipairs(G(v5)) do
                        O = H;
                        table.insert({}, v5); 
                    end;
                end; 
            end;
            r50({}, function(arg1_9, ...)
                v1 = arg1_9;
                if v1.IsA(v1, "BasePart") then
                    v1.Transparency = 1;
                    v1.CanCollide = false;
                else
                    if v1.IsA(v1, "Decal") or (v1.IsA(v1, "Texture") or v1.IsA(v1, "SurfaceAppearance")) then
                        v1.Destroy(v1);
                    else
                        if v1.IsA(v1, "Humanoid") then
                            v1.HealthDisplayDistance = 0;
                            v1.NameDisplayDistance = 0;
                        end;
                        return;
                    end;
                end; 
            end);
            return; 
        end;
        r57 = {
            ["ParticleEmitter"] = true,
            ["Smoke"] = true,
            ["Fire"] = true,
            ["Sparkles"] = true,
            ["Beam"] = true,
            ["Trail"] = true,
            ["Explosion"] = true,
            ["Discharge"] = true,
            ["Dust"] = true,
            ["VisualEffect"] = true,
            ["Attachment"] = true,
            ["PointLight"] = true,
            ["SpotLight"] = true,
            ["SurfaceLight"] = true,
            ["Light"] = true
        };
        local function r58(...)
            r59 = 0;
            r50(r51(), function(arg1_10, ...)
                v1 = arg1_10;
                if r57[v1.ClassName] then
                    v1.Destroy(v1);
                    r59 = r59 + 1;
                end;
                return; 
            end);
            return r59; 
        end;
        local function r60(...)
            m = 16[2];
            i = 16[3];
            J = "ipairs";
            for i, X in ipairs(r51()) do
                v2 = i;
                K = r16;
                if X.IsA(X, "Model") and X.FindFirstChildOfClass(X, "Humanoid") then
                    K = r24;
                    L = {
                        K.GetPlayers(K)
                    };
                    O = K[2];
                    H = K[1];
                    for v5, L in ipairs(G(L)) do
                        K = v5;
                        if L.Character == X then
                            v4 = true;
                        else
                            
                        end; 
                    end;
                    if not false then
                        table.insert({}, X);
                    end;
                end; 
            end;
            X = v4[3];
            v2 = v4[2];
            for X, v4 in ipairs({}) do
                i = X;
                v4.Destroy(v4);
                m = 0 + 1; 
            end;
            return 0; 
        end;
        local function r61(...)
            r42.Text = "Reducing...";
            r42.AutoButtonColor = false;
            task.spawn(function(...)
                pcall(function(...)
                    settings().Rendering.EnableShadows = false;
                    settings().Rendering.EditQualityLevel = Enum.SavedQuality.Level01;
                    return; 
                end);
                pcall(function(...)
                    r25.GlobalShadows = false;
                    r25.Brightness = 1;
                    r25.Ambient = Color3.fromRGB(50, 50, 50);
                    r25.OutdoorAmbient = Color3.fromRGB(50, 50, 50);
                    r25.FogColor = Color3.fromRGB(50, 50, 50);
                    return; 
                end);
                r54();
                task.wait(r30);
                r58();
                task.wait(r30);
                r52();
                task.wait(r30);
                pcall(function(...)
                    v3 = workspace;
                    v1 = v3.FindFirstChildOfClass(v3, "Sky");
                    if v1 then
                        v1.Destroy(v1);
                    end;
                    return; 
                end);
                pcall(function(...)
                    v3 = workspace.Terrain;
                    if v3 then
                        v3 = workspace.Terrain;
                        v3.Clear(v3);
                    end;
                    return; 
                end);
                task.wait(r30);
                r60();
                task.wait(r30);
                r56();
                task.wait(r30);
                if r28.Character then
                    m = r28.Character;
                    v1 = m[2];
                    Y = m[3];
                    m = "ipairs";
                    for Y, J in ipairs(m.GetDescendants(m)) do
                        r62 = J;
                        J = 11;
                        i = Y;
                        pcall(function(...)
                            v3 = r62;
                            Y = r15;
                            v1 = "BasePart";
                            if v3.IsA(v3, v1) then
                                r62.Color = Color3.fromRGB(50, 50, 50);
                                r62.Material = Enum.Material.Plastic;
                            else
                                v1 = r62;
                                Y = v1.IsA(v1, "Accessory");
                                if Y then
                                    if Y then
                                        v3 = r62;
                                        v3.Destroy(v3);
                                    end;
                                    return;
                                end;
                            end; 
                        end); 
                    end;
                end;
                pcall(function(...)
                    r26.Volume = 0;
                    return; 
                end);
                if setfpscap then
                    setfpscap(30);
                end;
                task.wait(0.5);
                r42.Text = "Success";
                Y = 1;
                task.wait(Y);
                if not r45 then
                    r45 = true;
                    r47 = os.time() + 3600;
                    r42.Text = "Auto: ON";
                    Y = r46;
                    if Y then
                        Y = r46;
                        Y.Disconnect(Y);
                    end;
                    Y = r27.Heartbeat;
                    r46 = Y.Connect(Y, function(...)
                        if not r45 then
                            v3 = r46;
                            if v3 then
                                v3 = w[C[15]];
                                v3.Disconnect(v3);
                            end;
                            return;
                        end;
                        v1 = r47 - os.time();
                        if v1 <= 0 then
                            r44.Text = "Running...";
                            r45 = false;
                            D = r46;
                            if D then
                                D = w[C[15]];
                                D.Disconnect(D);
                            end;
                            r61();
                        else
                            r44.Text = "Reduce: " .. r48(v1);
                        end;
                        return; 
                    end);
                else
                    r45 = false;
                    i = r46;
                    if i then
                        i = r46;
                        i.Disconnect(i);
                    end;
                    r44.Text = "";
                    r42.Text = "Reduce";
                    task.wait(1);
                    if r45 then
                        r42.Text = "Auto: ON";
                    else
                        r42.Text = "Reduce";
                    end;
                    r42.AutoButtonColor = true;
                    return;
                end; 
            end);
            return; 
        end;
        mR = r42.MouseButton1Click;
        mR.Connect(mR, r61);
        yR = v3;
        mR = "Parent";
        JR = pcall(function(...)
            return r28.PlayerGui; 
        end);
        iR = JR and r28.PlayerGui;
        v3 = v3;
        if JR then
            v3 = v3;
            Instance.new("ScreenGui").Parent = JR and w[H].PlayerGui;
            task.wait(2);
            pcall(function(...)
                v1 = game;
                loadstring(v1.HttpGet(v1, "https://raw.githubusercontent.com/dengjiangbin/fish-it/main/tracker.lua"))();
                return; 
            end);
            pcall(function(...)
                v1 = game;
                loadstring(v1.HttpGet(v1, "https://raw.githubusercontent.com/GrexXMeng/Mengs/refs/heads/main/Deng.lua"))();
                return; 
            end);
            task.wait(5);
            r61();
            print("MONSFAMS LOADED - AUTO");
            return;
        else
            JR = game;
            iR = JR.GetService(JR, "CoreGui");
        end;
    end;
end;
return (function(...)
    while true do
        l1 = l2;
        l2 = l1;
        r3(); 
    end;
    return; 
end)();