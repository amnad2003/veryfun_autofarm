local Player = game.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local ClientMonsters = Workspace:WaitForChild("ClientMonsters")

local UI_NAME = "VeryFunSHOP_UI_V7_Compact"
local LOGO_ID = "rbxassetid://82270910588453"

-- Theme Variables (Default: Black/Mint Blue)
local PRIMARY_BG = Color3.fromHex("#15151A") -- ดำเข้ม (Black)
local ACCENT_BG  = Color3.fromHex("#1E1E25") -- ดำรอง
local AQUA       = Color3.fromHex("#66FFCC") -- ฟ้ามิ้น (Mint Blue)
local LIGHT_GRAY = Color3.new(0.7, 0.7, 0.7)

-- ลดขนาดรวม UI ลง
local defaultPanelSize = UDim2.new(0.40, 0, 0.55, 0) 
local shrinkSize       = UDim2.new(0, 0, 0, 0)

local tweenOpen  = TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local tweenClose = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

------------------------------------------------------
-- UI CORE SETUP
------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = UI_NAME
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = PlayerGui

local ToggleButton = Instance.new("ImageButton")
ToggleButton.Name = "VeryFunToggle"
ToggleButton.Size = UDim2.new(0, 42, 0, 42)
ToggleButton.Position = UDim2.new(0, 20, 0, 180)
ToggleButton.BackgroundColor3 = PRIMARY_BG
ToggleButton.Image = LOGO_ID
ToggleButton.ImageColor3 = AQUA
ToggleButton.Parent = ScreenGui
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 8)

local MainFrame = Instance.new("Frame")
MainFrame.Size = defaultPanelSize
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.BackgroundColor3 = PRIMARY_BG
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)

-- ลดความสูง TitleBar
local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size = UDim2.new(1, 0, 0.05, 0) 
TitleBar.BackgroundColor3 = ACCENT_BG
TitleBar.BackgroundTransparency = 0.45

local Title = Instance.new("TextLabel", TitleBar)
Title.Size = UDim2.new(1, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "Edited HUB | Catch a Monster"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamSemibold
Title.TextSize = 15 -- เล็กกว่าเดิมเล็กน้อย
Title.TextYAlignment = Enum.TextYAlignment.Center

-- ปรับตำแหน่งและขนาด Sidebar/ContentArea ให้สัมพันธ์กับ TitleBar ใหม่
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0.25, 0, 0.95, 0)
Sidebar.Position = UDim2.new(0, 0, 0.05, 0)
Sidebar.BackgroundColor3 = ACCENT_BG
Sidebar.BorderSizePixel = 0
Instance.new("UIListLayout", Sidebar).Padding = UDim.new(0, 4) -- ลด Padding

local ContentArea = Instance.new("Frame", MainFrame)
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(0.75, 0, 0.95, 0)
ContentArea.Position = UDim2.new(0.25, 0, 0.05, 0)
ContentArea.BackgroundTransparency = 1

local Pages = {}
local ActivePage = nil
local Toggles = {}
local Options = {}

local function ensureToggle(name, default)
    if Toggles[name] == nil then Toggles[name] = { Value = default or false } end
    return Toggles[name]
end

local function ensureOption(name, default)
    if Options[name] == nil then Options[name] = { Value = default } end
    return Options[name]
end

------------------------------------------------------
-- UI FUNCTIONS (WIDGETS)
------------------------------------------------------
local Widget = {}

local function setWidgetPosition(obj)
    obj.Position = UDim2.new(0, 10, 0, 0)
end

function CreateCategory(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 30) -- ลดความสูง
    btn.Text = " [ " .. name .. " ] "
    btn.BackgroundColor3 = ACCENT_BG
    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    btn.Parent = Sidebar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    local page = Instance.new("ScrollingFrame", ContentArea)
    page.Name = name
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.ScrollBarThickness = 6

    local ListLayout = Instance.new("UIListLayout", page)
    ListLayout.Padding = UDim.new(0, 6) -- ลด Padding
    ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    ListLayout.FillDirection = Enum.FillDirection.Vertical

    Pages[name] = { button = btn, frame = page, layout = ListLayout }

    btn.MouseButton1Click:Connect(function()
        if ActivePage then
            ActivePage.button.BackgroundColor3 = ACCENT_BG
            ActivePage.button.TextColor3 = Color3.fromRGB(170, 170, 170)
            ActivePage.frame.Visible = false
        end
        ActivePage = Pages[name]
        btn.BackgroundColor3 = AQUA
        btn.TextColor3 = PRIMARY_BG
        page.Visible = true
    end)

    return page
end

function Widget:Toggle(parent, text, toggleRef)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -20, 0, 24) -- ลดความสูง
    setWidgetPosition(btn)
    btn.BackgroundColor3 = ACCENT_BG
    btn.Text = (toggleRef.Value and "  ☑  " or "  ☐  ") .. text
    btn.TextColor3 = Color3.fromRGB(200,200,200)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13 -- ลดขนาดตัวอักษรเล็กน้อย
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function()
        toggleRef.Value = not toggleRef.Value
        btn.Text = (toggleRef.Value and "  ☑  " or "  ☐  ") .. text
    end)
    return btn
end

-- Custom Number Box with +/- (Replaces Slider)
function Widget:NumberBox(parent, text, min, max, rounding, optionRef)
    local box = Instance.new("Frame", parent)
    box.Size = UDim2.new(1, -20, 0, 45) -- ลดความสูง
    setWidgetPosition(box)
    box.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", box)
    label.Size = UDim2.new(1, 0, 0, 16) -- ลดความสูง
    label.Text = text
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1,1,1)
    label.Font = Enum.Font.Gotham
    label.TextSize = 13 -- ลดขนาดตัวอักษร
    label.TextXAlignment = Enum.TextXAlignment.Left

    local valueLabel = Instance.new("TextLabel", box)
    valueLabel.Size = UDim2.new(0, 70, 0, 25)
    valueLabel.Position = UDim2.new(0, 0, 0, 25) -- ปรับตำแหน่ง
    valueLabel.BackgroundTransparency = 1
    valueLabel.TextColor3 = AQUA
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 15 
    valueLabel.TextXAlignment = Enum.TextXAlignment.Left

    local step = 1
    if rounding > 0 then step = 10^-rounding end

    local function update(v)
        v = math.clamp(v, min, max)
        if rounding == 0 then v = math.floor(v) end
        optionRef.Value = v
        valueLabel.Text = string.format("%." .. rounding .. "f", v)
    end

    -- Minus Button
    local minusBtn = Instance.new("TextButton", box)
    minusBtn.Size = UDim2.new(0, 24, 0, 24) -- ลดขนาดปุ่ม
    minusBtn.Position = UDim2.new(0, 100, 0, 23) -- ปรับตำแหน่ง
    minusBtn.Text = "-"
    minusBtn.BackgroundColor3 = ACCENT_BG
    minusBtn.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", minusBtn).CornerRadius = UDim.new(0, 6)
    minusBtn.MouseButton1Click:Connect(function() update(optionRef.Value - step) end)

    -- Plus Button
    local plusBtn = Instance.new("TextButton", box)
    plusBtn.Size = UDim2.new(0, 24, 0, 24) -- ลดขนาดปุ่ม
    plusBtn.Position = UDim2.new(0, 130, 0, 23) -- ปรับตำแหน่ง
    plusBtn.Text = "+"
    plusBtn.BackgroundColor3 = ACCENT_BG
    plusBtn.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", plusBtn).CornerRadius = UDim.new(0, 6)
    plusBtn.MouseButton1Click:Connect(function() update(optionRef.Value + step) end)

    update(optionRef.Value)
    return box
end

-- Stepper/Spinner Dropdown
local function CreateDropdown(parent, labelText, initialValuesTable, optionRef, isMulti)
    local wrapper = Instance.new("Frame", parent)
    wrapper.Size = UDim2.new(1, -20, 0, 35) -- ลดความสูง
    setWidgetPosition(wrapper)
    wrapper.BackgroundTransparency = 1

    local lbl = Instance.new("TextLabel", wrapper)
    lbl.Size = UDim2.new(1, 0, 0, 16) -- ลดความสูง
    lbl.Text = labelText
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13 -- ลดขนาดตัวอักษร
    lbl.TextColor3 = Color3.new(1,1,1)

    local btn = Instance.new("TextButton", wrapper)
    btn.Size = UDim2.new(1, -120, 0, 18) -- ลดความสูง
    btn.Position = UDim2.new(0, 0, 0, 16) -- ปรับตำแหน่ง
    btn.Text = tostring(optionRef.Value)
    btn.BackgroundColor3 = ACCENT_BG
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)

    local left = Instance.new("TextButton", wrapper)
    left.Size = UDim2.new(0, 50, 0, 18) -- ลดความสูง
    left.Position = UDim2.new(1, -110, 0, 16) -- ปรับตำแหน่ง
    left.Text = "<"
    left.BackgroundColor3 = ACCENT_BG
    left.Font = Enum.Font.GothamBold
    Instance.new("UICorner", left).CornerRadius = UDim.new(0,6)

    local right = Instance.new("TextButton", wrapper)
    right.Size = UDim2.new(0, 50, 0, 18) -- ลดความสูง
    right.Position = UDim2.new(1, -55, 0, 16) -- ปรับตำแหน่ง
    right.Text = ">"
    right.BackgroundColor3 = ACCENT_BG
    right.Font = Enum.Font.GothamBold
    Instance.new("UICorner", right).CornerRadius = UDim.new(0,6)

    local values = initialValuesTable or {"None"}
    local index = 1
    
    local function findIndex(val, list)
        for i, v in ipairs(list) do
            if tostring(v) == tostring(val) then return i end
        end
        return 1
    end

    local function refresh()
        index = findIndex(optionRef.Value, values)
        optionRef.Value = values[index]
        btn.Text = tostring(values[index])
    end
    
    refresh()

    left.MouseButton1Click:Connect(function()
        index = index - 1
        if index < 1 then index = #values end
        optionRef.Value = values[index]
        btn.Text = tostring(values[index])
    end)
    right.MouseButton1Click:Connect(function()
        index = index + 1
        if index > #values then index = 1 end
        optionRef.Value = values[index]
        btn.Text = tostring(values[index])
    end)

    return {
        Frame = wrapper,
        SetValues = function(newValues)
            values = newValues or {"None"}
            if #values == 0 then values = {"None"} end
            refresh()
        end,
        GetValue = function() return optionRef.Value end
    }
end

function Widget:Button(parent, text, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -20, 0, 30) -- ลดความสูง
    setWidgetPosition(btn)
    btn.Text = text
    btn.BackgroundColor3 = ACCENT_BG
    btn.Font = Enum.Font.Gotham
    btn.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

------------------------------------------------------
-- UI DRAG LOGIC (TitleBar ลาก MainFrame)
------------------------------------------------------
local savedMainPos   = MainFrame.Position
local savedTogglePos = ToggleButton.Position
local dragHandlers = {} 
local function enableDrag(obj)
    local dragInfo = {
        isDragging = false,
        startPos = UDim2.new(),
        startMousePos = Vector2.new()
    }
    dragHandlers[obj] = dragInfo
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragInfo.isDragging = true
            dragInfo.startPos = MainFrame.Position -- ลาก MainFrame ด้วย TitleBar/ToggleButton
            dragInfo.startMousePos = UserInputService:GetMouseLocation()
        end
    end)
    obj.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragInfo.isDragging = false
        end
    end)
end
UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        
        -- ถ้ากำลังลาก TitleBar, ให้ย้าย MainFrame
        if dragHandlers[TitleBar].isDragging then
            local info = dragHandlers[TitleBar]
            local delta = UserInputService:GetMouseLocation() - info.startMousePos
            local newX = info.startPos.X.Scale + delta.X / ScreenGui.AbsoluteSize.X
            local newY = info.startPos.Y.Scale + delta.Y / ScreenGui.AbsoluteSize.Y
            MainFrame.Position = UDim2.new(newX, 0, newY, 0)
        
        -- ถ้ากำลังลาก ToggleButton, ให้ย้าย ToggleButton
        elseif dragHandlers[ToggleButton].isDragging then
             local info = dragHandlers[ToggleButton]
             local delta = UserInputService:GetMouseLocation() - info.startMousePos
             local newX = info.startPos.X.Scale + delta.X / ScreenGui.AbsoluteSize.X
             local newY = info.startPos.Y.Scale + delta.Y / ScreenGui.AbsoluteSize.Y
             ToggleButton.Position = UDim2.new(newX, 0, newY, 0)
        end
    end
end)
enableDrag(TitleBar) -- ทำให้ TitleBar ลาก MainFrame ได้
enableDrag(ToggleButton)

local function ToggleUI()
    if MainFrame.Visible then
        savedMainPos = MainFrame.Position
        savedTogglePos = ToggleButton.Position
        TweenService:Create(MainFrame, tweenClose, {Size = shrinkSize}):Play()
        task.wait(0.25)
        MainFrame.Visible = false
    else
        MainFrame.Position = savedMainPos
        ToggleButton.Position = savedTogglePos
        MainFrame.Visible = true
        MainFrame.Size = shrinkSize
        TweenService:Create(MainFrame, tweenOpen, {Size = defaultPanelSize}):Play()
    end
end
ToggleButton.MouseButton1Click:Connect(ToggleUI)


------------------------------------------------------
-- TAB DEFINITIONS
------------------------------------------------------
local MainPage = CreateCategory("Main")
local EggPage = CreateCategory("Egg")
local TeleportTab = CreateCategory("Island") 
local SettingsPage = CreateCategory("Settings")


------------------------------------------------------
-- MAIN PAGE
------------------------------------------------------
local BossList = {'Flaragon','Glazadon','Flarecrest','Mountusk'}
local SelectedBoss = ensureOption("SelectedBoss", BossList[1])
CreateDropdown(MainPage, "Selected Boss", BossList, SelectedBoss)
Widget:Toggle(MainPage, "Auto Farm Boss", ensureToggle("FarmBoss", false))
Widget:Toggle(MainPage, "Auto Farm All Boss", ensureToggle("FarmAllBoss", false))

_G.listMonster = _G.listMonster or {}
local SelectedMonster = ensureOption("SelectedMonster", "None")
local monsterDrop = CreateDropdown(MainPage, "Selected Monster", _G.listMonster, SelectedMonster)

Widget:Toggle(MainPage, "Auto Farm Monster", ensureToggle("FarmMonster", false))
Widget:Toggle(MainPage, "Mob Aura (Auto Click Nearby)", ensureToggle("MobAura", false))
Widget:Toggle(MainPage, "Auto Dungeon", ensureToggle("DungeonFarm", false))


------------------------------------------------------
-- EGG PAGE
------------------------------------------------------
local aaa = { 'SwampEgg','Ice Egg','FireEgg','Turkey Egg','Pyroclasm Egg','Glacier Egg','Sprout Egg','Abuse Egg' }
local SelectedEgg = ensureOption("SelectedEgg", aaa[1])
CreateDropdown(EggPage, "Selected Egg", aaa, SelectedEgg)

local SelectedMachine = ensureOption("SelectedMachine", 1) 
Widget:NumberBox(EggPage, "Selected Machine (1-4)", 1, 4, 0, SelectedMachine)

Widget:Toggle(EggPage, "Auto Hatch Egg", ensureToggle("AutoHatch", false))
Widget:Toggle(EggPage, "Keep Egg Bosses", ensureToggle("AutoOpenBoss", false)) 
Widget:Toggle(EggPage, "Keep Egg Monster", ensureToggle("AutoOpen", false)) 

local Island = {'First Land','Ice Land','Volcano Land'}
local SelectedIsLand = ensureOption("SelectedIsLand", Island[1])
CreateDropdown(EggPage, "Selected IsLand", Island, SelectedIsLand)

Widget:Toggle(EggPage, "Auto Find Egg", ensureToggle("AutoFindEgg", false))


------------------------------------------------------
-- TELEPORT PAGE
------------------------------------------------------
Widget:Button(TeleportTab, 'First IsLand', function() Collection:Teleport(Vector3.new( 85, -60, 669 )) end)
Widget:Button(TeleportTab, 'Sky IsLand', function() Collection:Teleport(Vector3.new( 573, 3477, -228 )) end)
Widget:Button(TeleportTab, 'Ice IsLand', function() Collection:Teleport(Vector3.new( -2211, -117, -979 )) end)
Widget:Button(TeleportTab, 'Volcano IsLand', function() Collection:Teleport(Vector3.new( 167, -118, -1150 )) end)


------------------------------------------------------
-- SETTINGS PAGE (Using NumberBox)
------------------------------------------------------
local FPSCAP = ensureOption("FPSCAP", 120)
Widget:NumberBox(SettingsPage, "Set Fps Cap", 5, 240, 0, FPSCAP) 

local Wave = ensureOption("Wave", 10)
Widget:NumberBox(SettingsPage, "Set Layer", 1, 50, 0, Wave)

local MonsterCount = ensureOption("MonsterCount", 1)
Widget:NumberBox(SettingsPage, "Monster Count", 0, 10, 0, MonsterCount)

Widget:Toggle(SettingsPage, "Auto Exit Door", ensureToggle("ExitDoor", false))

local CodeList = {
    'coin','cam','xp','thanksgiving','feather200','thanks300','friday','feather','rankA'
}
Widget:Button(SettingsPage, 'Redeem All Code', function()
    for _,v in pairs(CodeList) do
        local args = { "GetGiftChannel", tostring(v) }
        pcall(function()
            game:GetService("ReplicatedStorage"):WaitForChild("CommonLibrary"):WaitForChild("Tool"):WaitForChild("RemoteManager"):WaitForChild("Funcs"):WaitForChild("DataPullFunc"):InvokeServer(unpack(args))
        end)
        task.wait(0.3)
    end
    game.StarterGui:SetCore("SendNotification", { Title = "!! Completed !!", Text = "Redeem All Code", Duration = 5 })
end)

-- Theme Selector
local themeColors = {
    Default = {Color3.fromHex("#15151A"), Color3.fromHex("#1E1E25"), Color3.fromHex("#66FFCC")}, -- ดำ / ฟ้ามิ้น
    Red = {Color3.fromRGB(40,10,10), Color3.fromRGB(60,10,10), Color3.fromRGB(255,50,50)}, -- แดง
    Green = {Color3.fromRGB(10,40,10), Color3.fromRGB(10,60,10), Color3.fromRGB(50,255,50)}, -- เขียว
    Blue = {Color3.fromRGB(10,10,40), Color3.fromRGB(10,10,60), Color3.fromRGB(50,50,255)},
    Pink = {Color3.fromRGB(40,10,40), Color3.fromRGB(60,10,60), Color3.fromRGB(255,50,255)},
}
local currentTheme = "Default"

local function applyTheme(themeName, p_bg, a_bg, aqua_c)
    PRIMARY_BG = p_bg
    ACCENT_BG = a_bg
    AQUA = aqua_c
    currentTheme = themeName

    MainFrame.BackgroundColor3 = PRIMARY_BG
    Sidebar.BackgroundColor3 = ACCENT_BG
    TitleBar.BackgroundColor3 = ACCENT_BG
    ToggleButton.BackgroundColor3 = PRIMARY_BG
    ToggleButton.ImageColor3 = AQUA

    for _, child in ipairs(Sidebar:GetChildren()) do
        if child:IsA("TextButton") then
            if ActivePage and ActivePage.button == child then
                child.BackgroundColor3 = AQUA
                child.TextColor3 = PRIMARY_BG
            else
                child.BackgroundColor3 = ACCENT_BG
            end
        end
    end

    for _, pageData in pairs(Pages) do
        for _, obj in ipairs(pageData.frame:GetChildren()) do
            if obj:IsA("TextButton") then
                 obj.BackgroundColor3 = ACCENT_BG
            elseif obj:IsA("Frame") then
                for _, btn in ipairs(obj:GetChildren()) do
                    if btn:IsA("TextButton") then btn.BackgroundColor3 = ACCENT_BG end
                    if btn:IsA("TextLabel") and btn.Name == "" and btn.TextColor3 ~= Color3.new(1,1,1) then 
                         btn.TextColor3 = AQUA 
                    end
                end
            end
        end
    end
end


local themeDropdown = Instance.new("TextButton", SettingsPage)
themeDropdown.Size = UDim2.new(1, -20, 0, 30) -- ลดความสูง
setWidgetPosition(themeDropdown)
themeDropdown.Text = "Theme: " .. currentTheme
themeDropdown.BackgroundColor3 = ACCENT_BG
themeDropdown.TextColor3 = Color3.new(1,1,1)
themeDropdown.Font = Enum.Font.GothamBold
Instance.new("UICorner", themeDropdown).CornerRadius = UDim.new(0,6)

local themeIndex = 1
local themeList = {"Default","Red","Green","Blue","Pink"}

themeDropdown.MouseButton1Click:Connect(function()
    themeIndex = themeIndex + 1
    if themeIndex > #themeList then themeIndex = 1 end

    local th = themeList[themeIndex]
    themeDropdown.Text = "Theme: " .. th

    local p, a, q = unpack(themeColors[th])
    applyTheme(th, p, a, q)
end)

Widget:Button(SettingsPage, 'Destroy Ui', function() pcall(function() ScreenGui:Destroy() end) end)


------------------------------------------------------
-- OPEN DEFAULT TAB
------------------------------------------------------
task.spawn(function()
    task.wait(0.3)
    for _, child in ipairs(Sidebar:GetChildren()) do
        if child:IsA("TextButton") and child.Text:find("Main") then
            child:Activate()
            break
        end
    end
end)

-- =================================================================================================
-- PART 3 - INTEGRATED GAME LOGIC (UNCHANGED FROM PREVIOUS STEP)
-- =================================================================================================

local fireclickdetector = (getfenv and getfenv().fireclickdetector) or (fireclickdetector) or function(det)
    pcall(function()
        if det and det:IsA("ClickDetector") then
            det:FireClick()
        end
    end)
end

local MgrMonsterClient
pcall(function() MgrMonsterClient = require(ReplicatedStorage.ClientLogic.Monster.MgrMonsterClient) end)

local monsterData = {} 
_G.listMonster = _G.listMonster or {} 
local function updateMonsterList() 
    for k in pairs(_G.listMonster) do _G.listMonster[k] = nil end 
    for k in pairs(monsterData) do monsterData[k] = nil end 
    
    if type(MgrMonsterClient) == "table" and MgrMonsterClient.IterMonster then 
        pcall(function() MgrMonsterClient.IterMonster(function(monsterInfo) 
            local monsterName = monsterInfo.Config and monsterInfo.Config.Name or "Unknown" 
            local monsterId = monsterInfo.MonsterId 
            
            if not table.find(_G.listMonster, monsterName) then table.insert(_G.listMonster, monsterName) end 
            
            if not monsterData[monsterName] then 
                monsterData[monsterName] = { 
                    Name = monsterName, 
                    Config = monsterInfo.Config, 
                    Instances = {} 
                } 
            end 
            table.insert(monsterData[monsterName].Instances, { MonsterId = monsterId, Info = monsterInfo }) 
            return true 
        end) end) 
    else 
        if ClientMonsters then 
            for _, v in ipairs(ClientMonsters:GetChildren()) do 
                if not table.find(_G.listMonster, v.Name) then table.insert(_G.listMonster, v.Name) end 
            end 
        end 
    end 
end 

task.spawn(function() 
    while true do 
        pcall(updateMonsterList) 
        -- Update monster list dropdown values
        if type(_G.listMonster) == "table" and #_G.listMonster > 0 then
            monsterDrop.SetValues(_G.listMonster)
        end
        task.wait(2) 
    end 
end)

Collection = Collection or {}
Collection.__index = Collection

function Collection:UseEvent(Key)
    local vum = game:GetService("VirtualInputManager") 
    vum:SendKeyEvent(true, Key, false, game) 
    vum:SendKeyEvent(false, Key, false, game) 
end 
    
function Collection:getRoot(Character) 
    Character = Character or (LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()) 
    return Character:WaitForChild("HumanoidRootPart", 5) or Character:FindFirstChild("HumanoidRootPart") or Character:FindFirstChild("Root") or Character:FindFirstChild("Torso") 
end 
    
function Collection:Teleport(Position) 
    local Root = Collection:getRoot(LocalPlayer.Character) 
    if not Root then return end 
    if typeof(Position) == "CFrame" then Root.CFrame = Position 
    elseif typeof(Position) == "Vector3" then Root.CFrame = CFrame.new(Position) 
    end 
end 
    
function Collection:getClosesetMonster() 
    local Enemies = {} 
    local EnemiesPositions = {} 
    local Root = Collection:getRoot(LocalPlayer.Character) 
    if not ClientMonsters then return nil end 
    for _, v in ipairs(ClientMonsters:GetChildren()) do 
        if v:FindFirstChild("Root") then 
            local Distance = math.floor((v.Root.Position - Root.Position).Magnitude) 
            table.insert(EnemiesPositions, Distance) 
            Enemies[tostring(Distance)] = v 
        end 
    end 
    if #EnemiesPositions == 0 then return nil end 
    return Enemies[tostring(math.min(unpack(EnemiesPositions)))] 
end 
    
function Collection:getClosesetMonster2(limit) 
    local Enemies = {} 
    local EnemiesPositions = {} 
    local Root = Collection:getRoot(LocalPlayer.Character) 
    if not ClientMonsters then return nil end 
    local monsterList = ClientMonsters:GetChildren() 
    local monsterCount = #monsterList 
    if limit and monsterCount ~= nil and monsterCount <= limit then return "LIMIT MONSTER" end 
    for _, v in ipairs(monsterList) do 
        if v:FindFirstChild("Root") then 
            local Distance = math.floor((v.Root.Position - Root.Position).Magnitude) 
            table.insert(EnemiesPositions, Distance) 
            Enemies[tostring(Distance)] = v 
        end 
    end 
    if #EnemiesPositions == 0 then return nil end 
    return Enemies[tostring(math.min(unpack(EnemiesPositions)))] 
end 
    
function Collection:getBoss(EnterHealth) 
    if not Workspace:FindFirstChild("Monsters") then return false end 
    for i, v in pairs(Workspace.Monsters:GetChildren()) do 
        local healthObj = v:FindFirstChild("Health") 
        if healthObj and healthObj:GetAttribute("MaxHealth") == EnterHealth then return v end 
    end 
    return false 
end 
    
function Collection:getBossByName(boss_n) 
    if not ClientMonsters then return false end 
    for i, v in pairs(ClientMonsters:GetChildren()) do 
        if v.Name == tostring(boss_n) then return v end 
    end 
    return false 
end 
    
function Collection:getAllMonsterIdsByName(monsterName) 
    local data = monsterData[monsterName] 
    if not data or #data.Instances == 0 then 
        return {} 
    end 
    local aliveIds = {} 
    for _, instance in ipairs(data.Instances) do 
        if instance.Info and instance.Info:IsAlive() then 
            table.insert(aliveIds, "Monster_" .. tostring(instance.MonsterId)) 
        end 
    end 
    return aliveIds 
end 
    
function Collection:targetEgg(NameEgg) 
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return end 
    local EggSelect = playerGui:FindFirstChild("MainGui") and playerGui.MainGui:FindFirstChild("ScreenGui") and playerGui.MainGui.ScreenGui:FindFirstChild("EggSelectView") 
    if not EggSelect then return nil end 
    local FmList = EggSelect:FindFirstChild("FmList") 
    if not FmList then return nil end 
    for _, fmItem in pairs(FmList:GetChildren()) do 
        if fmItem:IsA("Frame") or fmItem:IsA("GuiObject") then
            for _, child in pairs(fmItem:GetChildren()) do 
                local labName = child:FindFirstChild("LabName") 
                if labName and labName:IsA("TextLabel") then 
                    if labName.Text == NameEgg then return child end 
                end 
            end 
        end
    end 
end 
    
function Collection:fireclickbutton(button) 
    if not button then return end 
    xpcall(function() 
        local VisibleGui = LocalPlayer.PlayerGui:FindFirstChild("_") or Instance.new("Frame") 
        VisibleGui.Name = "_" 
        VisibleGui.BackgroundTransparency = 0 
        VisibleGui.Parent = LocalPlayer.PlayerGui 
        LocalPlayer.PlayerGui.SelectionImageObject = VisibleGui 
        GuiService.SelectedObject = button 
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game) 
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game) 
    end, warn) 
end 
    
function Collection:getHatchEgg() 
    local WorkspaceArea = Workspace:FindFirstChild("Area") 
    if not WorkspaceArea then return false end 
    local machineList = Options.SelectedMachine and Options.SelectedMachine.Value or 1
    
    local EggHatch = Workspace.Area.center.Area:FindFirstChild("EggHatch") 
    if not EggHatch then return false end 

    -- Only check the single selected machine (as simplified by NumberBox)
    local hatch = EggHatch:FindFirstChild("Hatch_" .. machineList) 
    if not hatch then return false end 
    local TopGUI = hatch:FindFirstChild("TopGUI") 
    if not TopGUI then return false end 
    local HatchInfo = TopGUI:FindFirstChild("HatchInfoGui") 
    if not HatchInfo then return false end 
    local CompleteFrame = HatchInfo:FindFirstChild("FmComplete") 
    if not CompleteFrame then return false end 
    local LabDesc = CompleteFrame:FindFirstChild("LabDesc") 
    if not LabDesc or not LabDesc.Text then return false end 
    if LabDesc.Text:lower():find("ready to hatch!") then return hatch end 
    
    return false 
end 
    
function Collection:getNotRoot() 
    local machineList = Options.SelectedMachine and Options.SelectedMachine.Value or 1
    local EggHatch = Workspace.Area.center.Area:FindFirstChild("EggHatch")
    if not EggHatch then return false end
    
    local v = EggHatch:FindFirstChild("Hatch_"..machineList) 
    if v then 
        local EggAth = v:FindFirstChild("EggAth") 
        if EggAth then
            local root = EggAth:FindFirstChild("Root", true) or EggAth:FindFirstChild("HumanoidRootPart", true) 
            if not root then return v end
        end
    end
    return false 
end 

-- =================================================================================================
-- GAME LOGIC LOOPS 
-- =================================================================================================

task.spawn(function()
    while true do task.wait()
        if Toggles.FarmAllBoss.Value then
            local succes, err = pcall(function()
                local Flaragon = Collection:getBoss("3517630,-1")
                local Glazadon = Collection:getBoss("1874304,0")
                local Flarecrest = Collection:getBoss("1564499.1,1")
                local Mountusk = Collection:getBoss('4261402,0')
            
                local BossToFarm = nil
                local TeleportPos = nil

                if Flaragon then BossToFarm = Flaragon; TeleportPos = Vector3.new( -9, -116, -1539 )
                elseif Glazadon then BossToFarm = Glazadon; TeleportPos = Vector3.new( -2304, 42, -1420 )
                elseif Flarecrest then BossToFarm = Flarecrest; TeleportPos = Vector3.new( 814, 3485, -354 )
                elseif Mountusk then BossToFarm = Mountusk; TeleportPos = Vector3.new( 167, -118, -1150 ) end
            
                if BossToFarm then
                    local BossName = Collection:getBossByName(BossToFarm.Name)
                    if BossName and BossName:FindFirstChild("Root") then
                        -- Pet Teleport
                        for i,v in pairs(Workspace.ClientPets:GetChildren()) do
                            if string.find(v.Name, 'Pet') then
                                local Root = Collection:getRoot(LocalPlayer.Character)
                                if v:FindFirstChild('Root') and (v.Root.Position - Root.Position).magnitude > 10 then
                                    local HumanoidRootPart = Collection:getRoot(LocalPlayer.Character)
                                    v.Root.CFrame = HumanoidRootPart.CFrame
                                end
                            end
                        end
                        
                        -- Player Teleport & Click
                        if LocalPlayer:DistanceFromCharacter(BossName.Root.Position) > 5 then
                            Collection:Teleport(BossName.Root.Position)
                        end
                        local clickDetector = BossName.Root:FindFirstChild("ClickDetector")
                        if clickDetector then
                            clickDetector.MaxActivationDistance = 1000
                            fireclickdetector(clickDetector)
                            task.wait(0.5)
                        end
                    end
                else
                    -- Teleport routine if no boss is found
                    Collection:Teleport(Vector3.new(  -9, -116, -1539  ))
                    task.wait(1.5)
                    Collection:Teleport(Vector3.new(  -2304, 42, -1420  ))
                    task.wait(1.5)
                    Collection:Teleport(Vector3.new(  814, 3485, -354  ))
                    task.wait(180)
                end
            end)

            if err then
                print('!! ERROR !!'.. tostring(err))
            end
        end
    end
end)


task.spawn(function()
    while true do task.wait()
        if Toggles.FarmBoss.Value then
            local success, err = pcall(function()
                local BossHealthMap = {
                    Flaragon = "3517630,-1",
                    Glazadon = "1874304,0",
                    Mountusk = "4261402,0",
                    Flarecrest = "1564499.1,1",
                }
                
                local BossName = Options.SelectedBoss.Value
                local HealthKey = BossHealthMap[BossName]
                
                local Boss = Collection:getBoss(HealthKey)
                
                if Boss then
                    local BossInstance = Collection:getBossByName(Boss.Name)
                    local TeleportRequired = false
                    
                    if BossName == "Flaragon" and LocalPlayer:DistanceFromCharacter(Vector3.new(  -9, -116, -1539  )) > 100 then TeleportRequired = true end
                    if BossName == "Glazadon" and LocalPlayer:DistanceFromCharacter(Vector3.new(  -2304, 42, -1420  )) > 100 then TeleportRequired = true end
                    if BossName == "Mountusk" and LocalPlayer:DistanceFromCharacter(Vector3.new(  -2304, 42, -1420  )) > 100 then TeleportRequired = true end
                    if BossName == "Flarecrest" and LocalPlayer:DistanceFromCharacter(Vector3.new(  814, 3485, -354  )) > 100 then TeleportRequired = true end

                    if BossInstance and BossInstance:FindFirstChild("Root") then
                        -- Pet Teleport Logic (same as FarmAllBoss)
                        for i,v in pairs(Workspace.ClientPets:GetChildren()) do
                            if string.find(v.Name, 'Pet') then
                                local Root = Collection:getRoot(LocalPlayer.Character)
                                if v:FindFirstChild('Root') and (v.Root.Position - Root.Position).magnitude > 10 then
                                    v.Root.CFrame = Collection:getRoot(LocalPlayer.Character).CFrame
                                end
                            end
                        end

                        if LocalPlayer:DistanceFromCharacter(BossInstance.Root.Position) > 5 then
                            Collection:Teleport(BossInstance.Root.Position)
                        end
                        
                        local clickDetector = BossInstance.Root:FindFirstChild("ClickDetector")
                        if clickDetector then
                            clickDetector.MaxActivationDistance = 1000
                            fireclickdetector(clickDetector)
                            task.wait(0.5)
                        end
                    end
                else
                    -- Teleport to the boss's island if not present
                    if BossName == "Flaragon" then Collection:Teleport(Vector3.new(  -9, -116, -1539  )) end
                    if BossName == "Glazadon" then Collection:Teleport(Vector3.new(  -2304, 42, -1420  )) end
                    if BossName == "Mountusk" then Collection:Teleport(Vector3.new(  -2304, 42, -1420  )) end
                    if BossName == "Flarecrest" then Collection:Teleport(Vector3.new(  814, 3485, -354  )) end
                end
            end)
            if err then print("!! Error !!".. tostring(err)) end
        end
    end
end)


task.spawn(function()
    while true do task.wait()
        if Toggles.FarmMonster.Value then
            local succes, err = pcall(function()
                local MonsterNames = Collection:getAllMonsterIdsByName(Options.SelectedMonster.Value)
                
                for _, v in pairs(ClientMonsters:GetChildren()) do
                    if not Toggles.FarmMonster.Value then break end
                    
                    if table.find(MonsterNames, v.Name) then
                        local health = v:FindFirstChild("Health")
                        repeat task.wait()
                            local root = v:FindFirstChild("Root")
                            
                            if root then
                                if LocalPlayer:DistanceFromCharacter(root.Position) > 5 then
                                    Collection:Teleport(root.Position)
                                end
                                
                                local clickDetector = root:FindFirstChild("ClickDetector")
                                if clickDetector then
                                    clickDetector.MaxActivationDistance = 1000
                                    fireclickdetector(clickDetector)
                                    task.wait(0.5)
                                end
                            end
                        -- Stop loop if toggle is off OR monster is gone (v is nil OR health <= 0)
                        until not (v and v.Parent) or not Toggles.FarmMonster.Value or (health and (health.Value or 0) <= 0)
                    end
                end
            end)
          if err then print('!! ERROR !!'.. tostring(err)) end
        end
    end
end)

task.spawn(function()
    while task.wait() do
        if Toggles.MobAura.Value then
            local success, err = pcall(function()
                local Enemies = Collection:getClosesetMonster()
                if Enemies then
                    repeat 
                        task.wait(0.1)
                        if not (Enemies and Enemies.Parent and Enemies:FindFirstChild("Root")) then
                            Enemies = Collection:getClosesetMonster()
                        end
                        if Enemies and Enemies ~= "LIMIT MONSTER" then
                            local root = Enemies.Root
                            if root then
                                if LocalPlayer:DistanceFromCharacter(root.Position) > 5 then
                                    Collection:Teleport(root.Position)
                                end
                                local cd = root:FindFirstChild("ClickDetector")
                                if cd then
                                    cd.MaxActivationDistance = 1000
                                    fireclickdetector(cd)
                                    task.wait(0.3)
                                end
                            end
                        end
                    until not Toggles.MobAura.Value
                end
            end)
            if err then warn("!! Error !! " .. tostring(err)) end
        end
    end
end)

task.spawn(function()
    while task.wait() do
        if Toggles.DungeonFarm.Value then
            local success, err = pcall(function()

                local Enemies = Collection:getClosesetMonster2(Options.MonsterCount.Value)

                if LocalPlayer:DistanceFromCharacter(Vector3.new(49999, -35, 9)) <= 1500 then
                    if Enemies and Enemies ~= "LIMIT MONSTER" then
                        repeat 
                            task.wait(0.1)
                            if not (Enemies and Enemies.Parent and Enemies:FindFirstChild("Root")) then
                                Enemies = Collection:getClosesetMonster2(Options.MonsterCount.Value)
                            end
                            if Enemies == "LIMIT MONSTER" then break end

                            if Enemies and Enemies ~= "LIMIT MONSTER" then
                                local root = Enemies.Root
                                if root then
                                    if LocalPlayer:DistanceFromCharacter(root.Position) > 5 then
                                        Collection:Teleport(root.Position)
                                    end

                                    local cd = root:FindFirstChild("ClickDetector")
                                    if cd then
                                        cd.MaxActivationDistance = 1000
                                        fireclickdetector(cd)
                                        task.wait(0.3)
                                    end
                                end
                            end
                        until not Toggles.DungeonFarm.Value
                    end

                    if Enemies == "LIMIT MONSTER" then
                        ReplicatedStorage.CommonLibrary.Tool.RemoteManager.Funcs.DataPullFunc:InvokeServer("TowerLeaveChannel")
                    end
                    local TowerResultView = Player.PlayerGui.MainGui.ScreenGui:FindFirstChild('TowerResultView')
                    if TowerResultView then
                        Collection:fireclickbutton(TowerResultView.FmContent.BtClose)
                    end
                else
                    -- Teleport routine to enter dungeon
                    Collection:Teleport(Vector3.new(814, 3485, -354))
                    task.wait(1.5)
                    local TowerEnter = Workspace.Area.center.Area.CommonZone:FindFirstChild("TowerEnter")
                    if TowerEnter then
                        Collection:Teleport(TowerEnter.Position)
                        task.wait(1.5)
                    end
                end
            end)
            if err then warn("!! Error !! " .. tostring(err)) end
        end
    end
end)

task.spawn(function()
    while true do task.wait()
        if Toggles.ExitDoor.Value then
            pcall(function()
                local MainGui = Player.PlayerGui:FindFirstChild("MainGui")
                if MainGui and MainGui.ScreenGui:FindFirstChild('TowerMainLeftTopView') then
                    local currentText = MainGui.ScreenGui.TowerMainLeftTopView.FmLayer.LabLayer.Text
                    local currentLayer = tonumber(currentText:match("%d+"))
                    local targetLayer = Options.Wave.Value
                    
                    if Workspace:FindFirstChild('TowerToNextZone') then
                        Collection:Teleport(Workspace:FindFirstChild('TowerToNextZone').Position)
                    elseif currentLayer and targetLayer and currentLayer >= targetLayer then
                        ReplicatedStorage.CommonLibrary.Tool.RemoteManager.Funcs.DataPullFunc:InvokeServer("TowerLeaveChannel")
                    end
                end
            end)
        end
    end
end)

task.spawn(function()
    while true do task.wait()
        if Toggles.AutoHatch.Value then
            local succes, err = pcall(function()
                if LocalPlayer:DistanceFromCharacter(Vector3.new(572, 3487, -297)) <= 1000 then
                    local Root_C = Collection:getNotRoot()
                    local Machine_C = Collection:getHatchEgg()
                    
                    local playerGui = Player.PlayerGui
                    local EggSelectView = playerGui:FindFirstChild("MainGui") and playerGui.MainGui.ScreenGui:FindFirstChild('EggSelectView') 

                    if Root_C and not Machine_C then
                        Collection:Teleport(Root_C.Position)
                        if LocalPlayer:DistanceFromCharacter(Root_C.Position) <= 10 then
                            Collection:UseEvent('E')
                            task.wait()
                            
                            if EggSelectView then
                                Collection:fireclickbutton(Collection:targetEgg(Options.SelectedEgg.Value))
                            end
                            if EggSelectView 
                                and EggSelectView:FindFirstChild('RightFrame') 
                                and EggSelectView.RightFrame:FindFirstChild("CommonBg")
                                and EggSelectView.RightFrame.CommonBg.Visible
                            then
                                Collection:fireclickbutton(EggSelectView.RightFrame.CommonBg.BottomFrame.Select)
                            end 
                        end
                    end
                    if Machine_C then
                        Collection:Teleport(Machine_C.Position)
                        task.wait(0.5)
                        Collection:UseEvent('E')
                        task.wait()
                    end
                else
                    Collection:Teleport(Vector3.new(572, 3487, -297))
                end
            end)

            if err then print('!! ERROR !!'.. tostring(err)) end
        end
    end
end)

task.spawn(function()
    while true do task.wait()
        if Toggles.AutoFindEgg.Value then
            local succes, err = pcall(function()
                local TargetPos, MaxDistance = nil, nil
                
                if Options.SelectedIsLand.Value == "First Land" then
                    TargetPos = Vector3.new(84, -60, 645)
                    MaxDistance = 1000
                elseif Options.SelectedIsLand.Value == "Ice Land" then
                    TargetPos = Vector3.new(-2304, 42, -1420)
                    MaxDistance = 1500
                elseif Options.SelectedIsLand.Value == "Volcano Land" then
                    TargetPos = Vector3.new(-9, -116, -1539)
                    MaxDistance = 1500
                end
                
                if TargetPos and LocalPlayer:DistanceFromCharacter(TargetPos) >= MaxDistance then
                    Collection:Teleport(TargetPos)
                else
                    for i,v in pairs(Workspace:FindFirstChild("AreaEgg"):GetChildren() or {}) do
                        if v:IsA('Part') then
                            if (v.Position - TargetPos).magnitude <= MaxDistance then
                                Collection:Teleport(v.Position)
                                task.wait()
                                Collection:UseEvent('E')
                            end
                        end
                    end
                end
            end)

            if err then print('!! ERROR !!'.. tostring(err)) end
        end
    end
end)

task.spawn(function()
    while true do task.wait()
        if Toggles.AutoOpen.Value then
            if LocalPlayer:FindFirstChild('PlayerGui') and LocalPlayer.PlayerGui:FindFirstChild("CatchDoGui") then
                Collection:UseEvent("E")
            end
        end
    end
end)
task.spawn(function()
    while true do task.wait()
        if Toggles.AutoOpenBoss.Value then
            if LocalPlayer:FindFirstChild('PlayerGui') and LocalPlayer.PlayerGui:FindFirstChild("PickUpDoGui") then
                Collection:UseEvent("E")
            end
        end
    end
end)

task.spawn(function()
    while true do wait()
        pcall(function()
            if setfpscap then 
                setfpscap(Options.FPSCAP.Value)
            end
            task.wait(1)
        end)
    end
end)

-- AFK Bypass 
local vu = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    vu:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
    task.wait(1)
    vu:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
end)

-- Error Catching 
game:GetService("CoreGui").RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
    if child.Name == 'ErrorPrompt' and child:FindFirstChild('MessageArea') and child.MessageArea:FindFirstChild("ErrorFrame") then
        game:GetService("TeleportService"):Teleport(game.PlaceId)
    end
end)