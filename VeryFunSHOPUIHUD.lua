--========================================================--
-- VeryFunSHOP UI HUD | CLEAN GRID SWITCH VERSION
--========================================================--

local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local UI_NAME = "VeryFunSHOP_UI_CLEAN"

pcall(function()
    if CoreGui:FindFirstChild(UI_NAME) then
        CoreGui[UI_NAME]:Destroy()
    end
end)

--================ THEME =================--
local Themes = {
    Mint   = {bg=Color3.fromRGB(15,23,32), card=Color3.fromRGB(31,41,55), accent=Color3.fromRGB(102,255,204)},
    Dark   = {bg=Color3.fromRGB(15,15,15), card=Color3.fromRGB(30,30,30), accent=Color3.fromRGB(0,200,255)}
}

local Library = {}

--================ CREATE =================--
function Library:Create(cfg)
    cfg = cfg or {}
    local theme = Themes[cfg.Theme] or Themes.Mint

    local Gui = Instance.new("ScreenGui", CoreGui)
    Gui.Name = UI_NAME
    Gui.ResetOnSpawn = false

    --================ MAIN =================--
    local Main = Instance.new("Frame", Gui)
    Main.Size = UDim2.new(0,820,0,520)
    Main.Position = UDim2.new(0.5,0,0.5,0)
    Main.AnchorPoint = Vector2.new(0.5,0.5)
    Main.BackgroundColor3 = theme.bg
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0,18)

    --================ TOP =================--
    local Top = Instance.new("Frame", Main)
    Top.Size = UDim2.new(1,0,0,56)
    Top.BackgroundColor3 = theme.card
    Instance.new("UICorner", Top).CornerRadius = UDim.new(0,18)

    local Title = Instance.new("TextLabel", Top)
    Title.Size = UDim2.new(1,-60,1,0)
    Title.Position = UDim2.new(0,20,0,0)
    Title.BackgroundTransparency = 1
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Text = cfg.Title or "VeryFunSHOP UI"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.TextColor3 = Color3.new(1,1,1)

    local Close = Instance.new("TextButton", Top)
    Close.Size = UDim2.new(0,36,0,36)
    Close.Position = UDim2.new(1,-46,0.5,-18)
    Close.Text = "✕"
    Close.Font = Enum.Font.GothamBold
    Close.TextSize = 16
    Close.BackgroundColor3 = Color3.fromRGB(180,60,60)
    Close.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", Close).CornerRadius = UDim.new(0,10)

    Close.MouseButton1Click:Connect(function()
        Gui:Destroy()
    end)

    --================ TAB BAR =================--
    local TabBar = Instance.new("Frame", Main)
    TabBar.Position = UDim2.new(0,20,0,76)
    TabBar.Size = UDim2.new(1,-40,0,42)
    TabBar.BackgroundTransparency = 1

    local TabLayout = Instance.new("UIListLayout", TabBar)
    TabLayout.FillDirection = Enum.FillDirection.Horizontal
    TabLayout.Padding = UDim.new(0,10)

    --================ CONTENT =================--
    local Pages = {}
    local Window = {}

    function Window:Toggle()
        Main.Visible = not Main.Visible
    end

    if cfg.ToggleKey then
        UIS.InputBegan:Connect(function(i,g)
            if not g and i.KeyCode == cfg.ToggleKey then
                Window:Toggle()
            end
        end)
    end

    --================ TAB =================--
    function Window:Tab(name)
        local TabBtn = Instance.new("TextButton", TabBar)
        TabBtn.Size = UDim2.new(0,120,1,0)
        TabBtn.Text = name
        TabBtn.Font = Enum.Font.GothamBold
        TabBtn.TextSize = 14
        TabBtn.BackgroundColor3 = theme.card
        TabBtn.TextColor3 = Color3.new(1,1,1)
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0,10)

        local Page = Instance.new("ScrollingFrame", Main)
        Page.Position = UDim2.new(0,20,0,130)
        Page.Size = UDim2.new(1,-40,1,-150)
        Page.CanvasSize = UDim2.new(0,0,0,0)
        Page.ScrollBarThickness = 6
        Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Page.Visible = false
        Page.BackgroundTransparency = 1

        local Grid = Instance.new("UIGridLayout", Page)
        Grid.CellSize = UDim2.new(0,260,0,120)
        Grid.CellPadding = UDim2.new(0,14,0,14)

        TabBtn.MouseButton1Click:Connect(function()
            for _,p in pairs(Pages) do
                p.page.Visible = false
                p.btn.BackgroundColor3 = theme.card
            end
            Page.Visible = true
            TabBtn.BackgroundColor3 = theme.accent
        end)

        if #Pages == 0 then
            Page.Visible = true
            TabBtn.BackgroundColor3 = theme.accent
        end

        table.insert(Pages,{btn=TabBtn,page=Page})

        local Tab = {}

        --================ CARD =================--
        local function Card(title)
            local C = Instance.new("Frame", Page)
            C.BackgroundColor3 = theme.card
            Instance.new("UICorner", C).CornerRadius = UDim.new(0,14)

            local T = Instance.new("TextLabel", C)
            T.Size = UDim2.new(1,-20,0,26)
            T.Position = UDim2.new(0,10,0,6)
            T.BackgroundTransparency = 1
            T.TextXAlignment = Enum.TextXAlignment.Left
            T.Text = title
            T.Font = Enum.Font.GothamBold
            T.TextSize = 14
            T.TextColor3 = theme.accent

            return C
        end

        --================ TOGGLE SWITCH =================--
        function Tab:Toggle(title, default, cb)
            local state = default
            local C = Card(title)

            local Switch = Instance.new("TextButton", C)
            Switch.Size = UDim2.new(0,44,0,22)
            Switch.Position = UDim2.new(1,-60,0,44)
            Switch.Text = ""
            Switch.BackgroundColor3 = state and theme.accent or Color3.fromRGB(80,80,80)
            Instance.new("UICorner", Switch).CornerRadius = UDim.new(0,11)

            Switch.MouseButton1Click:Connect(function()
                state = not state
                Switch.BackgroundColor3 = state and theme.accent or Color3.fromRGB(80,80,80)
                if cb then cb(state) end
            end)
        end

        --================ SLIDER (DRAG + INPUT) =================--
        function Tab:Slider(title,min,max,default,cb)
            local value = default or min
            local C = Card(title)

            local Bar = Instance.new("Frame", C)
            Bar.Size = UDim2.new(1,-20,0,8)
            Bar.Position = UDim2.new(0,10,0,60)
            Bar.BackgroundColor3 = Color3.fromRGB(70,70,70)
            Instance.new("UICorner", Bar).CornerRadius = UDim.new(0,6)

            local Fill = Instance.new("Frame", Bar)
            Fill.Size = UDim2.new((value-min)/(max-min),0,1,0)
            Fill.BackgroundColor3 = theme.accent
            Instance.new("UICorner", Fill).CornerRadius = UDim.new(0,6)

            local Box = Instance.new("TextBox", C)
            Box.Size = UDim2.new(0,60,0,24)
            Box.Position = UDim2.new(1,-80,0,28)
            Box.Text = tostring(value)
            Box.Font = Enum.Font.Gotham
            Box.TextSize = 13
            Box.BackgroundColor3 = Color3.fromRGB(50,50,50)
            Box.TextColor3 = Color3.new(1,1,1)
            Instance.new("UICorner", Box).CornerRadius = UDim.new(0,6)

            local function set(v)
                value = math.clamp(v,min,max)
                Box.Text = tostring(value)
                Fill.Size = UDim2.new((value-min)/(max-min),0,1,0)
                if cb then cb(value) end
            end

            Bar.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    local x = (i.Position.X - Bar.AbsolutePosition.X)/Bar.AbsoluteSize.X
                    set(math.floor(min + (max-min)*x))
                end
            end)

            Box.FocusLost:Connect(function()
                set(tonumber(Box.Text) or value)
            end)
        end

        return Tab
    end

    return Window
end

return Library
