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
    title.Size = UDim2.new(1,-24,0,48)
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
-- TOGGLE
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
    Instance.new("UICorner", outer).CornerRadius = UDim.new(0,14)

    local dot = Instance.new("Frame", outer)
    dot.Size = UDim2.fromOffset(24,24)
    dot.Position = UDim2.fromOffset(2,2)
    dot.BackgroundColor3 = Color3.fromRGB(245,245,245)
    Instance.new("UICorner", dot).CornerRadius = UDim.new(0,12)

    local function refresh()
        tw(outer,{
            BackgroundColor3 = state and Color3.fromRGB(120,80,220) or Color3.fromRGB(70,60,95)
        })
    end
    refresh()

    outer.MouseButton1Click:Connect(function()
        state = not state
        refresh()
        if cb then cb(state) end
    end)
end

--==============================
-- DROPDOWN (ZINDEX FIX)
--==============================
function UI:CreateDropdown(p, text, values, cb)
    local f = Instance.new("Frame", p)
    f.Size = UDim2.new(1,0,0,36)
    f.BackgroundTransparency = 1

    local lbl = Instance.new("TextLabel", f)
    lbl.Size = UDim2.new(0.6,0,1,0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextColor3 = Color3.fromRGB(230,230,255)
    lbl.Text = text

    local box = Instance.new("TextButton", f)
    box.Size = UDim2.fromOffset(180,28)
    box.Position = UDim2.new(1,-192,0,4)
    box.BackgroundColor3 = Color3.fromRGB(50,42,70)
    box.Font = Enum.Font.Gotham
    box.TextSize = 13
    box.TextColor3 = Color3.new(1,1,1)
    box.Text = tostring(values[1] or "Select")
    Instance.new("UICorner", box)

    local menu = Instance.new("Frame", self.Gui)
    menu.Visible = false
    menu.BackgroundColor3 = Color3.fromRGB(30,24,44)
    menu.ZIndex = 50
    Instance.new("UICorner", menu)

    local layout = Instance.new("UIListLayout", menu)

    local function rebuild(list)
        for _,c in pairs(menu:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        for _,v in ipairs(list) do
            local it = Instance.new("TextButton", menu)
            it.Size = UDim2.new(1,-8,0,28)
            it.Text = tostring(v)
            it.BackgroundTransparency = 1
            it.Font = Enum.Font.Gotham
            it.TextColor3 = Color3.fromRGB(235,235,255)
            it.ZIndex = 51
            it.MouseButton1Click:Connect(function()
                box.Text = tostring(v)
                menu.Visible = false
                if cb then cb(v) end
            end)
        end
        menu.Size = UDim2.new(0,box.AbsoluteSize.X,0,#list*28+8)
    end

    rebuild(values)

    box.MouseButton1Click:Connect(function()
        menu.Position = UDim2.fromOffset(
            box.AbsolutePosition.X,
            box.AbsolutePosition.Y + box.AbsoluteSize.Y + 2
        )
        menu.Visible = not menu.Visible
    end)
end

--==============================
-- SLIDER (INPUT + NO DRAG BUG)
--==============================
function UI:CreateSlider(p, text, min, max, def, cb)
    local f = Instance.new("Frame", p)
    f.Size = UDim2.new(1,0,0,46)
    f.BackgroundTransparency = 1

    local lbl = Instance.new("TextLabel", f)
    lbl.Size = UDim2.new(0.6,0,0,18)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextColor3 = Color3.fromRGB(230,230,255)

    local input = Instance.new("TextBox", f)
    input.Size = UDim2.new(0,60,0,18)
    input.Position = UDim2.new(1,-60,0,0)
    input.BackgroundColor3 = Color3.fromRGB(45,38,65)
    input.Font = Enum.Font.Gotham
    input.TextSize = 13
    input.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", input)

    local bar = Instance.new("Frame", f)
    bar.Size = UDim2.new(1,-40,0,12)
    bar.Position = UDim2.new(0,0,0,26)
    bar.BackgroundColor3 = Color3.fromRGB(60,50,85)
    Instance.new("UICorner", bar)

    local knob = Instance.new("Frame", bar)
    knob.Size = UDim2.fromOffset(12,12)
    knob.BackgroundColor3 = Color3.fromRGB(200,180,255)
    Instance.new("UICorner", knob)

    local dragging = false
    local main = self.Main

    local function set(v)
        v = math.clamp(tonumber(v) or def, min, max)
        local r = (v-min)/(max-min)
        knob.Position = UDim2.new(r,0,0,0)
        lbl.Text = text.." : "..v
        input.Text = tostring(v)
        if cb then cb(v) end
    end
    set(def)

    knob.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            if main then main.Draggable = false end
        end
    end)

    knob.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            if main then main.Draggable = true end
        end
    end)

    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local r = math.clamp((i.Position.X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
            set(math.floor(min+(max-min)*r))
        end
    end)

    input.FocusLost:Connect(function(enter)
        if enter then
            set(input.Text)
        end
    end)
end

--==============================
-- EXPORT
--==============================
local instance = setmetatable({}, UI)
instance:_init()
return instance
