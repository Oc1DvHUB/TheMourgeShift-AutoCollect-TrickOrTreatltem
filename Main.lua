-- ═══════════════════════════════════════════════════════════
-- Oc1DvHUB | MOURGE SHIFT HALLOWEEN EDITION — FINAL v2
-- FirePrompt Only | TP 3s Locked | iOS UI + Halloween Effects
-- + Custom BG + Custom Logo + Anti-AFK + Event Timer
-- by Oc1DvHUB
-- ═══════════════════════════════════════════════════════════

print("[Oc1DvHUB] Loading FINAL v2...")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 15)

pcall(function()
    for _, g in ipairs({PlayerGui, game:GetService("CoreGui")}) do
        local o = g:FindFirstChild("HalloweenIOS")
        if o then o:Destroy() end
        local o2 = g:FindFirstChild("HalloweenMiniUI")
        if o2 then o2:Destroy() end
    end
end)

-- ═══════════════════════════════════════════════════════════
-- iOS THEME
-- ═══════════════════════════════════════════════════════════
local iOS = {
    Bg = Color3.fromRGB(28, 28, 30),
    Card = Color3.fromRGB(44, 44, 48),
    Blue = Color3.fromRGB(10, 132, 255),
    Green = Color3.fromRGB(48, 209, 88),
    Red = Color3.fromRGB(255, 69, 58),
    Orange = Color3.fromRGB(255, 159, 10),
    Purple = Color3.fromRGB(191, 90, 242),
    Pink = Color3.fromRGB(255, 55, 95),
    Text = Color3.fromRGB(255, 255, 255),
    TextSub = Color3.fromRGB(152, 152, 157),
    TextDim = Color3.fromRGB(99, 99, 102),
}
local FONT = Enum.Font.GothamMedium
local FONT_BOLD = Enum.Font.GothamBold

-- ═══════════════════════════════════════════════════════════
-- ASSETS
-- ═══════════════════════════════════════════════════════════
local ASSETS = {
    BG = "rbxassetid://71753681160488",     -- Oc1DvHUB HALLOWEEN BG
    LOGO = "rbxassetid://78682047053280",   -- Oc1DvHUB Logo
}

-- ═══════════════════════════════════════════════════════════
-- STATE
-- ═══════════════════════════════════════════════════════════
local State = {
    AutoCollect = true,
    AutoTP = true,
    CollectInterval = 3,
    MaxDistance = 500,
    ItemKeyword = "TrickOrTreatItem",
    
    TPSettleDelay = 0.5,
    CollectDelay = 0.3,
    MaxPerCycle = 3,
    
    ItemESP = true,
    ReaperESP = true,
    ShowDistance = true,
    
    FirePrompt = true,
    AntiAFK = true,
    AntiAFKInterval = 60,
}

local Stats = {
    SessionStart = tick(),
    ItemsFound = 0,
    ItemsCollected = 0,
    ReapersFound = 0,
    AFKTicks = 0,
}

local itemCache = {}
local reaperCache = {}

-- ═══════════════════════════════════════════════════════════
-- HELPERS
-- ═══════════════════════════════════════════════════════════
local function getHRP()
    local c = LocalPlayer.Character
    return c and (c:FindFirstChild("HumanoidRootPart") 
                or c:FindFirstChild("Torso") 
                or c:FindFirstChild("UpperTorso"))
end

local function getPart(obj)
    if not obj or not obj.Parent then return nil end
    if obj:IsA("BasePart") then return obj end
    if obj:IsA("Model") then
        return obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
    end
    return nil
end

local function hasKeyword(name, kw)
    return name:lower():find(kw:lower()) ~= nil
end

-- ═══════════════════════════════════════════════════════════
-- ANTI-AFK
-- ═══════════════════════════════════════════════════════════
local function doAntiAFK()
    pcall(function()
        local vu = game:GetService("VirtualUser")
        vu:CaptureController()
        vu:ClickButton2(Vector2.new())
        Stats.AFKTicks += 1
    end)
end

task.spawn(function()
    while true do
        task.wait(State.AntiAFKInterval)
        if State.AntiAFK then doAntiAFK() end
    end
end)

pcall(function()
    LocalPlayer.Idled:Connect(function()
        if State.AntiAFK then doAntiAFK() end
    end)
end)

-- ═══════════════════════════════════════════════════════════
-- SCANNERS
-- ═══════════════════════════════════════════════════════════
local function scanItems()
    local found = {}
    pcall(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") or obj:IsA("Model") then
                if hasKeyword(obj.Name, State.ItemKeyword) then
                    local part = getPart(obj)
                    if part then table.insert(found, {model = obj, part = part}) end
                end
            end
        end
    end)
    return found
end

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

-- ═══════════════════════════════════════════════════════════
-- FIREPROMPT
-- ═══════════════════════════════════════════════════════════
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
        prompt.HoldDuration = old
        ok = true
    end)
    return ok
end

local function collectItem(data)
    if not data or not data.part or not data.part.Parent then return false end
    local part = data.part
    local model = data.model
    
    local prompt = model:FindFirstChildWhichIsA("ProximityPrompt", true)
    if not prompt and part then
        prompt = part:FindFirstChildWhichIsA("ProximityPrompt")
    end
    
    if not prompt then
        local hrp = getHRP()
        if hrp and firetouchinterest then
            pcall(function()
                firetouchinterest(hrp, part, 0)
                task.wait(0.01)
                firetouchinterest(hrp, part, 1)
            end)
        end
        return false
    end
    
    pcall(function()
        prompt.MaxActivationDistance = 9e9
        prompt.Enabled = true
    end)
    
    if not State.FirePrompt then return false end
    return firePrompt(prompt)
end

-- ═══════════════════════════════════════════════════════════
-- ESP
-- ═══════════════════════════════════════════════════════════
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
    lbl.Font = FONT_BOLD
    
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
    dLbl.Font = FONT_BOLD
    
    bb.Parent = part
end

local function removeESP(model)
    if not model then return end
    for _, c in ipairs(model:GetChildren()) do
        if c.Name == "ItemESP_HL" or c.Name == "ReaperESP_HL" then c:Destroy() end
    end
    for _, p in ipairs(model:GetDescendants()) do
        if p:IsA("BasePart") then
            local t1 = p:FindFirstChild("ItemESP_Tag")
            local t2 = p:FindFirstChild("ReaperESP_Tag")
            if t1 then t1:Destroy() end
            if t2 then t2:Destroy() end
        end
    end
end

-- ═══════════════════════════════════════════════════════════
-- AUTO COLLECT LOOP — 3s + Safety Delay
-- ═══════════════════════════════════════════════════════════
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
                
                local collected_count = 0
                for _, d in ipairs(items) do
                    if d.dist <= State.MaxDistance and collected_count < State.MaxPerCycle then
                        if State.AutoTP and d.dist > 5 then
                            pcall(function()
                                hrp.CFrame = CFrame.new(d.part.Position + Vector3.new(0, 3, 0))
                            end)
                            task.wait(State.TPSettleDelay)
                        end
                        if collectItem(d) then
                            Stats.ItemsCollected += 1
                            collected_count += 1
                            task.wait(State.CollectDelay)
                        end
                    end
                end
            end
        end
    end
end)

-- ESP Loop
task.spawn(function()
    while true do
        task.wait(0.5)
        local items = scanItems()
        Stats.ItemsFound = #items
        
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
                    createHL(m, iOS.Orange, "ItemESP_HL")
                    createTag(d.part, "🎃 " .. m.Name, iOS.Orange, "ItemESP_Tag")
                    itemCache[m] = d
                end
            end
        else
            for m, _ in pairs(itemCache) do removeESP(m) end
            itemCache = {}
        end
        
        if State.ReaperESP then
            local rs = scanReapers()
            Stats.ReapersFound = #rs
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
                    createHL(m, iOS.Pink, "ReaperESP_HL")
                    createTag(d.part, "💀 " .. m.Name, iOS.Pink, "ReaperESP_Tag")
                    reaperCache[m] = d
                end
            end
        else
            for m, _ in pairs(reaperCache) do removeESP(m) end
            reaperCache = {}
            Stats.ReapersFound = 0
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
                for m, d in pairs(itemCache) do
                    if d.part and d.part.Parent then
                        local dist = (d.part.Position - hrp.Position).Magnitude
                        local bb = d.part:FindFirstChild("ItemESP_Tag")
                        if bb then
                            local dl = bb:FindFirstChild("DistLbl")
                            if dl then
                                local c = iOS.Green
                                if dist > 200 then c = iOS.Orange
                                elseif dist > 500 then c = iOS.Red end
                                dl.Text = "📏 " .. math.floor(dist) .. " studs"
                                dl.TextColor3 = c
                            end
                        end
                    end
                end
                for m, d in pairs(reaperCache) do
                    if d.part and d.part.Parent then
                        local dist = (d.part.Position - hrp.Position).Magnitude
                        local bb = d.part:FindFirstChild("ReaperESP_Tag")
                        if bb then
                            local dl = bb:FindFirstChild("DistLbl")
                            if dl then dl.Text = "📏 " .. math.floor(dist) .. " studs" end
                        end
                    end
                end
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════
-- EVENT TIMER
-- ═══════════════════════════════════════════════════════════
local function getEventInfo()
    local t = os.date("*t")
    local hour = t.hour
    local min = t.min
    local sec = t.sec
    
    local currentMin = hour * 60 + min
    local nextEventMin
    if min < 30 then
        nextEventMin = hour * 60 + 30
    else
        nextEventMin = (hour + 1) * 60
    end
    
    local secondsToEvent = (nextEventMin - currentMin) * 60 - sec
    
    local prevEventMin
    if min < 30 then
        prevEventMin = hour * 60
    else
        prevEventMin = hour * 60 + 30
    end
    local secondsSinceEvent = (currentMin - prevEventMin) * 60 + sec
    
    local cdHour = math.floor(secondsToEvent / 3600)
    local cdMin = math.floor((secondsToEvent % 3600) / 60)
    local cdSec = secondsToEvent % 60
    local countdownStr = string.format("%02d:%02d:%02d", cdHour, cdMin, cdSec)
    
    local nextEventHour = math.floor(nextEventMin / 60) % 24
    local nextEventMinute = nextEventMin % 60
    local nextEventHour12 = nextEventHour % 12
    if nextEventHour12 == 0 then nextEventHour12 = 12 end
    local nextEventAmPm = nextEventHour >= 12 and "PM" or "AM"
    local nextEventStr = string.format("%02d:%02d %s", nextEventHour12, nextEventMinute, nextEventAmPm)
    
    local isEventActive = secondsSinceEvent <= 60
    
    return {
        countdownStr = countdownStr,
        nextEventStr = nextEventStr,
        isEventActive = isEventActive,
        percent = 1 - (secondsToEvent / (30 * 60)),
    }
end

-- ═══════════════════════════════════════════════════════════
-- UI iOS + HALLOWEEN EFFECTS + CUSTOM BG + LOGO
-- ═══════════════════════════════════════════════════════════
local SG = Instance.new("ScreenGui")
SG.Name = "HalloweenIOS"
SG.ResetOnSpawn = false
SG.IgnoreGuiInset = true
SG.DisplayOrder = 9999
SG.ZIndexBehavior = Enum.ZIndexBehavior.Global

local parented = false
if gethui then pcall(function() SG.Parent = gethui() parented = true end) end
if not parented then SG.Parent = PlayerGui end

-- ═══════════════════════════════════════════════════════════
-- FLOATING BUTTON — Logo Oc1DvHUB
-- ═══════════════════════════════════════════════════════════
local floatBtn = Instance.new("TextButton", SG)
floatBtn.Size = UDim2.fromOffset(60, 60)
floatBtn.Position = UDim2.new(0, 20, 0.4, 0)
floatBtn.BackgroundColor3 = Color3.fromRGB(50, 20, 60)
floatBtn.BorderSizePixel = 0
floatBtn.Text = ""
floatBtn.AutoButtonColor = false
floatBtn.Active = true
floatBtn.ZIndex = 100
Instance.new("UICorner", floatBtn).CornerRadius = UDim.new(1, 0)

-- Logo Image
local fbLogo = Instance.new("ImageLabel", floatBtn)
fbLogo.Size = UDim2.new(1, -8, 1, -8)
fbLogo.Position = UDim2.new(0, 4, 0, 4)
fbLogo.BackgroundTransparency = 1
fbLogo.Image = ASSETS.LOGO
fbLogo.ScaleType = Enum.ScaleType.Fit
fbLogo.ZIndex = 101
Instance.new("UICorner", fbLogo).CornerRadius = UDim.new(1, 0)

-- Gradient overlay
local fbGradFrame = Instance.new("Frame", floatBtn)
fbGradFrame.Size = UDim2.new(1, 0, 1, 0)
fbGradFrame.BackgroundColor3 = Color3.fromRGB(255, 145, 80)
fbGradFrame.BackgroundTransparency = 0.85
fbGradFrame.BorderSizePixel = 0
fbGradFrame.ZIndex = 99
Instance.new("UICorner", fbGradFrame).CornerRadius = UDim.new(1, 0)

-- Glow stroke
local fStroke = Instance.new("UIStroke", floatBtn)
fStroke.Color = Color3.fromRGB(255, 100, 50)
fStroke.Thickness = 2
fStroke.Transparency = 0.2

-- Pulse animation
task.spawn(function()
    while floatBtn.Parent do
        TweenService:Create(fStroke, TweenInfo.new(1.2, Enum.EasingStyle.Sine), {Thickness = 3, Transparency = 0.1}):Play()
        TweenService:Create(floatBtn, TweenInfo.new(1.2, Enum.EasingStyle.Sine), {Size = UDim2.fromOffset(64, 64)}):Play()
        task.wait(1.2)
        TweenService:Create(fStroke, TweenInfo.new(1.2, Enum.EasingStyle.Sine), {Thickness = 2, Transparency = 0.4}):Play()
        TweenService:Create(floatBtn, TweenInfo.new(1.2, Enum.EasingStyle.Sine), {Size = UDim2.fromOffset(60, 60)}):Play()
        task.wait(1.2)
    end
end)

-- Float animation
task.spawn(function()
    local baseY = 0.4
    while floatBtn.Parent do
        TweenService:Create(floatBtn, TweenInfo.new(2, Enum.EasingStyle.Sine), {
            Position = UDim2.new(0, 20, baseY - 0.015, 0)
        }):Play()
        task.wait(2)
        TweenService:Create(floatBtn, TweenInfo.new(2, Enum.EasingStyle.Sine), {
            Position = UDim2.new(0, 20, baseY + 0.015, 0)
        }):Play()
        task.wait(2)
    end
end)

-- ═══════════════════════════════════════════════════════════
-- MAIN PANEL — with Custom BG + Halloween Effects
-- ═══════════════════════════════════════════════════════════
local main = Instance.new("Frame", SG)
main.Size = UDim2.fromOffset(520, 340)
main.Position = UDim2.new(0.5, -260, 0.5, -170)
main.BackgroundColor3 = Color3.fromRGB(22, 18, 28)
main.BackgroundTransparency = 0.05
main.BorderSizePixel = 0
main.Active = true
main.Visible = false
main.ZIndex = 1
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 20)

-- Background gradient (base)
local bgGrad = Instance.new("UIGradient", main)
bgGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 15, 40)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(22, 18, 28)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 18, 20)),
})
bgGrad.Rotation = 135

-- ⭐ CUSTOM BACKGROUND IMAGE
local bgImg = Instance.new("ImageLabel", main)
bgImg.Name = "CustomBG"
bgImg.Size = UDim2.new(1, 0, 1, 0)
bgImg.Position = UDim2.new(0, 0, 0, 0)
bgImg.BackgroundTransparency = 1
bgImg.Image = ASSETS.BG
bgImg.ImageColor3 = Color3.fromRGB(255, 255, 255)
bgImg.ImageTransparency = 0.4
bgImg.ScaleType = Enum.ScaleType.Crop
bgImg.ZIndex = 2
Instance.new("UICorner", bgImg).CornerRadius = UDim.new(0, 20)

-- Overlay gelap biar teks kebaca
local bgOverlay = Instance.new("Frame", main)
bgOverlay.Size = UDim2.new(1, 0, 1, 0)
bgOverlay.BackgroundColor3 = Color3.fromRGB(15, 10, 20)
bgOverlay.BackgroundTransparency = 0.5
bgOverlay.BorderSizePixel = 0
bgOverlay.ZIndex = 2
Instance.new("UICorner", bgOverlay).CornerRadius = UDim.new(0, 20)

-- Glow border stroke
local mStroke = Instance.new("UIStroke", main)
mStroke.Color = iOS.Orange
mStroke.Thickness = 2
mStroke.Transparency = 0.3

-- Animated stroke
task.spawn(function()
    local hue = 0
    while main.Parent do
        hue = (hue + 0.005) % 1
        mStroke.Color = Color3.fromHSV(0.08 + math.sin(hue * math.pi * 2) * 0.08, 0.9, 1)
        task.wait(0.05)
    end
end)

-- Floating particles layer
local particleLayer = Instance.new("Frame", main)
particleLayer.Size = UDim2.new(1, 0, 1, 0)
particleLayer.BackgroundTransparency = 1
particleLayer.ClipsDescendants = true
particleLayer.ZIndex = 3
Instance.new("UICorner", particleLayer).CornerRadius = UDim.new(0, 20)

local particles = {}
for i = 1, 8 do
    local p = Instance.new("TextLabel", particleLayer)
    p.Size = UDim2.fromOffset(20, 20)
    p.BackgroundTransparency = 1
    p.Text = (i % 2 == 0) and "🎃" or "👻"
    p.TextSize = math.random(12, 18)
    p.TextTransparency = 0.6
    p.Position = UDim2.new(math.random(), 0, 1.1, 0)
    p.ZIndex = 4
    table.insert(particles, {
        obj = p,
        speed = math.random(30, 60) / 1000,
        startX = math.random(),
        offset = math.random() * math.pi * 2,
    })
end

task.spawn(function()
    while main.Parent do
        for _, p in ipairs(particles) do
            if p.obj and p.obj.Parent then
                local y = p.obj.Position.Y.Scale - p.speed
                if y < -0.1 then
                    y = 1.1
                    p.startX = math.random()
                end
                local wobble = math.sin(tick() * 2 + p.offset) * 0.05
                p.obj.Position = UDim2.new(p.startX + wobble, 0, y, 0)
                p.obj.Rotation = math.sin(tick() * 3 + p.offset) * 20
            end
        end
        task.wait(0.03)
    end
end)

-- ═══════════════════════════════════════════════════════════
-- HEADER — Halloween Edition
-- ═══════════════════════════════════════════════════════════
local header = Instance.new("Frame", main)
header.Size = UDim2.new(1, 0, 0, 44)
header.BackgroundColor3 = Color3.fromRGB(50, 20, 60)
header.BackgroundTransparency = 0.2
header.BorderSizePixel = 0
header.Active = true
header.ZIndex = 10
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 20)

local hGrad = Instance.new("UIGradient", header)
hGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 20, 90)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(120, 40, 80)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 90, 30)),
})
hGrad.Rotation = 30

local hFix = Instance.new("Frame", header)
hFix.Size = UDim2.new(1, 0, 0, 22)
hFix.Position = UDim2.new(0, 0, 1, -22)
hFix.BackgroundColor3 = Color3.fromRGB(60, 25, 70)
hFix.BackgroundTransparency = 0.4
hFix.BorderSizePixel = 0
hFix.ZIndex = 10

-- Pumpkin + Ghost decorations
local p1 = Instance.new("TextLabel", header)
p1.Size = UDim2.fromOffset(20, 20)
p1.Position = UDim2.new(0, 68, 0.5, -10)
p1.BackgroundTransparency = 1
p1.Text = "🎃"
p1.TextSize = 16
p1.ZIndex = 12

local p2 = Instance.new("TextLabel", header)
p2.Size = UDim2.fromOffset(20, 20)
p2.Position = UDim2.new(1, -110, 0.5, -10)
p2.BackgroundTransparency = 1
p2.Text = "👻"
p2.TextSize = 16
p2.ZIndex = 12

-- Traffic dots
local function makeDot(color, x)
    local dot = Instance.new("Frame", header)
    dot.Size = UDim2.fromOffset(12, 12)
    dot.Position = UDim2.new(0, x, 0.5, -6)
    dot.BackgroundColor3 = color
    dot.BorderSizePixel = 0
    dot.ZIndex = 11
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
end
makeDot(iOS.Red, 14)
makeDot(iOS.Orange, 32)
makeDot(iOS.Green, 50)

-- Title
local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1, -220, 1, 0)
title.Position = UDim2.fromOffset(90, 0)
title.BackgroundTransparency = 1
title.RichText = true
title.Text = '<font color="rgb(255,145,80)">Oc1DvHUB</font> <font color="rgb(255,255,255)">|</font> <font color="rgb(191,90,242)">MOURGE SHIFT HALOWEEN EDITION</font>'
title.TextSize = 11
title.Font = FONT_BOLD
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 11

-- Animated title hue
task.spawn(function()
    local hue = 0
    while title.Parent do
        hue = (hue + 0.01) % 1
        local c1 = Color3.fromHSV(0.08 + math.sin(hue * math.pi * 2) * 0.05, 1, 1)
        local c2 = Color3.fromHSV(0.75 + math.sin(hue * math.pi * 2) * 0.05, 0.8, 1)
        local r1, g1, b1 = math.floor(c1.R*255), math.floor(c1.G*255), math.floor(c1.B*255)
        local r2, g2, b2 = math.floor(c2.R*255), math.floor(c2.G*255), math.floor(c2.B*255)
        title.Text = string.format(
            '<font color="rgb(%d,%d,%d)">Oc1DvHUB</font> <font color="rgb(255,255,255)">|</font> <font color="rgb(%d,%d,%d)">MOURGE SHIFT HALOWEEN EDITION</font>',
            r1, g1, b1, r2, g2, b2
        )
        task.wait(0.1)
    end
end)

-- Badge
local badge = Instance.new("Frame", header)
badge.Size = UDim2.fromOffset(60, 20)
badge.Position = UDim2.new(1, -70, 0.5, -10)
badge.BackgroundColor3 = iOS.Green
badge.BackgroundTransparency = 0.8
badge.BorderSizePixel = 0
badge.ZIndex = 11
Instance.new("UICorner", badge).CornerRadius = UDim.new(1, 0)

local badgeLbl = Instance.new("TextLabel", badge)
badgeLbl.Size = UDim2.new(1, 0, 1, 0)
badgeLbl.BackgroundTransparency = 1
badgeLbl.Text = "ACTIVE"
badgeLbl.TextColor3 = iOS.Green
badgeLbl.TextSize = 9
badgeLbl.Font = FONT_BOLD
badgeLbl.ZIndex = 12

-- Badge pulse
task.spawn(function()
    while badge.Parent do
        TweenService:Create(badge, TweenInfo.new(1, Enum.EasingStyle.Sine), {BackgroundTransparency = 0.6}):Play()
        task.wait(1)
        TweenService:Create(badge, TweenInfo.new(1, Enum.EasingStyle.Sine), {BackgroundTransparency = 0.85}):Play()
        task.wait(1)
    end
end)

local closeBtn = Instance.new("TextButton", header)
closeBtn.Size = UDim2.fromOffset(20, 20)
closeBtn.Position = UDim2.new(0, 10, 0.5, -10)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = ""
closeBtn.ZIndex = 15
closeBtn.MouseButton1Click:Connect(function()
    main.Visible = false
    floatBtn.Visible = true
end)

-- ═══════════════════════════════════════════════════════════
-- LAYOUT HELPERS
-- ═══════════════════════════════════════════════════════════
local yStart = 52
local colHeight = main.Size.Y.Offset - yStart - 10

local function makeSection(parent, text)
    local l = Instance.new("TextLabel", parent)
    l.Size = UDim2.new(1, -4, 0, 16)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = iOS.Orange
    l.TextSize = 10
    l.Font = FONT_BOLD
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.ZIndex = 10
end

local function makeToggle(parent, text, initial, callback)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, -4, 0, 30)
    row.BackgroundColor3 = iOS.Card
    row.BackgroundTransparency = 0.2
    row.BorderSizePixel = 0
    row.ZIndex = 10
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)
    
    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1, -55, 1, 0)
    lbl.Position = UDim2.fromOffset(12, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = iOS.Text
    lbl.TextSize = 10
    lbl.Font = FONT
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 11
    
    local bg = Instance.new("Frame", row)
    bg.Size = UDim2.fromOffset(40, 22)
    bg.Position = UDim2.new(1, -52, 0.5, -11)
    bg.BackgroundColor3 = initial and iOS.Green or Color3.fromRGB(60, 60, 65)
    bg.BorderSizePixel = 0
    bg.ZIndex = 11
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)
    
    local knob = Instance.new("Frame", bg)
    knob.Size = UDim2.fromOffset(18, 18)
    knob.Position = initial and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.BorderSizePixel = 0
    knob.ZIndex = 12
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    
    local knobShadow = Instance.new("UIStroke", knob)
    knobShadow.Color = Color3.fromRGB(0, 0, 0)
    knobShadow.Thickness = 1
    knobShadow.Transparency = 0.85
    
    local state = initial
    local btn = Instance.new("TextButton", row)
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.ZIndex = 13
    btn.MouseButton1Click:Connect(function()
        state = not state
        knob.Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
        bg.BackgroundColor3 = state and iOS.Green or Color3.fromRGB(60, 60, 65)
        if callback then pcall(callback, state) end
    end)
end

local function makeSlider(parent, text, min, max, default, callback)
    local holder = Instance.new("Frame", parent)
    holder.Size = UDim2.new(1, -4, 0, 38)
    holder.BackgroundColor3 = iOS.Card
    holder.BackgroundTransparency = 0.2
    holder.BorderSizePixel = 0
    holder.ZIndex = 10
    Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 10)
    
    local lbl = Instance.new("TextLabel", holder)
    lbl.Size = UDim2.new(1, -16, 0, 14)
    lbl.Position = UDim2.fromOffset(12, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text = text .. ": " .. default
    lbl.TextColor3 = iOS.Text
    lbl.TextSize = 10
    lbl.Font = FONT
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 11
    
    local track = Instance.new("Frame", holder)
    track.Size = UDim2.new(1, -24, 0, 4)
    track.Position = UDim2.fromOffset(12, 24)
    track.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
    track.BorderSizePixel = 0
    track.ZIndex = 11
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)
    
    local fill = Instance.new("Frame", track)
    local rel = (default - min) / (max - min)
    fill.Size = UDim2.new(rel, 0, 1, 0)
    fill.BackgroundColor3 = iOS.Blue
    fill.BorderSizePixel = 0
    fill.ZIndex = 12
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    
    local knob = Instance.new("Frame", track)
    knob.Size = UDim2.fromOffset(16, 16)
    knob.Position = UDim2.new(rel, -8, 0.5, -8)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.BorderSizePixel = 0
    knob.ZIndex = 13
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    
    local drag = false
    local function update(x)
        local r = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(r, 0, 1, 0)
        knob.Position = UDim2.new(r, -8, 0.5, -8)
        local val = min + r * (max - min)
        val = (max - min > 10) and math.floor(val) or (math.floor(val * 100) / 100)
        lbl.Text = text .. ": " .. val
        if callback then pcall(callback, val) end
    end
    track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = true
            update(i.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            update(i.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = false
        end
    end)
end

-- ═══════════════════════════════════════════════════════════
-- LEFT COLUMN
-- ═══════════════════════════════════════════════════════════
local leftCol = Instance.new("ScrollingFrame", main)
leftCol.Size = UDim2.fromOffset(200, colHeight)
leftCol.Position = UDim2.fromOffset(10, yStart)
leftCol.BackgroundTransparency = 1
leftCol.BorderSizePixel = 0
leftCol.ScrollBarThickness = 2
leftCol.ScrollBarImageColor3 = iOS.Orange
leftCol.CanvasSize = UDim2.new(0, 0, 0, 0)
leftCol.AutomaticCanvasSize = Enum.AutomaticSize.Y
leftCol.ZIndex = 5

local leftLay = Instance.new("UIListLayout", leftCol)
leftLay.Padding = UDim.new(0, 5)
leftLay.SortOrder = Enum.SortOrder.LayoutOrder

makeSection(leftCol, "🎃 CONTROLS")
makeToggle(leftCol, "Auto Collect", true, function(v) State.AutoCollect = v end)
makeToggle(leftCol, "Auto TP", true, function(v) State.AutoTP = v end)

-- Locked TP Delay
local tpDelayCard = Instance.new("Frame", leftCol)
tpDelayCard.Size = UDim2.new(1, -4, 0, 32)
tpDelayCard.BackgroundColor3 = iOS.Card
tpDelayCard.BackgroundTransparency = 0.2
tpDelayCard.BorderSizePixel = 0
tpDelayCard.ZIndex = 10
Instance.new("UICorner", tpDelayCard).CornerRadius = UDim.new(0, 10)

local tpDelayLbl = Instance.new("TextLabel", tpDelayCard)
tpDelayLbl.Size = UDim2.new(1, -16, 1, 0)
tpDelayLbl.Position = UDim2.fromOffset(12, 0)
tpDelayLbl.BackgroundTransparency = 1
tpDelayLbl.Text = "⏱️ TP Delay: 3.0s (Locked)"
tpDelayLbl.TextColor3 = iOS.Blue
tpDelayLbl.TextSize = 10
tpDelayLbl.Font = FONT_BOLD
tpDelayLbl.TextXAlignment = Enum.TextXAlignment.Left
tpDelayLbl.ZIndex = 11

makeSlider(leftCol, "Max Dist", 10, 2000, 500, function(v) State.MaxDistance = v end)

makeSection(leftCol, "👁️ ESP")
makeToggle(leftCol, "Item ESP", true, function(v)
    State.ItemESP = v
    if not v then for m, _ in pairs(itemCache) do removeESP(m) end itemCache = {} end
end)
makeToggle(leftCol, "Reaper ESP", true, function(v)
    State.ReaperESP = v
    if not v then for m, _ in pairs(reaperCache) do removeESP(m) end reaperCache = {} end
end)
makeToggle(leftCol, "Show Distance", true, function(v) State.ShowDistance = v end)

makeSection(leftCol, "🔧 METHOD")

local fpBtn = Instance.new("TextButton", leftCol)
fpBtn.Size = UDim2.new(1, -4, 0, 40)
fpBtn.BackgroundColor3 = iOS.Green
fpBtn.BorderSizePixel = 0
fpBtn.Text = "⭐ FirePrompt: ON"
fpBtn.TextColor3 = Color3.new(1, 1, 1)
fpBtn.TextSize = 11
fpBtn.Font = FONT_BOLD
fpBtn.AutoButtonColor = false
fpBtn.ZIndex = 10
Instance.new("UICorner", fpBtn).CornerRadius = UDim.new(0, 10)
fpBtn.MouseButton1Click:Connect(function()
    State.FirePrompt = not State.FirePrompt
    if State.FirePrompt then
        fpBtn.Text = "⭐ FirePrompt: ON"
        fpBtn.BackgroundColor3 = iOS.Green
    else
        fpBtn.Text = "☆ FirePrompt: OFF"
        fpBtn.BackgroundColor3 = iOS.Card
    end
end)

makeSection(leftCol, "💤 ANTI-AFK ✅")
makeToggle(leftCol, "Anti-AFK", true, function(v) State.AntiAFK = v end)
makeSlider(leftCol, "AFK Interval", 15, 120, 60, function(v) State.AntiAFKInterval = v end)

-- ═══════════════════════════════════════════════════════════
-- CENTER COLUMN
-- ═══════════════════════════════════════════════════════════
local centerCol = Instance.new("ScrollingFrame", main)
centerCol.Size = UDim2.fromOffset(150, colHeight)
centerCol.Position = UDim2.fromOffset(220, yStart)
centerCol.BackgroundTransparency = 1
centerCol.BorderSizePixel = 0
centerCol.ScrollBarThickness = 2
centerCol.ScrollBarImageColor3 = iOS.Orange
centerCol.CanvasSize = UDim2.new(0, 0, 0, 0)
centerCol.AutomaticCanvasSize = Enum.AutomaticSize.Y
centerCol.ZIndex = 5

local centerLay = Instance.new("UIListLayout", centerCol)
centerLay.Padding = UDim.new(0, 5)
centerLay.SortOrder = Enum.SortOrder.LayoutOrder

makeSection(centerCol, "🕐 JAM")

local clockCard = Instance.new("Frame", centerCol)
clockCard.Size = UDim2.new(1, -4, 0, 60)
clockCard.BackgroundColor3 = iOS.Card
clockCard.BackgroundTransparency = 0.2
clockCard.BorderSizePixel = 0
clockCard.ZIndex = 10
Instance.new("UICorner", clockCard).CornerRadius = UDim.new(0, 10)

local clockLbl = Instance.new("TextLabel", clockCard)
clockLbl.Size = UDim2.new(1, -10, 0, 30)
clockLbl.Position = UDim2.fromOffset(5, 6)
clockLbl.BackgroundTransparency = 1
clockLbl.Text = "--:--:--"
clockLbl.TextColor3 = iOS.Blue
clockLbl.TextSize = 22
clockLbl.Font = FONT_BOLD
clockLbl.TextXAlignment = Enum.TextXAlignment.Center
clockLbl.ZIndex = 11

local dateLbl = Instance.new("TextLabel", clockCard)
dateLbl.Size = UDim2.new(1, -10, 0, 16)
dateLbl.Position = UDim2.fromOffset(5, 38)
dateLbl.BackgroundTransparency = 1
dateLbl.Text = "--"
dateLbl.TextColor3 = iOS.TextSub
dateLbl.TextSize = 10
dateLbl.Font = FONT
dateLbl.TextXAlignment = Enum.TextXAlignment.Center
dateLbl.ZIndex = 11

makeSection(centerCol, "🎃 EVENT")

local eventCard = Instance.new("Frame", centerCol)
eventCard.Size = UDim2.new(1, -4, 0, 100)
eventCard.BackgroundColor3 = iOS.Card
eventCard.BackgroundTransparency = 0.2
eventCard.BorderSizePixel = 0
eventCard.ZIndex = 10
Instance.new("UICorner", eventCard).CornerRadius = UDim.new(0, 10)

local eventTitleLbl = Instance.new("TextLabel", eventCard)
eventTitleLbl.Size = UDim2.new(1, -10, 0, 14)
eventTitleLbl.Position = UDim2.fromOffset(5, 6)
eventTitleLbl.BackgroundTransparency = 1
eventTitleLbl.Text = "NEXT EVENT IN"
eventTitleLbl.TextColor3 = iOS.TextSub
eventTitleLbl.TextSize = 9
eventTitleLbl.Font = FONT_BOLD
eventTitleLbl.TextXAlignment = Enum.TextXAlignment.Center
eventTitleLbl.ZIndex = 11

local eventTimerLbl = Instance.new("TextLabel", eventCard)
eventTimerLbl.Size = UDim2.new(1, -10, 0, 34)
eventTimerLbl.Position = UDim2.fromOffset(5, 22)
eventTimerLbl.BackgroundTransparency = 1
eventTimerLbl.Text = "00:00:00"
eventTimerLbl.TextColor3 = iOS.Orange
eventTimerLbl.TextSize = 26
eventTimerLbl.Font = FONT_BOLD
eventTimerLbl.TextXAlignment = Enum.TextXAlignment.Center
eventTimerLbl.ZIndex = 11

local eventProgressBg = Instance.new("Frame", eventCard)
eventProgressBg.Size = UDim2.new(1, -16, 0, 5)
eventProgressBg.Position = UDim2.fromOffset(8, 60)
eventProgressBg.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
eventProgressBg.BorderSizePixel = 0
eventProgressBg.ZIndex = 11
Instance.new("UICorner", eventProgressBg).CornerRadius = UDim.new(1, 0)

local eventProgressFill = Instance.new("Frame", eventProgressBg)
eventProgressFill.Size = UDim2.new(0, 0, 1, 0)
eventProgressFill.BackgroundColor3 = iOS.Orange
eventProgressFill.BorderSizePixel = 0
eventProgressFill.ZIndex = 12
Instance.new("UICorner", eventProgressFill).CornerRadius = UDim.new(1, 0)

local eventStatusLbl = Instance.new("TextLabel", eventCard)
eventStatusLbl.Size = UDim2.new(1, -10, 0, 14)
eventStatusLbl.Position = UDim2.fromOffset(5, 74)
eventStatusLbl.BackgroundTransparency = 1
eventStatusLbl.Text = "Next: --"
eventStatusLbl.TextColor3 = iOS.TextSub
eventStatusLbl.TextSize = 9
eventStatusLbl.Font = FONT
eventStatusLbl.TextXAlignment = Enum.TextXAlignment.Center
eventStatusLbl.ZIndex = 11

-- ═══════════════════════════════════════════════════════════
-- RIGHT COLUMN
-- ═══════════════════════════════════════════════════════════
local rightCol = Instance.new("ScrollingFrame", main)
rightCol.Size = UDim2.fromOffset(140, colHeight)
rightCol.Position = UDim2.fromOffset(378, yStart)
rightCol.BackgroundTransparency = 1
rightCol.BorderSizePixel = 0
rightCol.ScrollBarThickness = 2
rightCol.ScrollBarImageColor3 = iOS.Orange
rightCol.CanvasSize = UDim2.new(0, 0, 0, 0)
rightCol.AutomaticCanvasSize = Enum.AutomaticSize.Y
rightCol.ZIndex = 5

local rightLay = Instance.new("UIListLayout", rightCol)
rightLay.Padding = UDim.new(0, 5)
rightLay.SortOrder = Enum.SortOrder.LayoutOrder

makeSection(rightCol, "📊 STATS")

local function makeStatCard(parent, label, valueColor)
    local card = Instance.new("Frame", parent)
    card.Size = UDim2.new(1, -4, 0, 38)
    card.BackgroundColor3 = iOS.Card
    card.BackgroundTransparency = 0.2
    card.BorderSizePixel = 0
    card.ZIndex = 10
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)
    
    local lbl = Instance.new("TextLabel", card)
    lbl.Size = UDim2.new(1, -10, 0, 14)
    lbl.Position = UDim2.fromOffset(6, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = iOS.TextSub
    lbl.TextSize = 9
    lbl.Font = FONT
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 11
    
    local val = Instance.new("TextLabel", card)
    val.Size = UDim2.new(1, -10, 0, 18)
    val.Position = UDim2.fromOffset(6, 18)
    val.BackgroundTransparency = 1
    val.Text = "0"
    val.TextColor3 = valueColor or iOS.Text
    val.TextSize = 14
    val.Font = FONT_BOLD
    val.TextXAlignment = Enum.TextXAlignment.Left
    val.ZIndex = 11
    
    return val
end

local infoFound = makeStatCard(rightCol, "🎃 Found", iOS.Orange)
local infoCollected = makeStatCard(rightCol, "✅ Collected", iOS.Green)
local infoReapers = makeStatCard(rightCol, "💀 Reapers", iOS.Pink)
local infoAFK = makeStatCard(rightCol, "💤 AFK Ticks", iOS.Blue)
local infoUptime = makeStatCard(rightCol, "⏰ Uptime", iOS.TextSub)

-- ═══════════════════════════════════════════════════════════
-- UPDATE LOOP
-- ═══════════════════════════════════════════════════════════
task.spawn(function()
    while SG.Parent do
        task.wait(0.5)
        pcall(function()
            local t = os.date("*t")
            local hour12 = t.hour % 12
            if hour12 == 0 then hour12 = 12 end
            local ampm = t.hour >= 12 and "PM" or "AM"
            clockLbl.Text = string.format("%02d:%02d:%02d", hour12, t.min, t.sec)
            dateLbl.Text = string.format("%s %s", ampm, os.date("%A"))
            
            local ev = getEventInfo()
            eventTimerLbl.Text = ev.countdownStr
            eventStatusLbl.Text = "Next: " .. ev.nextEventStr
            eventProgressFill.Size = UDim2.new(math.clamp(ev.percent, 0, 1), 0, 1, 0)
            
            if ev.isEventActive then
                eventTimerLbl.TextColor3 = iOS.Green
                eventStatusLbl.Text = "🎉 EVENT AKTIF!"
                eventStatusLbl.TextColor3 = iOS.Green
                badgeLbl.Text = "EVENT!"
                badgeLbl.TextColor3 = iOS.Green
                badge.BackgroundColor3 = iOS.Green
            else
                eventTimerLbl.TextColor3 = iOS.Orange
                eventStatusLbl.TextColor3 = iOS.TextSub
                badgeLbl.Text = "ACTIVE"
                badgeLbl.TextColor3 = iOS.Green
                badge.BackgroundColor3 = iOS.Green
            end
            
            infoFound.Text = tostring(Stats.ItemsFound)
            infoCollected.Text = tostring(Stats.ItemsCollected)
            infoReapers.Text = tostring(Stats.ReapersFound)
            infoAFK.Text = tostring(Stats.AFKTicks)
            
            local uptime = tick() - Stats.SessionStart
            local m = math.floor(uptime / 60)
            local s = math.floor(uptime % 60)
            infoUptime.Text = string.format("%02d:%02d", m, s)
        end)
    end
end)

-- ═══════════════════════════════════════════════════════════
-- DRAG
-- ═══════════════════════════════════════════════════════════
local function makeDraggable(frame, handle)
    local drag = false
    local start, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = true
            start = input.Position
            startPos = frame.Position
            local c
            c = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    drag = false
                    if c then c:Disconnect() end
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not drag then return end
        if input.UserInputType ~= Enum.UserInputType.Touch and input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        local d = input.Position - start
        frame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + d.X,
            startPos.Y.Scale, startPos.Y.Offset + d.Y
        )
    end)
end

makeDraggable(main, header)

local btnDragging = false
local btnDragStart, btnStartPos, btnMoved

floatBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        btnDragging = true
        btnMoved = false
        btnDragStart = input.Position
        btnStartPos = floatBtn.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not btnDragging or not btnDragStart then return end
    if input.UserInputType ~= Enum.UserInputType.Touch and input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
    local d = input.Position - btnDragStart
    if d.Magnitude > 8 then
        btnMoved = true
        floatBtn.Position = UDim2.new(
            btnStartPos.X.Scale, btnStartPos.X.Offset + d.X,
            btnStartPos.Y.Scale, btnStartPos.Y.Offset + d.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        if btnDragging and not btnMoved then
            main.Visible = not main.Visible
            floatBtn.Visible = not main.Visible
        end
        btnDragging = false
        btnDragStart = nil
        btnMoved = false
    end
end)

print("═══════════════════════════════════════════════")
print("🎃 Oc1DvHUB | MOURGE SHIFT HALLOWEEN EDITION ✅")
print("  FirePrompt ONLY | TP 3s LOCKED")
print("  Auto Collect + Auto TP")
print("  Item ESP + Reaper ESP")
print("  Anti-AFK: AUTO ON")
print("  Event Timer + Jam Digital")
print("  🎃👻 Effects: Particles + Glow + Animated Title")
print("  🖼️ Custom BG: 71753681160488")
print("  🎨 Custom Logo: 78682047053280")
print("═══════════════════════════════════════════════")
