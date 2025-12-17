--==================================================
-- VERYFUN UI CORE (CatchaMonster Style)
-- UI ONLY / SELL VERSION
--==================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer

--==================================================
-- CLASS
--==================================================
local UI = {}
UI.__index = UI

--==================================================
-- PRIVATE CONFIG
--==================================================
local CFG = {
    Logo = "rbxassetid://82270910588453",
    Theme = {
        bg      = Color3.fromRGB(20,16,28),
        panel   = Color3.fromRGB(28,22,38),
        accent  = Color3.fromRGB(170,78,255),
        text    = Color3.fromRGB(235,210,255),
        dim     = Color3.fromRGB(70,60,95)
    }
}

--==================================================
-- UTILS
--==================================================
local function icon(v)
    if type(v) == "number" then
        return "rbxassetid://"..v
    elseif type(v) == "string" and not v:find("rbxassetid://") then
        return "rbxassetid://"..v
    end
    return v
end

local function tw(o,p,t)
    TweenService:Create(o,TweenInfo.new(t or 0.15,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),p):Play()
end

--==================================================
-- INIT
--==================================================
function UI:_init()
    pcall(function()
        if CoreGui:FindFirstChild("VeryFun_UI_Core") then
            CoreGui.VeryFun_UI_Core:Destroy()
        end
    end)

    local gui = Instance.new("ScreenGui", CoreGui)
    gui.Name = "VeryFun_UI_Core"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    self.Gui = gui

    --================ MAIN =================
    local main = Instance.new("Frame", gui)
    main.Size = UDim2.fromOffset(640,420)
    main.Position = UDim2.fromScale(0.5,0.5)
    main.AnchorPoint = Vector2.new(0.5,0.5)
    main.BackgroundColor3 = CFG.Theme.bg
    main.Active = true
    main.Draggable = true
    Instance.new("UICorner", main).CornerRadius = UDim.new(0,16)
    self.Main = main

    local stroke = Instance.new("UIStroke", main)
    stroke.Color = CFG.Theme.accent
    stroke.Thickness = 2

    local title = Instance.new("TextLabel", main)
    title.Size = UDim2.new(1,-24,0,50)
    title.Position = UDim2.fromOffset(12,8)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 18
    title.TextXAlignment = Left
    title.TextColor3 = CFG.Theme.text
    title.Text = "VeryFun UI"
    self.Title = title

    --================ SIDEBAR =================
    local side = Instance.new("ScrollingFrame", main)
    side.Position = UDim2.fromOffset(12,64)
    side.Size = UDim2.new(0,180,1,-76)
    side.BackgroundColor3 = CFG.Theme.panel
    side.ScrollBarThickness = 5
    Instance.new("UICorner", side).CornerRadius = UDim.new(0,12)
    self.Sidebar = side

    local sl = Instance.new("UIListLayout", side)
    sl.Padding = UDim.new(0,8)
    sl:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        side.CanvasSize = UDim2.new(0,0,0, sl.AbsoluteContentSize.Y + 16)
    end)

    --================ CONTENT =================
    local content = Instance.new("Frame", main)
    content.Position = UDim2.fromOffset(204,64)
    content.Size = UDim2.new(1,-216,1,-76)
    content.BackgroundTransparency = 1
    self.Content = content

    self.Pages = {}
    self.Current = nil

    --================ FLOAT TOGGLE =================
    local tg = Instance.new("ImageButton", gui)
    tg.Size = UDim2.fromOffset(64,64)
    tg.Position = UDim2.new(0,12,0.45,0)
    tg.BackgroundColor3 = CFG.Theme.panel
    tg.Image = icon(CFG.Logo)
    Instance.new("UICorner", tg).CornerRadius = UDim.new(0,16)

    local ts = Instance.new("UIStroke", tg)
    ts.Color = CFG.Theme.accent
    ts.Thickness = 3

    tg.MouseButton1Click:Connect(function()
        main.Visible = not main.Visible
    end)

    self.ToggleBtn = tg
end

--==================================================
-- PUBLIC API
--==================================================
function UI:SetLogo(v)
    CFG.Logo = icon(v)
    if self.ToggleBtn then
        self.ToggleBtn.Image = CFG.Logo
    end
end

function UI:CreatePage(name)
    local page = Instance.new("ScrollingFrame", self.Content)
    page.Size = UDim2.fromScale(1,1)
    page.ScrollBarThickness = 5
    page.Visible = false
    page.CanvasSize = UDim2.new(0,0,0,0)
    page.BackgroundTransparency = 1

    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0,12)
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y + 20)
    end)

    self.Pages[name] = page

    local btn = Instance.new("TextButton", self.Sidebar)
    btn.Size = UDim2.new(1,0,0,42)
    btn.Text = name
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 15
    btn.TextColor3 = CFG.Theme.text
    btn.BackgroundColor3 = CFG.Theme.panel
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)

    btn.MouseButton1Click:Connect(function()
        if self.Current then self.Current.Visible = false end
        self.Current = page
        page.Visible = true
    end)

    if not self.Current then
        self.Current = page
        page.Visible = true
    end

    return page
end

function UI:CreateSection(p, text)
    local l = Instance.new("TextLabel", p)
    l.Size = UDim2.new(1,0,0,22)
    l.BackgroundTransparency = 1
    l.Font = Enum.Font.GothamBold
    l.TextSize = 14
    l.TextXAlignment = Left
    l.TextColor3 = CFG.Theme.accent
    l.Text = text
end

function UI:CreateToggle(p, text, def, cb)
    local state = def == true

    local f = Instance.new("Frame", p)
    f.Size = UDim2.new(1,0,0,36)
    f.BackgroundTransparency = 1

    local lbl = Instance.new("TextLabel", f)
    lbl.Size = UDim2.new(0.65,0,1,0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.TextXAlignment = Left
    lbl.TextColor3 = CFG.Theme.text
    lbl.Text = text

    local sw = Instance.new("TextButton", f)
    sw.Size = UDim2.fromOffset(56,28)
    sw.Position = UDim2.new(1,-64,0,4)
    sw.Text = ""
    sw.BackgroundColor3 = CFG.Theme.dim
    Instance.new("UICorner", sw).CornerRadius = UDim.new(0,14)

    local dot = Instance.new("Frame", sw)
    dot.Size = UDim2.fromOffset(24,24)
    dot.Position = UDim2.fromOffset(2,2)
    dot.BackgroundColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", dot).CornerRadius = UDim.new(0,12)

    local function refresh()
        tw(sw,{BackgroundColor3 = state and CFG.Theme.accent or CFG.Theme.dim})
        tw(dot,{Position = state and UDim2.fromOffset(30,2) or UDim2.fromOffset(2,2)})
    end
    refresh()

    sw.MouseButton1Click:Connect(function()
        state = not state
        refresh()
        if cb then pcall(cb,state) end
    end)
end

function UI:CreateButton(p, text, cb)
    local b = Instance.new("TextButton", p)
    b.Size = UDim2.new(1,0,0,36)
    b.BackgroundColor3 = CFG.Theme.accent
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.TextColor3 = Color3.new(1,1,1)
    b.Text = text
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,10)
    b.MouseButton1Click:Connect(function()
        if cb then pcall(cb) end
    end)
end

function UI:CreateDropdown(p, text, list, cb)
    local cur = list[1]

    local b = Instance.new("TextButton", p)
    b.Size = UDim2.new(1,0,0,36)
    b.BackgroundColor3 = CFG.Theme.panel
    b.Font = Enum.Font.Gotham
    b.TextSize = 14
    b.TextColor3 = CFG.Theme.text
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,10)

    local function set(v)
        cur = v
        b.Text = text .. " : " .. tostring(v)
        if cb then pcall(cb,v) end
    end
    set(cur)

    b.MouseButton1Click:Connect(function()
        local i = table.find(list,cur) or 0
        i = i % #list + 1
        set(list[i])
    end)
end

function UI:CreateSlider(p, text, min, max, def, cb)
    local val = def or min

    local l = Instance.new("TextLabel", p)
    l.Size = UDim2.new(1,0,0,20)
    l.BackgroundTransparency = 1
    l.Font = Enum.Font.Gotham
    l.TextSize = 13
    l.TextXAlignment = Left
    l.TextColor3 = CFG.Theme.text

    local b = Instance.new("TextButton", p)
    b.Size = UDim2.new(1,0,0,28)
    b.BackgroundColor3 = CFG.Theme.panel
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,10)

    local function set(v)
        val = math.clamp(v,min,max)
        l.Text = text .. " : " .. val
        if cb then pcall(cb,val) end
    end
    set(val)

    b.MouseButton1Click:Connect(function()
        set(val + 1 > max and min or val + 1)
    end)
end

--==================================================
-- EXPORT
--==================================================
return function()
    local self = setmetatable({}, UI)
    self:_init()
    return self
end
