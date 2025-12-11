--============================--
-- VERYFUN SHOP - HWID LOCK 
--============================--

local HWID_URL = "https://raw.githubusercontent.com/amnad2003/veryfun_autofarm/refs/heads/main/hwidPremium_lock.lua"

local function GetHWID()
    if gethwid then
        return tostring(gethwid())
    elseif syn and syn.get_hwid then
        return tostring(syn.get_hwid())
    elseif crypt and crypt.generate_hash then
        return crypt.generate_hash("HWID")
    else
        return game:GetService("RbxAnalyticsService"):GetClientId()
    end
end

local myHWID = GetHWID()
local whitelistData = {}

local ok, rawData = pcall(function()
    return game:HttpGet(HWID_URL)
end)

if ok and rawData then
    local loadFunc = loadstring(rawData)
    if loadFunc then
        local suc, result = pcall(loadFunc)
        if suc and type(result) == "table" then
            whitelistData = result
        end
    end
end

local function IsHWIDAllowed()
    for _, hw in ipairs(whitelistData) do
        if tostring(hw) == tostring(myHWID) then
            return true
        end
    end
    return false
end

local function ShowHWIDScreen()
    local player = game.Players.LocalPlayer

    local gui = Instance.new("ScreenGui")
    gui.Name = "VERYFUN_HWID_UI"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = player:WaitForChild("PlayerGui")

    local blur = Instance.new("BlurEffect", game.Lighting)
    blur.Size = 15

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0, 450, 0, 260)
    frame.Position = UDim2.new(0.5, -225, 0.5, -130)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 16)
    local stroke = Instance.new("UIStroke", frame)
    stroke.Thickness = 2
    stroke.Color = Color3.fromRGB(255, 70, 70)

    frame.Position = UDim2.new(0.5, -225, 0.5, 260)
    game.TweenService:Create(frame, TweenInfo.new(.4, Enum.EasingStyle.Back), {
        Position = UDim2.new(0.5, -225, 0.5, -130)
    }):Play()

    local bar = Instance.new("Frame", frame)
    bar.Size = UDim2.new(1, 0, 0, 45)
    bar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 16)

    local title = Instance.new("TextLabel", bar)
    title.Size = UDim2.new(1, -50, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 21
    title.TextColor3 = Color3.fromRGB(255, 90, 90)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = "VERYFUN SHOP — HWID LOCK"

    local close = Instance.new("TextButton", bar)
    close.Size = UDim2.new(0, 50, 1, 0)
    close.Position = UDim2.new(1, -50, 0, 0)
    close.BackgroundTransparency = 1
    close.Font = Enum.Font.GothamBold
    close.TextSize = 22
    close.TextColor3 = Color3.fromRGB(255, 60, 60)
    close.Text = "✕"

    close.MouseButton1Click:Connect(function()
        frame.Position = UDim2.new(0.5, -225, 0.5, -130)
        game.TweenService:Create(frame, TweenInfo.new(.4, Enum.EasingStyle.Quad), {
            Position = UDim2.new(0.5, -225, 0.5, 300)
        }):Play()
        task.wait(.25)
        gui:Destroy()
        blur:Destroy()
    end)

    local hwidLabel = Instance.new("TextLabel", frame)
    hwidLabel.Size = UDim2.new(1, -20, 0, 80)
    hwidLabel.Position = UDim2.new(0, 10, 0, 60)
    hwidLabel.BackgroundTransparency = 1
    hwidLabel.Font = Enum.Font.Gotham
    hwidLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    hwidLabel.TextSize = 16
    hwidLabel.TextWrapped = true
    hwidLabel.Text = "HWID ของคุณ:\n" .. myHWID

    local loading = Instance.new("TextLabel", frame)
    loading.Size = UDim2.new(1, 0, 0, 30)
    loading.Position = UDim2.new(0, 0, 1, -85)
    loading.BackgroundTransparency = 1
    loading.Font = Enum.Font.GothamBold
    loading.TextSize = 18
    loading.TextColor3 = Color3.fromRGB(255, 80, 80)
    loading.Text = "กำลังตรวจสอบ HWID..."

    task.spawn(function()
        while gui.Parent do
            loading.Text = "กำลังตรวจสอบ HWID."
            task.wait(0.25)
            loading.Text = "กำลังตรวจสอบ HWID.."
            task.wait(0.25)
            loading.Text = "กำลังตรวจสอบ HWID..."
            task.wait(0.25)
        end
    end)

    local copyBtn = Instance.new("TextButton", frame)
    copyBtn.Size = UDim2.new(0, 200, 0, 40)
    copyBtn.Position = UDim2.new(0.5, -100, 1, -45)
    copyBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    copyBtn.Font = Enum.Font.GothamBold
    copyBtn.TextColor3 = Color3.new(1,1,1)
    copyBtn.TextSize = 16
    copyBtn.Text = "คัดลอก HWID"
    Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 10)

    copyBtn.MouseButton1Click:Connect(function()
        setclipboard(myHWID)
        copyBtn.Text = "คัดลอกแล้ว!"
        copyBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 60)
    end)
end

if not IsHWIDAllowed() then
    ShowHWIDScreen()
    return
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

local UI_NAME = "VeryFunSHOP_UniversalUI"
local LOGO_ID = "rbxassetid://82270910588453"

local old = PlayerGui:FindFirstChild(UI_NAME)
if old then old:Destroy() end

local THEMES = {
    Mint = { bg = Color3.fromHex("#0F1720"), accent = Color3.fromHex("#1F2937"), highlight = Color3.fromHex("#66FFCC") },
    Red = { bg = Color3.fromHex("#0F0A0A"), accent = Color3.fromHex("#241111"), highlight = Color3.fromHex("#FF5C5C") },
    Blue = { bg = Color3.fromHex("#071022"), accent = Color3.fromHex("#0E2438"), highlight = Color3.fromHex("#7FB3FF") },
    Pink = { bg = Color3.fromHex("#120812"), accent = Color3.fromHex("#261429"), highlight = Color3.fromHex("#FF8FD8") },
    Purple = { bg = Color3.fromHex("#0B0612"), accent = Color3.fromHex("#221633"), highlight = Color3.fromHex("#B47DFF") },
    Gold = { bg = Color3.fromHex("#0B0B06"), accent = Color3.fromHex("#2A260F"), highlight = Color3.fromHex("#FFC857") },
}
local currentTheme = THEMES.Mint

local function applyFPS(value)
    value = tonumber(value)
    if not value or value < 1 then return end

    if setfpscap then
        pcall(function() setfpscap(value) end)
    elseif setfps then
        pcall(function() setfps(value) end)
    elseif set_fps_cap then
        pcall(function() set_fps_cap(value) end)
    elseif set_fps then
        pcall(function() set_fps(value) end)
    else
        warn("⚠ Executor ของคุณไม่รองรับการตั้ง FPS")
    end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = UI_NAME
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false

local ToggleButton = Instance.new("ImageButton")
ToggleButton.Size = UDim2.new(0, 44, 0, 44)
ToggleButton.Position = UDim2.new(0, 18, 0, 180)
ToggleButton.BackgroundColor3 = currentTheme.bg
ToggleButton.Image = LOGO_ID
ToggleButton.ImageColor3 = currentTheme.highlight
ToggleButton.Parent = ScreenGui
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 8)

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0.425, 0, 0.552, 0)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = currentTheme.bg
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local mfStroke = Instance.new("UIStroke", MainFrame)
mfStroke.Color = currentTheme.accent
mfStroke.Thickness = 1.2

local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size = UDim2.new(1, 0, 0, 46)
TitleBar.BackgroundColor3 = currentTheme.accent
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0,12)
local Title = Instance.new("TextLabel", TitleBar)
Title.Text = "VeryFun SHOP | Universal UI"
Title.TextSize = 16
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamSemibold
Title.Size = UDim2.new(1, -10, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left

local ThemeContainer = Instance.new("Frame", TitleBar)
ThemeContainer.Size = UDim2.new(0, 120, 1, 0)
ThemeContainer.Position = UDim2.new(1, -120, 0, 0)
ThemeContainer.BackgroundTransparency = 1
local list = Instance.new("UIListLayout", ThemeContainer)
list.FillDirection = Enum.FillDirection.Horizontal
list.Padding = UDim.new(0,8)
list.HorizontalAlignment = Enum.HorizontalAlignment.Right

local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.BackgroundTransparency = 1
Sidebar.Size = UDim2.new(0.153,0,1,-46)
Sidebar.Position = UDim2.new(0,0,0,52)
local SideLayout = Instance.new("UIListLayout", Sidebar)
SideLayout.Padding = UDim.new(0, 6)
SideLayout.SortOrder = Enum.SortOrder.LayoutOrder

local Content = Instance.new("Frame", MainFrame)
Content.BackgroundTransparency = 1
Content.Size = UDim2.new(0.847,0,1,-46)
Content.Position = UDim2.new(0.153,0,0,46)

local Pages = {}
local ActivePage = nil
local function CreateCategory(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,-10,0,34)
    btn.Text = "  " .. name
    btn.Font = Enum.Font.Gotham
    btn.BackgroundColor3 = currentTheme.accent
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = Sidebar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)

    local frame = Instance.new("Frame", Content)
    frame.Visible = false
    frame.Size = UDim2.new(1, -12, 1, -12)
    frame.Position = UDim2.new(0,8,0,8)
    frame.BackgroundTransparency = 1

    local scrolling = Instance.new("ScrollingFrame", frame)
    scrolling.Size = UDim2.new(1,0,1,0)
    scrolling.BackgroundTransparency = 1
    scrolling.ScrollBarThickness = 6
    local layout = Instance.new("UIListLayout", scrolling)
    layout.Padding = UDim.new(0,10)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.VerticalAlignment = Enum.VerticalAlignment.Top

    Pages[name] = {button = btn, frame = frame, content = scrolling}

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

    return scrolling
end

local function applyTheme(name)
    local th = THEMES[name]
    if not th then return end
    currentTheme = th
    MainFrame.BackgroundColor3 = th.bg
    TitleBar.BackgroundColor3 = th.accent
    ToggleButton.BackgroundColor3 = th.bg
    ToggleButton.ImageColor3 = th.highlight
    mfStroke.Color = th.accent
    for _, p in pairs(Pages) do
        p.button.BackgroundColor3 = th.accent
        p.button.TextColor3 = Color3.fromRGB(255,255,255)
    end
end
for name, data in pairs(THEMES) do
    local b = Instance.new("TextButton", ThemeContainer)
    b.Size = UDim2.new(0,14,0,14)
    b.BackgroundColor3 = data.highlight
    b.Text = ""
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
    b.MouseButton1Click:Connect(function() applyTheme(name) end)
end

local dragging = false
local dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)
TitleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

local tweenOpen  = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
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
        TweenService:Create(MainFrame, tweenOpen, { Size = UDim2.new(0.425,0,0.552,0) }):Play()
    end
end
ToggleButton.MouseButton1Click:Connect(ToggleUI)

local page_order = {"Main","🐝 Auto Bee","🥚 Auto Egg","👻 Auto Ghost","🚀 Auto Rocket","Settings"}
for _, name in ipairs(page_order) do
    CreateCategory(name)
end

_G.Fps = _G.Fps or 120
local jumpInterval, afkWalkDuration, afkWaitDuration = 30000, 5, 5
local antiAfkEnabled = true
local ghostFarmSpeed, rocketFarmSpeed = 10, 10
local currentFps = _G.Fps

local beeShopData = player:WaitForChild("Data"):WaitForChild("BeeShop"):WaitForChild("CurrentStock")
local beesStorage = ReplicatedStorage:WaitForChild("Storage"):WaitForChild("Bees")
local eggModifiers = ReplicatedStorage:WaitForChild("Storage"):WaitForChild("EggModifiers")
local plotsFolder = Workspace:WaitForChild("Core"):WaitForChild("Scriptable"):WaitForChild("Plots")
local idleEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Idle")

local autoBuyBeeEnabled, autoBuyEggEnabled, autoGhostEnabled, autoRocketEnabled = false, false, false, false
local selectedBees, selectedEggNames, selectedEggModifiers = {}, {}, {}
local ghostKillCount, rocketCollectCount = 0, 0
local ghostTime, rocketTime = 0, 0
local originalWalkspeed = (player.Character and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("Humanoid").WalkSpeed) or 16
local isIdle, idleStartTime, idleConnection, idleCheckThread = false, nil, nil, nil
local currentGhostTarget, currentRocketTarget = nil, nil
local platform, currentTween = nil, nil

local leftClickEnabled = true
local leftClickInterval = 900 

local function formatTime(s) local m = math.floor(s / 60) local rs = s % 60 return string.format("%02i:%02i", m, rs) end
local function setPlayerSpeed(speed) local char = player.Character if char then local h = char:FindFirstChild("Humanoid") if h then h.WalkSpeed = speed end end end
local function getAllEggNames() return {"Seedling Egg","Leafy Egg","Buzzing Egg","Icey Egg","Blaze Egg","Crystal Egg","Toxic Egg","Prism Egg","Void Egg","Duality Egg","Inspector Egg"} end
local function getAllBeeNames() local names = {} for _, bee in pairs(beesStorage:GetChildren()) do table.insert(names, bee.Name) end table.sort(names) return names end
local function getAllEggModifiers() local mods = {} for _, mod in pairs(eggModifiers:GetChildren()) do if mod:IsA("Folder") then table.insert(mods, mod.Name) end end table.sort(mods) return mods end

local function getOurPlotNumber()
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
    for i = 1, 11 do
        local slot = beeShopData:FindFirstChild("Slot" .. i)
        if slot then
            local beeId = slot:FindFirstChild("BeeId")
            if beeId and beeId.Value ~= "" then table.insert(stock, {slotIndex = i, beeName = beeId.Value}) end
        end
    end
    return stock
end

local function purchaseBee(slotIndex) pcall(function() ReplicatedStorage:WaitForChild("Events"):WaitForChild("BeeShopHandler"):FireServer("Purchase", {slotIndex = slotIndex, quantity = 1}) end) end

local function checkAllEggs()
    local eggs = {}
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
                    if assetName then
                        table.insert(eggs, {eggId = egg.Name, eggName = assetName, modifier = modifierFolder and modifierFolder.Name or nil})
                    end
                end
            end
        end
    end
    return eggs
end
local function purchaseEgg(eggId)
    local plotNum = getOurPlotNumber()
    if plotNum then pcall(function() ReplicatedStorage:WaitForChild("Events"):WaitForChild("PurchaseConveyorEgg"):FireServer(eggId, plotNum) end) end
end

local function getAllGhosts()
    local ghosts = {}
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj:IsA("Model") and (
            string.find(obj.Name, "NormalGhost_") or 
            string.find(obj.Name, "FastGhost_") or 
            string.find(obj.Name, "SlowGhost_")
        ) then
            local rootPart = obj:FindFirstChild("HumanoidRootPart")
            if rootPart then 
                table.insert(ghosts, obj) 
            end
        end
    end
    return ghosts
end

local function attackGhost()
    pcall(function()
        local events = ReplicatedStorage:FindFirstChild("Events")
        if events then
            local swatter = events:FindFirstChild("Swatter")
            if swatter and swatter:IsA("RemoteEvent") then swatter:FireServer() end
        end
    end)
end

local function createPlatform()
    if platform then platform:Destroy() end
    platform = Instance.new("Part")
    platform.Name = "FarmPlatform"
    platform.Size = Vector3.new(6, 0.5, 6)
    platform.Anchored = true
    platform.CanCollide = true
    platform.Transparency = 0.8
    platform.Material = Enum.Material.ForceField
    platform.BrickColor = BrickColor.new("Bright blue")
    platform.Parent = Workspace
    return platform
end

local function tweenToPosition(targetPos)
    local char = player.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    if not platform or not platform.Parent then platform = createPlatform() end
    local platformPos = Vector3.new(targetPos.X, targetPos.Y - 3.5, targetPos.Z)
    platform.CFrame = CFrame.new(platformPos)
    if currentTween and typeof(currentTween.Cancel) == "function" then
        pcall(function() currentTween:Cancel() end)
    end
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
    currentTween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(targetPos)})
    currentTween:Play()
    currentTween.Completed:Wait()
    return true
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
    local hrp = rocket:FindFirstChild("HumanoidRootPart")
    if hrp then
        local prompt = hrp:FindFirstChild("ProximityPrompt")
        if prompt then pcall(function() fireproximityprompt(prompt) end) end
    end
end

local function initAntiIdleSystem()
    player.Idled:Connect(function()
        if not isIdle then
            isIdle = true
            idleStartTime = os.time()
            if idleConnection then idleConnection:Disconnect() end
            idleConnection = UserInputService.InputBegan:Connect(function()
                isIdle = false
                idleStartTime = nil
                if idleConnection then idleConnection:Disconnect() idleConnection = nil end
                if idleCheckThread then task.cancel(idleCheckThread) idleCheckThread = nil end
            end)
            idleCheckThread = task.spawn(function()
                while isIdle and player.Parent do
                    if idleStartTime and os.time() - idleStartTime >= 900 then
                        idleEvent:FireServer()
                        isIdle = false
                        idleStartTime = nil
                        if idleConnection then idleConnection:Disconnect() idleConnection = nil end
                        break
                    end
                    task.wait(30)
                end
                idleCheckThread = nil
            end)
        end
    end)
end

local function autoBuyBeeLoop()
    while autoBuyBeeEnabled do
        local stock = checkBeeStock()
        for _, item in pairs(stock) do
            if not autoBuyBeeEnabled then break end
            if selectedBees[item.beeName] then purchaseBee(item.slotIndex) wait(0.1) end
        end
        wait(0.3)
    end
end

local function autoBuyEggLoop()
    while autoBuyEggEnabled do
        local eggs = checkAllEggs()
        for _, egg in pairs(eggs) do
            if not autoBuyEggEnabled then break end
            local nameMatch, modMatch = false, false
            local nameCount, modCount = 0, 0
            for name, sel in pairs(selectedEggNames) do
                if sel then nameCount = nameCount + 1 if egg.eggName == name then nameMatch = true end end
            end
            if nameCount == 0 then nameMatch = true end
            for mod, sel in pairs(selectedEggModifiers) do
                if sel then modCount = modCount + 1 if egg.modifier == mod then modMatch = true end end
            end
            if modCount == 0 then modMatch = true end
            if nameMatch and modMatch then purchaseEgg(egg.eggId) wait(0.1) end
        end
        wait(0.3)
    end
end

local function autoGhostLoop(statusLabel)
    local startTime = tick()
    platform = createPlatform()
    setPlayerSpeed(ghostFarmSpeed)
    
    while autoGhostEnabled do
        local ghosts = getAllGhosts()
        if #ghosts > 0 then
            for _, ghost in pairs(ghosts) do
                if not autoGhostEnabled then break end
                if ghost and ghost.Parent then
                    currentGhostTarget = ghost
                    local ghostRoot = ghost:FindFirstChild("HumanoidRootPart")
                    if ghostRoot then
                        local followConnection
                        followConnection = RunService.Heartbeat:Connect(function()
                            if not ghost or not ghost.Parent or not autoGhostEnabled then
                                if followConnection then followConnection:Disconnect() end
                                return
                            end
                            local char = player.Character
                            if not char then return end
                            local hrp = char:FindFirstChild("HumanoidRootPart")
                            if not hrp then return end
                            local currentGhostRoot = ghost:FindFirstChild("HumanoidRootPart")
                            if currentGhostRoot then
                                local targetPos = currentGhostRoot.Position
                                local platformPos = Vector3.new(targetPos.X, targetPos.Y - 3.5, targetPos.Z)
                                
                                if platform and platform.Parent then
                                    platform.CFrame = CFrame.new(platformPos)
                                end
                                
                                hrp.CFrame = CFrame.new(targetPos)
                            end
                        end)
                        
                        while ghost and ghost.Parent and autoGhostEnabled do
                            attackGhost()
                            wait(0.1)
                            
                            if not ghost.Parent then
                                ghostKillCount = ghostKillCount + 1
                                break
                            end
                        end
                        
                        if followConnection then followConnection:Disconnect() end
                    end
                    currentGhostTarget = nil
                    wait(0.1)
                end
            end
        else wait(0.5) end
        ghostTime = math.floor(tick() - startTime)
        if statusLabel and statusLabel.Text then
            statusLabel.Text = (autoGhostEnabled and "🟢 สถานะ: เปิด " or "🔴 สถานะ: ปิด ") .. " | " .. "เวลา: " .. formatTime(ghostTime)
        end
    end
    
    setPlayerSpeed(originalWalkspeed)
    if platform then platform:Destroy() platform = nil end
    currentGhostTarget = nil
    ghostTime = 0
    if statusLabel and statusLabel.Text ~= "" then statusLabel.Text = "🔴 สถานะ: ปิด" end
end

local function autoRocketLoop(statusLabel)
    local startTime = tick()
    platform = createPlatform()
    while autoRocketEnabled do
        local rockets = getAllRockets()
        if #rockets > 0 then
            for _, rocket in pairs(rockets) do
                if not autoRocketEnabled then break end
                if rocket and rocket.Parent then
                    currentRocketTarget = rocket
                    local rocketRoot = rocket:FindFirstChild("HumanoidRootPart")
                    if rocketRoot then
                        local targetPos = rocketRoot.Position + Vector3.new(0, 0, 3)
                        if tweenToPosition(targetPos) then
                            collectRocket(rocket)
                            wait(0.5)
                            if not rocket.Parent then rocketCollectCount = rocketCollectCount + 1 end
                        end
                    end
                    currentRocketTarget = nil
                    wait(0.5)
                end
            end
        else wait(1) end
        rocketTime = math.floor(tick() - startTime)
        if statusLabel and statusLabel.Text then
            statusLabel.Text = (autoRocketEnabled and "🟢 สถานะ: เปิด " or "🔴 สถานะ: ปิด ") .. " | " .. "เวลา: " .. formatTime(rocketTime)
        end
    end
    if currentTween then pcall(function() currentTween:Cancel() end) end
    if platform then platform:Destroy() platform = nil end
    currentRocketTarget = nil
    rocketTime = 0
    if statusLabel and statusLabel.Text ~= "" then statusLabel.Text = "🔴 สถานะ: ปิด" end
end

spawn(function() initAntiIdleSystem() end)
player.Idled:Connect(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end)
spawn(function()
    while true do
        if antiAfkEnabled then wait(math.random(jumpInterval - 100, jumpInterval + 100) / 1000)
            local h = player.Character and player.Character:FindFirstChild("Humanoid")
            if h and h.Health > 0 then h.Jump = true end
        else wait(1) end
    end
end)
spawn(function()
    while true do
        if antiAfkEnabled and not autoGhostEnabled and not autoRocketEnabled then
            local char = player.Character local h = char and char:FindFirstChild("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if h and hrp then
                local originalPosition = hrp.CFrame
                h:Move(Vector3.new(0, 0, -1), Enum.WalkDirection.Forward) wait(afkWalkDuration)
                h:Move(Vector3.new(0, 0, 0), Enum.WalkDirection.Forward)
                hrp.CFrame = originalPosition
                wait(afkWaitDuration)
            else wait(1) end
        else
            local h = player.Character and player.Character:FindFirstChild("Humanoid")
            if h then h:Move(Vector3.new(0, 0, 0), Enum.WalkDirection.Forward) end
            wait(1)
        end
    end
end)
spawn(function()
    while wait(math.random(180, 230)) do
        pcall(function()
            local character = player.Character
            if character and antiAfkEnabled and not autoGhostEnabled and not autoRocketEnabled then
                local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                if humanoidRootPart then
                    local randomMove = Vector3.new(math.random(-2, 2), 0, math.random(-2, 2))
                    humanoidRootPart.CFrame = humanoidRootPart.CFrame + randomMove
                end
            end
        end)
    end
end)

spawn(function()
    while true do
        task.wait(math.max(1, leftClickInterval))
        if leftClickEnabled and antiAfkEnabled then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton1(Vector2.new(0, 0))
            end)
        end
    end
end)

local function createTitle(parent, text)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, 22)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = Color3.fromRGB(230,230,230)
    l.TextSize = 14
    l.Font = Enum.Font.GothamBold
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = parent
    return l
end

local function createSmallInput(parent, labelText, initialValue, onSet)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -110, 0, 18)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(230, 230, 230)
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left

    local box = Instance.new("TextBox", frame)
    box.Size = UDim2.new(0, 92, 0, 30)
    box.Position = UDim2.new(1, -100, 0, 20)
    box.Text = tostring(initialValue)
    box.ClearTextOnFocus = false
    box.Font = Enum.Font.GothamSemibold
    box.TextSize = 13
    box.TextColor3 = Color3.fromRGB(240,240,240)
    box.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 8)

    box.FocusLost:Connect(function()
        local num = tonumber(box.Text)
        if num then
            onSet(num)
        else
            box.Text = tostring(initialValue)
        end
    end)

    return frame
end

local function createToggleButton(parent, labelText, default, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, 0, 0, 38)
    frame.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -70, 1, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextColor3 = Color3.fromRGB(235,235,235)
    label.Text = labelText

    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0, 48, 0, 26)
    btn.Position = UDim2.new(1, -56, 0.5, -13)
    btn.BackgroundColor3 = default and Color3.fromRGB(50,200,100) or Color3.fromRGB(70,70,75)
    btn.Text = ""
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 14)

    local circle = Instance.new("Frame", btn)
    circle.Size = UDim2.new(0, 20, 0, 20)
    circle.Position = default and UDim2.new(1,-22,0.5,-10) or UDim2.new(0,2,0.5,-10)
    circle.BackgroundColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1,0)

    local enabled = default
    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        btn.BackgroundColor3 = enabled and Color3.fromRGB(50,200,100) or Color3.fromRGB(70,70,75)
        circle:TweenPosition(enabled and UDim2.new(1,-22,0.5,-10) or UDim2.new(0,2,0.5,-10), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, .15, true)
        callback(enabled)
    end)

    return frame
end

local function createScrollList(parent, itemsFunc, selectedTable, highlightColor)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 160)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local scroll = Instance.new("ScrollingFrame", container)
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 6
    scroll.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)

    local layout = Instance.new("UIListLayout", scroll)
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    local function refresh()
        for _, v in pairs(scroll:GetChildren()) do
            if v:IsA("TextButton") then v:Destroy() end
        end

        local items = itemsFunc()
        for _, item in ipairs(items) do
            local btn = Instance.new("TextButton")
            btn.Parent = scroll
            btn.Size = UDim2.new(1, -8, 0, 34)
            btn.Position = UDim2.new(0, 4, 0, 0)
            btn.BackgroundColor3 = selectedTable[item] and highlightColor or Color3.fromRGB(38, 38, 46)
            btn.Text = "  • " .. item
            btn.TextSize = 13
            btn.Font = Enum.Font.Gotham
            btn.TextColor3 = Color3.fromRGB(230, 230, 230)
            btn.TextXAlignment = Enum.TextXAlignment.Left
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

            -- small check circle on right
            local checkFrame = Instance.new("Frame", btn)
            checkFrame.Size = UDim2.new(0, 22, 0, 22)
            checkFrame.Position = UDim2.new(1, -30, 0.5, -11)
            checkFrame.BackgroundColor3 = Color3.fromRGB(28,28,34)
            Instance.new("UICorner", checkFrame).CornerRadius = UDim.new(0, 6)
            local checkLabel = Instance.new("TextLabel", checkFrame)
            checkLabel.Size = UDim2.new(1,0,1,0)
            checkLabel.BackgroundTransparency = 1
            checkLabel.Text = selectedTable[item] and "✓" or ""
            checkLabel.Font = Enum.Font.GothamSemibold
            checkLabel.TextColor3 = Color3.fromRGB(230,230,230)
            checkLabel.TextSize = 14

            btn.MouseButton1Click:Connect(function()
                selectedTable[item] = not selectedTable[item]
                btn.BackgroundColor3 = selectedTable[item] and highlightColor or Color3.fromRGB(38, 38, 46)
                checkLabel.Text = selectedTable[item] and "✓" or ""
            end)
        end

        task.wait()
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 6)
    end

    refresh()
    return container, refresh
end

local mainContent = Pages["Main"].content
createTitle(mainContent, "Welcome to VeryFun SHOP - Unified AutoFarm")
local infoLabel = Instance.new("TextLabel", mainContent)
infoLabel.Size = UDim2.new(1,0,0,48)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "Use the sidebar to access Auto Bee, Egg, Ghost, Rocket and Settings."
infoLabel.TextColor3 = Color3.fromRGB(200,200,200)
infoLabel.TextWrapped = true
infoLabel.TextYAlignment = Enum.TextYAlignment.Top
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextSize = 14

local beeContent = Pages["🐝 Auto Bee"].content
createTitle(beeContent, "Auto Bee — เลือกผึ้งที่จะซื้อ")
local beeScroll, refreshBeeList = createScrollList(beeContent, getAllBeeNames, selectedBees, currentTheme.highlight)
local beeToggleBtn = Instance.new("TextButton", beeContent)
beeToggleBtn.Size = UDim2.new(1,0,0,40)
beeToggleBtn.Text = "▶ เริ่มซื้อผึ้ง"
beeToggleBtn.Font = Enum.Font.GothamSemibold
beeToggleBtn.TextSize = 14
beeToggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
beeToggleBtn.BackgroundColor3 = currentTheme.highlight
Instance.new("UICorner", beeToggleBtn).CornerRadius = UDim.new(0,8)
beeToggleBtn.MouseButton1Click:Connect(function()
    autoBuyBeeEnabled = not autoBuyBeeEnabled
    beeToggleBtn.Text = autoBuyBeeEnabled and "⏸ หยุดซื้อผึ้ง" or "▶ เริ่มซื้อผึ้ง"
    beeToggleBtn.BackgroundColor3 = autoBuyBeeEnabled and Color3.fromRGB(200,50,50) or currentTheme.highlight
    if autoBuyBeeEnabled then spawn(autoBuyBeeLoop) end
end)

local eggContent = Pages["🥚 Auto Egg"].content
createTitle(eggContent, "Auto Egg — เลือกชื่อไข่ และบัฟ")
local eggScrollNames, refreshEggNames = createScrollList(eggContent, getAllEggNames, selectedEggNames, currentTheme.highlight)
local eggScrollMods, refreshEggMods = createScrollList(eggContent, getAllEggModifiers, selectedEggModifiers, currentTheme.highlight)
local eggToggleBtn = Instance.new("TextButton", eggContent)
eggToggleBtn.Size = UDim2.new(1,0,0,40)
eggToggleBtn.Text = "▶ เริ่มซื้อไข่"
eggToggleBtn.Font = Enum.Font.GothamSemibold
eggToggleBtn.TextSize = 14
eggToggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
eggToggleBtn.BackgroundColor3 = Color3.fromRGB(255,128,0)
Instance.new("UICorner", eggToggleBtn).CornerRadius = UDim.new(0,8)
eggToggleBtn.MouseButton1Click:Connect(function()
    autoBuyEggEnabled = not autoBuyEggEnabled
    eggToggleBtn.Text = autoBuyEggEnabled and "⏸ หยุดซื้อไข่" or "▶ เริ่มซื้อไข่"
    eggToggleBtn.BackgroundColor3 = autoBuyEggEnabled and Color3.fromRGB(200,50,50) or Color3.fromRGB(255,128,0)
    if autoBuyEggEnabled then spawn(autoBuyEggLoop) end
end)

local ghostContent = Pages["👻 Auto Ghost"].content
createTitle(ghostContent, "Auto Ghost — ฟาร์มผี")
local ghostStatus = Instance.new("TextLabel", ghostContent)
ghostStatus.Size = UDim2.new(1,0,0,34)
ghostStatus.Text = "🔴 สถานะ: ปิด"
ghostStatus.TextColor3 = Color3.fromRGB(255,255,255)
ghostStatus.BackgroundTransparency = 0
ghostStatus.BackgroundColor3 = Color3.fromRGB(36,36,42)
Instance.new("UICorner", ghostStatus).CornerRadius = UDim.new(0,8)
local ghostCountLabel = Instance.new("TextLabel", ghostContent)
ghostCountLabel.Size = UDim2.new(1,0,0,26)
ghostCountLabel.Text = "👻 ผีที่ตี: 0"
ghostCountLabel.TextColor3 = Color3.fromRGB(220,220,220)
ghostCountLabel.BackgroundTransparency = 1
spawn(function()
    while wait(0.5) do
        if ghostCountLabel and ghostCountLabel.Parent then
            ghostCountLabel.Text = "👻 ผีที่ตี: " .. tostring(ghostKillCount)
        else break end
    end
end)
local ghostToggleBtn = Instance.new("TextButton", ghostContent)
ghostToggleBtn.Size = UDim2.new(1,0,0,40)
ghostToggleBtn.Text = "▶ เริ่มฟาร์มผี"
ghostToggleBtn.Font = Enum.Font.GothamSemibold
ghostToggleBtn.TextSize = 14
ghostToggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
ghostToggleBtn.BackgroundColor3 = Color3.fromRGB(120,60,150)
Instance.new("UICorner", ghostToggleBtn).CornerRadius = UDim.new(0,8)
ghostToggleBtn.MouseButton1Click:Connect(function()
    autoGhostEnabled = not autoGhostEnabled
    ghostToggleBtn.Text = autoGhostEnabled and "⏸ หยุดฟาร์มผี" or "▶ เริ่มฟาร์มผี"
    ghostToggleBtn.BackgroundColor3 = autoGhostEnabled and Color3.fromRGB(200,50,50) or Color3.fromRGB(120,60,150)
    ghostStatus.Text = autoGhostEnabled and "🟢 สถานะ: เปิด" or "🔴 สถานะ: ปิด"
    ghostStatus.BackgroundColor3 = autoGhostEnabled and Color3.fromRGB(40,167,69) or Color3.fromRGB(36,36,42)
    if autoGhostEnabled then spawn(function() autoGhostLoop(ghostStatus) end) end
end)

local rocketContent = Pages["🚀 Auto Rocket"].content
createTitle(rocketContent, "Auto Rocket — เก็บจรวด")
local rocketStatus = Instance.new("TextLabel", rocketContent)
rocketStatus.Size = UDim2.new(1,0,0,34)
rocketStatus.Text = "🔴 สถานะ: ปิด"
rocketStatus.TextColor3 = Color3.fromRGB(255,255,255)
rocketStatus.BackgroundTransparency = 0
rocketStatus.BackgroundColor3 = Color3.fromRGB(36,36,42)
Instance.new("UICorner", rocketStatus).CornerRadius = UDim.new(0,8)
local rocketCountLabel = Instance.new("TextLabel", rocketContent)
rocketCountLabel.Size = UDim2.new(1,0,0,26)
rocketCountLabel.Text = "🚀 จรวดที่เก็บ: 0"
rocketCountLabel.TextColor3 = Color3.fromRGB(220,220,220)
rocketCountLabel.BackgroundTransparency = 1
spawn(function()
    while wait(0.5) do
        if rocketCountLabel and rocketCountLabel.Parent then
            rocketCountLabel.Text = "🚀 จรวดที่เก็บ: " .. tostring(rocketCollectCount)
        else break end
    end
end)
local rocketToggleBtn = Instance.new("TextButton", rocketContent)
rocketToggleBtn.Size = UDim2.new(1,0,0,40)
rocketToggleBtn.Text = "▶ เริ่มเก็บจรวด"
rocketToggleBtn.Font = Enum.Font.GothamSemibold
rocketToggleBtn.TextSize = 14
rocketToggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
rocketToggleBtn.BackgroundColor3 = Color3.fromRGB(50,150,50)
Instance.new("UICorner", rocketToggleBtn).CornerRadius = UDim.new(0,8)
rocketToggleBtn.MouseButton1Click:Connect(function()
    autoRocketEnabled = not autoRocketEnabled
    rocketToggleBtn.Text = autoRocketEnabled and "⏸ หยุดเก็บจรวด" or "▶ เริ่มเก็บจรวด"
    rocketToggleBtn.BackgroundColor3 = autoRocketEnabled and Color3.fromRGB(200,50,50) or Color3.fromRGB(50,150,50)
    rocketStatus.Text = autoRocketEnabled and "🟢 สถานะ: เปิด" or "🔴 สถานะ: ปิด"
    rocketStatus.BackgroundColor3 = autoRocketEnabled and Color3.fromRGB(40,167,69) or Color3.fromRGB(36,36,42)
    if autoRocketEnabled then spawn(function() autoRocketLoop(rocketStatus) end) end
end)

local settingsContent = Pages["Settings"].content
createTitle(settingsContent, "Settings / System")
local afkToggleFrame = createToggleButton(settingsContent, "เปิด Anti-AFK", antiAfkEnabled, function(state) antiAfkEnabled = state end)
createSmallInput(settingsContent, "AFK Walk (วินาที)", afkWalkDuration, function(v) afkWalkDuration = tonumber(v) or afkWalkDuration end)
createSmallInput(settingsContent, "AFK Wait (วินาที)", afkWaitDuration, function(v) afkWaitDuration = tonumber(v) or afkWaitDuration end)
createSmallInput(settingsContent, "Jump Interval (ms)", jumpInterval, function(v) jumpInterval = tonumber(v) or jumpInterval end)

createTitle(settingsContent, "Anti-AFK — Click Left")
local leftClickToggleFrame = createToggleButton(settingsContent, "คลิกซ้ายทุก X วินาที", leftClickEnabled, function(state) leftClickEnabled = state end)
createSmallInput(settingsContent, "ตั้งเวลา คลิกซ้าย (วินาที)", leftClickInterval, function(v) leftClickInterval = tonumber(v) or leftClickInterval end)

createSmallInput(settingsContent, "เฟรมเรท (FPS)", currentFps, function(v)
    currentFps = tonumber(v) or currentFps
    applyFPS(currentFps)
end)

local destroyBtn = Instance.new("TextButton", settingsContent)
destroyBtn.Size = UDim2.new(0,160,0,38)
destroyBtn.Text = "Destroy UI"
destroyBtn.Font = Enum.Font.GothamSemibold
destroyBtn.TextSize = 14
destroyBtn.BackgroundColor3 = Color3.fromRGB(80,80,80)
destroyBtn.TextColor3 = Color3.fromRGB(255,255,255)
Instance.new("UICorner", destroyBtn).CornerRadius = UDim.new(0,8)
destroyBtn.Position = UDim2.new(0,0,0,8)
destroyBtn.MouseButton1Click:Connect(function()
    autoBuyBeeEnabled = false
    autoBuyEggEnabled = false
    autoGhostEnabled = false
    autoRocketEnabled = false
    local gui = PlayerGui:FindFirstChild(UI_NAME)
    if gui then gui:Destroy() end
end)

Pages["Main"].button:MouseButton1Click()

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.LeftControl then
        ToggleUI()
    end
end)

MainFrame.Visible = true

