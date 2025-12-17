--====================================================
-- VeryFun UI CORE (FULL)
-- Pure UI | Customer Build Menu Themselves
--====================================================

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local UI = {}
UI.__index = UI

--==============================
-- STATE
--==============================
local STATE = {
    Logo = "rbxassetid://82270910588453",
    Title = "VeryFun UI"
}

local function tw(obj, props, t)
    TweenService:Create(
        obj,
        TweenInfo.new(t or 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        props
    ):Play()
end

local function icon(i)
    if type(i) == "number" then
        return "rbxassetid://" .. i
    elseif type(i) == "string" and not i:find("rbxassetid://") then
        return "rbxassetid://" .. i
    end
    return i
end

--==============================
-- INIT
--==============================
function UI:_init()
    pcall(function()
        if CoreGui:FindFirstChild("VeryFun_UI_Core") then
            CoreGui.VeryFun_UI_Core:Destroy()
        end
    end)

    local gui = Instance.new("ScreenGui")
    gui.Name = "VeryFun_UI_Core"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = CoreGui
    self.Gui = gui

    --================ MAIN =================
    local main = Instance.new("Frame", gui)
    main.Size = UDim2.fromOffset(640,420)
    main.Position = UDim2.fromScale(0.5,0.5)
    main.AnchorPoint = Vector2.new(0.5,0.5)
    main.BackgroundColor3 = Color3.fromRGB(20,16,28)
    main.Active = true
    main.Draggable = true
    Instance.new("UICorner", main).CornerRadius = UDim.new(0,16)
    self.Main = main

    local stroke = Instance.new("UIStroke", main)
    stroke.Color = Color3.fromRGB(170,78,255)
    stroke.Thickness = 2

    local title = Instance.new("TextLabel", main)
    title.Size = UDim2.new(1,-140,0,48)
    title.Position = UDim2.fromOffset(12,8)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextColor3 = Color3.fromRGB(235,210,255)
    title.Text = STATE.Title
    self.TitleLabel = title

    local close = Instance.new("TextButton", main)
    close.Size = UDim2.fromOffset(36,36)
    close.Position = UDim2.new(1,-44,0,10)
    close.Text = "✕"
    close.Font = Enum.Font.GothamBold
    close.TextSize = 16
    close.TextColor3 = Color3.new(1,1,1)
    close.BackgroundColor3 = Color3.fromRGB(50,40,70)
    Instance.new("UICorner", close).CornerRadius = UDim.new(0,8)
    close.MouseButton1Click:Connect(function()
        main.Visible = false
    end)

    --================ SIDEBAR =================
    local side = Instance.new("ScrollingFrame", main)
    side.Position = UDim2.fromOffset(12,64)
    side.Size = UDim2.new(0,180,1,-76)
    side.BackgroundColor3 = Color3.fromRGB(28,22,38)
    side.ScrollBarThickness = 6
    Instance.new("UICorner", side).CornerRadius = UDim.new(0,12)
    self.Sidebar = side

    local sl = Instance.new("UIListLayout", side)
    sl.Padding = UDim.new(0,8)
    sl:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        side.CanvasSize = UDim2.new(0,0,0, sl.AbsoluteContentSize.Y + 20)
    end)

    local sp = Instance.new("UIPadding", side)
    sp.PaddingTop = UDim.new(0,12)
    sp.PaddingLeft = UDim.new(0,8)
    sp.PaddingRight = UDim.new(0,8)

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
    tg.BackgroundColor3 = Color3.fromRGB(22,18,30)
    tg.Image = STATE.Logo
    Instance.new("UICorner", tg).CornerRadius = UDim.new(0,16)

    local ts = Instance.new("UIStroke", tg)
    ts.Color = Color3.fromRGB(170,78,255)
    ts.Thickness = 3

    tg.MouseButton1Click:Connect(function()
        main.Visible = not main.Visible
    end)

    self.ToggleBtn = tg
end

--==============================
-- PUBLIC API
--==============================
function UI:SetLogo(v)
    STATE.Logo = icon(v)
    if self.ToggleBtn then
        self.ToggleBtn.Image = STATE.Logo
    end
end

function UI:SetTitle(t)
    STATE.Title = tostring(t)
    if self.TitleLabel then
        self.TitleLabel.Text = STATE.Title
    end
end

--==============================
-- TAG (VERSION / STATUS)
--==============================
function UI:Tag(opt)
    opt = opt or {}

    if self._Tag then
        self._Tag:Destroy()
    end

    local tag = Instance.new("Frame", self.Main)
    tag.Size = UDim2.fromOffset(90,26)
    tag.Position = UDim2.new(1,-110,0,14)
    tag.BackgroundColor3 = opt.Color or Color3.fromRGB(48,255,106)
    tag.ZIndex = 5
    Instance.new("UICorner", tag).CornerRadius =
        UDim.new(0, math.clamp(opt.Radius or 8,0,13))

    local layout = Instance.new("UIListLayout", tag)
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0,6)

    local pad = Instance.new("UIPadding", tag)
    pad.PaddingLeft = UDim.new(0,8)
    pad.PaddingRight = UDim.new(0,8)

    if opt.Icon then
        local ic = Instance.new("ImageLabel", tag)
        ic.Size = UDim2.fromOffset(14,14)
        ic.BackgroundTransparency = 1
        ic.Image = icon(opt.Icon)
        ic.ZIndex = 6
    end

    local txt = Instance.new("TextLabel", tag)
    txt.BackgroundTransparency = 1
    txt.Font = Enum.Font.GothamBold
    txt.TextSize = 12
    txt.TextColor3 = Color3.new(0,0,0)
    txt.Text = tostring(opt.Title or "")
    txt.ZIndex = 6

    self._Tag = tag
end

--==============================
-- PAGE / LABEL
--==============================
function UI:CreatePage(name)
    local page = Instance.new("ScrollingFrame", self.Content)
    page.Size = UDim2.fromScale(1,1)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 6
    page.Visible = false

    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0,12)
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y + 20)
    end)

    local btn = Instance.new("TextButton", self.Sidebar)
    btn.Size = UDim2.new(1,0,0,42)
    btn.Text = name
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 16
    btn.TextColor3 = Color3.fromRGB(230,200,255)
    btn.BackgroundColor3 = Color3.fromRGB(45,35,70)
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

function UI:CreateLabel(p, text)
    local l = Instance.new("TextLabel", p)
    l.Size = UDim2.new(1,0,0,22)
    l.BackgroundTransparency = 1
    l.Font = Enum.Font.GothamSemibold
    l.TextSize = 14
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextColor3 = Color3.fromRGB(235,210,255)
    l.Text = text
end

--==============================
-- TOGGLE (SWITCH)
--==============================
function UI:CreateToggle(p, text, def, cb)
    local state = def == true

    local f = Instance.new("Frame", p)
    f.Size = UDim2.new(1,0,0,36)
    f.BackgroundTransparency = 1

    local lbl = Instance.new("TextLabel", f)
    lbl.Size = UDim2.new(0.68,0,1,0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextColor3 = Color3.fromRGB(235,235,255)
    lbl.Text = text

    local outer = Instance.new("TextButton", f)
    outer.Size = UDim2.fromOffset(56,28)
    outer.Position = UDim2.new(1,-68,0,4)
    outer.BackgroundColor3 = Color3.fromRGB(70,60,95)
    outer.Text = ""
    outer.AutoButtonColor = false
    Instance.new("UICorner", outer).CornerRadius = UDim.new(0,14)

    local dot = Instance.new("Frame", outer)
    dot.Size = UDim2.fromOffset(24,24)
    dot.BackgroundColor3 = Color3.fromRGB(245,245,245)
    Instance.new("UICorner", dot).CornerRadius = UDim.new(0,12)

    local function refresh(instantly)
        if state then
            if instantly then
                outer.BackgroundColor3 = Color3.fromRGB(120,80,220)
                dot.Position = UDim2.new(1,-26,0,2)
            else
                tw(outer,{BackgroundColor3 = Color3.fromRGB(120,80,220)})
                tw(dot,{Position = UDim2.new(1,-26,0,2)})
            end
        else
            if instantly then
                outer.BackgroundColor3 = Color3.fromRGB(70,60,95)
                dot.Position = UDim2.new(0,2,0,2)
            else
                tw(outer,{BackgroundColor3 = Color3.fromRGB(70,60,95)})
                tw(dot,{Position = UDim2.new(0,2,0,2)})
            end
        end
    end

    refresh(true)

    outer.MouseButton1Click:Connect(function()
        state = not state
        refresh(false)
        if cb then cb(state) end
    end)
end

--==============================
-- EXPORT
--==============================
local instance = setmetatable({}, UI)
instance:_init()
return instance
