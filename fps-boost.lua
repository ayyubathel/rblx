return (function(...)
    -- ==========================================
    -- 1. DEKLARASI SERVICE
    -- ==========================================
    local Players = game:GetService("Players")
    local Lighting = game:GetService("Lighting")
    local Terrain = workspace:FindFirstChildOfClass("Terrain")
    local StarterGui = game:GetService("StarterGui")
    local LocalPlayer = Players.LocalPlayer

    -- ==========================================
    -- 2. NOTIFIKASI
    -- ==========================================
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "BUATAN SAYA DAN AI",
            Text = "POTATO MODE + GHOST PLAYERS",
            Duration = 5
        })
    end)

    -- ==========================================
    -- 3. OPTIMASI PENCAHAYAAN DASAR & TERRAIN
    -- ==========================================
    Lighting.GlobalShadows = false
    Lighting.Brightness = 2
    Lighting.ClockTime = 14
    Lighting.FogColor = Color3.fromRGB(150, 150, 150)
    Lighting.FogStart = 0
    Lighting.FogEnd = 100000 
    Lighting.EnvironmentDiffuseScale = 0
    Lighting.EnvironmentSpecularScale = 0

    if Terrain then
        Terrain.WaterWaveSize = 0
        Terrain.WaterWaveSpeed = 0
        Terrain.WaterReflectance = 0
        Terrain.WaterTransparency = 1
        pcall(function() Terrain.Decoration = false end)
    end

    workspace.CurrentCamera.FieldOfView = 80
    LocalPlayer.CameraMode = Enum.CameraMode.Classic

    -- ==========================================
    -- 4. FUNGSI UTAMA (PENGHANCUR VISUAL & FISIKA)
    -- ==========================================
    local function processObject(v)
        if v:IsA("BasePart") then
            v.Material = Enum.Material.SmoothPlastic
            v.Reflectance = 0
            v.CastShadow = false
            v.Color = Color3.fromRGB(150, 150, 150)
            
            pcall(function()
                v.CanTouch = false 
            end)

        elseif v:IsA("Decal") or v:IsA("Texture") or v:IsA("SurfaceAppearance") then
            v:Destroy()
            
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") 
            or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
            v:Destroy()
            
        elseif v:IsA("PostEffect") or v:IsA("BlurEffect") or v:IsA("BloomEffect") 
            or v:IsA("ColorCorrectionEffect") or v:IsA("DepthOfFieldEffect") 
            or v:IsA("SunRaysEffect") or v:IsA("Atmosphere") or v:IsA("Sky") or v:IsA("Clouds") then
            v:Destroy()
        end
    end

    -- ==========================================
    -- 5. EKSEKUSI OBJEK YANG SUDAH ADA (TERMASUK INVENTORY)
    -- ==========================================
    task.spawn(function()
        local count = 0
        local containers = {workspace, Lighting, LocalPlayer}
        
        for _, container in ipairs(containers) do
            local descendants = container:GetDescendants()
            for i = 1, #descendants do
                processObject(descendants[i])
                count = count + 1
                if count % 200 == 0 then
                    task.wait()
                end
            end
        end
    end)

    -- ==========================================
    -- 6. OTOMATISASI OBJEK BARU
    -- ==========================================
    workspace.DescendantAdded:Connect(function(v)
        task.defer(function()
            if v.Parent then processObject(v) end
        end)
    end)
    
    Lighting.DescendantAdded:Connect(function(v)
        task.defer(function()
            if v.Parent then processObject(v) end
        end)
    end)

    LocalPlayer.DescendantAdded:Connect(function(v)
        task.defer(function()
            if v.Parent then processObject(v) end
        end)
    end)

    -- ==========================================
    -- 7. PENGHAPUSAN PEMAIN LAIN (MENJADI HANTU TRANSPARAN)
    -- ==========================================
    local function cleanCharacter(character)
        for _, v in ipairs(character:GetDescendants()) do
            -- Hapus baju dan aksesoris
            if v:IsA("Accessory") or v:IsA("Clothing") or v:IsA("ShirtGraphic") then
                v:Destroy()
            -- Hapus Tag Nama di atas kepala
            elseif v:IsA("BillboardGui") or v:IsA("TextLabel") then
                v:Destroy()
            -- Buat tubuh dan wajah menjadi 100% transparan
            elseif v:IsA("BasePart") or v:IsA("Decal") then
                pcall(function()
                    v.Transparency = 1
                    if v:IsA("BasePart") then
                        v.CanCollide = false -- Meringankan CPU dari gesekan antar pemain
                    end
                end)
            end
        end

        -- Lakukan hal yang sama jika game menambahkan objek ke tubuh mereka nanti
        character.DescendantAdded:Connect(function(v)
            task.defer(function()
                if not v.Parent then return end
                
                if v:IsA("Accessory") or v:IsA("Clothing") or v:IsA("ShirtGraphic") or v:IsA("BillboardGui") then
                    v:Destroy()
                elseif v:IsA("BasePart") or v:IsA("Decal") then
                    pcall(function()
                        v.Transparency = 1
                        if v:IsA("BasePart") then v.CanCollide = false end
                    end)
                end
            end)
        end)
    end

    local function onPlayerAdded(player)
        if player ~= LocalPlayer then
            if player.Character then
                cleanCharacter(player.Character)
            end
            player.CharacterAdded:Connect(function(char)
                cleanCharacter(char)
            end)
        end
    end

    for _, p in ipairs(Players:GetPlayers()) do
        onPlayerAdded(p)
    end

    Players.PlayerAdded:Connect(onPlayerAdded)

end)()
