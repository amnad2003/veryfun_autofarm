--========================================--
-- VERYFUN SHOP - FULL MOBILE UI + AUTO SYSTEMS
-- (Single file; mobile optimized: MainFrame=0.42x0.55, Sidebar=0.22)
--========================================--

-- HWID fetch URL (unchanged)
local HWID_URL = "https://raw.githubusercontent.com/amnad2003/veryfun_autofarm/refs/heads/main/hwidPremium_lock.lua"

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

-- Basic constants
local UI_NAME = "VeryFunSHOP_MobileFull"
local LOGO_ID = "rbxassetid://82270910588453"

-- Theme list
local THEMES = {
    Mint =   { bg = Color3.fromHex("#0F1720"), accent = Color3.fromHex("#1F2937"), highlight = Color3.fromHex("#66FFCC") },
    Red =    { bg = Color3.fromHex("#0F0A0A"), accent = Color3.fromHex("#241111"), highlight = Color3.fromHex("#FF5C5C") },
    Blue =   { bg = Color3.fromHex("#071022"), accent = Color3.fromHex("#0E2438"), highlight = Color3.fromHex("#7FB3FF") },
    Pink =   { bg = Color3.fromHex("#120812"), accent = Color3.fromHex("#261429"), highlight = Color3.fromHex("#FF8FD8") },
    Purple = { bg = Color3.fromHex("#0B0612"), accent = Color3.fromHex("#221633"), highlight = Color3.fromHex("#B47DFF") },
    Gold =   { bg = Color3.fromHex("#0B0B06"), accent = Color3.fromHex("#2A260F"), highlight = Color3.fromHex("#FFC857") },
}
local currentTheme = THEMES.Mint

-- Remove old UI if exists
local old = PlayerGui:FindFirstChild(UI_NAME)
if old then old:Destroy() end

-- =========================
-- HWID Helpers & Screen
-- =========================
local function GetHWID()
    if gethwid then return tostring(gethwid()) end
    if syn and syn.get_hwid then return tostring(syn.get_hwid()) end
    if crypt and crypt.generate_hash then return crypt.generate_hash("HWID") end
    return game:GetService("RbxAnalyticsService"):GetClientId()
end

local myHWID = GetHWID()
local whitelistData = {}

do
    local ok, raw = pcall(function() return game:HttpGet(HWID_URL) end)
    if ok and raw then
        local f = loadstring(raw)
        if f then
            local suc, res = pcall(f)
            if suc and type(res) == "table" then whitelistData = res end
        end
    end
end

local function IsHWIDAllowed()
    for _, hw in ipairs(whitelistData) do
        if tostring(hw) == tostring(myHWID) then return true end
    end
    return false
end

local function ShowHWIDScreen()
    local gui = Instance.new("ScreenGui", PlayerGui)
    gui.Name = UI_NAME .. "_HWID"
    gui.ResetOnSpawn = false

    local blur = Instance.new("BlurEffect", game:GetService("Lighting"))
    blur.Size = 15

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0, 440, 0, 260)
    frame.Position = UDim2.new(0.5, -220, 0.5, -130)
    frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
    frame.BorderSizePixel = 0
    local uc = Instance.new("UICorner", frame); uc.CornerRadius = UDim.new(0,14)
    local stroke = Instance.new("UIStroke", frame); stroke.Color = Color3.fromRGB(120,120,120); stroke.Thickness = 1

    local bar = Instance.new("Frame", frame); bar.Size = UDim2.new(1,0,0,44); bar.BackgroundColor3 = Color3.fromRGB(28,28,28)
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0,14)

    local title = Instance.new("TextLabel", bar)
    title.Size = UDim2.new(1,-60,1,0); title.Position = UDim2.new(0,12,0,0)
    title.BackgroundTransparency = 1; title.Font = Enum.Font.GothamBold; title.TextSize = 18
    title.TextColor3 = Color3.fromRGB(240,80,80); title.Text = "VERYFUN SHOP — HWID LOCK"; title.TextXAlignment = Enum.TextXAlignment.Left

    local close = Instance.new("TextButton", bar)
    close.Size = UDim2.new(0,44,0,34); close.Position = UDim2.new(1,-52,0.5,-17)
    close.BackgroundTransparency = 1; close.Font = Enum.Font.GothamBold; close.Text = "✕"; close.TextSize = 20
    close.TextColor3 = Color3.fromRGB(230,80,80)
    close.MouseButton1Click:Connect(function() gui:Destroy(); blur:Destroy() end)

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1,-24,0,120); label.Position = UDim2.new(0,12,0,56)
    label.BackgroundTransparency = 1; label.Font = Enum.Font.Gotham; label.TextSize = 14; label.TextColor3 = Color3.fromRGB(230,230,230)
    label.TextWrapped = true
    label.Text = "HWID ของคุณ:\n" .. tostring(myHWID)

    local copyBtn = Instance.new("TextButton", frame)
    copyBtn.Size = UDim2.new(0,200,0,36); copyBtn.Position = UDim2.new(0.5,-100,1,-52)
    copyBtn.BackgroundColor3 = Color3.fromRGB(60,60,60); copyBtn.Font = Enum.Font.GothamBold
    copyBtn.Text = "คัดลอก HWID"; copyBtn.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0,8)
    copyBtn.MouseButton1Click:Connect(function()
        pcall(function() setclipboard(tostring(myHWID)) end)
        copyBtn.Text = "คัดลอกแล้ว!"
        copyBtn.BackgroundColor3 = Color3.fromRGB(50,140,60)
        task.delay(1.2, function() if copyBtn.Parent then copyBtn.Text = "คัดลอก HWID"; copyBtn.BackgroundColor3 = Color3.fromRGB(60,60,60) end end)
    end)
end

if not IsHWIDAllowed() then
    ShowHWIDScreen()
    return
end

-- =========================
-- applyFPS: auto-detect executor functions
-- =========================
local function applyFPS(value)
    value = tonumber(value)
    if not value or value < 1 then return end
    if setfpscap then pcall(setfpscap, value); return end
    if setfps then pcall(setfps, value); return end
    if set_fps_cap then pcall(set_fps_cap, value); return end
    if set_fps then pcall(set_fps, value); return end
    warn("⚠ Executor ของคุณอาจไม่รองรับการตั้ง FPS")
end

-- =========================
-- UI Creation (Mobile)
-- =========================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = UI_NAME
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false

-- small UIScale for mobile-friendly (works across devices)
local uiScale = Instance.new("UIScale", ScreenGui)
uiScale.Scale = 1 -- can be adjusted in Settings if wanted

local ToggleButton = Instance.new("ImageButton", ScreenGui)
ToggleButton.Size = UDim2.new(0,44,0,44)
ToggleButton.Position = UDim2.new(0, 14, 0, 160)
ToggleButton.AnchorPoint = Vector2.new(0,0)
ToggleButton.BackgroundColor3 = currentTheme.bg
ToggleButton.Image = LOGO_ID
ToggleButton.ImageColor3 = currentTheme.highlight
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0,8)

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0.42,0,0.55,0) -- mobile size
MainFrame.Position = UDim2.new(0.5,0,0.5,0)
MainFrame.AnchorPoint = Vector2.new(0.5,0.5)
MainFrame.BackgroundColor3 = currentTheme.bg
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0,10)
local mfStroke = Instance.new("UIStroke", MainFrame); mfStroke.Color = currentTheme.accent; mfStroke.Thickness = 1

-- Title bar
local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size = UDim2.new(1,0,0,42); TitleBar.BackgroundColor3 = currentTheme.accent
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0,10)
local Title = Instance.new("TextLabel", TitleBar)
Title.Size = UDim2.new(1,-10,1,0); Title.Position = UDim2.new(0,10,0,0)
Title.BackgroundTransparency = 1; Title.Text = "VeryFun SHOP | Mobile UI"
Title.Font = Enum.Font.GothamSemibold; Title.TextSize = 15; Title.TextColor3 = Color3.new(1,1,1)
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Theme container
local ThemeContainer = Instance.new("Frame", TitleBar)
ThemeContainer.Size = UDim2.new(0,110,1,0); ThemeContainer.Position = UDim2.new(1,-115,0,0); ThemeContainer.BackgroundTransparency = 1
local tList = Instance.new("UIListLayout", ThemeContainer); tList.FillDirection = Enum.FillDirection.Horizontal; tList.Padding = UDim.new(0,3); tList.HorizontalAlignment = Enum.HorizontalAlignment.Right

-- Sidebar & Content (mobile sizes)
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.BackgroundTransparency = 1
Sidebar.Size = UDim2.new(0.22, 0, 1, -42)
Sidebar.Position = UDim2.new(0, 0, 0, 42)
local sideList = Instance.new("UIListLayout", Sidebar); sideList.Padding = UDim.new(0,6); sideList.SortOrder = Enum.SortOrder.LayoutOrder

local Content = Instance.new("Frame", MainFrame)
Content.BackgroundTransparency = 1
Content.Size = UDim2.new(0.78,0,1,-42)
Content.Position = UDim2.new(0.22,0,0,42)

-- Page system
local Pages = {}
local ActivePage = nil
local function CreateCategory(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,-10,0,30)
    btn.Text = "  " .. name
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.BackgroundColor3 = currentTheme.accent
    btn.TextColor3 = Color3.fromRGB(240,240,240)
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = Sidebar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)

    local frame = Instance.new("ScrollingFrame", Content)
    frame.Visible = false
    frame.Size = UDim2.new(1,-6,1,-6)
    frame.Position = UDim2.new(0,3,0,3)
    frame.ScrollBarThickness = 6
    frame.BackgroundTransparency = 1
    local layout = Instance.new("UIListLayout", frame); layout.Padding = UDim.new(0,6)

    Pages[name] = {button = btn, frame = frame}

    btn.MouseButton1Click:Connect(function()
        if ActivePage then
            ActivePage.button.BackgroundColor3 = currentTheme.accent
            ActivePage.button.TextColor3 = Color3.new(1,1,1)
            ActivePage.frame.Visible = false
        end
        ActivePage = Pages[name]
        btn.BackgroundColor3 = currentTheme.highlight
        btn.TextColor3 = currentTheme.bg
        frame.Visible = true
    end)

    return frame
end

-- Helpers: UI widget creators
local function createTitle(parent, text)
    local label = Instance.new("TextLabel", parent)
    label.Size = UDim2.new(1,0,0,22)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextColor3 = Color3.fromRGB(230,230,230)
    label.Text = text
    label.TextXAlignment = Enum.TextXAlignment.Left
    return label
end

local function createSmallInput(parent, labelText, initialValue, onSet)
    local frame = Instance.new("Frame", parent); frame.Size = UDim2.new(1,0,0,48); frame.BackgroundTransparency = 1
    local label = Instance.new("TextLabel", frame); label.Size = UDim2.new(1,-110,0,18); label.Position = UDim2.new(0,0,0,0)
    label.BackgroundTransparency = 1; label.Font = Enum.Font.Gotham; label.TextSize = 13; label.TextColor3 = Color3.fromRGB(230,230,230); label.Text = labelText
    local box = Instance.new("TextBox", frame); box.Size = UDim2.new(0,92,0,30); box.Position = UDim2.new(1,-100,0,18)
    box.Text = tostring(initialValue); box.ClearTextOnFocus = false; box.Font = Enum.Font.GothamSemibold; box.TextSize = 13; box.TextColor3 = Color3.fromRGB(240,240,240)
    box.BackgroundColor3 = Color3.fromRGB(28,28,32); Instance.new("UICorner", box).CornerRadius = UDim.new(0,8)
    box.FocusLost:Connect(function()
        local num = tonumber(box.Text)
        if num then onSet(num) else box.Text = tostring(initialValue) end
    end)
    return frame
end

local function createToggleButton(parent, labelText, default, callback)
    local frame = Instance.new("Frame", parent); frame.Size = UDim2.new(1,0,0,38); frame.BackgroundTransparency = 1
    local label = Instance.new("TextLabel", frame); label.Size = UDim2.new(1,-70,1,0); label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham; label.TextSize = 13; label.TextXAlignment = Enum.TextXAlignment.Left; label.TextColor3 = Color3.fromRGB(235,235,235)
    label.Text = labelText
    local btn = Instance.new("TextButton", frame); btn.Size = UDim2.new(0,48,0,26); btn.Position = UDim2.new(1,-56,0.5,-13); btn.AutoButtonColor = false
    btn.BackgroundColor3 = default and Color3.fromRGB(50,200,100) or Color3.fromRGB(70,70,75); btn.Text = ""
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,14)
    local circle = Instance.new("Frame", btn); circle.Size = UDim2.new(0,20,0,20); circle.Position = default and UDim2.new(1,-22,0.5,-10) or UDim2.new(0,2,0.5,-10)
    circle.BackgroundColor3 = Color3.new(1,1,1); Instance.new("UICorner", circle).CornerRadius = UDim.new(1,0)
    local enabled = default
    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        btn.BackgroundColor3 = enabled and Color3.fromRGB(50,200,100) or Color3.fromRGB(70,70,75)
        circle:TweenPosition(enabled and UDim2.new(1,-22,0.5,-10) or UDim2.new(0,2,0.5,-10), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, .15, true)
        callback(enabled)
    end)
    return frame
end

local function createScrollList(parent, itemsFunc, selectedTable, highlightColor, height)
    local container = Instance.new("Frame", parent); container.Size = UDim2.new(1,0,0,height or 140); container.BackgroundTransparency = 1
    local scroll = Instance.new("ScrollingFrame", container); scroll.Size = UDim2.new(1,0,1,0); scroll.CanvasSize = UDim2.new(0,0,0,0); scroll.BackgroundTransparency = 1; scroll.ScrollBarThickness = 6
    local layout = Instance.new("UIListLayout", scroll); layout.Padding = UDim.new(0,6)
    local function refresh()
        for _, v in pairs(scroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
        local items = itemsFunc()
        for _, item in ipairs(items) do
            local btn = Instance.new("TextButton", scroll)
            btn.Size = UDim2.new(1,-8,0,34); btn.Position = UDim2.new(0,4,0,0)
            btn.BackgroundColor3 = selectedTable[item] and highlightColor or Color3.fromRGB(28,28,32)
            btn.Text = "  • " .. item; btn.Font = Enum.Font.Gotham; btn.TextSize = 13; btn.TextColor3 = Color3.fromRGB(230,230,230); btn.TextXAlignment = Enum.TextXAlignment.Left
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
            local checkFrame = Instance.new("Frame", btn); checkFrame.Size = UDim2.new(0,22,0,22); checkFrame.Position = UDim2.new(1,-30,0.5,-11); checkFrame.BackgroundColor3 = Color3.fromRGB(24,24,26); Instance.new("UICorner", checkFrame).CornerRadius = UDim.new(0,6)
            local checkLabel = Instance.new("TextLabel", checkFrame); checkLabel.Size = UDim2.new(1,0,1,0); checkLabel.BackgroundTransparency = 1; checkLabel.Text = selectedTable[item] and "✓" or ""; checkLabel.Font = Enum.Font.GothamSemibold; checkLabel.TextColor3 = Color3.fromRGB(230,230,230); checkLabel.TextSize = 14
            btn.MouseButton1Click:Connect(function()
                selectedTable[item] = not selectedTable[item]
                btn.BackgroundColor3 = selectedTable[item] and highlightColor or Color3.fromRGB(28,28,32)
                checkLabel.Text = selectedTable[item] and "✓" or ""
            end)
        end
        task.wait()
        scroll.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y + 8)
    end
    refresh()
    return container, refresh
end

-- Theme buttons creation
for name, data in pairs(THEMES) do
    local b = Instance.new("TextButton", ThemeContainer)
    b.Size = UDim2.new(0,14,0,14); b.BackgroundColor3 = data.highlight; b.Text = ""
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
    b.MouseButton1Click:Connect(function() 
        currentTheme = data
        -- apply
        MainFrame.BackgroundColor3 = data.bg
        TitleBar.BackgroundColor3 = data.accent
        ToggleButton.BackgroundColor3 = data.bg
        ToggleButton.ImageColor3 = data.highlight
        mfStroke.Color = data.accent
        for _, p in pairs(Pages) do p.button.BackgroundColor3 = data.accent; p.button.TextColor3 = Color3.new(1,1,1) end
    end)
end

-- Dragging
local dragging = false; local dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = input.Position; startPos = MainFrame.Position end
end)
TitleBar.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Open/close UI
local tweenOpen = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local tweenClose = TweenInfo.new(0.20, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local savedPos = MainFrame.Position
local function ToggleUI()
    if MainFrame.Visible then
        savedPos = MainFrame.Position
        TweenService:Create(MainFrame, tweenClose, { Size = UDim2.new(0,0,0,0) }):Play()
        task.wait(0.2)
        MainFrame.Visible = false
    else
        MainFrame.Position = savedPos
        MainFrame.Size = UDim2.new(0,0,0,0)
        MainFrame.Visible = true
        TweenService:Create(MainFrame, tweenOpen, { Size = UDim2.new(0.42,0,0.55,0) }):Play()
    end
end
ToggleButton.MouseButton1Click:Connect(ToggleUI)
UserInputService.InputBegan:Connect(function(input, gp) if not gp and input.KeyCode == Enum.KeyCode.LeftControl then ToggleUI() end end)

--=========================
-- Game-specific refs (adjust names based on game)
--=========================
local success, beeShopData = pcall(function() return player:WaitForChild("Data"):WaitForChild("BeeShop"):WaitForChild("CurrentStock") end)
if not success then beeShopData = nil end
local beesStorage = (ReplicatedStorage:FindFirstChild("Storage") and ReplicatedStorage.Storage:FindFirstChild("Bees")) or nil
local eggModifiers = (ReplicatedStorage:FindFirstChild("Storage") and ReplicatedStorage.Storage:FindFirstChild("EggModifiers")) or nil
local plotsFolder = (Workspace:FindFirstChild("Core") and Workspace.Core:FindFirstChild("Scriptable") and Workspace.Core.Scriptable:FindFirstChild("Plots")) or nil
local idleEvent = (ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("Idle")) or nil

-- =========================
-- Auto toggles & variables
-- =========================
local autoBuyBeeEnabled, autoBuyEggEnabled, autoGhostEnabled, autoRocketEnabled = false, false, false, false
local selectedBees, selectedEggNames, selectedEggModifiers = {}, {}, {}
local ghostKillCount, rocketCollectCount = 0, 0
local ghostTime, rocketTime = 0, 0
local originalWalkspeed = (player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.WalkSpeed) or 16
local isIdle, idleStartTime, idleConnection, idleCheckThread = false, nil, nil, nil
local currentGhostTarget, currentRocketTarget = nil, nil
local platform, currentTween = nil, nil

-- Left-click AFK default
local leftClickEnabled = true
local leftClickInterval = 900 -- seconds (15 minutes default)

-- Formatting helper
local function formatTime(s) local m = math.floor(s/60) local rs = s%60 return string.format("%02i:%02i", m, rs) end

-- Game helpers (attempt to be robust)
local function getOurPlotNumber()
    if not plotsFolder then return nil end
    for _, plot in pairs(plotsFolder:GetChildren()) do
        local title = plot:FindFirstChild("PlayerTitle")
        if title then
            local gui = title:FindFirstChild("SurfaceGui")
            if gui then
                local main = gui:FindFirstChild("Main")
                if main then
                    local label = main:FindFirstChild("PlayerName")
                    if label and label.Text == player.Name then return plot.Name end
                end
            end
        end
    end
    return nil
end

local function checkBeeStock()
    local stock = {}
    if not beeShopData then return stock end
    for i = 1, 11 do
        local slot = beeShopData:FindFirstChild("Slot" .. i)
        if slot then
            local beeId = slot:FindFirstChild("BeeId")
            if beeId and beeId.Value ~= "" then table.insert(stock, {slotIndex = i, beeName = beeId.Value}) end
        end
    end
    return stock
end

local function purchaseBee(slotIndex)
    pcall(function()
        local events = ReplicatedStorage:FindFirstChild("Events")
        if events and events:FindFirstChild("BeeShopHandler") then
            events.BeeShopHandler:FireServer("Purchase", {slotIndex = slotIndex, quantity = 1})
        end
    end)
end

local function checkAllEggs()
    local eggs = {}
    if not plotsFolder then return eggs end
    for _, plot in pairs(plotsFolder:GetChildren()) do
        local eggsFolder = plot:FindFirstChild("Eggs")
        if eggsFolder then
            for _, egg in pairs(eggsFolder:GetChildren()) do
                local primaryPart = egg:FindFirstChild("PrimaryPart")
                if primaryPart then
                    local attach = primaryPart:FindFirstChild("attach")
                    local assetName, modifierFolder = nil, nil
                    if attach then
                        local hover = attach:FindFirstChild("EggHover")
                        if hover then
                            local main = hover:FindFirstChild("Main")
                            if main then
                                local asset = main:FindFirstChild("AssetName")
                                if asset then assetName = asset.Text end
                            end
                        end
                    end
                    for _, child in pairs(primaryPart:GetChildren()) do
                        if child:IsA("Folder") then modifierFolder = child break end
                    end
                    if assetName then table.insert(eggs, {eggId = egg.Name, eggName = assetName, modifier = modifierFolder and modifierFolder.Name or nil}) end
                end
            end
        end
    end
    return eggs
end

local function purchaseEgg(eggId)
    pcall(function()
        local events = ReplicatedStorage:FindFirstChild("Events")
        if events and events:FindFirstChild("PurchaseConveyorEgg") then
            local plotNum = getOurPlotNumber()
            if plotNum then events.PurchaseConveyorEgg:FireServer(eggId, plotNum) end
        end
    end)
end

local function getAllGhosts()
    local ghosts = {}
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj:IsA("Model") and (string.find(obj.Name, "NormalGhost_") or string.find(obj.Name, "FastGhost_") or string.find(obj.Name, "SlowGhost_")) then
            local rootPart = obj:FindFirstChild("HumanoidRootPart")
            if rootPart then table.insert(ghosts, obj) end
        end
    end
    return ghosts
end

local function attackGhost()
    pcall(function()
        local events = ReplicatedStorage:FindFirstChild("Events")
        if events and events:FindFirstChild("Swatter") then events.Swatter:FireServer() end
    end)
end

local function getAllRockets()
    local rockets = {}
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj:IsA("Model") and obj.Name == "RocketLanding" then
            local hrp = obj:FindFirstChild("HumanoidRootPart")
            if hrp then table.insert(rockets, obj) end
        end
    end
    return rockets
end

local function collectRocket(rocket)
    pcall(function()
        local hrp = rocket:FindFirstChild("HumanoidRootPart")
        if hrp then
            local prompt = hrp:FindFirstChild("ProximityPrompt")
            if prompt then fireproximityprompt(prompt) end
        end
    end)
end

-- Platform & movement helpers
local function createPlatform()
    if platform then platform:Destroy() end
    platform = Instance.new("Part", Workspace)
    platform.Name = "FarmPlatform"
    platform.Size = Vector3.new(6,0.5,6)
    platform.Anchored = true
    platform.CanCollide = true
    platform.Transparency = 0.8
    platform.Material = Enum.Material.ForceField
    platform.BrickColor = BrickColor.new("Bright blue")
    return platform
end

local function tweenToPosition(targetPos)
    local char = player.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    if not platform or not platform.Parent then platform = createPlatform() end
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
    local suc, err = pcall(function()
        local t = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(targetPos)})
        t:Play()
        t.Completed:Wait()
    end)
    return suc
end

-- =========================
-- Auto loops
-- =========================
local function autoBuyBeeLoop()
    while autoBuyBeeEnabled do
        local stock = checkBeeStock()
        for _, item in pairs(stock) do
            if not autoBuyBeeEnabled then break end
            if selectedBees[item.beeName] then purchaseBee(item.slotIndex); task.wait(0.12) end
        end
        task.wait(0.3)
    end
end

local function autoBuyEggLoop()
    while autoBuyEggEnabled do
        local eggs = checkAllEggs()
        for _, egg in pairs(eggs) do
            if not autoBuyEggEnabled then break end
            local nameMatch, modMatch = false, false
            local nameCount, modCount = 0, 0
            for name, sel in pairs(selectedEggNames) do if sel then nameCount = nameCount + 1 if egg.eggName == name then nameMatch = true end end end
            if nameCount == 0 then nameMatch = true end
            for mod, sel in pairs(selectedEggModifiers) do if sel then modCount = modCount + 1 if egg.modifier == mod then modMatch = true end end end
            if modCount == 0 then modMatch = true end
            if nameMatch and modMatch then purchaseEgg(egg.eggId); task.wait(0.12) end
        end
        task.wait(0.3)
    end
end

local function autoGhostLoop(statusLabel)
    local startTime = tick(); platform = createPlatform()
    while autoGhostEnabled do
        local ghosts = getAllGhosts()
        if #ghosts > 0 then
            for _, ghost in pairs(ghosts) do
                if not autoGhostEnabled then break end
                if ghost and ghost.Parent then
                    currentGhostTarget = ghost
                    local root = ghost:FindFirstChild("HumanoidRootPart")
                    if root then
                        local followConn
                        followConn = RunService.Heartbeat:Connect(function()
                            if not ghost or not ghost.Parent or not autoGhostEnabled then if followConn then followConn:Disconnect() end return end
                            local char = player.Character; if not char then return end
                            local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
                            local pos = root.Position
                            hrp.CFrame = CFrame.new(pos)
                        end)
                        while ghost and ghost.Parent and autoGhostEnabled do
                            attackGhost()
                            task.wait(0.1)
                        end
                        if followConn then followConn:Disconnect() end
                    end
                    currentGhostTarget = nil
                    task.wait(0.08)
                end
            end
        else task.wait(0.5) end
        ghostTime = math.floor(tick() - startTime)
        if statusLabel and statusLabel.Text then statusLabel.Text = (autoGhostEnabled and "🟢 สถานะ: เปิด " or "🔴 สถานะ: ปิด ") .. " | เวลา: " .. formatTime(ghostTime) end
    end
    if platform then platform:Destroy(); platform = nil end
    ghostTime = 0
    if statusLabel then statusLabel.Text = "🔴 สถานะ: ปิด" end
end

local function autoRocketLoop(statusLabel)
    local startTime = tick(); platform = createPlatform()
    while autoRocketEnabled do
        local rockets = getAllRockets()
        if #rockets > 0 then
            for _, rocket in pairs(rockets) do
                if not autoRocketEnabled then break end
                if rocket and rocket.Parent then
                    currentRocketTarget = rocket
                    local rr = rocket:FindFirstChild("HumanoidRootPart")
                    if rr then
                        local targetPos = rr.Position + Vector3.new(0,0,3)
                        if tweenToPosition(targetPos) then
                            collectRocket(rocket); task.wait(0.5)
                        end
                    end
                    currentRocketTarget = nil
                end
            end
        else task.wait(1) end
        rocketTime = math.floor(tick() - startTime)
        if statusLabel and statusLabel.Text then statusLabel.Text = (autoRocketEnabled and "🟢 สถานะ: เปิด " or "🔴 สถานะ: ปิด ") .. " | เวลา: " .. formatTime(rocketTime) end
    end
    if platform then platform:Destroy(); platform = nil end
    rocketTime = 0
    if statusLabel then statusLabel.Text = "🔴 สถานะ: ปิด" end
end

-- =========================
-- Anti-idle + Left-click AFK
-- =========================
local antiAfkEnabled = true
local afkWalkDuration, afkWaitDuration = 5, 5
local jumpInterval = 30000 -- ms

local function initAntiIdleSystem()
    player.Idled:Connect(function()
        if not isIdle then
            isIdle = true; idleStartTime = os.time()
            if idleConnection then idleConnection:Disconnect() end
            idleConnection = UserInputService.InputBegan:Connect(function()
                isIdle = false; idleStartTime = nil
                if idleConnection then idleConnection:Disconnect(); idleConnection = nil end
                if idleCheckThread then task.cancel(idleCheckThread); idleCheckThread = nil end
            end)
            idleCheckThread = task.spawn(function()
                while isIdle and player.Parent do
                    if idleStartTime and os.time() - idleStartTime >= 900 then
                        if idleEvent and idleEvent.FireServer then pcall(function() idleEvent:FireServer() end) end
                        isIdle = false; idleStartTime = nil
                        if idleConnection then idleConnection:Disconnect(); idleConnection = nil end
                        break
                    end
                    task.wait(30)
                end
                idleCheckThread = nil
            end)
        end
    end)
end
spawn(initAntiIdleSystem)

-- small AFK movement
spawn(function()
    while true do
        if antiAfkEnabled and not autoGhostEnabled and not autoRocketEnabled then
            local char = player.Character; local h = char and char:FindFirstChild("Humanoid"); local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if h and hrp then
                local ori = hrp.CFrame
                h:Move(Vector3.new(0,0,-1), Enum.WalkDirection.Forward); task.wait(afkWalkDuration)
                h:Move(Vector3.new(0,0,0), Enum.WalkDirection.Forward)
                hrp.CFrame = ori
                task.wait(afkWaitDuration)
            else task.wait(1) end
        else task.wait(1) end
    end
end)

-- left-click AFK loop
spawn(function()
    while true do
        task.wait(math.max(1, leftClickInterval))
        if leftClickEnabled and antiAfkEnabled then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton1(Vector2.new(0,0))
            end)
        end
    end
end)

-- =========================
-- BUILD PAGES & UI CONTENT
-- =========================
-- Create pages
local page_order = {"Main","🐝 Auto Bee","🥚 Auto Egg","👻 Auto Ghost","🚀 Auto Rocket","Settings"}
for _, name in ipairs(page_order) do CreateCategory(name) end

-- Fill Main
local mainContent = Pages["Main"].frame
createTitle(mainContent, "Welcome to VeryFun SHOP - Mobile")
local info = Instance.new("TextLabel", mainContent)
info.Size = UDim2.new(1,0,0,48)
info.BackgroundTransparency = 1
info.Text = "Sidebar เลือกเมนู — ปรับค่าจาก Settings"
info.Font = Enum.Font.Gotham; info.TextSize = 13; info.TextColor3 = Color3.fromRGB(220,220,220); info.TextWrapped = true

-- Auto Bee content
local beeContent = Pages["🐝 Auto Bee"].frame
createTitle(beeContent, "Auto Bee — เลือกผึ้ง")
local function getBees()
    local list = {}
    if beesStorage then
        for _, b in pairs(beesStorage:GetChildren()) do table.insert(list, b.Name) end
        table.sort(list)
    end
    return list
end
local beeScroll, refreshBeeList = createScrollList(beeContent, getBees, selectedBees, currentTheme.highlight, 130)
local beeToggle = Instance.new("TextButton", beeContent)
beeToggle.Size = UDim2.new(1,0,0,36); beeToggle.Text = "▶ เริ่มซื้อผึ้ง"; beeToggle.Font = Enum.Font.GothamSemibold; beeToggle.TextSize = 14
beeToggle.TextColor3 = Color3.fromRGB(255,255,255); beeToggle.BackgroundColor3 = currentTheme.highlight; Instance.new("UICorner", beeToggle).CornerRadius = UDim.new(0,8)
beeToggle.MouseButton1Click:Connect(function()
    autoBuyBeeEnabled = not autoBuyBeeEnabled
    beeToggle.Text = autoBuyBeeEnabled and "⏸ หยุดซื้อผึ้ง" or "▶ เริ่มซื้อผึ้ง"
    beeToggle.BackgroundColor3 = autoBuyBeeEnabled and Color3.fromRGB(220,60,60) or currentTheme.highlight
    if autoBuyBeeEnabled then spawn(autoBuyBeeLoop) end
end)

-- Auto Egg content
local eggContent = Pages["🥚 Auto Egg"].frame
createTitle(eggContent, "Auto Egg — เลือกไข่/บัฟ")
local function getEggNames()
    return {"Seedling Egg","Leafy Egg","Buzzing Egg","Icey Egg","Blaze Egg","Crystal Egg","Toxic Egg","Prism Egg","Void Egg","Duality Egg","Inspector Egg"}
end
local function getEggMods()
    local mods = {}
    if eggModifiers then for _, m in pairs(eggModifiers:GetChildren()) do if m:IsA("Folder") then table.insert(mods, m.Name) end end end
    table.sort(mods)
    return mods
end
local eggScrollNames, r1 = createScrollList(eggContent, getEggNames, selectedEggNames, currentTheme.highlight, 120)
local eggScrollMods, r2 = createScrollList(eggContent, getEggMods, selectedEggModifiers, currentTheme.highlight, 120)
local eggToggle = Instance.new("TextButton", eggContent)
eggToggle.Size = UDim2.new(1,0,0,36); eggToggle.Text = "▶ เริ่มซื้อไข่"; eggToggle.Font = Enum.Font.GothamSemibold; eggToggle.TextSize = 14
eggToggle.TextColor3 = Color3.fromRGB(255,255,255); eggToggle.BackgroundColor3 = Color3.fromRGB(255,128,0); Instance.new("UICorner", eggToggle).CornerRadius = UDim.new(0,8)
eggToggle.MouseButton1Click:Connect(function()
    autoBuyEggEnabled = not autoBuyEggEnabled
    eggToggle.Text = autoBuyEggEnabled and "⏸ หยุดซื้อไข่" or "▶ เริ่มซื้อไข่"
    eggToggle.BackgroundColor3 = autoBuyEggEnabled and Color3.fromRGB(200,50,50) or Color3.fromRGB(255,128,0)
    if autoBuyEggEnabled then spawn(autoBuyEggLoop) end
end)

-- Auto Ghost content
local ghostContent = Pages["👻 Auto Ghost"].frame
createTitle(ghostContent, "Auto Ghost — ฟาร์มผี")
local ghostStatus = Instance.new("TextLabel", ghostContent)
ghostStatus.Size = UDim2.new(1,0,0,30); ghostStatus.BackgroundColor3 = Color3.fromRGB(36,36,42); ghostStatus.Text = "🔴 สถานะ: ปิด"; ghostStatus.TextColor3 = Color3.fromRGB(255,255,255)
Instance.new("UICorner", ghostStatus).CornerRadius = UDim.new(0,8)
local ghostCount = Instance.new("TextLabel", ghostContent); ghostCount.Size = UDim2.new(1,0,0,22); ghostCount.BackgroundTransparency = 1; ghostCount.TextColor3 = Color3.fromRGB(220,220,220)
spawn(function() while task.wait(0.5) do if ghostCount.Parent then ghostCount.Text = "👻 ตีแล้ว: " .. tostring(ghostKillCount) else break end end end)
local ghostToggleBtn = Instance.new("TextButton", ghostContent)
ghostToggleBtn.Size = UDim2.new(1,0,0,36); ghostToggleBtn.Text = "▶ เริ่มฟาร์มผี"; ghostToggleBtn.Font = Enum.Font.GothamSemibold; ghostToggleBtn.TextSize = 14
ghostToggleBtn.TextColor3 = Color3.fromRGB(255,255,255); ghostToggleBtn.BackgroundColor3 = Color3.fromRGB(120,60,150); Instance.new("UICorner", ghostToggleBtn).CornerRadius = UDim.new(0,8)
ghostToggleBtn.MouseButton1Click:Connect(function()
    autoGhostEnabled = not autoGhostEnabled
    ghostToggleBtn.Text = autoGhostEnabled and "⏸ หยุดฟาร์มผี" or "▶ เริ่มฟาร์มผี"
    ghostToggleBtn.BackgroundColor3 = autoGhostEnabled and Color3.fromRGB(200,50,50) or Color3.fromRGB(120,60,150)
    if autoGhostEnabled then spawn(function() autoGhostLoop(ghostStatus) end) end
end)

-- Auto Rocket content
local rocketContent = Pages["🚀 Auto Rocket"].frame
createTitle(rocketContent, "Auto Rocket — เก็บจรวด")
local rocketStatus = Instance.new("TextLabel", rocketContent)
rocketStatus.Size = UDim2.new(1,0,0,30); rocketStatus.BackgroundColor3 = Color3.fromRGB(36,36,42); rocketStatus.Text = "🔴 สถานะ: ปิด"; rocketStatus.TextColor3 = Color3.fromRGB(255,255,255)
Instance.new("UICorner", rocketStatus).CornerRadius = UDim.new(0,8)
local rocketCountLbl = Instance.new("TextLabel", rocketContent); rocketCountLbl.Size = UDim2.new(1,0,0,22); rocketCountLbl.BackgroundTransparency = 1; rocketCountLbl.TextColor3 = Color3.fromRGB(220,220,220)
spawn(function() while task.wait(0.5) do if rocketCountLbl.Parent then rocketCountLbl.Text = "🚀 เก็บแล้ว: " .. tostring(rocketCollectCount) else break end end end)
local rocketToggleBtn = Instance.new("TextButton", rocketContent)
rocketToggleBtn.Size = UDim2.new(1,0,0,36); rocketToggleBtn.Text = "▶ เริ่มเก็บจรวด"; rocketToggleBtn.Font = Enum.Font.GothamSemibold; rocketToggleBtn.TextSize = 14
rocketToggleBtn.TextColor3 = Color3.fromRGB(255,255,255); rocketToggleBtn.BackgroundColor3 = Color3.fromRGB(50,150,50); Instance.new("UICorner", rocketToggleBtn).CornerRadius = UDim.new(0,8)
rocketToggleBtn.MouseButton1Click:Connect(function()
    autoRocketEnabled = not autoRocketEnabled
    rocketToggleBtn.Text = autoRocketEnabled and "⏸ หยุดเก็บจรวด" or "▶ เริ่มเก็บจรวด"
    rocketToggleBtn.BackgroundColor3 = autoRocketEnabled and Color3.fromRGB(200,50,50) or Color3.fromRGB(50,150,50)
    if autoRocketEnabled then spawn(function() autoRocketLoop(rocketStatus) end) end
end)

-- Settings content
local settingsContent = Pages["Settings"].frame
createTitle(settingsContent, "Settings / System")
local afkToggle = createToggleButton(settingsContent, "เปิด Anti-AFK", antiAfkEnabled, function(state) antiAfkEnabled = state end)
createSmallInput(settingsContent, "AFK Walk (วินาที)", afkWalkDuration, function(v) afkWalkDuration = tonumber(v) or afkWalkDuration end)
createSmallInput(settingsContent, "AFK Wait (วินาที)", afkWaitDuration, function(v) afkWaitDuration = tonumber(v) or afkWaitDuration end)
createSmallInput(settingsContent, "Jump Interval (ms)", jumpInterval, function(v) jumpInterval = tonumber(v) or jumpInterval end)
createTitle(settingsContent, "Anti-AFK — Click Left")
local leftClickToggle = createToggleButton(settingsContent, "คลิกซ้ายทุก X วินาที", leftClickEnabled, function(state) leftClickEnabled = state end)
createSmallInput(settingsContent, "ตั้งเวลา คลิกซ้าย (วินาที)", leftClickInterval, function(v) leftClickInterval = tonumber(v) or leftClickInterval end)
createSmallInput(settingsContent, "เฟรมเรท (FPS)", (getgenv and getgenv().Fps) or 120, function(v) applyFPS(v) end)

local destroyBtn = Instance.new("TextButton", settingsContent)
destroyBtn.Size = UDim2.new(0,140,0,34); destroyBtn.Text = "Destroy UI"; destroyBtn.Font = Enum.Font.GothamSemibold; destroyBtn.TextSize = 14
destroyBtn.BackgroundColor3 = currentTheme.accent; destroyBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", destroyBtn).CornerRadius = UDim.new(0,8)
destroyBtn.MouseButton1Click:Connect(function()
    autoBuyBeeEnabled = false; autoBuyEggEnabled = false; autoGhostEnabled = false; autoRocketEnabled = false
    local g = PlayerGui:FindFirstChild(UI_NAME); if g then g:Destroy() end
end)

-- Open first page
Pages["Main"].button:MouseButton1Click()

-- Make UI visible
MainFrame.Visible = true

-- End of file
