
-- ========== Services & base ==========
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

-- ========== Constants ==========
local UI_NAME = "VeryFunSHOP_FinalCompact"
local LOGO_ID = "rbxassetid://82270910588453"
local HWID_URL = "https://raw.githubusercontent.com/amnad2003/veryfun_autofarm/refs/heads/main/hwidPremium_lock.lua"

-- ========== Theme list ==========
local THEMES = {
    Mint =   { bg = Color3.fromHex("#0F1720"), accent = Color3.fromHex("#1F2937"), highlight = Color3.fromHex("#66FFCC") },
    Red =    { bg = Color3.fromHex("#0F0A0A"), accent = Color3.fromHex("#241111"), highlight = Color3.fromHex("#FF5C5C") },
    Blue =   { bg = Color3.fromHex("#071022"), accent = Color3.fromHex("#0E2438"), highlight = Color3.fromHex("#7FB3FF") },
    Pink =   { bg = Color3.fromHex("#120812"), accent = Color3.fromHex("#261429"), highlight = Color3.fromHex("#FF8FD8") },
    Purple = { bg = Color3.fromHex("#0B0612"), accent = Color3.fromHex("#221633"), highlight = Color3.fromHex("#B47DFF") },
    Gold =   { bg = Color3.fromHex("#0B0B06"), accent = Color3.fromHex("#2A260F"), highlight = Color3.fromHex("#FFC857") }
}
local currentTheme = THEMES.Mint

-- Remove old UI if exists
local old = PlayerGui:FindFirstChild(UI_NAME)
if old then old:Destroy() end

-- ========= HWID helpers & check =========
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

    local blur = Instance.new("BlurEffect", Lighting); blur.Size = 12

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0, 420, 0, 240)
    frame.Position = UDim2.new(0.5, -210, 0.5, -120)
    frame.BackgroundColor3 = Color3.fromRGB(18,18,20)
    frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
    local stroke = Instance.new("UIStroke", frame); stroke.Color = Color3.fromRGB(100,100,100); stroke.Thickness = 1

    local bar = Instance.new("Frame", frame); bar.Size = UDim2.new(1,0,0,44); bar.BackgroundColor3 = Color3.fromRGB(28,28,28)
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0,12)

    local title = Instance.new("TextLabel", bar); title.Size = UDim2.new(1,-60,1,0); title.Position = UDim2.new(0,12,0,0)
    title.BackgroundTransparency = 1; title.Font = Enum.Font.GothamBold; title.TextSize = 18; title.TextColor3 = Color3.fromRGB(240,80,80)
    title.Text = "VERYFUN SHOP — HWID LOCK"; title.TextXAlignment = Enum.TextXAlignment.Left

    local close = Instance.new("TextButton", bar); close.Size = UDim2.new(0,44,0,34); close.Position = UDim2.new(1,-52,0.5,-17)
    close.BackgroundTransparency = 1; close.Font = Enum.Font.GothamBold; close.Text = "✕"; close.TextSize = 20; close.TextColor3 = Color3.fromRGB(230,80,80)
    close.MouseButton1Click:Connect(function() frame:Destroy(); blur:Destroy() end)

    local hwidLabel = Instance.new("TextLabel", frame)
    hwidLabel.Size = UDim2.new(1,-24,0,120); hwidLabel.Position = UDim2.new(0,12,0,56)
    hwidLabel.BackgroundTransparency = 1; hwidLabel.Font = Enum.Font.Gotham; hwidLabel.TextSize = 14; hwidLabel.TextColor3 = Color3.fromRGB(230,230,230)
    hwidLabel.TextWrapped = true; hwidLabel.Text = "HWID ของคุณ:\n" .. tostring(myHWID)

    local copyBtn = Instance.new("TextButton", frame)
    copyBtn.Size = UDim2.new(0,180,0,34); copyBtn.Position = UDim2.new(0.5,-90,1,-54)
    copyBtn.BackgroundColor3 = Color3.fromRGB(64,64,64); copyBtn.Font = Enum.Font.GothamBold; copyBtn.Text = "คัดลอก HWID"; copyBtn.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0,8)
    copyBtn.MouseButton1Click:Connect(function()
        pcall(setclipboard, tostring(myHWID))
        copyBtn.Text = "คัดลอกแล้ว!"
        copyBtn.BackgroundColor3 = Color3.fromRGB(50,140,60)
        task.delay(1.2, function() if copyBtn.Parent then copyBtn.Text = "คัดลอก HWID"; copyBtn.BackgroundColor3 = Color3.fromRGB(64,64,64) end end)
    end)
end

if not IsHWIDAllowed() then
    ShowHWIDScreen()
    return
end

-- ========== applyFPS (auto detect) ==========
local function applyFPS(value)
    value = tonumber(value)
    if not value or value < 1 then return end
    if setfpscap then pcall(setfpscap, value); return end
    if setfps then pcall(setfps, value); return end
    if set_fps_cap then pcall(set_fps_cap, value); return end
    if set_fps then pcall(set_fps, value); return end
    warn("⚠ Executor ของคุณอาจไม่รองรับการตั้ง FPS")
end

-- ========== UI Creation ==========
local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.Name = UI_NAME
ScreenGui.ResetOnSpawn = false

-- Auto UIScale responsive
local uiScale = Instance.new("UIScale", ScreenGui)
do
    local w = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize.X or 800
    if w <= 360 then uiScale.Scale = 0.68
    elseif w <= 480 then uiScale.Scale = 0.78
    elseif w <= 720 then uiScale.Scale = 0.88
    else uiScale.Scale = 1 end
end

-- ========== Utility: FixText (prevent overflow) ==========
local function FixText(obj)
    if not obj then return end
    -- apply common safe properties for labels/buttons/textboxes
    if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
        obj.TextWrapped = true
        obj.TextXAlignment = obj.TextXAlignment or Enum.TextXAlignment.Left
        obj.TextYAlignment = obj.TextYAlignment or Enum.TextYAlignment.Center
        obj.ClipsDescendants = true
        -- UITextSizeConstraint to auto-shrink text but not below min
        local constr = obj:FindFirstChildOfClass("UITextSizeConstraint")
        if not constr then
            constr = Instance.new("UITextSizeConstraint")
            constr.Parent = obj
            constr.MaxTextSize = obj.TextSize or 14
            constr.MinTextSize = 10
        else
            constr.MaxTextSize = obj.TextSize or constr.MaxTextSize
        end
    end
end

local function addCorner(parent, radius)
    local c = Instance.new("UICorner", parent)
    c.CornerRadius = UDim.new(0, radius or 8)
    return c
end


currentTheme = THEMES.Mint

local ToggleButton = Instance.new("ImageButton", ScreenGui)
ToggleButton.Size = UDim2.new(0,31,0,31)
ToggleButton.Position = UDim2.new(0,18,0,140)
ToggleButton.Image = LOGO_ID
ToggleButton.ImageColor3 = currentTheme.highlight
ToggleButton.BackgroundColor3 = currentTheme.bg
addCorner(ToggleButton,8)

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0.52, 0, 0.85, 0)
MainFrame.Position = UDim2.new(0.5, 0, 0.4, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = currentTheme.bg
addCorner(MainFrame,10)
local mfStroke = Instance.new("UIStroke", MainFrame); mfStroke.Color = currentTheme.accent; mfStroke.Thickness = 1

local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size = UDim2.new(1,0,0,36); TitleBar.BackgroundColor3 = currentTheme.accent
addCorner(TitleBar,10)
local Title = Instance.new("TextLabel", TitleBar)
Title.Size = UDim2.new(1,-10,1,0); Title.Position = UDim2.new(0,10,0,0)
Title.BackgroundTransparency = 1; Title.Font = Enum.Font.GothamSemibold; Title.TextSize = 14
Title.TextColor3 = Color3.fromRGB(245,245,245); Title.Text = "VeryFun SHOP | BeeGarden"; Title.TextXAlignment = Enum.TextXAlignment.Left
FixText(Title)

local ThemeContainer = Instance.new("Frame", TitleBar)
ThemeContainer.Size = UDim2.new(0,96,1,0); ThemeContainer.Position = UDim2.new(1,-100,0,0); ThemeContainer.BackgroundTransparency = 1
local tList = Instance.new("UIListLayout", ThemeContainer); tList.FillDirection = Enum.FillDirection.Horizontal; tList.Padding = UDim.new(0,3); tList.HorizontalAlignment = Enum.HorizontalAlignment.Right

local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0.18,0,1,-36)
Sidebar.Position = UDim2.new(0,0,0,43)
Sidebar.BackgroundTransparency = 1
local SideLayout = Instance.new("UIListLayout", Sidebar); SideLayout.Padding = UDim.new(0,6)

local Content = Instance.new("Frame", MainFrame)
Content.Size = UDim2.new(0.82,0,1,-36)
Content.Position = UDim2.new(0.18,0,0,36)
Content.BackgroundTransparency = 1

local Pages = {}
local ActivePage = nil

local function CreateCategory(name, icon)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,-10,0,26)
    btn.BackgroundColor3 = currentTheme.accent
    btn.TextColor3 = Color3.fromRGB(245,245,245)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Text = "  " .. (icon or "") .. "  " .. name
    btn.Parent = Sidebar
    addCorner(btn,8)
    FixText(btn)

    local frame = Instance.new("ScrollingFrame", Content)
    frame.Visible = false
    frame.Size = UDim2.new(1,-6,1,-6)
    frame.Position = UDim2.new(0,3,0,3)
    frame.ScrollBarThickness = 6
    frame.BackgroundTransparency = 1
    frame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    local layout = Instance.new("UIListLayout", frame); layout.Padding = UDim.new(0,8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    local function updateCanvas()
        task.wait()
        local s = layout.AbsoluteContentSize.Y + 20
        pcall(function() frame.CanvasSize = UDim2.new(0,0,0, s) end)
    end
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
    updateCanvas()

    Pages[name] = {button = btn, frame = frame, layout = layout}

    btn.MouseButton1Click:Connect(function()
        if ActivePage then
            ActivePage.button.BackgroundColor3 = currentTheme.accent
            ActivePage.button.TextColor3 = Color3.fromRGB(245,245,245)
            ActivePage.frame.Visible = false
        end
        ActivePage = Pages[name]
        btn.BackgroundColor3 = currentTheme.highlight
        btn.TextColor3 = currentTheme.bg
        frame.Visible = true
    end)

    return frame
end

local function createTitle(parent, text)
    local t = Instance.new("TextLabel", parent)
    t.Size = UDim2.new(1,0,0,20)
    t.BackgroundTransparency = 1
    t.Font = Enum.Font.GothamBold; t.TextSize = 13
    t.TextColor3 = Color3.fromRGB(230,230,230)
    t.Text = text; t.TextXAlignment = Enum.TextXAlignment.Left
    FixText(t)
    return t
end

local function createSmallInput(parent, labelText, initialValue, onSet)
    local frame = Instance.new("Frame", parent); frame.Size = UDim2.new(1,0,0,44); frame.BackgroundTransparency = 1
    local label = Instance.new("TextLabel", frame); label.Size = UDim2.new(1,-100,0,16); label.Position = UDim2.new(0,0,0,0)
    label.BackgroundTransparency = 1; label.Font = Enum.Font.Gotham; label.TextSize = 12; label.TextColor3 = Color3.fromRGB(230,230,230); label.Text = labelText
    FixText(label)
    local box = Instance.new("TextBox", frame); box.Size = UDim2.new(0,92,0,28); box.Position = UDim2.new(1,-96,0,14)
    box.Text = tostring(initialValue); box.ClearTextOnFocus = false; box.Font = Enum.Font.GothamSemibold; box.TextSize = 12; box.TextColor3 = Color3.fromRGB(240,240,240)
    box.BackgroundColor3 = Color3.fromRGB(28,28,32); addCorner(box,8)
    FixText(box)
    box.FocusLost:Connect(function(enter)
        local num = tonumber(box.Text)
        if num then onSet(num) else box.Text = tostring(initialValue) end
    end)
    return frame
end

local function createToggleButton(parent, labelText, default, callback)
    local frame = Instance.new("Frame", parent); frame.Size = UDim2.new(1,0,0,36); frame.BackgroundTransparency = 1
    local label = Instance.new("TextLabel", frame); label.Size = UDim2.new(1,-70,1,0); label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham; label.TextSize = 12; label.TextColor3 = Color3.fromRGB(235,235,235); label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = labelText; FixText(label)
    local btn = Instance.new("TextButton", frame); btn.Size = UDim2.new(0,44,0,26); btn.Position = UDim2.new(1,-52,0.5,-13); btn.AutoButtonColor = false
    btn.BackgroundColor3 = default and Color3.fromRGB(50,200,100) or Color3.fromRGB(70,70,75); btn.Text = ""
    addCorner(btn,14)
    local circle = Instance.new("Frame", btn); circle.Size = UDim2.new(0,20,0,20); circle.Position = default and UDim2.new(1,-22,0.5,-10) or UDim2.new(0,2,0.5,-10)
    circle.BackgroundColor3 = Color3.fromRGB(255,255,255); addCorner(circle,20)
    local enabled = default
    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        btn.BackgroundColor3 = enabled and Color3.fromRGB(50,200,100) or Color3.fromRGB(70,70,75)
        circle:TweenPosition(enabled and UDim2.new(1,-22,0.5,-10) or UDim2.new(0,2,0.5,-10), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, .15, true)
        callback(enabled)
    end)
    FixText(btn); FixText(label)
    return frame
end

local function createScrollList(parent, itemsFunc, selectedTable, highlightColor, height)
    local h = height or 120
    local container = Instance.new("Frame", parent); container.Size = UDim2.new(1,0,0,h); container.BackgroundTransparency = 1
    local scroll = Instance.new("ScrollingFrame", container); scroll.Size = UDim2.new(1,0,1,0); scroll.BackgroundTransparency = 1; scroll.ScrollBarThickness = 6
    local layout = Instance.new("UIListLayout", scroll); layout.Padding = UDim.new(0,6)
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        pcall(function() scroll.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y + 24) end)
    end)
    local function refresh()
        for _, v in pairs(scroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
        local items = itemsFunc()
        for _, item in ipairs(items) do
            local btn = Instance.new("TextButton", scroll); btn.Size = UDim2.new(1,-8,0,32); btn.Position = UDim2.new(0,4,0,0)
            btn.BackgroundColor3 = selectedTable[item] and highlightColor or Color3.fromRGB(28,28,32)
            btn.Text = "  • " .. item; btn.Font = Enum.Font.Gotham; btn.TextSize = 13; btn.TextColor3 = Color3.fromRGB(230,230,230); btn.TextXAlignment = Enum.TextXAlignment.Left
            addCorner(btn,8)
            local checkFrame = Instance.new("Frame", btn); checkFrame.Size = UDim2.new(0,20,0,20); checkFrame.Position = UDim2.new(1,-28,0.5,-10)
            checkFrame.BackgroundColor3 = Color3.fromRGB(26,26,28); addCorner(checkFrame,6)
            local checkLabel = Instance.new("TextLabel", checkFrame); checkLabel.Size = UDim2.new(1,0,1,0); checkLabel.BackgroundTransparency = 1; checkLabel.Text = selectedTable[item] and "✓" or ""
            checkLabel.Font = Enum.Font.GothamSemibold; checkLabel.TextColor3 = Color3.fromRGB(230,230,230); checkLabel.TextSize = 14
            FixText(btn); FixText(checkLabel)
            btn.MouseButton1Click:Connect(function()
                selectedTable[item] = not selectedTable[item]
                btn.BackgroundColor3 = selectedTable[item] and highlightColor or Color3.fromRGB(28,28,32)
                checkLabel.Text = selectedTable[item] and "✓" or ""
            end)
        end
        task.wait()
        pcall(function() scroll.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y + 24) end)
    end
    refresh()
    return container, refresh
end

for name, data in pairs(THEMES) do
    local b = Instance.new("TextButton", ThemeContainer)
    b.Size = UDim2.new(0,12,0,12); b.BackgroundColor3 = data.highlight; b.Text = ""
    addCorner(b,6)
    b.MouseButton1Click:Connect(function()
        currentTheme = data
        MainFrame.BackgroundColor3 = data.bg
        TitleBar.BackgroundColor3 = data.accent
        ToggleButton.BackgroundColor3 = data.bg
        ToggleButton.ImageColor3 = data.highlight
        mfStroke.Color = data.accent
        for _, p in pairs(Pages) do p.button.BackgroundColor3 = data.accent; p.button.TextColor3 = Color3.fromRGB(245,245,245) end
    end)
end

local dragging, dragStart, startPos = false, nil, nil
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

local tweenOpen = TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local tweenClose = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local savedPos = MainFrame.Position
local function ToggleUI()
    if MainFrame.Visible then
        savedPos = MainFrame.Position
        TweenService:Create(MainFrame, tweenClose, {Size = UDim2.new(0,31,0,31)}):Play()
        task.wait(0.18)
        MainFrame.Visible = false
    else
        MainFrame.Position = savedPos
        MainFrame.Size = UDim2.new(0,0,0,0)
        MainFrame.Visible = true
        TweenService:Create(MainFrame, tweenOpen, {Size = UDim2.new(0.52,0,0.85,0)}):Play()
    end
end
ToggleButton.MouseButton1Click:Connect(ToggleUI)
UserInputService.InputBegan:Connect(function(input, gp) if not gp and input.KeyCode == Enum.KeyCode.LeftControl then ToggleUI() end end)

local function safe(path)
    local ok, res = pcall(function() return path end)
    if ok then return res end
    return nil
end

local beeShopData = safe(player and player:FindFirstChild("Data") and player.Data:FindFirstChild("BeeShop") and player.Data.BeeShop:FindFirstChild("CurrentStock"))
local beesStorage = safe(ReplicatedStorage and ReplicatedStorage:FindFirstChild("Storage") and ReplicatedStorage.Storage:FindFirstChild("Bees"))
local eggModifiers = safe(ReplicatedStorage and ReplicatedStorage:FindFirstChild("Storage") and ReplicatedStorage.Storage:FindFirstChild("EggModifiers"))
local plotsFolder = safe(Workspace and Workspace:FindFirstChild("Core") and Workspace.Core:FindFirstChild("Scriptable") and Workspace.Core.Scriptable:FindFirstChild("Plots"))
local idleEvent = safe(ReplicatedStorage and ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("Idle"))

local autoBuyBeeEnabled, autoBuyEggEnabled, autoGhostEnabled, autoRocketEnabled = false, false, false, false
local selectedBees, selectedEggNames, selectedEggModifiers = {}, {}, {}
local ghostKillCount, rocketCollectCount = 0, 0
local ghostTime, rocketTime = 0, 0
local originalWalkspeed = (player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.WalkSpeed) or 16
local isIdle, idleStartTime, idleConnection, idleCheckThread = false, nil, nil, nil
local currentGhostTarget, currentRocketTarget = nil, nil
local platform, currentTween = nil, nil

local leftClickEnabled = true
local leftClickInterval = 900

local antiAfkEnabled = true
local afkWalkDuration, afkWaitDuration = 5, 5
local jumpInterval = 30000 -- ms

local function formatTime(s) local m = math.floor(s/60) local rs = s%60 return string.format("%02i:%02i", m, rs) end

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
        if events and events:FindFirstChild("BeeShopHandler") then events.BeeShopHandler:FireServer("Purchase", {slotIndex = slotIndex, quantity = 1}) end
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

local function createPlatform()
    if platform and platform.Parent then platform:Destroy() end
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
                            hrp.CFrame = CFrame.new(root.Position)
                        end)
                        while ghost and ghost.Parent and autoGhostEnabled do
                            attackGhost()
                            task.wait(0.08)
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

local page_order = {
    {name="Main", icon="🏠"},
    {name="Auto Bee", icon="🐝"},
    {name="Auto Egg", icon="🥚"},
    {name="Auto Ghost", icon="👻"},
    {name="Auto Rocket", icon="🚀"},
    {name="Settings", icon="⚙"}
}

for _, p in ipairs(page_order) do CreateCategory(p.name, p.icon) end

local mainFrame = Pages["Main"].frame
createTitle(mainFrame, "VeryFun SHOP | BeeGarden")
local info = Instance.new("TextLabel", mainFrame)
info.Size = UDim2.new(1,0,0,40); info.BackgroundTransparency = 1; info.Font = Enum.Font.Gotham; info.TextSize = 13
info.TextColor3 = Color3.fromRGB(220,220,220); info.TextWrapped = true
info.Text = [[
✨💎 VeryFunSHOP 💎✨

ขอบคุณที่ใช้งานระบบของเรา!  
ติดปันหาตรงไหนแจ้งผ่านดิสได้เลย

ติดต่อทีมงานผ่าน Discord ได้ที่นี่:
🔗 https://discord.gg/TSDpFZkKdD

]]
FixText(info)


local beeFrame = Pages["Auto Bee"].frame
createTitle(beeFrame, "Auto Bee — เลือกผึ้ง")
local function getAllBeeNames()
    local t = {}
    if beesStorage then for _, v in pairs(beesStorage:GetChildren()) do table.insert(t, v.Name) end end
    table.sort(t); return t
end
local beeScroll, refreshBee = createScrollList(beeFrame, getAllBeeNames, selectedBees, currentTheme.highlight, 120)
local beeToggleBtn = Instance.new("TextButton", beeFrame)
beeToggleBtn.Size = UDim2.new(1,0,0,32)
beeToggleBtn.Font = Enum.Font.GothamSemibold; beeToggleBtn.TextSize = 13; beeToggleBtn.TextColor3 = Color3.new(1,1,1)
beeToggleBtn.BackgroundColor3 = currentTheme.highlight; beeToggleBtn.Text = "▶ เริ่มซื้อผึ้ง"
addCorner(beeToggleBtn,8); FixText(beeToggleBtn)
beeToggleBtn.MouseButton1Click:Connect(function()
    autoBuyBeeEnabled = not autoBuyBeeEnabled
    beeToggleBtn.Text = autoBuyBeeEnabled and "⏸ หยุดซื้อผึ้ง" or "▶ เริ่มซื้อผึ้ง"
    beeToggleBtn.BackgroundColor3 = autoBuyBeeEnabled and Color3.fromRGB(210,60,60) or currentTheme.highlight
    if autoBuyBeeEnabled then spawn(autoBuyBeeLoop) end
end)

-- Auto Egg page
local eggFrame = Pages["Auto Egg"].frame
createTitle(eggFrame, "Auto Egg — เลือกไข่/บัฟ")
local function getEggNames()
    return {"Seedling Egg","Leafy Egg","Buzzing Egg","Icey Egg","Blaze Egg","Crystal Egg","Toxic Egg","Prism Egg","Void Egg","Duality Egg","Inspector Egg"}
end
local function getEggMods()
    local t = {}
    if eggModifiers then for _, v in pairs(eggModifiers:GetChildren()) do if v:IsA("Folder") then table.insert(t, v.Name) end end end
    table.sort(t); return t
end
local eggScrollNames, refreshEggNames = createScrollList(eggFrame, getEggNames, selectedEggNames, currentTheme.highlight, 110)
local eggScrollMods, refreshEggMods = createScrollList(eggFrame, getEggMods, selectedEggModifiers, currentTheme.highlight, 110)
local eggToggleBtn = Instance.new("TextButton", eggFrame)
eggToggleBtn.Size = UDim2.new(1,0,0,32); eggToggleBtn.Font = Enum.Font.GothamSemibold; eggToggleBtn.TextSize = 13
eggToggleBtn.TextColor3 = Color3.new(1,1,1); eggToggleBtn.BackgroundColor3 = Color3.fromRGB(255,128,0); eggToggleBtn.Text = "▶ เริ่มซื้อไข่"
addCorner(eggToggleBtn,8); FixText(eggToggleBtn)
eggToggleBtn.MouseButton1Click:Connect(function()
    autoBuyEggEnabled = not autoBuyEggEnabled
    eggToggleBtn.Text = autoBuyEggEnabled and "⏸ หยุดซื้อไข่" or "▶ เริ่มซื้อไข่"
    eggToggleBtn.BackgroundColor3 = autoBuyEggEnabled and Color3.fromRGB(200,50,50) or Color3.fromRGB(255,128,0)
    if autoBuyEggEnabled then spawn(autoBuyEggLoop) end
end)

local ghostFrame = Pages["Auto Ghost"].frame
createTitle(ghostFrame, "Auto Ghost — ฟาร์มผี")
local ghostStatus = Instance.new("TextLabel", ghostFrame); ghostStatus.Size = UDim2.new(1,0,0,26); ghostStatus.BackgroundColor3 = Color3.fromRGB(36,36,42); ghostStatus.Text = "🔴 สถานะ: ปิด"; ghostStatus.TextColor3 = Color3.fromRGB(255,255,255)
addCorner(ghostStatus,8); FixText(ghostStatus)
local ghostCountLbl = Instance.new("TextLabel", ghostFrame); ghostCountLbl.Size = UDim2.new(1,0,0,20); ghostCountLbl.BackgroundTransparency = 1; ghostCountLbl.TextColor3 = Color3.fromRGB(220,220,220)
FixText(ghostCountLbl)
spawn(function() while task.wait(0.5) do if ghostCountLbl.Parent then ghostCountLbl.Text = "👻 ตีแล้ว: " .. tostring(ghostKillCount) else break end end end)
local ghostToggle = Instance.new("TextButton", ghostFrame); ghostToggle.Size = UDim2.new(1,0,0,32); ghostToggle.Font = Enum.Font.GothamSemibold; ghostToggle.TextSize = 13
ghostToggle.BackgroundColor3 = Color3.fromRGB(120,60,150); ghostToggle.TextColor3 = Color3.new(1,1,1); ghostToggle.Text = "▶ เริ่มฟาร์มผี"
addCorner(ghostToggle,8); FixText(ghostToggle)
ghostToggle.MouseButton1Click:Connect(function()
    autoGhostEnabled = not autoGhostEnabled
    ghostToggle.Text = autoGhostEnabled and "⏸ หยุดฟาร์มผี" or "▶ เริ่มฟาร์มผี"
    ghostToggle.BackgroundColor3 = autoGhostEnabled and Color3.fromRGB(200,50,50) or Color3.fromRGB(120,60,150)
    if autoGhostEnabled then spawn(function() autoGhostLoop(ghostStatus) end) end
end)

local rocketFrame = Pages["Auto Rocket"].frame
createTitle(rocketFrame, "Auto Rocket — เก็บจรวด")
local rocketStatus = Instance.new("TextLabel", rocketFrame); rocketStatus.Size = UDim2.new(1,0,0,26); rocketStatus.BackgroundColor3 = Color3.fromRGB(36,36,42); rocketStatus.Text = "🔴 สถานะ: ปิด"; rocketStatus.TextColor3 = Color3.fromRGB(255,255,255)
addCorner(rocketStatus,8); FixText(rocketStatus)
local rocketCountLbl = Instance.new("TextLabel", rocketFrame); rocketCountLbl.Size = UDim2.new(1,0,0,20); rocketCountLbl.BackgroundTransparency = 1; rocketCountLbl.TextColor3 = Color3.fromRGB(220,220,220)
FixText(rocketCountLbl)
spawn(function() while task.wait(0.5) do if rocketCountLbl.Parent then rocketCountLbl.Text = "🚀 เก็บแล้ว: " .. tostring(rocketCollectCount) else break end end end)
local rocketToggle = Instance.new("TextButton", rocketFrame); rocketToggle.Size = UDim2.new(1,0,0,32); rocketToggle.Font = Enum.Font.GothamSemibold; rocketToggle.TextSize = 13
rocketToggle.TextColor3 = Color3.new(1,1,1); rocketToggle.BackgroundColor3 = Color3.fromRGB(50,150,50); rocketToggle.Text = "▶ เริ่มเก็บจรวด"
addCorner(rocketToggle,8); FixText(rocketToggle)
rocketToggle.MouseButton1Click:Connect(function()
    autoRocketEnabled = not autoRocketEnabled
    rocketToggle.Text = autoRocketEnabled and "⏸ หยุดเก็บจรวด" or "▶ เริ่มเก็บจรวด"
    rocketToggle.BackgroundColor3 = autoRocketEnabled and Color3.fromRGB(200,50,50) or Color3.fromRGB(50,150,50)
    if autoRocketEnabled then spawn(function() autoRocketLoop(rocketStatus) end) end
end)

local settingsFrame = Pages["Settings"].frame
createTitle(settingsFrame, "Settings & System")
local afkToggle = createToggleButton(settingsFrame, "เปิด Anti-AFK", antiAfkEnabled, function(state) antiAfkEnabled = state end)
createSmallInput(settingsFrame, "AFK Walk (วินาที)", afkWalkDuration, function(v) afkWalkDuration = tonumber(v) or afkWalkDuration end)
createSmallInput(settingsFrame, "AFK Wait (วินาที)", afkWaitDuration, function(v) afkWaitDuration = tonumber(v) or afkWaitDuration end)
createSmallInput(settingsFrame, "Jump Interval (ms)", jumpInterval, function(v) jumpInterval = tonumber(v) or jumpInterval end)

createTitle(settingsFrame, "Anti-AFK — Left Click")
local leftClickToggle = createToggleButton(settingsFrame, "คลิกซ้ายทุก X วินาที", leftClickEnabled, function(state) leftClickEnabled = state end)
createSmallInput(settingsFrame, "ตั้งเวลา คลิกซ้าย (วินาที)", leftClickInterval, function(v) leftClickInterval = tonumber(v) or leftClickInterval end)

createSmallInput(settingsFrame, "เฟรมเรท (FPS)", 120, function(v) applyFPS(v) end)

local destroyBtn = Instance.new("TextButton", settingsFrame)
destroyBtn.Size = UDim2.new(0,140,0,30); destroyBtn.Text = "Destroy UI"; destroyBtn.Font = Enum.Font.GothamSemibold; destroyBtn.TextSize = 13
destroyBtn.BackgroundColor3 = currentTheme.accent; destroyBtn.TextColor3 = Color3.new(1,1,1); addCorner(destroyBtn,8); FixText(destroyBtn)
destroyBtn.MouseButton1Click:Connect(function()
    autoBuyBeeEnabled = false; autoBuyEggEnabled = false; autoGhostEnabled = false; autoRocketEnabled = false
    local g = PlayerGui:FindFirstChild(UI_NAME)
    if g then g:Destroy() end
end)

Pages["Main"].button:MouseButton1Click()

MainFrame.Visible = true

for k,v in pairs(Pages) do
    pcall(function()
        local frame = v.frame
        local layout = v.layout or frame:FindFirstChildOfClass("UIListLayout")
        if layout then
            layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                local s = layout.AbsoluteContentSize.Y + 24
                pcall(function() frame.CanvasSize = UDim2.new(0,0,0,s) end)
            end)
            -- initial update
            task.spawn(function() task.wait(0.05); local s = layout.AbsoluteContentSize.Y + 24; pcall(function() frame.CanvasSize = UDim2.new(0,0,0,s) end) end)
        end
    end)
end


