-- [[ ส่วนประกาศตัวแปรและฟังก์ชันหลัก ]]
_G.Fps = 120
local jumpInterval, afkWalkDuration, afkWaitDuration = 30000, 5, 5
local antiAfkEnabled = true
local ghostFarmSpeed, rocketFarmSpeed = 10, 10
local currentFps = _G.Fps
setfpscap(currentFps)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local playerData = player:WaitForChild("Data")
local beeShopData = playerData:WaitForChild("BeeShop"):WaitForChild("CurrentStock")
local beesStorage = ReplicatedStorage:WaitForChild("Storage"):WaitForChild("Bees")
local eggModifiers = ReplicatedStorage:WaitForChild("Storage"):WaitForChild("EggModifiers")
local plotsFolder = Workspace:WaitForChild("Core"):WaitForChild("Scriptable"):WaitForChild("Plots")
local idleEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Idle")

local autoBuyBeeEnabled, autoBuyEggEnabled, autoGhostEnabled, autoRocketEnabled = false, false, false, false
local selectedBees, selectedEggNames, selectedEggModifiers = {}, {}, {}
local ghostKillCount, rocketCollectCount = 0, 0
local ghostTime, rocketTime = 0, 0
local originalWalkspeed = player.Character and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("Humanoid").WalkSpeed or 16
local isIdle, idleStartTime, idleConnection, idleCheckThread = false, nil, nil, nil
local currentGhostTarget, currentRocketTarget = nil, nil
local platform, currentTween = nil, nil

-- Helper Functions (keep as is)
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
    if currentTween then currentTween:Cancel() end
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
local function autoGhostLoop(ghostStatusLabel)
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
    end
    
    setPlayerSpeed(originalWalkspeed)
    if platform then platform:Destroy() platform = nil end
    currentGhostTarget = nil
    ghostTime = 0
    if ghostStatusLabel and ghostStatusLabel.Text ~= "" then ghostStatusLabel.Text = "🔴 สถานะ: ปิด" end
end
local function autoRocketLoop(rocketStatusLabel)
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
    end
    if currentTween then currentTween:Cancel() currentTween = nil end
    if platform then platform:Destroy() platform = nil end
    currentRocketTarget = nil
    rocketTime = 0
    if rocketStatusLabel and rocketStatusLabel.Text ~= "" then rocketStatusLabel.Text = "🔴 สถานะ: ปิด" end
end


-- [[ ส่วน UI Colors และ Setup ]]
local accentColor = Color3.fromRGB(100, 200, 255)
local darkBg = Color3.fromRGB(20, 20, 25)
local midBg = Color3.fromRGB(30, 30, 38)
local inputBg = Color3.fromRGB(45, 45, 55)
local textClr = Color3.fromRGB(255, 255, 255)
local tabActive = Color3.fromRGB(70, 130, 180)
local redClr = Color3.fromRGB(220, 53, 69)
local greenClr = Color3.fromRGB(40, 167, 69)

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UnifiedFarmGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Toggle Button (ไม่เปลี่ยนแปลง)
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 60, 0, 60)
toggleButton.Position = UDim2.new(0, 10, 0.5, -30)
toggleButton.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
toggleButton.Text = ""
toggleButton.Active = true
toggleButton.Draggable = true
toggleButton.Parent = screenGui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 15)
toggleCorner.Parent = toggleButton

local toggleStroke = Instance.new("UIStroke")
toggleStroke.Color = Color3.fromRGB(100, 200, 255)
toggleStroke.Thickness = 2
toggleStroke.Parent = toggleButton

local toggleGradient = Instance.new("UIGradient")
toggleGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(70, 130, 180)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 100, 150))
}
toggleGradient.Rotation = 45
toggleGradient.Parent = toggleButton

local toggleIcon = Instance.new("TextLabel")
toggleIcon.Size = UDim2.new(1, 0, 1, 0)
toggleIcon.BackgroundTransparency = 1
toggleIcon.Text = "🎯"
toggleIcon.TextColor3 = textClr
toggleIcon.TextSize = 28
toggleIcon.Font = Enum.Font.GothamBold
toggleIcon.Parent = toggleButton

-- Main Frame (ใช้ขนาดเดิม 420x520)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 420, 0, 520) 
mainFrame.Position = UDim2.new(0.5, -210, 0.5, -260) -- จัดให้อยู่กลาง
mainFrame.BackgroundColor3 = darkBg
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Visible = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 15)
mainCorner.Parent = mainFrame

-- Title Bar (ไม่เปลี่ยนแปลง)
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 50)
titleBar.BackgroundColor3 = midBg
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 15)
titleCorner.Parent = titleBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -60, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.Text = "AutoFarm [🐝] Bee Garden"
title.TextColor3 = accentColor
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 35, 0, 35)
closeBtn.Position = UDim2.new(1, -45, 0.5, -17.5)
closeBtn.BackgroundColor3 = redClr
closeBtn.Text = "✕"
closeBtn.TextColor3 = textClr
closeBtn.TextSize = 16
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = titleBar

local closeBtnCorner = Instance.new("UICorner")
closeBtnCorner.CornerRadius = UDim.new(0, 10)
closeBtnCorner.Parent = closeBtn

-- Toggle functionality (ไม่เปลี่ยนแปลง)
toggleButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
    if mainFrame.Visible then
        toggleButton.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
        toggleGradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(70, 130, 180)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 100, 150))
        }
        toggleStroke.Color = Color3.fromRGB(100, 200, 255)
    else
        toggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        toggleGradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 60, 70)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 40, 50))
        }
        toggleStroke.Color = Color3.fromRGB(100, 100, 120)
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.LeftControl then
        mainFrame.Visible = not mainFrame.Visible
        if mainFrame.Visible then
            toggleButton.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
            toggleGradient.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(70, 130, 180)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 100, 150))
            }
            toggleStroke.Color = Color3.fromRGB(100, 200, 255)
        else
            toggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
            toggleGradient.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 60, 70)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 40, 50))
            }
            toggleStroke.Color = Color3.fromRGB(100, 100, 120)
        end
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    autoBuyBeeEnabled = false
    autoBuyEggEnabled = false
    autoGhostEnabled = false
    autoRocketEnabled = false
    screenGui:Destroy()
end)

-- --- เริ่มการจัดโครงสร้าง Tab/Content ใหม่ (Side-by-Side) ---

-- Panel Container for Tabs and Content
local panelContainer = Instance.new("Frame")
panelContainer.Size = UDim2.new(1, -20, 1, -70)
panelContainer.Position = UDim2.new(0, 10, 0, 60)
panelContainer.BackgroundTransparency = 1
panelContainer.Parent = mainFrame

-- Layout for Side-by-Side (Sidebar and Content)
local listLayout = Instance.new("UIListLayout")
listLayout.FillDirection = Enum.FillDirection.Horizontal
listLayout.Padding = UDim.new(0, 10)
listLayout.Parent = panelContainer
listLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- 1. Side Bar Frame (สำหรับปุ่มเมนู Tab)
local sideBarFrame = Instance.new("Frame")
sideBarFrame.Size = UDim2.new(0, 100, 1, 0) -- กำหนดความกว้าง 100 (เล็กลง)
sideBarFrame.BackgroundColor3 = midBg
sideBarFrame.BorderSizePixel = 0
sideBarFrame.Parent = panelContainer
sideBarFrame.LayoutOrder = 1

local sideBarCorner = Instance.new("UICorner")
sideBarCorner.CornerRadius = UDim.new(0, 8)
sideBarCorner.Parent = sideBarFrame

local sideBarLayout = Instance.new("UIListLayout")
sideBarLayout.Padding = UDim.new(0, 5)
sideBarLayout.SortOrder = Enum.SortOrder.LayoutOrder
sideBarLayout.Parent = sideBarFrame

local sideBarPadding = Instance.new("UIPadding")
sideBarPadding.PaddingTop = UDim.new(0, 5)
sideBarPadding.PaddingBottom = UDim.new(0, 5)
sideBarPadding.PaddingLeft = UDim.new(0, 5)
sideBarPadding.PaddingRight = UDim.new(0, 5)
sideBarPadding.Parent = sideBarFrame

-- 2. Content Panel Frame (สำหรับเนื้อหา)
local contentPanelFrame = Instance.new("Frame")
contentPanelFrame.Size = UDim2.new(1, -110, 1, 0) -- ใช้พื้นที่ที่เหลือ
contentPanelFrame.BackgroundTransparency = 1
contentPanelFrame.BorderSizePixel = 0
contentPanelFrame.ClipsDescendants = true
contentPanelFrame.Parent = panelContainer
contentPanelFrame.LayoutOrder = 2

local contentPanelCorner = Instance.new("UICorner")
contentPanelCorner.CornerRadius = UDim.new(0, 8)
contentPanelCorner.Parent = contentPanelFrame

local tabs = {}
local contents = {}
-- ลบ "📦 ไอเท็ม" ออก
local tabNames = {"⚙️ ตั้งค่า", "🐝 ผึ้ง", "🥚 ไข่", "👻 ผี", "🚀 จรวด"}
local tabColors = {
    {Color3.fromRGB(70, 130, 180), Color3.fromRGB(255, 255, 255)},
    {Color3.fromRGB(60, 120, 60), Color3.fromRGB(255, 255, 255)},
    {Color3.fromRGB(220, 130, 50), Color3.fromRGB(255, 255, 255)},
    {Color3.fromRGB(150, 50, 150), Color3.fromRGB(255, 255, 255)},
    {Color3.fromRGB(50, 150, 50), Color3.fromRGB(255, 255, 255)},
}

for i, name in ipairs(tabNames) do
    -- สร้างปุ่ม Tab ใน Side Bar
    local tab = Instance.new("TextButton")
    tab.Size = UDim2.new(1, 0, 0, 40) -- ลดความสูงลง
    tab.BackgroundColor3 = i == 1 and tabColors[i][1] or Color3.fromRGB(40, 40, 50)
    tab.Text = name
    tab.TextColor3 = i == 1 and tabColors[i][2] or Color3.fromRGB(180, 180, 180)
    tab.TextSize = 12
    tab.Font = Enum.Font.GothamBold
    tab.Parent = sideBarFrame
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 8)
    tabCorner.Parent = tab
    
    -- สร้าง Content Frame
    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1, 0, 1, 0)
    content.Position = UDim2.new(0, 0, 0, 0)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 6
    content.Visible = i == 1
    content.Parent = contentPanelFrame
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 10)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Parent = content
    
    -- เพิ่ม Padding ให้ Content
    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingTop = UDim.new(0, 10)
    contentPadding.PaddingLeft = UDim.new(0, 10)
    contentPadding.PaddingRight = UDim.new(0, 10)
    contentPadding.PaddingBottom = UDim.new(0, 10)
    contentPadding.Parent = content
    
    -- ปรับ CanvasSize แบบอัตโนมัติเพื่อให้เห็นทั้งหมดโดยไม่ล้น
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        content.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 20)
    end)
    
    tabs[i] = tab
    contents[i] = content
    
    tab.MouseButton1Click:Connect(function()
        for j, t in ipairs(tabs) do
            t.BackgroundColor3 = j == i and tabColors[j][1] or Color3.fromRGB(40, 40, 50)
            t.TextColor3 = j == i and tabColors[j][2] or Color3.fromRGB(180, 180, 180)
            contents[j].Visible = j == i
        end
        -- ลบโค้ดการโหลด Inventory ออก
    end)
end

-- Helper Functions for UI Elements (ปรับขนาดให้เล็กลง)
local function createTitle(parent, text)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, 20) -- เล็กลง
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = textClr
    l.TextSize = 12
    l.Font = Enum.Font.GothamBold
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = parent
    return l
end

local function createStatusBox(parent, initialText, initialColor)
    local s = Instance.new("TextLabel")
    s.Size = UDim2.new(1, 0, 0, 35) -- เล็กลง
    s.BackgroundColor3 = initialColor
    s.Text = initialText
    s.TextColor3 = textClr
    s.TextSize = 13
    s.Font = Enum.Font.GothamBold
    s.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = s
    
    return s
end

local function createInputGroup(parent, labelText, initialValue, unit, onSet, isNumber, minVal, maxVal)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 60) -- เล็กลง
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = createTitle(frame, labelText .. " (" .. unit .. ")")
    label.Size = UDim2.new(1, 0, 0, 15) -- เล็กลง
    label.Position = UDim2.new(0, 0, 0, 0)
    
    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(1, -60, 0, 30) -- เล็กลง
    textBox.Position = UDim2.new(0, 0, 0, 20) -- ปรับตำแหน่งตาม label ใหม่
    textBox.BackgroundColor3 = inputBg
    textBox.Text = tostring(initialValue)
    textBox.TextColor3 = textClr
    textBox.TextSize = 12
    textBox.Font = Enum.Font.Gotham
    textBox.PlaceholderText = labelText
    textBox.Parent = frame
    
    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 6)
    boxCorner.Parent = textBox
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 55, 0, 30) -- เล็กลง
    button.Position = UDim2.new(1, -55, 0, 20)
    button.BackgroundColor3 = tabActive
    button.Text = "ตั้งค่า"
    button.TextColor3 = textClr
    button.TextSize = 11
    button.Font = Enum.Font.GothamBold
    button.Parent = frame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = button

    button.MouseButton1Click:Connect(function()
        local val = isNumber and tonumber(textBox.Text) or textBox.Text
        local valid = true
        local errorMsg = "ค่าไม่ถูกต้อง!"
        
        if isNumber and val then
            if minVal and val < minVal then valid = false errorMsg = "ต่ำกว่า " .. minVal end
            if maxVal and val > maxVal then valid = false errorMsg = "เกิน " .. maxVal end
        elseif isNumber and not val then
            valid = false
            errorMsg = "ไม่ใช่ตัวเลข"
        end
        
        if valid then
            onSet(val, button)
            button.Text = "✓"
            wait(0.5)
            button.Text = "ตั้งค่า"
        else
            local originalText = textBox.Text
            textBox.Text = errorMsg
            wait(1)
            textBox.Text = originalText
        end
    end)
    
    return frame
end

local function createToggleSwitch(parent, labelText, initialValue, onToggle)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 35) -- เล็กลง
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = createTitle(frame, labelText)
    label.Position = UDim2.new(0, 0, 0, 5) -- ปรับตำแหน่ง
    label.Size = UDim2.new(1, -50, 0, 25)
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 45, 0, 25) -- เล็กลง
    toggleBtn.Position = UDim2.new(1, -45, 0, 5)
    toggleBtn.BackgroundColor3 = initialValue and greenClr or redClr
    toggleBtn.Text = initialValue and "เปิด" or "ปิด"
    toggleBtn.TextColor3 = textClr
    toggleBtn.TextSize = 11
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.Parent = frame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 8)
    toggleCorner.Parent = toggleBtn
    
    local state = initialValue
    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        toggleBtn.BackgroundColor3 = state and greenClr or redClr
        toggleBtn.Text = state and "เปิด" or "ปิด"
        onToggle(state)
    end)
    
    return frame
end

-- ฟังก์ชันนี้ยังคงเป็น ScrollingFrame เพื่อให้สามารถเลือกรายการจำนวนมากได้ในขนาดที่จำกัด
local function createScrollList(parent, items, selectedTable, activeColor)
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 0, 180) -- จำกัดความสูงไว้ที่ 180
    scroll.BackgroundColor3 = midBg
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 6
    scroll.Parent = parent
    
    local scrollCorner = Instance.new("UICorner")
    scrollCorner.CornerRadius = UDim.new(0, 10)
    scrollCorner.Parent = scroll
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 5)
    layout.Parent = scroll
    
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 8)
    padding.PaddingLeft = UDim.new(0, 8)
    padding.PaddingRight = UDim.new(0, 8)
    padding.PaddingBottom = UDim.new(0, 8)
    padding.Parent = scroll
    
    for _, item in pairs(items) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -16, 0, 28) -- เล็กลง
        btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        btn.Text = "  " .. item
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.TextSize = 11
        btn.Font = Enum.Font.Gotham
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Parent = scroll
        
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = btn
        
        local checkbox = Instance.new("TextLabel")
        checkbox.Size = UDim2.new(0, 20, 0, 20) -- เล็กลง
        checkbox.Position = UDim2.new(1, -26, 0.5, -10)
        checkbox.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        checkbox.Text = ""
        checkbox.TextColor3 = textClr
        checkbox.TextSize = 12
        checkbox.Font = Enum.Font.GothamBold
        checkbox.Parent = btn
        
        local checkCorner = Instance.new("UICorner")
        checkCorner.CornerRadius = UDim.new(0, 5)
        checkCorner.Parent = checkbox
        
        btn.MouseButton1Click:Connect(function()
            selectedTable[item] = not selectedTable[item]
            if selectedTable[item] then
                btn.BackgroundColor3 = activeColor
                btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                checkbox.BackgroundColor3 = activeColor
                checkbox.Text = "✓"
            else
                btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
                btn.TextColor3 = Color3.fromRGB(200, 200, 200)
                checkbox.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
                checkbox.Text = ""
            end
        end)
    end
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 16)
    end)
    
    return scroll
end

-- [[ ส่วนสร้าง Content ในแต่ละ Tab ]]

-- Settings Tab (Tab 1)
local settingsContent = contents[1]

createTitle(settingsContent, "🔨 Anti-AFK (กระโดด/เดิน/วาร์ป)")
createToggleSwitch(settingsContent, "เปิด Anti-AFK", antiAfkEnabled, function(state)
    antiAfkEnabled = state
end)

createTitle(settingsContent, "⏱️ เวลา (วินาที/ms)")
createInputGroup(settingsContent, "AFK Walk (เดิน)", afkWalkDuration, "วินาที", function(val)
    afkWalkDuration = val
end, true, 1, 600)

createInputGroup(settingsContent, "AFK Wait (รอ)", afkWaitDuration, "วินาที", function(val)
    afkWaitDuration = val
end, true, 1, 600)

createInputGroup(settingsContent, "Jump Interval", jumpInterval, "ms", function(val)
    jumpInterval = val
end, true, 100, 60000)

createTitle(settingsContent, "⚡ ความเร็ว/FPS")
createInputGroup(settingsContent, "ความเร็วฟาร์มผี", ghostFarmSpeed, "WS", function(val)
    ghostFarmSpeed = val
    if autoGhostEnabled then
        setPlayerSpeed(ghostFarmSpeed)
    end
end, true, 16, 200)

createInputGroup(settingsContent, "ความเร็วเก็บจรวด", rocketFarmSpeed, "WS", function(val)
    rocketFarmSpeed = val
    if autoRocketEnabled then
        setPlayerSpeed(rocketFarmSpeed)
    end
end, true, 16, 200)

createInputGroup(settingsContent, "เฟรมเรต", currentFps, "FPS", function(val)
    _G.Fps = val
    currentFps = val
    setfpscap(currentFps)
end, true, 1, 1000)

-- Bee Tab (Tab 2)
local beeContent = contents[2]

createTitle(beeContent, "📝 เลือกผึ้งที่ต้องการซื้อ:")
createScrollList(beeContent, getAllBeeNames(), selectedBees, Color3.fromRGB(60, 120, 60))

local beeToggleFrame = Instance.new("Frame")
beeToggleFrame.Size = UDim2.new(1, 0, 0, 50)
beeToggleFrame.BackgroundTransparency = 1
beeToggleFrame.Parent = beeContent

local beeToggle = Instance.new("TextButton")
beeToggle.Size = UDim2.new(1, 0, 0, 40) -- เล็กลง
beeToggle.Position = UDim2.new(0, 0, 0, 0)
beeToggle.BackgroundColor3 = Color3.fromRGB(40, 167, 69)
beeToggle.Text = "▶ เริ่มซื้อผึ้ง"
beeToggle.TextColor3 = textClr
beeToggle.TextSize = 13
beeToggle.Font = Enum.Font.GothamBold
beeToggle.Parent = beeToggleFrame

local beeToggleCorner = Instance.new("UICorner")
beeToggleCorner.CornerRadius = UDim.new(0, 10)
beeToggleCorner.Parent = beeToggle

beeToggle.MouseButton1Click:Connect(function()
    autoBuyBeeEnabled = not autoBuyBeeEnabled
    beeToggle.Text = autoBuyBeeEnabled and "⏸ หยุดซื้อผึ้ง" or "▶ เริ่มซื้อผึ้ง"
    beeToggle.BackgroundColor3 = autoBuyBeeEnabled and Color3.fromRGB(220, 53, 69) or Color3.fromRGB(40, 167, 69)
    if autoBuyBeeEnabled then
        spawn(autoBuyBeeLoop)
    end
end)

-- Egg Tab (Tab 3)
local eggContent = contents[3]

createTitle(eggContent, "🥚 เลือกชื่อไข่:")
createScrollList(eggContent, getAllEggNames(), selectedEggNames, Color3.fromRGB(220, 130, 50))

createTitle(eggContent, "✨ เลือกบัฟไข่:")
createScrollList(eggContent, getAllEggModifiers(), selectedEggModifiers, Color3.fromRGB(120, 60, 120))

local eggToggleFrame = Instance.new("Frame")
eggToggleFrame.Size = UDim2.new(1, 0, 0, 50)
eggToggleFrame.BackgroundTransparency = 1
eggToggleFrame.Parent = eggContent

local eggToggle = Instance.new("TextButton")
eggToggle.Size = UDim2.new(1, 0, 0, 40) -- เล็กลง
eggToggle.Position = UDim2.new(0, 0, 0, 0)
eggToggle.BackgroundColor3 = Color3.fromRGB(255, 128, 0)
eggToggle.Text = "▶ เริ่มซื้อไข่"
eggToggle.TextColor3 = textClr
eggToggle.TextSize = 13
eggToggle.Font = Enum.Font.GothamBold
eggToggle.Parent = eggToggleFrame

local eggToggleCorner = Instance.new("UICorner")
eggToggleCorner.CornerRadius = UDim.new(0, 10)
eggToggleCorner.Parent = eggToggle

eggToggle.MouseButton1Click:Connect(function()
    autoBuyEggEnabled = not autoBuyEggEnabled
    eggToggle.Text = autoBuyEggEnabled and "⏸ หยุดซื้อไข่" or "▶ เริ่มซื้อไข่"
    eggToggle.BackgroundColor3 = autoBuyEggEnabled and Color3.fromRGB(200, 50, 50) or Color3.fromRGB(255, 128, 0)
    if autoBuyEggEnabled then
        spawn(autoBuyEggLoop)
    end
end)

-- Ghost Tab (Tab 4)
local ghostContent = contents[4]

local ghostStatus = createStatusBox(ghostContent, "🔴 สถานะ: ปิด", Color3.fromRGB(45, 45, 55))

local ghostCount = Instance.new("TextLabel")
ghostCount.Size = UDim2.new(1, 0, 0, 35) -- เล็กลง
ghostCount.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
ghostCount.Text = "👻 ผีที่ตี: 0"
ghostCount.TextColor3 = textClr
ghostCount.TextSize = 13
ghostCount.Font = Enum.Font.Gotham
ghostCount.Parent = ghostContent

local ghostCountCorner = Instance.new("UICorner")
ghostCountCorner.CornerRadius = UDim.new(0, 10)
ghostCountCorner.Parent = ghostCount

spawn(function()
    while wait(0.5) do
        ghostCount.Text = "👻 ผีที่ตี: " .. ghostKillCount
    end
end)

local ghostToggleFrame = Instance.new("Frame")
ghostToggleFrame.Size = UDim2.new(1, 0, 0, 50)
ghostToggleFrame.BackgroundTransparency = 1
ghostToggleFrame.Parent = ghostContent

local ghostToggle = Instance.new("TextButton")
ghostToggle.Size = UDim2.new(1, 0, 0, 40) -- เล็กลง
ghostToggle.Position = UDim2.new(0, 0, 0, 0)
ghostToggle.BackgroundColor3 = Color3.fromRGB(150, 50, 150)
ghostToggle.Text = "▶ เริ่มฟาร์มผี"
ghostToggle.TextColor3 = textClr
ghostToggle.TextSize = 13
ghostToggle.Font = Enum.Font.GothamBold
ghostToggle.Parent = ghostToggleFrame

local ghostToggleCorner = Instance.new("UICorner")
ghostToggleCorner.CornerRadius = UDim.new(0, 10)
ghostToggleCorner.Parent = ghostToggle

ghostToggle.MouseButton1Click:Connect(function()
    autoGhostEnabled = not autoGhostEnabled
    ghostToggle.Text = autoGhostEnabled and "⏸ หยุดฟาร์มผี" or "▶ เริ่มฟาร์มผี"
    ghostToggle.BackgroundColor3 = autoGhostEnabled and Color3.fromRGB(200, 50, 50) or Color3.fromRGB(150, 50, 150)
    ghostStatus.Text = autoGhostEnabled and "🟢 สถานะ: เปิด" or "🔴 สถานะ: ปิด"
    ghostStatus.BackgroundColor3 = autoGhostEnabled and Color3.fromRGB(40, 167, 69) or Color3.fromRGB(45, 45, 55)
    if autoGhostEnabled then
        spawn(function()
            autoGhostLoop(ghostStatus)
        end)
    end
end)

-- Rocket Tab (Tab 5)
local rocketContent = contents[5]

local rocketStatus = createStatusBox(rocketContent, "🔴 สถานะ: ปิด", Color3.fromRGB(45, 45, 55))

local rocketCount = Instance.new("TextLabel")
rocketCount.Size = UDim2.new(1, 0, 0, 35) -- เล็กลง
rocketCount.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
rocketCount.Text = "🚀 จรวดที่เก็บ: 0"
rocketCount.TextColor3 = textClr
rocketCount.TextSize = 13
rocketCount.Font = Enum.Font.Gotham
rocketCount.Parent = rocketContent

local rocketCountCorner = Instance.new("UICorner")
rocketCountCorner.CornerRadius = UDim.new(0, 10)
rocketCountCorner.Parent = rocketCount

spawn(function()
    while wait(0.5) do
        rocketCount.Text = "🚀 จรวดที่เก็บ: " .. rocketCollectCount
    end
end)

local rocketToggleFrame = Instance.new("Frame")
rocketToggleFrame.Size = UDim2.new(1, 0, 0, 50)
rocketToggleFrame.BackgroundTransparency = 1
rocketToggleFrame.Parent = rocketContent

local rocketToggle = Instance.new("TextButton")
rocketToggle.Size = UDim2.new(1, 0, 0, 40) -- เล็กลง
rocketToggle.Position = UDim2.new(0, 0, 0, 0)
rocketToggle.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
rocketToggle.Text = "▶ เริ่มเก็บจรวด"
rocketToggle.TextColor3 = textClr
rocketToggle.TextSize = 13
rocketToggle.Font = Enum.Font.GothamBold
rocketToggle.Parent = rocketToggleFrame

local rocketToggleCorner = Instance.new("UICorner")
rocketToggleCorner.CornerRadius = UDim.new(0, 10)
rocketToggleCorner.Parent = rocketToggle

rocketToggle.MouseButton1Click:Connect(function()
    autoRocketEnabled = not autoRocketEnabled
    rocketToggle.Text = autoRocketEnabled and "⏸ หยุดเก็บจรวด" or "▶ เริ่มเก็บจรวด"
    rocketToggle.BackgroundColor3 = autoRocketEnabled and Color3.fromRGB(200, 50, 50) or Color3.fromRGB(50, 150, 50)
    rocketStatus.Text = autoRocketEnabled and "🟢 สถานะ: เปิด" or "🔴 สถานะ: ปิด"
    rocketStatus.BackgroundColor3 = autoRocketEnabled and Color3.fromRGB(40, 167, 69) or Color3.fromRGB(45, 45, 55)
    if autoRocketEnabled then
        spawn(function()
            autoRocketLoop(rocketStatus)
        end)
    end
end)

-- Run initial systems
spawn(function() initAntiIdleSystem() end)
player.Idled:Connect(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end)
spawn(function()
    while true do
        if antiAfkEnabled then wait(math.random(jumpInterval - 100, jumpInterval + 100) / 1000)
            local h = player.Character:FindFirstChild("Humanoid") if h and h.Health > 0 then h.Jump = true end
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
