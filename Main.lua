--[[ Oc1DvHUB × MOURGE SHIFT HALLOWEEN EDITION — FINAL
     UI: Custom Oc1DvHUB
     Tabs: RUMAH, COLLECT, ESP, TELEPORT, EVENT, MISC, TEMA, CREDITS
     Update: Auto Scan Item + Pumpkin + Multi Method Collect + Fix Hold/Skip
]]
print("[Oc1DvHUB] Loading Halloween Edition FINAL...")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Stats = game:GetService("Stats")
local MPS = game:GetService("MarketplaceService")
local LP = Players.LocalPlayer

local CONFIG = {
    DISCORD = "https://discord.gg/wtVKkDvyz",
    LOGO = "rbxassetid://78682047053280",
    SND = "rbxassetid://7405483764",
    BG = "rbxassetid://71753681160488",
}

local BG_LIST = {
    {name = "HALLOWEEN", id = "rbxassetid://71753681160488"},
    {name = "UTAMA", id = "rbxassetid://124159830401488"},
    {name = "LANSKYP", id = "rbxassetid://70693066629625"},
    {name = "LUFFY", id = "rbxassetid://77692656015127"},
    {name = "TEXT", id = "rbxassetid://136619070579232"},
    {name = "MBG BLUE", id = "rbxassetid://75442560708193"},
}

local IC = {
    Collect = "rbxassetid://10734950020",
    ESP = "rbxassetid://10734950309",
    TP = "rbxassetid://10734942198",
    Event = "rbxassetid://10734961809",
    Misc = "rbxassetid://10734961809",
    Rumah = "rbxassetid://10734950020",
    Tema = "rbxassetid://10734961809",
    Credits = "rbxassetid://10734950309",
}

local C = {
    Pri = Color3.fromRGB(255, 145, 80),
    PriDark = Color3.fromRGB(210, 110, 55),
    Bg = Color3.fromRGB(24, 24, 28),
    Panel = Color3.fromRGB(34, 34, 40),
    Card = Color3.fromRGB(44, 44, 52),
    Txt = Color3.fromRGB(240, 240, 245),
    Dim = Color3.fromRGB(150, 150, 160),
    Off = Color3.fromRGB(70, 70, 78),
    Red = Color3.fromRGB(255, 100, 110),
    Grn = Color3.fromRGB(110, 220, 140),
    Yel = Color3.fromRGB(255, 210, 110),
    Cyn = Color3.fromRGB(110, 200, 245),
    Pur = Color3.fromRGB(191, 90, 242),
    Orng = Color3.fromRGB(255, 165, 0),
    Stroke = Color3.fromRGB(255,255,255),
}

local S = {
    StartTime = os.time(),
    GameName = "Loading...",
    curBG = 1,
    selBG = 1,
    HueColor = C.Pri,
    BGBrightness = 0.55,
    MiniMode = true,
    FPRunning = false,
}

local colorEls = {}
local function track(obj, prop) table.insert(colorEls, {obj = obj, prop = prop}) end
local function applyColor(newC)
    C.Pri = newC
    C.PriDark = Color3.new(newC.R*0.82, newC.G*0.82, newC.B*0.82)
    for _, e in ipairs(colorEls) do
        if e.obj and e.obj.Parent then
            pcall(function() e.obj[e.prop] = newC end)
        end
    end
end

local searchables = {}
local function trackSearch(frame, text)
    frame:SetAttribute("SearchText", string.lower(text))
    table.insert(searchables, frame)
end

local pg = LP:WaitForChild("PlayerGui", 10) or game:GetService("CoreGui")
local old = pg:FindFirstChild("Oc1DvHUB_UI")
if old then old:Destroy() end

task.spawn(function()
    local ok, info = pcall(function() return MPS:GetProductInfo(game.PlaceId) end)
    S.GameName = (ok and info and info.Name) or "Unknown"
end)

local function sfx()
    pcall(function()
        local s = Instance.new("Sound")
        s.SoundId = CONFIG.SND; s.Volume = 0.25; s.Parent = pg
        s:Play(); Debris:AddItem(s, 2)
    end)
end

local NotifyUser
local Log

-- ═══════════════════════════════════════════════════════════
-- STATE
-- ═══════════════════════════════════════════════════════════
local State = {
    AutoCollect = true,
    AutoTP = true,
    CollectInterval = 1,
    MaxDistance = 500,
    ItemKeyword = "TrickOrTreatItem",
    TPSettleDelay = 0.3,
    CollectDelay = 0.2,
    MaxPerCycle = 5,

    AutoCollectPumpkin = true,
    PumpkinTP = true,
    PumpkinInterval = 1,
    PumpkinMaxDistance = 500,
    PumpkinMaxPerCycle = 5,

    ItemESP = true,
    PumpkinESP = true,
    ReaperESP = true,
    GhostESP = false,
    ShowDistance = true,

    FirePrompt = true,
    NoDelay = true,

    AntiAFK = true,
    AntiAFKInterval = 60,

    GodMode = false,
    DesyncRadius = 30,
    DesyncTPDistance = 500,

    Invisible = false,
    Noclip = false,

    WalkSpeedEnabled = false,
    WalkSpeedValue = 16,
}

local StatsData = {
    ItemsFound = 0,
    ItemsCollected = 0,
    ItemsSpawned = 0,
    PumpkinsFound = 0,
    PumpkinsCollected = 0,
    PumpkinsSpawned = 0,
    ReapersFound = 0,
    GhostsFound = 0,
    AFKTicks = 0,
    DesyncCount = 0,
}

local itemCache = {}
local pumpkinCache = {}
local reaperCache = {}
local ghostCache = {}
local countedItems = {}
local countedPumpkins = {}
local lastSeenItems = {}
local lastSeenPumpkins = {}

-- ═══════════════════════════════════════════════════════════
-- TP LOCATIONS
-- ═══════════════════════════════════════════════════════════
local TP_LOCATIONS = {
    {name = "Ambil Jenazah", pos = Vector3.new(56.62, 4.65, -70.89), category = "LOBBY BAWAH"},
    {name = "Autopsy Room", pos = Vector3.new(72.55, 4.65, -57.78), category = "LOBBY BAWAH"},
    {name = "Cremation Room", pos = Vector3.new(36.62, 4.65, -55.07), category = "LOBBY BAWAH"},
    {name = "Morgue / Freeze Room", pos = Vector3.new(22.62, 4.65, -38.59), category = "LOBBY BAWAH"},
    {name = "Sterilization Room", pos = Vector3.new(89.32, 4.65, -43.71), category = "LOBBY BAWAH"},
    {name = "Storage Room", pos = Vector3.new(78.08, 17.65, -37.13), category = "LOBBY ATAS"},
    {name = "Embalming Room", pos = Vector3.new(32.42, 17.65, -24.84), category = "LOBBY ATAS"},
    {name = "Electric Room", pos = Vector3.new(28.48, 17.65, -58.53), category = "LOBBY ATAS"},
    {name = "Tempat Berduka", pos = Vector3.new(56.73, 17.75, -40.54), category = "LOBBY ATAS"},
    {name = "Kamar 101", pos = Vector3.new(28.42, 30.65, -69.55), category = "LANTAI 1"},
    {name = "Kamar 102", pos = Vector3.new(45.02, 30.65, -69.68), category = "LANTAI 1"},
    {name = "Kamar 103", pos = Vector3.new(69.10, 30.65, -68.18), category = "LANTAI 1"},
    {name = "Kamar 104", pos = Vector3.new(85.81, 30.65, -69.92), category = "LANTAI 1"},
    {name = "Kamar 105", pos = Vector3.new(83.51, 30.65, -43.62), category = "LANTAI 1"},
    {name = "Kamar 106", pos = Vector3.new(69.65, 30.65, -42.30), category = "LANTAI 1"},
    {name = "Kamar 107", pos = Vector3.new(43.51, 30.65, -42.08), category = "LANTAI 1"},
    {name = "Kamar 108", pos = Vector3.new(28.18, 30.65, -41.82), category = "LANTAI 1"},
    {name = "Kamar 201", pos = Vector3.new(29.22, 43.65, -70.04), category = "LANTAI 2"},
    {name = "Kamar 202", pos = Vector3.new(45.28, 43.65, -69.55), category = "LANTAI 2"},
    {name = "Kamar 203", pos = Vector3.new(70.57, 43.65, -69.77), category = "LANTAI 2"},
    {name = "Kamar 204", pos = Vector3.new(86.70, 43.65, -70.00), category = "LANTAI 2"},
    {name = "Kamar 205", pos = Vector3.new(42.23, 43.65, -41.67), category = "LANTAI 2"},
    {name = "Kamar 206", pos = Vector3.new(27.39, 43.65, -41.69), category = "LANTAI 2"},
    {name = "Archives Room", pos = Vector3.new(43.78, 56.65, -27.24), category = "LANTAI 3"},
    {name = "Kamar 301", pos = Vector3.new(30.26, 56.65, -69.43), category = "LANTAI 3"},
    {name = "Kamar 302", pos = Vector3.new(45.47, 56.65, -69.29), category = "LANTAI 3"},
    {name = "Kamar 303", pos = Vector3.new(70.20, 56.65, -70.11), category = "LANTAI 3"},
    {name = "Kamar 304", pos = Vector3.new(86.42, 56.65, -69.70), category = "LANTAI 3"},
    {name = "Kamar 305", pos = Vector3.new(42.37, 56.65, -41.27), category = "LANTAI 3"},
    {name = "Kamar 306", pos = Vector3.new(26.33, 56.65, -42.68), category = "LANTAI 3"},
    {name = "Lantai 4", pos = Vector3.new(58.29, 69.65, -22.85), category = "LANTAI 4"},
}

-- ═══════════════════════════════════════════════════════════
-- HELPERS
-- ═══════════════════════════════════════════════════════════
local function getHRP()
    local c = LP.Character
    return c and (c:FindFirstChild("HumanoidRootPart")
                or c:FindFirstChild("Torso")
                or c:FindFirstChild("UpperTorso"))
end

local function getHum()
    local c = LP.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function getPart(obj)
    if not obj or not obj.Parent then return nil end
    if obj:IsA("BasePart") then return obj end
    if obj:IsA("Model") then
        return obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
    end
    return nil
end

local function doAntiAFK()
    pcall(function()
        local vu = game:GetService("VirtualUser")
        vu:CaptureController()
        vu:ClickButton2(Vector2.new())
        StatsData.AFKTicks += 1
    end)
end

task.spawn(function()
    while true do
        task.wait(State.AntiAFKInterval)
        if State.AntiAFK then doAntiAFK() end
    end
end)

pcall(function()
    LP.Idled:Connect(function()
        if State.AntiAFK then doAntiAFK() end
    end)
end)

task.spawn(function()
    while true do
        task.wait(0.2)
        local c = LP.Character
        if c then
            for _, p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") then
                    if State.Invisible then
                        p.LocalTransparencyModifier = 1
                        p.Transparency = 1
                    else
                        p.LocalTransparencyModifier = 0
                        p.Transparency = 0
                    end
                    if State.Noclip or State.Invisible then
                        p.CanCollide = false
                    else
                        p.CanCollide = true
                    end
                end
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════
-- SCAN ITEM
-- ═══════════════════════════════════════════════════════════
local ITEM_KEYWORDS = {
    "trickortreatitem", "trickortreat", "trick_or_treat",
    "trick", "treat", "candy", "candies", "sweet",
    "halloweenitem", "eventitem", "collectitem", "pickupitem",
    "trickortreatltem",
}

local ITEM_BLACKLIST = {
    "prompt", "ui", "gui", "shop", "sign", "spawner",
    "spawn", "effect", "sound", "particle", "highlight",
    "button", "text", "label", "screen", "folder",
}

local function isItemBlacklisted(name)
    local low = name:lower()
    for _, bl in ipairs(ITEM_BLACKLIST) do
        if low:find(bl, 1, true) then return true end
    end
    return false
end

local function isItemName(name)
    local low = name:lower()
    for _, kw in ipairs(ITEM_KEYWORDS) do
        if low:find(kw, 1, true) then
            return true
        end
    end
    return false
end

local function scanItems()
    local found = {}
    local seen = {}
    pcall(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if seen[obj] then continue end
            if isItemBlacklisted(obj.Name) then continue end

            if isItemName(obj.Name) then
                local part = nil
                if obj:IsA("BasePart") then
                    part = obj
                elseif obj:IsA("Model") then
                    part = obj.PrimaryPart
                        or obj:FindFirstChildWhichIsA("BasePart")
                        or obj:FindFirstChild("HumanoidRootPart", true)
                elseif obj:IsA("Tool") then
                    part = obj:FindFirstChildWhichIsA("BasePart")
                    if not part and obj.Parent and obj.Parent:IsA("Backpack") then
                        continue
                    end
                elseif obj:IsA("Folder") then
                    part = obj:FindFirstChildWhichIsA("BasePart", true)
                    if part then
                        local model = part:FindFirstAncestorOfClass("Model") or obj
                        if not seen[model] then
                            seen[model] = true
                            table.insert(found, {model = model, part = part, source = obj.Name})
                        end
                        continue
                    end
                end

                if part and part.Parent then
                    local root = part:FindFirstAncestorOfClass("Model") or obj
                    if not seen[root] then
                        seen[root] = true
                        table.insert(found, {model = root, part = part, source = obj.Name})
                    end
                end
            end
        end
    end)
    return found
end

-- ═══════════════════════════════════════════════════════════
-- SCAN PUMPKIN
-- ═══════════════════════════════════════════════════════════
local PUMPKIN_KEYWORDS = {
    "spookypumpkin", "spooky_pumpkin", "spooky pumpkin",
    "pumpkin", "pumkin", "jacko", "jackolantern", "jack_o_lantern",
    "halloweenpumpkin", "pumpkinitem", "pumpkin_item",
}

local PUMPKIN_BLACKLIST = {
    "prompt", "ui", "gui", "shop", "sign", "spawner",
    "spawn", "effect", "sound", "particle", "highlight",
    "button", "text", "label", "screen", "folder", "decal",
    "texture", "mesh", "light", "beam", "trail",
}

local function isPumpkinBlacklisted(name)
    local low = name:lower()
    for _, bl in ipairs(PUMPKIN_BLACKLIST) do
        if low:find(bl, 1, true) then return true end
    end
    return false
end

local function isPumpkinName(name)
    local low = name:lower()
    for _, kw in ipairs(PUMPKIN_KEYWORDS) do
        if low:find(kw, 1, true) then
            return true
        end
    end
    return false
end

local function scanPumpkins()
    local found = {}
    local seen = {}
    pcall(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if seen[obj] then continue end
            if isPumpkinBlacklisted(obj.Name) then continue end

            if isPumpkinName(obj.Name) then
                local part = nil
                if obj:IsA("BasePart") or obj:IsA("MeshPart") then
                    part = obj
                elseif obj:IsA("Model") then
                    part = obj.PrimaryPart
                        or obj:FindFirstChildWhichIsA("BasePart")
                        or obj:FindFirstChildWhichIsA("MeshPart")
                elseif obj:IsA("Tool") then
                    part = obj:FindFirstChildWhichIsA("BasePart")
                    if not part and obj.Parent and obj.Parent:IsA("Backpack") then
                        continue
                    end
                elseif obj:IsA("Folder") then
                    part = obj:FindFirstChildWhichIsA("BasePart", true)
                    if part then
                        local model = part:FindFirstAncestorOfClass("Model") or obj
                        if not seen[model] then
                            seen[model] = true
                            table.insert(found, {model = model, part = part, source = obj.Name})
                        end
                        continue
                    end
                end

                if part and part.Parent then
                    local root = part:FindFirstAncestorOfClass("Model") or obj
                    if not seen[root] then
                        seen[root] = true
                        table.insert(found, {model = root, part = part, source = obj.Name})
                    end
                end
            end
        end
    end)
    return found
end

-- ═══════════════════════════════════════════════════════════
-- SCAN REAPER & GHOST
-- ═══════════════════════════════════════════════════════════
local function scanReapers()
    local found = {}
    pcall(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") then
                local n = obj.Name:lower()
                if (n:find("reaper") or n:find("death") or n:find("grim"))
                   and not Players:GetPlayerFromCharacter(obj) then
                    local part = getPart(obj)
                    if part then table.insert(found, {model = obj, part = part}) end
                end
            end
        end
    end)
    return found
end

local GHOST_KEYWORDS = {
    "ghost", "hantu", "spirit", "phantom", "wraith", "soul",
    "specter", "spectre", "haunt", "poltergeist", "banshee",
    "revenant", "demon", "devil", "monster", "zombie",
    "skeleton", "skull", "shadow", "nightmare", "undead", "curse"
}
local GHOST_BLACKLIST = {
    "ghostbuster", "ghost_shop", "ghostsign", "ghost_ui",
    "soulmate", "soul_shop", "console", "shining", "souvenir"
}
local function isBlacklisted(name)
    local low = name:lower()
    for _, bl in ipairs(GHOST_BLACKLIST) do
        if low:find(bl, 1, true) then return true end
    end
    return false
end
local function isGhostName(name)
    local low = name:lower()
    for _, kw in ipairs(GHOST_KEYWORDS) do
        if low == kw
           or low:find("^" .. kw .. "_")
           or low:find("^" .. kw .. " ")
           or low:find(" " .. kw .. " ")
           or low:find(" " .. kw .. "$")
           or low:find("^" .. kw .. "$") then
            return true
        end
    end
    return false
end
local function scanGhosts()
    local found = {}
    local seen = {}
    pcall(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") then
                if not Players:GetPlayerFromCharacter(obj) then
                    local n = obj.Name
                    if not isBlacklisted(n) and isGhostName(n) then
                        local hum = obj:FindFirstChildOfClass("Humanoid")
                        if hum and hum.Health > 0 then
                            if not seen[obj] then
                                seen[obj] = true
                                local part = getPart(obj)
                                if part then
                                    table.insert(found, {model = obj, part = part, name = n})
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
    return found
end

-- GOD MODE DESYNC
local function getNearestGhost(maxRadius)
    local hrp = getHRP()
    if not hrp then return nil end
    local ghosts = scanGhosts()
    local nearest, minDist = nil, math.huge
    for _, g in ipairs(ghosts) do
        local dist = (g.part.Position - hrp.Position).Magnitude
        if dist < minDist then
            minDist = dist
            nearest = g
        end
    end
    if nearest and minDist <= maxRadius then
        nearest.dist = minDist
        return nearest
    end
    return nil
end

task.spawn(function()
    while true do
        task.wait(0.05)
        if State.GodMode then
            local hrp = getHRP()
            if hrp then
                local ghost = getNearestGhost(State.DesyncRadius)
                if ghost then
                    if getconnections then
                        for _, obj in ipairs(ghost.model:GetDescendants()) do
                            if obj:IsA("BasePart") then
                                for _, conn in ipairs(getconnections(obj.Touched)) do
                                    if conn.Disable then conn:Disable() end
                                end
                            end
                        end
                    end
                    local myPos = hrp.Position
                    local gPos = ghost.part.Position
                    local dir = (myPos - gPos)
                    if dir.Magnitude > 0 then dir = dir.Unit else dir = Vector3.new(1, 0, 0) end
                    pcall(function()
                        hrp.CFrame = CFrame.new(gPos + (dir * State.DesyncTPDistance))
                    end)
                    StatsData.DesyncCount += 1
                end
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.3)
        if State.WalkSpeedEnabled then
            local hum = getHum()
            if hum and math.abs(hum.WalkSpeed - State.WalkSpeedValue) > 0.5 then
                hum.WalkSpeed = State.WalkSpeedValue
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════
-- FIX HOLD/SKIP BUTTON
-- ═══════════════════════════════════════════════════════════
local function forceNoDelayPrompt(obj)
    if obj:IsA("ProximityPrompt") and State.NoDelay then
        pcall(function()
            obj.HoldDuration = 0
            obj.MaxActivationDistance = 9e9
            obj.Enabled = true
        end)
    end
end

pcall(function()
    for _, obj in ipairs(workspace:GetDescendants()) do
        forceNoDelayPrompt(obj)
    end
end)

workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("ProximityPrompt") and State.NoDelay then
        task.wait(0.05)
        forceNoDelayPrompt(obj)
    end
end)

local function firePrompt(prompt)
    if not prompt or not fireproximityprompt then return false end
    local ok = false
    pcall(function()
        local old = prompt.HoldDuration
        prompt.HoldDuration = 0
        prompt.MaxActivationDistance = 9e9
        prompt.Enabled = true
        fireproximityprompt(prompt, 0)
        task.wait(0.05)
        if not State.NoDelay then prompt.HoldDuration = old end
        ok = true
    end)
    return ok
end

-- ═══════════════════════════════════════════════════════════
-- COLLECT ITEM (Multi Method)
-- ═══════════════════════════════════════════════════════════
local function collectItem(data)
    if not data or not data.part or not data.part.Parent then return false end
    local part = data.part
    local model = data.model
    local success = false

    local prompt = model:FindFirstChildWhichIsA("ProximityPrompt", true)
    if not prompt and part then
        prompt = part:FindFirstChildWhichIsA("ProximityPrompt")
    end
    if prompt then
        pcall(function()
            prompt.MaxActivationDistance = 9e9
            prompt.Enabled = true
            if State.NoDelay then prompt.HoldDuration = 0 end
        end)
        if State.FirePrompt then
            pcall(function()
                fireproximityprompt(prompt, 0)
                success = true
            end)
        end
    end

    local cd = model:FindFirstChildWhichIsA("ClickDetector", true)
    if not cd and part then
        cd = part:FindFirstChildWhichIsA("ClickDetector")
    end
    if cd and fireclickdetector then
        pcall(function()
            fireclickdetector(cd)
            success = true
        end)
    end

    local hrp = getHRP()
    if hrp and firetouchinterest then
        pcall(function()
            firetouchinterest(hrp, part, 0)
            task.wait(0.02)
            firetouchinterest(hrp, part, 1)
            success = true
        end)
    end

    if not success then
        pcall(function()
            for _, obj in ipairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
                if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                    local n = obj.Name:lower()
                    if n:find("collect") or n:find("pickup") or n:find("trick")
                       or n:find("treat") or n:find("pumpkin") then
                        pcall(function() obj:FireServer(part) end)
                        pcall(function() obj:InvokeServer(part) end)
                        success = true
                    end
                end
            end
        end)
    end

    return success
end

-- ESP
local function createHL(model, color, name)
    if not model or not model.Parent then return end
    local e = model:FindFirstChild(name)
    if e then e:Destroy() end
    local hl = Instance.new("Highlight")
    hl.Name = name
    hl.FillColor = color
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency = 0.6
    hl.OutlineTransparency = 0.1
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee = model
    hl.Parent = model
end

local function createTag(part, label, color, tagName)
    if not part or not part.Parent then return end
    local e = part:FindFirstChild(tagName)
    if e then e:Destroy() end
    local bb = Instance.new("BillboardGui")
    bb.Name = tagName
    bb.Size = UDim2.fromOffset(200, 40)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.AlwaysOnTop = true
    bb.Adornee = part
    local lbl = Instance.new("TextLabel", bb)
    lbl.Name = "NameLbl"
    lbl.Size = UDim2.new(1, 0, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = color
    lbl.TextStrokeTransparency = 0
    lbl.TextStrokeColor3 = Color3.new(0, 0, 0)
    lbl.TextSize = 14
    lbl.Font = Enum.Font.GothamBold
    local dLbl = Instance.new("TextLabel", bb)
    dLbl.Name = "DistLbl"
    dLbl.Size = UDim2.new(1, 0, 0, 16)
    dLbl.Position = UDim2.new(0, 0, 0, 22)
    dLbl.BackgroundTransparency = 1
    dLbl.Text = "---"
    dLbl.TextColor3 = Color3.new(1, 1, 1)
    dLbl.TextStrokeTransparency = 0
    dLbl.TextStrokeColor3 = Color3.new(0, 0, 0)
    dLbl.TextSize = 12
    dLbl.Font = Enum.Font.GothamBold
    bb.Parent = part
end

local function removeESP(model)
    if not model then return end
    for _, c in ipairs(model:GetChildren()) do
        if c.Name == "ItemESP_HL" or c.Name == "PumpkinESP_HL"
           or c.Name == "ReaperESP_HL" or c.Name == "GhostESP_HL" then c:Destroy() end
    end
    for _, p in ipairs(model:GetDescendants()) do
        if p:IsA("BasePart") then
            local t1 = p:FindFirstChild("ItemESP_Tag")
            local t2 = p:FindFirstChild("PumpkinESP_Tag")
            local t3 = p:FindFirstChild("ReaperESP_Tag")
            local t4 = p:FindFirstChild("GhostESP_Tag")
            if t1 then t1:Destroy() end
            if t2 then t2:Destroy() end
            if t3 then t3:Destroy() end
            if t4 then t4:Destroy() end
        end
    end
end

-- AUTO COLLECT ITEM LOOP
task.spawn(function()
    while true do
        task.wait(State.CollectInterval)
        if State.AutoCollect then
            local items = scanItems()
            local hrp = getHRP()
            if #items > 0 and hrp then
                for _, d in ipairs(items) do
                    d.dist = (d.part.Position - hrp.Position).Magnitude
                end
                table.sort(items, function(a, b) return a.dist < b.dist end)
                local collected = 0
                for _, d in ipairs(items) do
                    if d.dist <= State.MaxDistance and collected < State.MaxPerCycle then
                        if State.AutoTP and d.dist > 5 then
                            pcall(function()
                                hrp.CFrame = CFrame.new(d.part.Position + Vector3.new(0, 3, 0))
                            end)
                            task.wait(State.TPSettleDelay)
                        end
                        if collectItem(d) then
                            if not countedItems[d.model] then
                                countedItems[d.model] = true
                                StatsData.ItemsCollected += 1
                                if NotifyUser then
                                    NotifyUser("Collected", "TrickOrTreatItem collected!", "success")
                                end
                            end
                            collected += 1
                            task.wait(State.CollectDelay)
                        end
                    end
                end
            end
        end
    end
end)

-- AUTO COLLECT PUMPKIN LOOP
task.spawn(function()
    while true do
        task.wait(State.PumpkinInterval)
        if State.AutoCollectPumpkin then
            local pumpkins = scanPumpkins()
            local hrp = getHRP()
            if #pumpkins > 0 and hrp then
                for _, d in ipairs(pumpkins) do
                    d.dist = (d.part.Position - hrp.Position).Magnitude
                end
                table.sort(pumpkins, function(a, b) return a.dist < b.dist end)
                local collected = 0
                for _, d in ipairs(pumpkins) do
                    if d.dist <= State.PumpkinMaxDistance and collected < State.PumpkinMaxPerCycle then
                        if State.PumpkinTP and d.dist > 5 then
                            pcall(function()
                                hrp.CFrame = CFrame.new(d.part.Position + Vector3.new(0, 3, 0))
                            end)
                            task.wait(State.TPSettleDelay)
                        end
                        if collectItem(d) then
                            if not countedPumpkins[d.model] then
                                countedPumpkins[d.model] = true
                                StatsData.PumpkinsCollected += 1
                                if NotifyUser then
                                    NotifyUser("Pumpkin", "Pumpkin collected!", "success")
                                end
                            end
                            collected += 1
                            task.wait(State.CollectDelay)
                        end
                    end
                end
            end
        end
    end
end)

-- SPAWN COUNTER (item + pumpkin)
task.spawn(function()
    while true do
        task.wait(0.5)
        local items = scanItems()
        StatsData.ItemsFound = #items
        for _, d in ipairs(items) do
            if not lastSeenItems[d.model] then
                lastSeenItems[d.model] = true
                StatsData.ItemsSpawned += 1
            end
        end
        local currentSet = {}
        for _, d in ipairs(items) do currentSet[d.model] = true end
        for model in pairs(lastSeenItems) do
            if not currentSet[model] then lastSeenItems[model] = nil end
        end
        for model in pairs(countedItems) do
            if not model.Parent then countedItems[model] = nil end
        end

        local pumpkins = scanPumpkins()
        StatsData.PumpkinsFound = #pumpkins
        for _, d in ipairs(pumpkins) do
            if not lastSeenPumpkins[d.model] then
                lastSeenPumpkins[d.model] = true
                StatsData.PumpkinsSpawned += 1
            end
        end
        local curP = {}
        for _, d in ipairs(pumpkins) do curP[d.model] = true end
        for model in pairs(lastSeenPumpkins) do
            if not curP[model] then lastSeenPumpkins[model] = nil end
        end
        for model in pairs(countedPumpkins) do
            if not model.Parent then countedPumpkins[model] = nil end
        end
    end
end)

-- ESP LOOP
task.spawn(function()
    while true do
        task.wait(0.5)
        local items = scanItems()

        if State.ItemESP then
            local cur = {}
            for _, d in ipairs(items) do cur[d.model] = d end
            for m, _ in pairs(itemCache) do
                if not cur[m] or not m.Parent then
                    removeESP(m)
                    itemCache[m] = nil
                end
            end
            for m, d in pairs(cur) do
                if not itemCache[m] then
                    createHL(m, C.Pri, "ItemESP_HL")
                    createTag(d.part, d.model.Name, C.Pri, "ItemESP_Tag")
                    itemCache[m] = d
                end
            end
        else
            for m, _ in pairs(itemCache) do removeESP(m) end
            itemCache = {}
        end

        if State.PumpkinESP then
            local ps = scanPumpkins()
            local cur = {}
            for _, d in ipairs(ps) do cur[d.model] = d end
            for m, _ in pairs(pumpkinCache) do
                if not cur[m] or not m.Parent then
                    removeESP(m)
                    pumpkinCache[m] = nil
                end
            end
            for m, d in pairs(cur) do
                if not pumpkinCache[m] then
                    createHL(m, C.Orng, "PumpkinESP_HL")
                    createTag(d.part, d.model.Name, C.Orng, "PumpkinESP_Tag")
                    pumpkinCache[m] = d
                end
            end
        else
            for m, _ in pairs(pumpkinCache) do removeESP(m) end
            pumpkinCache = {}
        end

        if State.ReaperESP then
            local rs = scanReapers()
            StatsData.ReapersFound = #rs
            local cur = {}
            for _, d in ipairs(rs) do cur[d.model] = d end
            for m, _ in pairs(reaperCache) do
                if not cur[m] or not m.Parent then
                    removeESP(m)
                    reaperCache[m] = nil
                end
            end
            for m, d in pairs(cur) do
                if not reaperCache[m] then
                    createHL(m, C.Red, "ReaperESP_HL")
                    createTag(d.part, d.model.Name, C.Red, "ReaperESP_Tag")
                    reaperCache[m] = d
                end
            end
        else
            for m, _ in pairs(reaperCache) do removeESP(m) end
            reaperCache = {}
            StatsData.ReapersFound = 0
        end

        if State.GhostESP then
            local gs = scanGhosts()
            StatsData.GhostsFound = #gs
            local cur = {}
            for _, d in ipairs(gs) do cur[d.model] = d end
            for m, _ in pairs(ghostCache) do
                if not cur[m] or not m.Parent then
                    removeESP(m)
                    ghostCache[m] = nil
                end
            end
            for m, d in pairs(cur) do
                if not ghostCache[m] then
                    createHL(m, C.Pur, "GhostESP_HL")
                    createTag(d.part, d.name, C.Pur, "GhostESP_Tag")
                    ghostCache[m] = d
                end
            end
        else
            for m, _ in pairs(ghostCache) do removeESP(m) end
            ghostCache = {}
            StatsData.GhostsFound = 0
        end
    end
end)

-- Distance updater
task.spawn(function()
    while true do
        task.wait(0.15)
        if State.ShowDistance then
            local hrp = getHRP()
            if hrp then
                local function update(cache, tagName, baseColor)
                    for m, d in pairs(cache) do
                        if d.part and d.part.Parent then
                            local dist = (d.part.Position - hrp.Position).Magnitude
                            local bb = d.part:FindFirstChild(tagName)
                            if bb then
                                local dl = bb:FindFirstChild("DistLbl")
                                if dl then
                                    local c = baseColor
                                    if dist > 200 then c = C.Yel
                                    elseif dist > 500 then c = C.Red end
                                    dl.Text = math.floor(dist) .. " studs"
                                    dl.TextColor3 = c
                                end
                            end
                        end
                    end
                end
                update(itemCache, "ItemESP_Tag", C.Grn)
                update(pumpkinCache, "PumpkinESP_Tag", C.Orng)
                update(reaperCache, "ReaperESP_Tag", C.Red)
                update(ghostCache, "GhostESP_Tag", C.Cyn)
            end
        end
    end
end)

-- EVENT TIMER
local function getEventInfo()
    local t = os.date("*t")
    local hour = t.hour
    local min = t.min
    local sec = t.sec
    local currentMin = hour * 60 + min
    local nextEventMin
    if min < 30 then nextEventMin = hour * 60 + 30 else nextEventMin = (hour + 1) * 60 end
    local secondsToEvent = (nextEventMin - currentMin) * 60 - sec
    local prevEventMin
    if min < 30 then prevEventMin = hour * 60 else prevEventMin = hour * 60 + 30 end
    local secondsSinceEvent = (currentMin - prevEventMin) * 60 + sec
    local cdHour = math.floor(secondsToEvent / 3600)
    local cdMin = math.floor((secondsToEvent % 3600) / 60)
    local cdSec = secondsToEvent % 60
    local nextEventHour = math.floor(nextEventMin / 60) % 24
    local nextEventMinute = nextEventMin % 60
    local nextEventHour12 = nextEventHour % 12
    if nextEventHour12 == 0 then nextEventHour12 = 12 end
    local nextEventAmPm = nextEventHour >= 12 and "PM" or "AM"
    return {
        countdownStr = string.format("%02d:%02d:%02d", cdHour, cdMin, cdSec),
        nextEventStr = string.format("%02d:%02d %s", nextEventHour12, nextEventMinute, nextEventAmPm),
        isEventActive = secondsSinceEvent <= 60,
        percent = 1 - (secondsToEvent / (30 * 60)),
    }
end

-- ═══════════════════════════════════════════════════════════
-- UI
-- ═══════════════════════════════════════════════════════════
local SG = Instance.new("ScreenGui")
SG.Name = "Oc1DvHUB_UI"
SG.ResetOnSpawn = false
SG.IgnoreGuiInset = true
SG.Parent = pg

local NotifyContainer = Instance.new("Frame")
NotifyContainer.Size = UDim2.new(0, 300, 0, 400)
NotifyContainer.Position = UDim2.new(1, -310, 1, -410)
NotifyContainer.BackgroundTransparency = 1
NotifyContainer.ZIndex = 490
NotifyContainer.Parent = SG
local NotifyLayout = Instance.new("UIListLayout", NotifyContainer)
NotifyLayout.FillDirection = Enum.FillDirection.Vertical
NotifyLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotifyLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotifyLayout.Padding = UDim.new(0, 6)

NotifyUser = function(title, msg, tp)
    tp = tp or "info"
    local colors = {success=C.Grn, error=C.Red, warn=C.Yel, info=C.Cyn}
    local iconTxt = {success="OK", error="X", warn="!", info="i"}
    local card = Instance.new("Frame")
    card.Size = UDim2.new(0, 290, 0, 60)
    card.BackgroundColor3 = Color3.fromRGB(22,22,28)
    card.BackgroundTransparency = 0.08
    card.BorderSizePixel = 0
    card.ZIndex = 500
    card.Parent = NotifyContainer
    Instance.new("UICorner", card).CornerRadius = UDim.new(0,10)
    local stroke = Instance.new("UIStroke", card)
    stroke.Color = colors[tp] or C.Pri
    stroke.Thickness = 1.5
    stroke.Transparency = 0.2
    stroke.Parent = card
    local accent = Instance.new("Frame", card)
    accent.Size = UDim2.new(0, 4, 1, -8)
    accent.Position = UDim2.new(0, 4, 0, 4)
    accent.BackgroundColor3 = colors[tp] or C.Pri
    accent.BorderSizePixel = 0
    accent.ZIndex = 501
    Instance.new("UICorner", accent).CornerRadius = UDim.new(1,0)
    local iconBox = Instance.new("Frame", card)
    iconBox.Size = UDim2.new(0, 32, 0, 32)
    iconBox.Position = UDim2.new(0, 16, 0.5, -16)
    iconBox.BackgroundColor3 = colors[tp] or C.Pri
    iconBox.BackgroundTransparency = 0.15
    iconBox.BorderSizePixel = 0
    iconBox.ZIndex = 501
    Instance.new("UICorner", iconBox).CornerRadius = UDim.new(1,0)
    local icon = Instance.new("TextLabel", iconBox)
    icon.Size = UDim2.new(1,0,1,0)
    icon.BackgroundTransparency = 1
    icon.Text = iconTxt[tp] or "i"
    icon.TextColor3 = Color3.fromRGB(20,20,20)
    icon.TextSize = 16
    icon.Font = Enum.Font.GothamBold
    icon.ZIndex = 502
    local titleL = Instance.new("TextLabel", card)
    titleL.Size = UDim2.new(1, -64, 0, 20)
    titleL.Position = UDim2.new(0, 56, 0, 8)
    titleL.BackgroundTransparency = 1
    titleL.Text = title
    titleL.TextColor3 = colors[tp] or C.Pri
    titleL.TextSize = 14
    titleL.Font = Enum.Font.GothamBold
    titleL.TextXAlignment = Enum.TextXAlignment.Left
    titleL.TextTruncate = Enum.TextTruncate.AtEnd
    titleL.ZIndex = 501
    local msgL = Instance.new("TextLabel", card)
    msgL.Size = UDim2.new(1, -64, 0, 22)
    msgL.Position = UDim2.new(0, 56, 0, 28)
    msgL.BackgroundTransparency = 1
    msgL.Text = msg
    msgL.TextColor3 = C.Txt
    msgL.TextSize = 12
    msgL.Font = Enum.Font.Gotham
    msgL.TextXAlignment = Enum.TextXAlignment.Left
    msgL.TextWrapped = true
    msgL.TextTruncate = Enum.TextTruncate.AtEnd
    msgL.ZIndex = 501
    card.Position = UDim2.new(0, 340, 0, 0)
    TS:Create(card, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, 0, 0),
    }):Play()
    task.delay(3.5, function()
        pcall(function()
            TS:Create(card, TweenInfo.new(0.3), {
                Position = UDim2.new(0, 340, 0, 0),
                BackgroundTransparency = 1,
            }):Play()
            task.wait(0.3)
            card:Destroy()
        end)
    end)
end

local LiveLog = {}
local liveRef = nil
Log = function(txt, tp)
    tp = tp or "info"
    table.insert(LiveLog, {t = "[" .. os.date("%H:%M:%S") .. "] " .. txt, tp = tp})
    if #LiveLog > 80 then table.remove(LiveLog, 1) end
    if liveRef and liveRef.Parent then
        task.spawn(function()
            pcall(function()
                for _, c in ipairs(liveRef:GetChildren()) do
                    if c:IsA("TextLabel") then c:Destroy() end
                end
                local cm = {success=C.Grn, error=C.Red, warn=C.Yel, info=C.Cyn}
                for i, e in ipairs(LiveLog) do
                    local l = Instance.new("TextLabel")
                    l.Size = UDim2.new(1,-8,0,18)
                    l.Position = UDim2.new(0,4,0,(i-1)*20)
                    l.BackgroundTransparency = 1
                    l.Text = e.t
                    l.TextColor3 = cm[e.tp] or C.Cyn
                    l.TextSize = 12
                    l.Font = Enum.Font.Gotham
                    l.TextXAlignment = Enum.TextXAlignment.Left
                    l.TextTruncate = Enum.TextTruncate.AtEnd
                    l.ZIndex = 15
                    l.Parent = liveRef
                end
                liveRef.CanvasSize = UDim2.new(0,0,0,#LiveLog*20+8)
                liveRef.CanvasPosition = Vector2.new(0, #LiveLog*20)
            end)
        end)
    end
    print("[LIVE]["..tp:upper().."] "..txt)
end

local TW, TH = 480, 360
local TW_NORMAL, TH_NORMAL = 560, 440

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0,TW,0,TH)
Main.Position = UDim2.new(0.5,-TW/2,0.5,-TH/2)
Main.BackgroundColor3 = C.Bg
Main.BackgroundTransparency = 1
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Active = true
Main.Parent = SG
Instance.new("UICorner", Main).CornerRadius = UDim.new(0,16)

local bgI = Instance.new("ImageLabel", Main)
bgI.Size = UDim2.new(1,0,1,0)
bgI.BackgroundTransparency = 1
bgI.Image = BG_LIST[S.curBG].id
bgI.ImageTransparency = 0.15
bgI.ScaleType = Enum.ScaleType.Crop
bgI.ZIndex = 0
Instance.new("UICorner", bgI).CornerRadius = UDim.new(0,16)

local ovl = Instance.new("Frame", Main)
ovl.Size = UDim2.new(1,0,1,0)
ovl.BackgroundColor3 = C.Bg
ovl.BackgroundTransparency = S.BGBrightness
ovl.BorderSizePixel = 0
ovl.ZIndex = 1
Instance.new("UICorner", ovl).CornerRadius = UDim.new(0,16)

local mst = Instance.new("UIStroke", Main)
mst.Thickness = 1.5
mst.Color = C.Pri
mst.Transparency = 0.35
mst.Parent = Main
track(mst, "Color")

local effectsLayer = Instance.new("Frame", Main)
effectsLayer.Size = UDim2.new(1,0,1,0)
effectsLayer.BackgroundTransparency = 1
effectsLayer.ClipsDescendants = true
effectsLayer.ZIndex = 2
Instance.new("UICorner", effectsLayer).CornerRadius = UDim.new(0,16)

local gradLayer = Instance.new("Frame", effectsLayer)
gradLayer.Size = UDim2.new(1,0,1,0)
gradLayer.BackgroundColor3 = Color3.fromRGB(255,255,255)
gradLayer.BackgroundTransparency = 0.78
gradLayer.BorderSizePixel = 0
gradLayer.ZIndex = 3
Instance.new("UICorner", gradLayer).CornerRadius = UDim.new(0,16)
local gradBg = Instance.new("UIGradient", gradLayer)
gradBg.Rotation = 45
gradBg.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0.0, Color3.fromRGB(255, 140, 70)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 200, 120)),
    ColorSequenceKeypoint.new(1.0, Color3.fromRGB(255, 100, 50)),
})
gradBg.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.85),
    NumberSequenceKeypoint.new(0.5, 0.5),
    NumberSequenceKeypoint.new(1, 0.85),
})
task.spawn(function()
    while gradLayer.Parent do
        for i = 0, 1, 0.015 do
            if not gradLayer.Parent then break end
            gradBg.Rotation = 45 + i * 360
            task.wait(0.03)
        end
    end
end)

local bgOrbs = {}
for i = 1, 6 do
    local orb = Instance.new("ImageLabel", effectsLayer)
    local sz = math.random(60, 140)
    orb.Size = UDim2.new(0, sz, 0, sz)
    orb.Position = UDim2.new(math.random(), 0, math.random(), 0)
    orb.BackgroundTransparency = 1
    orb.Image = "rbxassetid://5028857084"
    orb.ImageColor3 = Color3.fromRGB(255, 130, 60)
    orb.ImageTransparency = math.random(70, 90) / 100
    orb.ZIndex = 4
    table.insert(bgOrbs, {obj = orb, phase = math.random() * math.pi * 2})
end

task.spawn(function()
    while effectsLayer.Parent do
        local t = os.clock()
        for _, o in ipairs(bgOrbs) do
            if o.obj and o.obj.Parent then
                local x = 0.5 + math.sin(t * 0.3 + o.phase) * 0.4
                local y = 0.5 + math.cos(t * 0.25 + o.phase) * 0.4
                o.obj.Position = UDim2.new(x, 0, y, 0)
                o.obj.ImageTransparency = 0.75 + math.sin(t + o.phase) * 0.15
            end
        end
        task.wait(0.03)
    end
end)

local pulseStroke = Instance.new("UIStroke", Main)
pulseStroke.Color = C.Pri
pulseStroke.Thickness = 1.5
pulseStroke.Transparency = 0.5
pulseStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
pulseStroke.Parent = Main
track(pulseStroke, "Color")

task.spawn(function()
    while Main.Parent do
        local t = os.clock()
        pulseStroke.Transparency = 0.5 + math.sin(t * 2) * 0.25
        pulseStroke.Thickness = 1.5 + math.sin(t * 2) * 0.5
        task.wait(0.05)
    end
end)

local halloweenLayer = Instance.new("Frame", Main)
halloweenLayer.Size = UDim2.new(1, 0, 1, 0)
halloweenLayer.BackgroundTransparency = 1
halloweenLayer.ClipsDescendants = true
halloweenLayer.ZIndex = 5
Instance.new("UICorner", halloweenLayer).CornerRadius = UDim.new(0, 16)

local halloweenEmoji = {"🎃", "👻", "🦇", "🕷️", "💀", "🕸️", "🍬"}

local halloweenParticles = {}
for i = 1, 12 do
    local p = Instance.new("TextLabel", halloweenLayer)
    p.Size = UDim2.fromOffset(24, 24)
    p.BackgroundTransparency = 1
    p.Text = halloweenEmoji[(i - 1) % #halloweenEmoji + 1]
    p.TextSize = math.random(14, 22)
    p.TextTransparency = math.random(60, 85) / 100
    p.Position = UDim2.new(math.random(), 0, 1.15, 0)
    p.Rotation = math.random(-30, 30)
    p.ZIndex = 6
    table.insert(halloweenParticles, {
        obj = p,
        speed = math.random(15, 45) / 1000,
        startX = math.random(),
        offset = math.random() * math.pi * 2,
    })
end

task.spawn(function()
    while Main.Parent do
        for _, hp in ipairs(halloweenParticles) do
            if hp.obj and hp.obj.Parent then
                local y = hp.obj.Position.Y.Scale - hp.speed
                if y < -0.15 then
                    y = 1.15
                    hp.startX = math.random()
                    hp.obj.Text = halloweenEmoji[math.random(1, #halloweenEmoji)]
                    hp.obj.TextSize = math.random(14, 22)
                    hp.obj.TextTransparency = math.random(60, 85) / 100
                end
                local wobble = math.sin(tick() * 1.5 + hp.offset) * 0.04
                hp.obj.Position = UDim2.new(hp.startX + wobble, 0, y, 0)
                hp.obj.Rotation = math.sin(tick() * 2 + hp.offset) * 25
            end
        end
        task.wait(0.03)
    end
end)

local TH_H = 40
local Title = Instance.new("Frame", Main)
Title.Size = UDim2.new(1,0,0,TH_H)
Title.BackgroundColor3 = C.PriDark
Title.BackgroundTransparency = 0.8
Title.BorderSizePixel = 0
Title.ZIndex = 20
Title.Active = true
Instance.new("UICorner", Title).CornerRadius = UDim.new(0,16)
track(Title, "BackgroundColor3")

local hGradNew = Instance.new("UIGradient", Title)
hGradNew.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 20, 90)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(120, 40, 80)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 90, 30)),
})
hGradNew.Rotation = 30

local Ttl = Instance.new("TextLabel", Title)
Ttl.Size = UDim2.new(1,-140,1,0)
Ttl.Position = UDim2.new(0,118,0,0)
Ttl.BackgroundTransparency = 1
Ttl.RichText = true
Ttl.Text = '<font color="rgb(255,255,255)">Oc1Dv</font><font color="rgb(255,145,80)">HUB</font>'
Ttl.TextSize = 14
Ttl.Font = Enum.Font.GothamBold
Ttl.TextXAlignment = Enum.TextXAlignment.Left
Ttl.ZIndex = 21

task.spawn(function()
    local hue = 0
    while Main.Parent do
        hue = (hue + 0.008) % 1
        local c = Color3.fromHSV(0.08 + math.sin(hue * math.pi * 2) * 0.35, 0.9, 1)
        pcall(function() mst.Color = c end)
        task.wait(0.05)
    end
end)

local DOT_SIZE = 12
local DOT_Y = 0.5
local GrnB = Instance.new("TextButton", Title)
GrnB.Size = UDim2.new(0,DOT_SIZE,0,DOT_SIZE)
GrnB.Position = UDim2.new(1,-72,DOT_Y,-DOT_SIZE/2)
GrnB.BackgroundColor3 = Color3.fromRGB(80, 220, 120)
GrnB.BorderSizePixel = 0
GrnB.Text = ""
GrnB.AutoButtonColor = false
GrnB.ZIndex = 22
Instance.new("UICorner", GrnB).CornerRadius = UDim.new(1,0)

local MinB = Instance.new("TextButton", Title)
MinB.Size = UDim2.new(0,DOT_SIZE,0,DOT_SIZE)
MinB.Position = UDim2.new(1,-52,DOT_Y,-DOT_SIZE/2)
MinB.BackgroundColor3 = Color3.fromRGB(255,200,70)
MinB.BorderSizePixel = 0
MinB.Text = ""
MinB.AutoButtonColor = false
MinB.ZIndex = 22
Instance.new("UICorner", MinB).CornerRadius = UDim.new(1,0)

local ClsB = Instance.new("TextButton", Title)
ClsB.Size = UDim2.new(0,DOT_SIZE,0,DOT_SIZE)
ClsB.Position = UDim2.new(1,-32,DOT_Y,-DOT_SIZE/2)
ClsB.BackgroundColor3 = Color3.fromRGB(255,95,90)
ClsB.BorderSizePixel = 0
ClsB.Text = ""
ClsB.AutoButtonColor = false
ClsB.ZIndex = 22
Instance.new("UICorner", ClsB).CornerRadius = UDim.new(1,0)

local FB = Instance.new("TextButton")
FB.Size = UDim2.new(0,52,0,52)
FB.Position = UDim2.new(0,15,0,150)
FB.BackgroundColor3 = C.Bg
FB.BackgroundTransparency = 0.15
FB.BorderSizePixel = 0
FB.Text = ""
FB.AutoButtonColor = false
FB.Visible = false
FB.ZIndex = 100
FB.Parent = SG
Instance.new("UICorner", FB).CornerRadius = UDim.new(0,12)
local fbs = Instance.new("UIStroke", FB)
fbs.Color = C.Pri; fbs.Thickness = 2; fbs.Transparency = 0.3; fbs.Parent = FB
track(fbs, "Color")
local fbi = Instance.new("ImageLabel", FB)
fbi.Size = UDim2.new(1,-10,1,-10)
fbi.Position = UDim2.new(0,5,0,5)
fbi.BackgroundTransparency = 1
fbi.Image = CONFIG.LOGO
fbi.ZIndex = 101

local drg, dst, spt
Title.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        drg=true; dst=i.Position; spt=Main.Position
    end
end)
Title.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drg=false end
end)
UIS.InputChanged:Connect(function(i)
    if drg and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - dst
        Main.Position = UDim2.new(spt.X.Scale, spt.X.Offset + d.X, spt.Y.Scale, spt.Y.Offset + d.Y)
    end
end)

local fdrg, fdst, fspt
FB.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        fdrg=true; fdst=i.Position; fspt=FB.Position
    end
end)
FB.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then fdrg=false end
end)
UIS.InputChanged:Connect(function(i)
    if fdrg and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - fdst
        FB.Position = UDim2.new(fspt.X.Scale, fspt.X.Offset + d.X, fspt.Y.Scale, fspt.Y.Offset + d.Y)
    end
end)

local function doClose() sfx() Main.Visible=false; FB.Visible=true end
local function doShow() sfx() Main.Visible=true; FB.Visible=false end

ClsB.MouseButton1Click:Connect(doClose)
MinB.MouseButton1Click:Connect(function()
    sfx()
    local isMin = Main.AbsoluteSize.Y <= TH_H + 5
    TS:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
        Size = isMin and UDim2.new(0,TW,0,TH) or UDim2.new(0,TW,0,TH_H)
    }):Play()
end)
GrnB.MouseButton1Click:Connect(function()
    sfx()
    S.MiniMode = not S.MiniMode
    local targetW, targetH
    if S.MiniMode then targetW, targetH = TW, TH else targetW, targetH = TW_NORMAL, TH_NORMAL end
    TS:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quint), { Size = UDim2.new(0, targetW, 0, targetH) }):Play()
    NotifyUser("Size", S.MiniMode and "Mini" or "Normal", "info")
end)
FB.MouseButton1Click:Connect(doShow)

local SX, SY = 10, TH_H + 10
local SW = 110
local UH = 46
local CX = SX + SW + 8

local SB = Instance.new("Frame", Main)
SB.Size = UDim2.new(0,SW,1,-SY-UH-14)
SB.Position = UDim2.new(0,SX,0,SY)
SB.BackgroundColor3 = C.Panel
SB.BackgroundTransparency = 0.5
SB.BorderSizePixel = 0
SB.ZIndex = 10
SB.Active = true
Instance.new("UICorner", SB).CornerRadius = UDim.new(0,10)
local sbs = Instance.new("UIStroke", SB)
sbs.Color = C.Pri; sbs.Thickness = 1; sbs.Transparency = 0.7; sbs.Parent = SB
track(sbs, "Color")

local UI_ = Instance.new("Frame", Main)
UI_.Size = UDim2.new(0,SW,0,UH)
UI_.Position = UDim2.new(0,SX,1,-(UH+10))
UI_.BackgroundColor3 = C.Panel
UI_.BackgroundTransparency = 0.5
UI_.BorderSizePixel = 0
UI_.ZIndex = 10
Instance.new("UICorner", UI_).CornerRadius = UDim.new(0,10)
local uis = Instance.new("UIStroke", UI_)
uis.Color = C.Pri; uis.Thickness = 1; uis.Transparency = 0.7; uis.Parent = UI_
track(uis, "Color")

local AV = Instance.new("Frame", UI_)
AV.Size = UDim2.new(0,30,0,30)
AV.Position = UDim2.new(0,8,0.5,-15)
AV.BackgroundColor3 = Color3.fromRGB(50,50,58)
AV.BorderSizePixel = 0
AV.ZIndex = 11
Instance.new("UICorner", AV).CornerRadius = UDim.new(1,0)
local avs = Instance.new("UIStroke", AV)
avs.Color = C.Pri; avs.Thickness = 1.5; avs.Transparency = 0.35; avs.Parent = AV
track(avs, "Color")
local AVi = Instance.new("ImageLabel", AV)
AVi.Size = UDim2.new(1,-4,1,-4)
AVi.Position = UDim2.new(0,2,0,2)
AVi.BackgroundTransparency = 1
AVi.ZIndex = 12
Instance.new("UICorner", AVi).CornerRadius = UDim.new(1,0)
task.spawn(function()
    local ok, t = pcall(function()
        return Players:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
    end)
    if ok and t then AVi.Image = t end
end)

local DN = Instance.new("TextLabel", UI_)
DN.Size = UDim2.new(1,-48,0,14)
DN.Position = UDim2.new(0,44,0,8)
DN.BackgroundTransparency = 1
DN.Text = LP.DisplayName or LP.Name
DN.TextColor3 = C.Txt
DN.TextSize = 11
DN.Font = Enum.Font.GothamMedium
DN.TextXAlignment = Enum.TextXAlignment.Left
DN.TextTruncate = Enum.TextTruncate.AtEnd
DN.ZIndex = 11

local UN = Instance.new("TextLabel", UI_)
UN.Size = UDim2.new(1,-48,0,12)
UN.Position = UDim2.new(0,44,0,24)
UN.BackgroundTransparency = 1
UN.Text = "@" .. LP.Name
UN.TextColor3 = C.Dim
UN.TextSize = 9
UN.Font = Enum.Font.Gotham
UN.TextXAlignment = Enum.TextXAlignment.Left
UN.TextTruncate = Enum.TextTruncate.AtEnd
UN.ZIndex = 11

local Cont = Instance.new("Frame", Main)
Cont.Size = UDim2.new(1,-(CX+10),1,-SY-10)
Cont.Position = UDim2.new(0,CX,0,SY)
Cont.BackgroundColor3 = C.Panel
Cont.BackgroundTransparency = 0.55
Cont.BorderSizePixel = 0
Cont.ZIndex = 10
Instance.new("UICorner", Cont).CornerRadius = UDim.new(0,10)
local cts = Instance.new("UIStroke", Cont)
cts.Color = C.Pri; cts.Thickness = 1; cts.Transparency = 0.7; cts.Parent = Cont
track(cts, "Color")

local SearchBar = Instance.new("Frame", Cont)
SearchBar.Size = UDim2.new(1,-16,0,26)
SearchBar.Position = UDim2.new(0,8,0,8)
SearchBar.BackgroundColor3 = Color3.fromRGB(52,52,60)
SearchBar.BackgroundTransparency = 0.25
SearchBar.BorderSizePixel = 0
SearchBar.ZIndex = 11
Instance.new("UICorner", SearchBar).CornerRadius = UDim.new(0,8)

local SearchInput = Instance.new("TextBox", SearchBar)
SearchInput.Size = UDim2.new(1,-12,1,0)
SearchInput.Position = UDim2.new(0,6,0,0)
SearchInput.BackgroundTransparency = 1
SearchInput.Text = ""
SearchInput.PlaceholderText = "Cari fitur..."
SearchInput.PlaceholderColor3 = C.Dim
SearchInput.TextColor3 = C.Txt
SearchInput.TextSize = 11
SearchInput.Font = Enum.Font.Gotham
SearchInput.TextXAlignment = Enum.TextXAlignment.Left
SearchInput.ClearTextOnFocus = false
SearchInput.ZIndex = 12

local THF = Instance.new("Frame", Cont)
THF.Size = UDim2.new(1,-16,0,22)
THF.Position = UDim2.new(0,8,0,40)
THF.BackgroundTransparency = 1
THF.ZIndex = 11

local THt = Instance.new("TextLabel", THF)
THt.Size = UDim2.new(1,-30,1,0)
THt.Position = UDim2.new(0,4,0,0)
THt.BackgroundTransparency = 1
THt.Text = "RUMAH"
THt.TextColor3 = C.Txt
THt.TextSize = 13
THt.Font = Enum.Font.GothamMedium
THt.TextXAlignment = Enum.TextXAlignment.Left
THt.ZIndex = 12

local tabData = {
    {name="RUMAH", icon=IC.Rumah},
    {name="COLLECT", icon=IC.Collect},
    {name="ESP", icon=IC.ESP},
    {name="TELEPORT", icon=IC.TP},
    {name="EVENT", icon=IC.Event},
    {name="MISC", icon=IC.Misc},
    {name="TEMA", icon=IC.Tema},
    {name="CREDITS", icon=IC.Credits},
}

local tabContent = {}
local CONTENT_Y = 70
for i, t in ipairs(tabData) do
    local sc = Instance.new("ScrollingFrame", Cont)
    sc.Size = UDim2.new(1,-16,1,-CONTENT_Y-8)
    sc.Position = UDim2.new(0,8,0,CONTENT_Y)
    sc.BackgroundTransparency = 1
    sc.BorderSizePixel = 0
    sc.ScrollBarThickness = 3
    sc.ScrollBarImageColor3 = C.Pri
    sc.CanvasSize = UDim2.new(0,0,0,0)
    sc.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sc.Visible = (i == 1)
    sc.ZIndex = 10
    tabContent[t.name] = sc
    track(sc, "ScrollBarImageColor3")
    local lay = Instance.new("UIListLayout", sc)
    lay.Padding = UDim.new(0,6)
    lay.SortOrder = Enum.SortOrder.LayoutOrder
    local pad = Instance.new("UIPadding", sc)
    pad.PaddingRight = UDim.new(0,4)
end

local tabBtns = {}
local curTab = "RUMAH"
for i, t in ipairs(tabData) do
    local b = Instance.new("TextButton", SB)
    b.Size = UDim2.new(1,-16,0,24)
    b.Position = UDim2.new(0,8,0,4+(i-1)*26)
    b.BackgroundColor3 = (i==1) and C.Pri or Color3.fromRGB(50,50,58)
    b.BackgroundTransparency = (i==1) and 0.05 or 0.35
    b.BorderSizePixel = 0
    b.Text = t.name
    b.TextColor3 = (i==1) and Color3.fromRGB(255,255,255) or C.Txt
    b.TextSize = 9
    b.Font = Enum.Font.GothamMedium
    b.AutoButtonColor = false
    b.Active = true
    b.ZIndex = 100
    b.TextXAlignment = Enum.TextXAlignment.Center
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
    tabBtns[t.name] = b
    if i == 1 then track(b, "BackgroundColor3") end

    b.MouseButton1Click:Connect(function()
        if curTab == t.name then return end
        sfx()
        curTab = t.name
        for n, bb in pairs(tabBtns) do
            local on = (n == t.name)
            TS:Create(bb, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                BackgroundColor3 = on and C.Pri or Color3.fromRGB(50,50,58),
                BackgroundTransparency = on and 0.05 or 0.35,
            }):Play()
            TS:Create(bb, TweenInfo.new(0.2), {
                TextColor3 = on and Color3.fromRGB(255,255,255) or C.Txt
            }):Play()
        end
        THt.Text = t.name
        for n, c in pairs(tabContent) do c.Visible = (n == t.name) end
    end)
end

SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
    local q = string.lower(SearchInput.Text)
    for _, el in ipairs(searchables) do
        if el and el.Parent then
            if q == "" then el.Visible = true
            else
                local txt = el:GetAttribute("SearchText") or ""
                el.Visible = (txt:find(q, 1, true) ~= nil)
            end
        end
    end
end)

local function Btn(parent, text, cb, col)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1,-4,0,32)
    b.BackgroundColor3 = col or C.Card
    b.BackgroundTransparency = 0.2
    b.BorderSizePixel = 0
    b.Text = text
    b.TextColor3 = (col and Color3.fromRGB(255,255,255)) or C.Pri
    b.TextSize = 11
    b.Font = Enum.Font.GothamMedium
    b.AutoButtonColor = false
    b.ZIndex = 11
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,10)
    if not col then track(b, "TextColor3") end
    trackSearch(b, text)
    b.MouseEnter:Connect(function()
        TS:Create(b, TweenInfo.new(0.15), {BackgroundTransparency = 0.05}):Play()
    end)
    b.MouseLeave:Connect(function()
        TS:Create(b, TweenInfo.new(0.15), {BackgroundTransparency = 0.2}):Play()
    end)
    b.MouseButton1Click:Connect(function()
        sfx()
        if cb then pcall(cb) end
    end)
    return b
end

local function Sect(parent, text)
    local l = Instance.new("TextLabel", parent)
    l.Size = UDim2.new(1,-4,0,16)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = C.Pri
    l.TextSize = 10
    l.Font = Enum.Font.GothamBold
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.ZIndex = 10
    track(l, "TextColor3")
    trackSearch(l, text)
end

local function Toggle(parent, title, initial, cb)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1,-4,0,30)
    f.BackgroundColor3 = C.Card
    f.BackgroundTransparency = 0.2
    f.BorderSizePixel = 0
    f.ZIndex = 10
    Instance.new("UICorner", f).CornerRadius = UDim.new(0,10)
    trackSearch(f, title)

    local lbl = Instance.new("TextLabel", f)
    lbl.Size = UDim2.new(1,-60,1,0)
    lbl.Position = UDim2.new(0,10,0,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = title
    lbl.TextColor3 = C.Txt
    lbl.TextSize = 11
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 11

    local bg = Instance.new("Frame", f)
    bg.Size = UDim2.new(0,40,0,22)
    bg.Position = UDim2.new(1,-50,0.5,-11)
    bg.BackgroundColor3 = initial and C.Grn or Color3.fromRGB(60,60,68)
    bg.BorderSizePixel = 0
    bg.ZIndex = 11
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1,0)

    local knob = Instance.new("Frame", bg)
    knob.Size = UDim2.new(0,18,0,18)
    knob.Position = initial and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9)
    knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
    knob.BorderSizePixel = 0
    knob.ZIndex = 12
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

    local state = initial
    local btn = Instance.new("TextButton", f)
    btn.Size = UDim2.new(1,0,1,0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.ZIndex = 13
    btn.MouseButton1Click:Connect(function()
        sfx()
        state = not state
        knob.Position = state and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9)
        bg.BackgroundColor3 = state and C.Grn or Color3.fromRGB(60,60,68)
        if cb then pcall(cb, state) end
        if state then
            NotifyUser("Feature Enabled", title .. " activated", "success")
        end
    end)
    return f
end

local function Slider(parent, title, mn, mx, df, cb)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1,-4,0,44)
    f.BackgroundColor3 = C.Card
    f.BackgroundTransparency = 0.25
    f.BorderSizePixel = 0
    f.ZIndex = 10
    Instance.new("UICorner", f).CornerRadius = UDim.new(0,10)
    local s = Instance.new("UIStroke", f)
    s.Color = C.Stroke; s.Thickness = 1; s.Transparency = 0.82; s.Parent = f
    trackSearch(f, title)

    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1,-14,0,14)
    l.Position = UDim2.new(0,10,0,6)
    l.BackgroundTransparency = 1
    l.Text = title .. ": " .. df
    l.TextColor3 = C.Txt
    l.TextSize = 11
    l.Font = Enum.Font.GothamMedium
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.ZIndex = 11

    local bar = Instance.new("Frame", f)
    bar.Size = UDim2.new(1,-20,0,8)
    bar.Position = UDim2.new(0,10,0,26)
    bar.BackgroundColor3 = Color3.fromRGB(60,60,68)
    bar.BorderSizePixel = 0
    bar.ZIndex = 11
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1,0)

    local fl = Instance.new("Frame", bar)
    fl.Size = UDim2.new((df-mn)/(mx-mn),0,1,0)
    fl.BackgroundColor3 = C.Pri
    fl.BorderSizePixel = 0
    fl.ZIndex = 12
    Instance.new("UICorner", fl).CornerRadius = UDim.new(1,0)
    track(fl, "BackgroundColor3")

    local knob = Instance.new("Frame", fl)
    knob.Size = UDim2.new(0,14,0,14)
    knob.Position = UDim2.new(1,-7,0.5,-7)
    knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
    knob.BorderSizePixel = 0
    knob.ZIndex = 13
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

    local dr = false
    bar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dr = true
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dr = false
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dr and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local bs = bar.AbsoluteSize.X
            if bs <= 0 then return end
            local pct = math.clamp((i.Position.X - bar.AbsolutePosition.X)/bs, 0, 1)
            local v = math.floor(mn + (mx-mn)*pct)
            fl.Size = UDim2.new(pct,0,1,0)
            l.Text = title .. ": " .. v
            if cb then pcall(cb, v) end
        end
    end)
end

-- ═══════════════════════════════════════════════════════════
-- FILL: RUMAH
-- ═══════════════════════════════════════════════════════════
local tr = tabContent.RUMAH

local welcomeCard = Instance.new("Frame", tr)
welcomeCard.Size = UDim2.new(1,-4,0,70)
welcomeCard.BackgroundColor3 = C.Card
welcomeCard.BackgroundTransparency = 0.25
welcomeCard.BorderSizePixel = 0
welcomeCard.ZIndex = 10
Instance.new("UICorner", welcomeCard).CornerRadius = UDim.new(0,12)

local bigAv = Instance.new("Frame", welcomeCard)
bigAv.Size = UDim2.new(0,52,0,52)
bigAv.Position = UDim2.new(0,10,0.5,-26)
bigAv.BackgroundColor3 = Color3.fromRGB(55,55,63)
bigAv.BorderSizePixel = 0
bigAv.ZIndex = 12
Instance.new("UICorner", bigAv).CornerRadius = UDim.new(1,0)
local bigAvS = Instance.new("UIStroke", bigAv)
bigAvS.Color = C.Pri; bigAvS.Thickness = 2; bigAvS.Transparency = 0.35; bigAvS.Parent = bigAv
track(bigAvS, "Color")
local bigAvI = Instance.new("ImageLabel", bigAv)
bigAvI.Size = UDim2.new(1,-6,1,-6)
bigAvI.Position = UDim2.new(0,3,0,3)
bigAvI.BackgroundTransparency = 1
bigAvI.ZIndex = 13
Instance.new("UICorner", bigAvI).CornerRadius = UDim.new(1,0)
task.spawn(function()
    local ok, t = pcall(function()
        return Players:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size100x100)
    end)
    if ok and t then bigAvI.Image = t end
end)

local greetLbl = Instance.new("TextLabel", welcomeCard)
greetLbl.Size = UDim2.new(1,-74,0,18)
greetLbl.Position = UDim2.new(0,72,0,12)
greetLbl.BackgroundTransparency = 1
greetLbl.Text = "Halo, " .. (LP.DisplayName or LP.Name) .. "!"
greetLbl.TextColor3 = C.Txt
greetLbl.TextSize = 13
greetLbl.Font = Enum.Font.GothamMedium
greetLbl.TextXAlignment = Enum.TextXAlignment.Left
greetLbl.ZIndex = 12

local clockLbl = Instance.new("TextLabel", welcomeCard)
clockLbl.Size = UDim2.new(1,-74,0,14)
clockLbl.Position = UDim2.new(0,72,0,32)
clockLbl.BackgroundTransparency = 1
clockLbl.Text = "--"
clockLbl.TextColor3 = C.Dim
clockLbl.TextSize = 10
clockLbl.Font = Enum.Font.Gotham
clockLbl.TextXAlignment = Enum.TextXAlignment.Left
clockLbl.ZIndex = 12

local uptimeLbl = Instance.new("TextLabel", welcomeCard)
uptimeLbl.Size = UDim2.new(1,-74,0,14)
uptimeLbl.Position = UDim2.new(0,72,0,48)
uptimeLbl.BackgroundTransparency = 1
uptimeLbl.Text = "Playtime: 00:00:00"
uptimeLbl.TextColor3 = C.Dim
uptimeLbl.TextSize = 10
uptimeLbl.Font = Enum.Font.Gotham
uptimeLbl.TextXAlignment = Enum.TextXAlignment.Left
uptimeLbl.ZIndex = 12

Sect(tr, "LIVE STATS")

local statsCard = Instance.new("Frame", tr)
statsCard.Size = UDim2.new(1,-4,0,58)
statsCard.BackgroundColor3 = C.Card
statsCard.BackgroundTransparency = 0.25
statsCard.BorderSizePixel = 0
statsCard.ZIndex = 10
Instance.new("UICorner", statsCard).CornerRadius = UDim.new(0,12)

local function mkStatBox(parent, x, title)
    local box = Instance.new("Frame", parent)
    box.Size = UDim2.new(0,100,0,48)
    box.Position = UDim2.new(0,x,0.5,-24)
    box.BackgroundColor3 = Color3.fromRGB(52,52,60)
    box.BackgroundTransparency = 0.2
    box.BorderSizePixel = 0
    box.ZIndex = 11
    Instance.new("UICorner", box).CornerRadius = UDim.new(0,8)
    local tL = Instance.new("TextLabel", box)
    tL.Size = UDim2.new(1,0,0,12)
    tL.Position = UDim2.new(0,0,0,6)
    tL.BackgroundTransparency = 1
    tL.Text = title
    tL.TextColor3 = C.Dim
    tL.TextSize = 9
    tL.Font = Enum.Font.GothamMedium
    tL.ZIndex = 12
    local vL = Instance.new("TextLabel", box)
    vL.Size = UDim2.new(1,0,0,20)
    vL.Position = UDim2.new(0,0,0,22)
    vL.BackgroundTransparency = 1
    vL.Text = "--"
    vL.TextColor3 = C.Pri
    vL.TextSize = 14
    vL.Font = Enum.Font.GothamBold
    vL.ZIndex = 12
    track(vL, "TextColor3")
    return vL
end

local fpsVal = mkStatBox(statsCard, 8, "FPS")
local pingVal = mkStatBox(statsCard, 116, "PING")
local playerVal = mkStatBox(statsCard, 224, "PLAYERS")

Sect(tr, "SERVER INFO")

local infoCard = Instance.new("Frame", tr)
infoCard.Size = UDim2.new(1,-4,0,86)
infoCard.BackgroundColor3 = C.Card
infoCard.BackgroundTransparency = 0.25
infoCard.BorderSizePixel = 0
infoCard.ZIndex = 10
Instance.new("UICorner", infoCard).CornerRadius = UDim.new(0,12)

local function mkInfoRow(parent, y, label)
    local rL = Instance.new("TextLabel", parent)
    rL.Size = UDim2.new(0,80,0,16)
    rL.Position = UDim2.new(0,12,0,y)
    rL.BackgroundTransparency = 1
    rL.Text = label
    rL.TextColor3 = C.Dim
    rL.TextSize = 10
    rL.Font = Enum.Font.Gotham
    rL.TextXAlignment = Enum.TextXAlignment.Left
    rL.ZIndex = 12
    local vL = Instance.new("TextLabel", parent)
    vL.Size = UDim2.new(1,-106,0,16)
    vL.Position = UDim2.new(0,98,0,y)
    vL.BackgroundTransparency = 1
    vL.Text = "--"
    vL.TextColor3 = C.Txt
    vL.TextSize = 10
    vL.Font = Enum.Font.Gotham
    vL.TextXAlignment = Enum.TextXAlignment.Left
    vL.TextTruncate = Enum.TextTruncate.AtEnd
    vL.ZIndex = 12
    return vL
end

local jobVal = mkInfoRow(infoCard, 8, "Job ID")
local placeVal = mkInfoRow(infoCard, 28, "Place ID")
local gameVal = mkInfoRow(infoCard, 48, "Game")
local regionVal = mkInfoRow(infoCard, 68, "Region")
placeVal.Text = tostring(game.PlaceId)
jobVal.Text = game.JobId ~= "" and game.JobId or "Studio/Private"
gameVal.Text = S.GameName
regionVal.Text = (game.JobId ~= "" and "Online") or "Studio"

local fpsCount, fpsTime, curFPS = 0, 0, 0
RunService.RenderStepped:Connect(function(dt)
    fpsCount = fpsCount + 1
    fpsTime = fpsTime + dt
    if fpsTime >= 1 then
        curFPS = math.floor(fpsCount / fpsTime)
        fpsCount = 0; fpsTime = 0
    end
end)

task.spawn(function()
    while SG.Parent do
        task.wait(1)
        pcall(function()
            local t = os.date("*t")
            local h = t.hour
            local clockStr = string.format("%02d:%02d:%02d", t.hour, t.min, t.sec)
            local greet
            if h < 12 then greet = "Selamat Pagi"
            elseif h < 15 then greet = "Selamat Siang"
            elseif h < 18 then greet = "Selamat Sore"
            else greet = "Selamat Malam" end
            clockLbl.Text = clockStr
            greetLbl.Text = greet .. ", " .. (LP.DisplayName or LP.Name) .. "!"
            local el = os.time() - S.StartTime
            uptimeLbl.Text = string.format("Playtime: %02d:%02d:%02d", math.floor(el/3600), math.floor((el%3600)/60), el%60)
            fpsVal.Text = tostring(curFPS)
            pcall(function()
                local ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
                pingVal.Text = math.floor(ping) .. "ms"
            end)
            playerVal.Text = #Players:GetPlayers() .. "/" .. Players.MaxPlayers
            if S.GameName ~= "Loading..." then gameVal.Text = S.GameName end
        end)
    end
end)

-- ═══════════════════════════════════════════════════════════
-- FILL: COLLECT
-- ═══════════════════════════════════════════════════════════
local tcol = tabContent.COLLECT
Sect(tcol, "TREAT COLLECT")
Toggle(tcol, "Auto Collect Item", true, function(v) State.AutoCollect = v end)
Toggle(tcol, "Auto TP", true, function(v) State.AutoTP = v end)
Slider(tcol, "Max Distance", 50, 2000, 500, function(v) State.MaxDistance = v end)
Slider(tcol, "Collect Interval", 1, 10, 1, function(v) State.CollectInterval = v end)

Sect(tcol, "PUMPKIN COLLECT")
Toggle(tcol, "Auto Collect Pumpkin", true, function(v) State.AutoCollectPumpkin = v end)
Toggle(tcol, "Pumpkin Auto TP", true, function(v) State.PumpkinTP = v end)
Slider(tcol, "Pumpkin Max Distance", 50, 2000, 500, function(v) State.PumpkinMaxDistance = v end)
Slider(tcol, "Pumpkin Interval", 1, 10, 1, function(v) State.PumpkinInterval = v end)

Sect(tcol, "METHOD")
Toggle(tcol, "FirePrompt", true, function(v) State.FirePrompt = v end)
Toggle(tcol, "No Delay Button", true, function(v) State.NoDelay = v end)

-- ═══════════════════════════════════════════════════════════
-- FILL: ESP
-- ═══════════════════════════════════════════════════════════
local te = tabContent.ESP
Sect(te, "ESP")

Toggle(te, "Item ESP", true, function(v)
    State.ItemESP = v
    if not v then for m, _ in pairs(itemCache) do removeESP(m) end itemCache = {} end
end)
Toggle(te, "Pumpkin ESP", true, function(v)
    State.PumpkinESP = v
    if not v then for m, _ in pairs(pumpkinCache) do removeESP(m) end pumpkinCache = {} end
end)
Toggle(te, "Reaper ESP", true, function(v)
    State.ReaperESP = v
    if not v then for m, _ in pairs(reaperCache) do removeESP(m) end reaperCache = {} end
end)
Toggle(te, "Ghost ESP (All)", false, function(v)
    State.GhostESP = v
    if not v then for m, _ in pairs(ghostCache) do removeESP(m) end ghostCache = {} end
end)
Toggle(te, "Show Distance", true, function(v) State.ShowDistance = v end)

-- ═══════════════════════════════════════════════════════════
-- FILL: TELEPORT
-- ═══════════════════════════════════════════════════════════
local tp = tabContent.TELEPORT
local currentCat = ""
for i, loc in ipairs(TP_LOCATIONS) do
    if loc.category ~= currentCat then
        currentCat = loc.category
        Sect(tp, "-- " .. loc.category .. " --")
    end
    local b = Instance.new("TextButton", tp)
    b.Size = UDim2.new(1,-4,0,28)
    b.BackgroundColor3 = C.Card
    b.BackgroundTransparency = 0.2
    b.BorderSizePixel = 0
    b.Text = loc.name
    b.TextColor3 = C.Txt
    b.TextSize = 10
    b.Font = Enum.Font.GothamMedium
    b.AutoButtonColor = false
    b.ZIndex = 11
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
    trackSearch(b, loc.name)
    b.MouseButton1Click:Connect(function()
        sfx()
        local hrp = getHRP()
        if hrp then
            pcall(function()
                hrp.CFrame = CFrame.new(loc.pos + Vector3.new(0, 3, 0))
            end)
            Log("TP: " .. loc.name, "success")
            local oldTxt = b.Text
            b.Text = "TELEPORTED!"
            b.BackgroundColor3 = C.Grn
            task.wait(0.4)
            b.Text = oldTxt
            b.BackgroundColor3 = C.Card
        end
    end)
end

-- ═══════════════════════════════════════════════════════════
-- FILL: EVENT
-- ═══════════════════════════════════════════════════════════
local tEv = tabContent.EVENT
Sect(tEv, "EVENT TIMER")

local eventCard = Instance.new("Frame", tEv)
eventCard.Size = UDim2.new(1,-4,0,80)
eventCard.BackgroundColor3 = C.Card
eventCard.BackgroundTransparency = 0.2
eventCard.BorderSizePixel = 0
eventCard.ZIndex = 10
Instance.new("UICorner", eventCard).CornerRadius = UDim.new(0,10)

local eventTimerLbl = Instance.new("TextLabel", eventCard)
eventTimerLbl.Size = UDim2.new(1,-10,0,32)
eventTimerLbl.Position = UDim2.new(0,5,0,8)
eventTimerLbl.BackgroundTransparency = 1
eventTimerLbl.Text = "00:00:00"
eventTimerLbl.TextColor3 = C.Pri
eventTimerLbl.TextSize = 24
eventTimerLbl.Font = Enum.Font.GothamBold
eventTimerLbl.TextXAlignment = Enum.TextXAlignment.Center
eventTimerLbl.ZIndex = 11
track(eventTimerLbl, "TextColor3")

local eventProgressBg = Instance.new("Frame", eventCard)
eventProgressBg.Size = UDim2.new(1,-16,0,6)
eventProgressBg.Position = UDim2.new(0,8,0,48)
eventProgressBg.BackgroundColor3 = Color3.fromRGB(60,60,68)
eventProgressBg.BorderSizePixel = 0
eventProgressBg.ZIndex = 11
Instance.new("UICorner", eventProgressBg).CornerRadius = UDim.new(1,0)

local eventProgressFill = Instance.new("Frame", eventProgressBg)
eventProgressFill.Size = UDim2.new(0, 0, 1, 0)
eventProgressFill.BackgroundColor3 = C.Pri
eventProgressFill.BorderSizePixel = 0
eventProgressFill.ZIndex = 12
Instance.new("UICorner", eventProgressFill).CornerRadius = UDim.new(1,0)
track(eventProgressFill, "BackgroundColor3")

local eventStatusLbl = Instance.new("TextLabel", eventCard)
eventStatusLbl.Size = UDim2.new(1,-10,0,14)
eventStatusLbl.Position = UDim2.new(0,5,0,60)
eventStatusLbl.BackgroundTransparency = 1
eventStatusLbl.Text = "Next: --"
eventStatusLbl.TextColor3 = C.Dim
eventStatusLbl.TextSize = 10
eventStatusLbl.Font = Enum.Font.GothamMedium
eventStatusLbl.TextXAlignment = Enum.TextXAlignment.Center
eventStatusLbl.ZIndex = 11

Sect(tEv, "JAM DIGITAL")

local clockCard = Instance.new("Frame", tEv)
clockCard.Size = UDim2.new(1,-4,0,60)
clockCard.BackgroundColor3 = C.Card
clockCard.BackgroundTransparency = 0.2
clockCard.BorderSizePixel = 0
clockCard.ZIndex = 10
Instance.new("UICorner", clockCard).CornerRadius = UDim.new(0,10)

local clockLbl2 = Instance.new("TextLabel", clockCard)
clockLbl2.Size = UDim2.new(1,-10,0,30)
clockLbl2.Position = UDim2.new(0,5,0,6)
clockLbl2.BackgroundTransparency = 1
clockLbl2.Text = "--:--:--"
clockLbl2.TextColor3 = C.Cyn
clockLbl2.TextSize = 22
clockLbl2.Font = Enum.Font.GothamBold
clockLbl2.TextXAlignment = Enum.TextXAlignment.Center
clockLbl2.ZIndex = 11

local dateLbl2 = Instance.new("TextLabel", clockCard)
dateLbl2.Size = UDim2.new(1,-10,0,16)
dateLbl2.Position = UDim2.new(0,5,0,38)
dateLbl2.BackgroundTransparency = 1
dateLbl2.Text = "--"
dateLbl2.TextColor3 = C.Dim
dateLbl2.TextSize = 10
dateLbl2.Font = Enum.Font.Gotham
dateLbl2.TextXAlignment = Enum.TextXAlignment.Center
dateLbl2.ZIndex = 11

Sect(tEv, "STATISTIK")

local function mkStatRow(parent, title, color)
    local bx = Instance.new("Frame", parent)
    bx.Size = UDim2.new(1,-4,0,36)
    bx.BackgroundColor3 = C.Card
    bx.BackgroundTransparency = 0.2
    bx.BorderSizePixel = 0
    bx.ZIndex = 10
    Instance.new("UICorner", bx).CornerRadius = UDim.new(0,10)
    local t = Instance.new("TextLabel", bx)
    t.Size = UDim2.new(0.5,0,1,0)
    t.BackgroundTransparency = 1
    t.Text = title
    t.TextColor3 = C.Dim
    t.TextSize = 10
    t.Font = Enum.Font.GothamMedium
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.ZIndex = 11
    t.Position = UDim2.fromOffset(10,0)
    local v = Instance.new("TextLabel", bx)
    v.Size = UDim2.new(0.5,-10,1,0)
    v.Position = UDim2.new(0.5,0,0,0)
    v.BackgroundTransparency = 1
    v.Text = "0"
    v.TextColor3 = color
    v.TextSize = 16
    v.Font = Enum.Font.GothamBold
    v.TextXAlignment = Enum.TextXAlignment.Right
    v.ZIndex = 11
    return v
end

local statCollectedVal = mkStatRow(tEv, "Total Item Collected", C.Grn)
local statSpawnVal = mkStatRow(tEv, "Total Item Spawn", C.Pri)
local statPumpkinColVal = mkStatRow(tEv, "Total Pumpkin Collected", C.Orng)
local statPumpkinSpawnVal = mkStatRow(tEv, "Total Pumpkin Spawn", C.Yel)

Sect(tEv, "GHOST LIST")

local ghostListCard = Instance.new("Frame", tEv)
ghostListCard.Size = UDim2.new(1,-4,0,140)
ghostListCard.BackgroundColor3 = C.Card
ghostListCard.BackgroundTransparency = 0.2
ghostListCard.BorderSizePixel = 0
ghostListCard.ZIndex = 10
Instance.new("UICorner", ghostListCard).CornerRadius = UDim.new(0,10)

local ghostScroll = Instance.new("ScrollingFrame", ghostListCard)
ghostScroll.Size = UDim2.new(1,-8,1,-8)
ghostScroll.Position = UDim2.new(0,4,0,4)
ghostScroll.BackgroundTransparency = 1
ghostScroll.BorderSizePixel = 0
ghostScroll.ScrollBarThickness = 2
ghostScroll.ScrollBarImageColor3 = C.Pur
ghostScroll.CanvasSize = UDim2.new(0,0,0,0)
ghostScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
ghostScroll.ZIndex = 11

local ghostListLay = Instance.new("UIListLayout", ghostScroll)
ghostListLay.Padding = UDim.new(0,2)
ghostListLay.SortOrder = Enum.SortOrder.LayoutOrder

local ghostListPad = Instance.new("UIPadding", ghostScroll)
ghostListPad.PaddingTop = UDim.new(0,4)
ghostListPad.PaddingLeft = UDim.new(0,6)
ghostListPad.PaddingRight = UDim.new(0,6)

task.spawn(function()
    while SG.Parent do
        task.wait(0.5)
        pcall(function()
            local t = os.date("*t")
            local hour12 = t.hour % 12
            if hour12 == 0 then hour12 = 12 end
            local ampm = t.hour >= 12 and "PM" or "AM"
            clockLbl2.Text = string.format("%02d:%02d:%02d %s", hour12, t.min, t.sec, ampm)
            dateLbl2.Text = os.date("%A, %d %B %Y")

            local ev = getEventInfo()
            eventTimerLbl.Text = ev.countdownStr
            eventStatusLbl.Text = "Next: " .. ev.nextEventStr
            eventProgressFill.Size = UDim2.new(math.clamp(ev.percent, 0, 1), 0, 1, 0)

            if ev.isEventActive then
                eventTimerLbl.TextColor3 = C.Grn
                eventStatusLbl.Text = "EVENT ACTIVE!"
                eventStatusLbl.TextColor3 = C.Grn
            else
                eventTimerLbl.TextColor3 = C.Pri
                eventStatusLbl.TextColor3 = C.Dim
            end

            statCollectedVal.Text = tostring(StatsData.ItemsCollected)
            statSpawnVal.Text = tostring(StatsData.ItemsSpawned)
            statPumpkinColVal.Text = tostring(StatsData.PumpkinsCollected)
            statPumpkinSpawnVal.Text = tostring(StatsData.PumpkinsSpawned)

            for _, c in ipairs(ghostScroll:GetChildren()) do
                if c:IsA("TextLabel") then c:Destroy() end
            end
            if State.GhostESP then
                local hrp = getHRP()
                if hrp then
                    local gs = scanGhosts()
                    if #gs > 0 then
                        for i, g in ipairs(gs) do
                            local dist = (g.part.Position - hrp.Position).Magnitude
                            local row = Instance.new("TextLabel", ghostScroll)
                            row.Size = UDim2.new(1,-4,0,14)
                            row.BackgroundTransparency = 1
                            row.Text = string.format("%s - %d studs", g.name, math.floor(dist))
                            row.TextColor3 = C.Pur
                            row.TextSize = 9
                            row.Font = Enum.Font.Gotham
                            row.TextXAlignment = Enum.TextXAlignment.Left
                            row.LayoutOrder = i
                            row.ZIndex = 12
                        end
                    else
                        local empty = Instance.new("TextLabel", ghostScroll)
                        empty.Size = UDim2.new(1,-4,0,20)
                        empty.BackgroundTransparency = 1
                        empty.Text = "No ghosts detected"
                        empty.TextColor3 = C.Dim
                        empty.TextSize = 9
                        empty.Font = Enum.Font.Gotham
                        empty.ZIndex = 12
                    end
                end
            else
                local off = Instance.new("TextLabel", ghostScroll)
                off.Size = UDim2.new(1,-4,0,20)
                off.BackgroundTransparency = 1
                off.Text = "Ghost ESP is OFF"
                off.TextColor3 = C.Dim
                off.TextSize = 9
                off.Font = Enum.Font.Gotham
                off.ZIndex = 12
            end
        end)
    end
end)

-- ═══════════════════════════════════════════════════════════
-- FILL: MISC
-- ═══════════════════════════════════════════════════════════
local tm = tabContent.MISC
Sect(tm, "WALKSPEED")

Toggle(tm, "Enable WalkSpeed", false, function(v)
    State.WalkSpeedEnabled = v
    if not v then
        local hum = getHum()
        if hum then hum.WalkSpeed = 16 end
    end
end)
Slider(tm, "Speed", 16, 200, 16, function(v)
    State.WalkSpeedValue = v
    if State.WalkSpeedEnabled then
        local hum = getHum()
        if hum then hum.WalkSpeed = v end
    end
end)

Sect(tm, "GOD MODE / DESYNC")
Toggle(tm, "GodMode Desync", false, function(v) State.GodMode = v end)
Slider(tm, "Detect Radius", 10, 200, 30, function(v) State.DesyncRadius = v end)

Sect(tm, "INVISIBLE")
Toggle(tm, "Invisible", false, function(v) State.Invisible = v end)

Sect(tm, "NOCLIP")
Toggle(tm, "Noclip", false, function(v) State.Noclip = v end)

Sect(tm, "ANTI-AFK")
Toggle(tm, "Anti-AFK", true, function(v) State.AntiAFK = v end)
Slider(tm, "AFK Interval", 15, 120, 60, function(v) State.AntiAFKInterval = v end)

Sect(tm, "UTILITY")
Btn(tm, "Rejoin Server", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LP)
end, Color3.fromRGB(60, 120, 90))

Btn(tm, "Copy Discord Invite", function()
    if setclipboard then setclipboard(CONFIG.DISCORD) Log("Discord copied", "success") end
end)

Btn(tm, "Unload UI", function()
    S.FPRunning = false
    task.wait(0.3)
    SG:Destroy()
end, Color3.fromRGB(150, 60, 70))

-- ═══════════════════════════════════════════════════════════
-- FILL: TEMA
-- ═══════════════════════════════════════════════════════════
local ttem = tabContent.TEMA
Sect(ttem, "BACKGROUND IMAGE")

local themeBtns = {}
for i, bg in ipairs(BG_LIST) do
    local b = Instance.new("TextButton", ttem)
    b.Size = UDim2.new(1,-4,0,44)
    b.BackgroundColor3 = C.Card
    b.BackgroundTransparency = 0.25
    b.BorderSizePixel = 0
    b.Text = ""
    b.AutoButtonColor = false
    b.ZIndex = 11
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,10)
    local s = Instance.new("UIStroke", b)
    s.Color = (i == S.selBG) and C.Pri or Color3.fromRGB(80,80,88)
    s.Thickness = (i == S.selBG) and 2 or 1
    s.Transparency = (i == S.selBG) and 0.2 or 0.6
    s.Parent = b
    trackSearch(b, "Theme " .. bg.name)
    local prev = Instance.new("ImageLabel", b)
    prev.Size = UDim2.new(0,36,0,36)
    prev.Position = UDim2.new(0,6,0.5,-18)
    prev.BackgroundColor3 = Color3.fromRGB(55,55,63)
    prev.BorderSizePixel = 0
    prev.Image = bg.id
    prev.ZIndex = 12
    Instance.new("UICorner", prev).CornerRadius = UDim.new(0,7)
    local lbl = Instance.new("TextLabel", b)
    lbl.Size = UDim2.new(1,-86,0,14)
    lbl.Position = UDim2.new(0,48,0,8)
    lbl.BackgroundTransparency = 1
    lbl.Text = i .. ". " .. bg.name
    lbl.TextColor3 = (i == S.selBG) and C.Pri or C.Txt
    lbl.TextSize = 11
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 12
    local chk = Instance.new("TextLabel", b)
    chk.Size = UDim2.new(0,24,1,0)
    chk.Position = UDim2.new(1,-28,0,0)
    chk.BackgroundTransparency = 1
    chk.Text = (i == S.selBG) and "V" or ""
    chk.TextColor3 = C.Pri
    chk.TextSize = 16
    chk.Font = Enum.Font.GothamBold
    chk.ZIndex = 12
    themeBtns[i] = {btn=b, stroke=s, lbl=lbl, chk=chk}
    b.MouseButton1Click:Connect(function()
        sfx()
        S.selBG = i
        for j, item in pairs(themeBtns) do
            local isSel = (j == S.selBG)
            item.stroke.Color = isSel and C.Pri or Color3.fromRGB(80,80,88)
            item.stroke.Thickness = isSel and 2 or 1
            item.stroke.Transparency = isSel and 0.2 or 0.6
            item.lbl.TextColor3 = isSel and C.Pri or C.Txt
            item.chk.Text = isSel and "V" or ""
        end
    end)
end

Btn(ttem, "Ganti Background", function()
    if S.selBG == S.curBG then Log("Sama", "warn"); return end
    S.curBG = S.selBG
    bgI.Image = BG_LIST[S.curBG].id
    Log("BG: " .. BG_LIST[S.curBG].name, "success")
end, Color3.fromRGB(60,120,90))

Sect(ttem, "WARNA UI")

local hueFrame = Instance.new("Frame", ttem)
hueFrame.Size = UDim2.new(1,-4,0,60)
hueFrame.BackgroundColor3 = C.Card
hueFrame.BackgroundTransparency = 0.25
hueFrame.BorderSizePixel = 0
hueFrame.ZIndex = 10
Instance.new("UICorner", hueFrame).CornerRadius = UDim.new(0,10)

local hueLbl = Instance.new("TextLabel", hueFrame)
hueLbl.Size = UDim2.new(1,-50,0,14)
hueLbl.Position = UDim2.new(0,10,0,6)
hueLbl.BackgroundTransparency = 1
hueLbl.Text = "Geser untuk pilih warna"
hueLbl.TextColor3 = C.Txt
hueLbl.TextSize = 11
hueLbl.Font = Enum.Font.GothamMedium
hueLbl.TextXAlignment = Enum.TextXAlignment.Left
hueLbl.ZIndex = 11

local huePrev = Instance.new("Frame", hueFrame)
huePrev.Size = UDim2.new(0,18,0,18)
huePrev.Position = UDim2.new(1,-30,0,4)
huePrev.BackgroundColor3 = Color3.fromHSV(0.08, 0.65, 0.95)
huePrev.BorderSizePixel = 0
huePrev.ZIndex = 12
Instance.new("UICorner", huePrev).CornerRadius = UDim.new(1,0)

local hueBar = Instance.new("Frame", hueFrame)
hueBar.Size = UDim2.new(1,-20,0,22)
hueBar.Position = UDim2.new(0,10,0,28)
hueBar.BackgroundColor3 = Color3.fromRGB(255,255,255)
hueBar.BorderSizePixel = 0
hueBar.ZIndex = 11
Instance.new("UICorner", hueBar).CornerRadius = UDim.new(1,0)

local hueGrad = Instance.new("UIGradient", hueBar)
hueGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 90, 90)),
    ColorSequenceKeypoint.new(0.14, Color3.fromRGB(255, 170, 90)),
    ColorSequenceKeypoint.new(0.28, Color3.fromRGB(255, 230, 110)),
    ColorSequenceKeypoint.new(0.42, Color3.fromRGB(150, 230, 130)),
    ColorSequenceKeypoint.new(0.56, Color3.fromRGB(110, 210, 240)),
    ColorSequenceKeypoint.new(0.70, Color3.fromRGB(120, 150, 250)),
    ColorSequenceKeypoint.new(0.85, Color3.fromRGB(210, 130, 250)),
    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 90, 90)),
})

local hueKnob = Instance.new("Frame", hueBar)
hueKnob.Size = UDim2.new(0,24,0,24)
hueKnob.Position = UDim2.new(0.08, -12, 0.5, -12)
hueKnob.BackgroundColor3 = Color3.fromRGB(255,255,255)
hueKnob.BorderSizePixel = 0
hueKnob.ZIndex = 13
Instance.new("UICorner", hueKnob).CornerRadius = UDim.new(1,0)

local hueDrag = false
local function updateHue(px)
    local bs = hueBar.AbsoluteSize.X
    if bs <= 0 then return end
    local pct = math.clamp((px - hueBar.AbsolutePosition.X)/bs, 0, 1)
    hueKnob.Position = UDim2.new(pct, -12, 0.5, -12)
    local col = Color3.fromHSV(pct, 0.65, 0.98)
    huePrev.BackgroundColor3 = col
    S.HueColor = col
    applyColor(col)
end
hueBar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        hueDrag = true
        updateHue(i.Position.X)
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        hueDrag = false
    end
end)
UIS.InputChanged:Connect(function(i)
    if hueDrag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        updateHue(i.Position.X)
    end
end)

Btn(ttem, "Reset Warna (Orange)", function()
    S.HueColor = Color3.fromRGB(255, 145, 80)
    applyColor(S.HueColor)
end, Color3.fromRGB(140, 70, 50))

Sect(ttem, "BG BRIGHTNESS")
Slider(ttem, "Kegelapan BG (x100)", 0, 80, math.floor(S.BGBrightness*100), function(v)
    S.BGBrightness = v/100
    ovl.BackgroundTransparency = S.BGBrightness
end)

-- ═══════════════════════════════════════════════════════════
-- FILL: CREDITS
-- ═══════════════════════════════════════════════════════════
local tcr = tabContent.CREDITS

local creditCard = Instance.new("Frame", tcr)
creditCard.Size = UDim2.new(1,-4,0,130)
creditCard.BackgroundColor3 = C.Card
creditCard.BackgroundTransparency = 0.25
creditCard.BorderSizePixel = 0
creditCard.ZIndex = 10
Instance.new("UICorner", creditCard).CornerRadius = UDim.new(0,12)

local ccS = Instance.new("UIStroke", creditCard)
ccS.Color = C.Pri
ccS.Thickness = 1
ccS.Transparency = 0.7
ccS.Parent = creditCard
track(ccS, "Color")

local creditLogo = Instance.new("ImageLabel", creditCard)
creditLogo.Size = UDim2.new(0, 56, 0, 56)
creditLogo.Position = UDim2.new(0.5, -28, 0, 10)
creditLogo.BackgroundTransparency = 1
creditLogo.Image = CONFIG.LOGO
creditLogo.ZIndex = 12

local creditTitle = Instance.new("TextLabel", creditCard)
creditTitle.Size = UDim2.new(1, -20, 0, 22)
creditTitle.Position = UDim2.new(0, 10, 0, 70)
creditTitle.BackgroundTransparency = 1
creditTitle.RichText = true
creditTitle.Text = '<font color="rgb(255,255,255)">Oc1Dv</font><font color="rgb(255,145,80)">HUB</font>'
creditTitle.TextSize = 18
creditTitle.Font = Enum.Font.GothamBlack
creditTitle.TextXAlignment = Enum.TextXAlignment.Center
creditTitle.ZIndex = 12

local creditSub = Instance.new("TextLabel", creditCard)
creditSub.Size = UDim2.new(1, -20, 0, 16)
creditSub.Position = UDim2.new(0, 10, 0, 94)
creditSub.BackgroundTransparency = 1
creditSub.Text = "MOURGE SHIFT HALLOWEEN EDITION"
creditSub.TextColor3 = C.Dim
creditSub.TextSize = 10
creditSub.Font = Enum.Font.GothamMedium
creditSub.TextXAlignment = Enum.TextXAlignment.Center
creditSub.ZIndex = 12

local creditMade = Instance.new("TextLabel", creditCard)
creditMade.Size = UDim2.new(1, -20, 0, 14)
creditMade.Position = UDim2.new(0, 10, 0, 112)
creditMade.BackgroundTransparency = 1
creditMade.Text = "(c) 2026 - All rights reserved"
creditMade.TextColor3 = C.Dim
creditMade.TextSize = 9
creditMade.Font = Enum.Font.Gotham
creditMade.TextXAlignment = Enum.TextXAlignment.Center
creditMade.ZIndex = 12

Sect(tcr, "CREDITS")

local cr1 = Instance.new("Frame", tcr)
cr1.Size = UDim2.new(1,-4,0,36)
cr1.BackgroundColor3 = C.Card
cr1.BackgroundTransparency = 0.25
cr1.BorderSizePixel = 0
cr1.ZIndex = 10
Instance.new("UICorner", cr1).CornerRadius = UDim.new(0,10)
local cr1t = Instance.new("TextLabel", cr1)
cr1t.Size = UDim2.new(0.5,0,1,0)
cr1t.Position = UDim2.fromOffset(10,0)
cr1t.BackgroundTransparency = 1
cr1t.Text = "CREATE BY"
cr1t.TextColor3 = C.Dim
cr1t.TextSize = 10
cr1t.Font = Enum.Font.GothamBold
cr1t.TextXAlignment = Enum.TextXAlignment.Left
cr1t.ZIndex = 11
local cr1v = Instance.new("TextLabel", cr1)
cr1v.Size = UDim2.new(0.5,-10,1,0)
cr1v.Position = UDim2.new(0.5,0,0,0)
cr1v.BackgroundTransparency = 1
cr1v.Text = "Oc1DvHUB"
cr1v.TextColor3 = C.Pri
cr1v.TextSize = 12
cr1v.Font = Enum.Font.GothamBold
cr1v.TextXAlignment = Enum.TextXAlignment.Right
cr1v.ZIndex = 11
track(cr1v, "TextColor3")

local cr2 = Instance.new("Frame", tcr)
cr2.Size = UDim2.new(1,-4,0,36)
cr2.BackgroundColor3 = C.Card
cr2.BackgroundTransparency = 0.25
cr2.BorderSizePixel = 0
cr2.ZIndex = 10
Instance.new("UICorner", cr2).CornerRadius = UDim.new(0,10)
local cr2t = Instance.new("TextLabel", cr2)
cr2t.Size = UDim2.new(0.5,0,1,0)
cr2t.Position = UDim2.fromOffset(10,0)
cr2t.BackgroundTransparency = 1
cr2t.Text = "UI TYPE"
cr2t.TextColor3 = C.Dim
cr2t.TextSize = 10
cr2t.Font = Enum.Font.GothamBold
cr2t.TextXAlignment = Enum.TextXAlignment.Left
cr2t.ZIndex = 11
local cr2v = Instance.new("TextLabel", cr2)
cr2v.Size = UDim2.new(0.5,-10,1,0)
cr2v.Position = UDim2.new(0.5,0,0,0)
cr2v.BackgroundTransparency = 1
cr2v.Text = "RRFMLY UI"
cr2v.TextColor3 = C.Cyn
cr2v.TextSize = 12
cr2v.Font = Enum.Font.GothamBold
cr2v.TextXAlignment = Enum.TextXAlignment.Right
cr2v.ZIndex = 11

Sect(tcr, "SOCIAL MEDIA")

local crDiscord = Instance.new("TextButton", tcr)
crDiscord.Size = UDim2.new(1,-4,0,36)
crDiscord.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
crDiscord.BackgroundTransparency = 0.15
crDiscord.BorderSizePixel = 0
crDiscord.Text = ""
crDiscord.AutoButtonColor = false
crDiscord.ZIndex = 10
Instance.new("UICorner", crDiscord).CornerRadius = UDim.new(0,10)
trackSearch(crDiscord, "Discord")
local cdTitle = Instance.new("TextLabel", crDiscord)
cdTitle.Size = UDim2.new(0.4,0,1,0)
cdTitle.Position = UDim2.fromOffset(12,0)
cdTitle.BackgroundTransparency = 1
cdTitle.Text = "DISCORD"
cdTitle.TextColor3 = Color3.fromRGB(255,255,255)
cdTitle.TextSize = 11
cdTitle.Font = Enum.Font.GothamBold
cdTitle.TextXAlignment = Enum.TextXAlignment.Left
cdTitle.ZIndex = 11
local cdValue = Instance.new("TextLabel", crDiscord)
cdValue.Size = UDim2.new(0.6,-12,1,0)
cdValue.Position = UDim2.new(0.4,0,0,0)
cdValue.BackgroundTransparency = 1
cdValue.Text = "discord.gg/wtVKkDvyz"
cdValue.TextColor3 = Color3.fromRGB(220,220,255)
cdValue.TextSize = 10
cdValue.Font = Enum.Font.GothamMedium
cdValue.TextXAlignment = Enum.TextXAlignment.Right
cdValue.TextTruncate = Enum.TextTruncate.AtEnd
cdValue.ZIndex = 11
crDiscord.MouseButton1Click:Connect(function()
    sfx()
    if setclipboard then setclipboard("https://discord.gg/wtVKkDvyz") end
    NotifyUser("Discord", "Link copied!", "success")
end)

local crInsta = Instance.new("TextButton", tcr)
crInsta.Size = UDim2.new(1,-4,0,36)
crInsta.BackgroundColor3 = Color3.fromRGB(225, 48, 108)
crInsta.BackgroundTransparency = 0.15
crInsta.BorderSizePixel = 0
crInsta.Text = ""
crInsta.AutoButtonColor = false
crInsta.ZIndex = 10
Instance.new("UICorner", crInsta).CornerRadius = UDim.new(0,10)
trackSearch(crInsta, "Instagram")
local igTitle = Instance.new("TextLabel", crInsta)
igTitle.Size = UDim2.new(0.4,0,1,0)
igTitle.Position = UDim2.fromOffset(12,0)
igTitle.BackgroundTransparency = 1
igTitle.Text = "INSTAGRAM"
igTitle.TextColor3 = Color3.fromRGB(255,255,255)
igTitle.TextSize = 11
igTitle.Font = Enum.Font.GothamBold
igTitle.TextXAlignment = Enum.TextXAlignment.Left
igTitle.ZIndex = 11
local igValue = Instance.new("TextLabel", crInsta)
igValue.Size = UDim2.new(0.6,-12,1,0)
igValue.Position = UDim2.new(0.4,0,0,0)
igValue.BackgroundTransparency = 1
igValue.Text = "@mfrsyddd"
igValue.TextColor3 = Color3.fromRGB(255,220,230)
igValue.TextSize = 10
igValue.Font = Enum.Font.GothamMedium
igValue.TextXAlignment = Enum.TextXAlignment.Right
igValue.ZIndex = 11
crInsta.MouseButton1Click:Connect(function()
    sfx()
    if setclipboard then setclipboard("https://www.instagram.com/mfrsyddd?psln=NHZ2a242aXdqbXBr") end
    NotifyUser("Instagram", "Link copied!", "success")
end)

local crTiktok = Instance.new("TextButton", tcr)
crTiktok.Size = UDim2.new(1,-4,0,36)
crTiktok.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
crTiktok.BackgroundTransparency = 0.1
crTiktok.BorderSizePixel = 0
crTiktok.Text = ""
crTiktok.AutoButtonColor = false
crTiktok.ZIndex = 10
Instance.new("UICorner", crTiktok).CornerRadius = UDim.new(0,10)
local ttStroke = Instance.new("UIStroke", crTiktok)
ttStroke.Color = Color3.fromRGB(255, 0, 80)
ttStroke.Thickness = 1
ttStroke.Transparency = 0.3
trackSearch(crTiktok, "TikTok")
local ttTitle = Instance.new("TextLabel", crTiktok)
ttTitle.Size = UDim2.new(0.4,0,1,0)
ttTitle.Position = UDim2.fromOffset(12,0)
ttTitle.BackgroundTransparency = 1
ttTitle.Text = "TIKTOK"
ttTitle.TextColor3 = Color3.fromRGB(255,255,255)
ttTitle.TextSize = 11
ttTitle.Font = Enum.Font.GothamBold
ttTitle.TextXAlignment = Enum.TextXAlignment.Left
ttTitle.ZIndex = 11
local ttValue = Instance.new("TextLabel", crTiktok)
ttValue.Size = UDim2.new(0.6,-12,1,0)
ttValue.Position = UDim2.new(0.4,0,0,0)
ttValue.BackgroundTransparency = 1
ttValue.Text = "@mfrsydqt"
ttValue.TextColor3 = Color3.fromRGB(255,180,200)
ttValue.TextSize = 10
ttValue.Font = Enum.Font.GothamMedium
ttValue.TextXAlignment = Enum.TextXAlignment.Right
ttValue.ZIndex = 11
crTiktok.MouseButton1Click:Connect(function()
    sfx()
    if setclipboard then setclipboard("tiktok.com/@mfrsydqt") end
    NotifyUser("TikTok", "Link copied!", "success")
end)

local crWA = Instance.new("TextButton", tcr)
crWA.Size = UDim2.new(1,-4,0,36)
crWA.BackgroundColor3 = Color3.fromRGB(37, 211, 102)
crWA.BackgroundTransparency = 0.15
crWA.BorderSizePixel = 0
crWA.Text = ""
crWA.AutoButtonColor = false
crWA.ZIndex = 10
Instance.new("UICorner", crWA).CornerRadius = UDim.new(0,10)
trackSearch(crWA, "WhatsApp")
local waTitle = Instance.new("TextLabel", crWA)
waTitle.Size = UDim2.new(0.4,0,1,0)
waTitle.Position = UDim2.fromOffset(12,0)
waTitle.BackgroundTransparency = 1
waTitle.Text = "WHATSAPP"
waTitle.TextColor3 = Color3.fromRGB(255,255,255)
waTitle.TextSize = 11
waTitle.Font = Enum.Font.GothamBold
waTitle.TextXAlignment = Enum.TextXAlignment.Left
waTitle.ZIndex = 11
local waValue = Instance.new("TextLabel", crWA)
waValue.Size = UDim2.new(0.6,-12,1,0)
waValue.Position = UDim2.new(0.4,0,0,0)
waValue.BackgroundTransparency = 1
waValue.Text = "Saluran WA"
waValue.TextColor3 = Color3.fromRGB(230,255,230)
waValue.TextSize = 10
waValue.Font = Enum.Font.GothamMedium
waValue.TextXAlignment = Enum.TextXAlignment.Right
waValue.ZIndex = 11
crWA.MouseButton1Click:Connect(function()
    sfx()
    if setclipboard then setclipboard("https://whatsapp.com/channel/0029VbBXI1lJZg45TdQXq129") end
    NotifyUser("WhatsApp", "Link copied!", "success")
end)

Sect(tcr, "INFO")

local infoCreditCard = Instance.new("Frame", tcr)
infoCreditCard.Size = UDim2.new(1,-4,0,44)
infoCreditCard.BackgroundColor3 = C.Card
infoCreditCard.BackgroundTransparency = 0.4
infoCreditCard.BorderSizePixel = 0
infoCreditCard.ZIndex = 10
Instance.new("UICorner", infoCreditCard).CornerRadius = UDim.new(0,12)
local infoCreditTxt = Instance.new("TextLabel", infoCreditCard)
infoCreditTxt.Size = UDim2.new(1,-20,1,0)
infoCreditTxt.Position = UDim2.fromOffset(10,0)
infoCreditTxt.BackgroundTransparency = 1
infoCreditTxt.Text = "Made by Oc1DvHUB - (c) 2026"
infoCreditTxt.TextColor3 = C.Dim
infoCreditTxt.TextSize = 10
infoCreditTxt.Font = Enum.Font.GothamMedium
infoCreditTxt.TextXAlignment = Enum.TextXAlignment.Center
infoCreditTxt.TextYAlignment = Enum.TextYAlignment.Center
infoCreditTxt.ZIndex = 11

UIS.InputBegan:Connect(function(i, g)
    if g then return end
    if i.KeyCode == Enum.KeyCode.RightShift then
        if Main.Visible then doClose() else doShow() end
    end
end)

Log("Halloween Edition FINAL ready", "success")
NotifyUser("Oc1DvHUB", "Halloween Edition loaded!", "success")
print("[Oc1DvHUB] Halloween Edition FINAL loaded ✅")
