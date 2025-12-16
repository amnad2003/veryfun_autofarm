--========================================================--
-- VeryFunSHOP UI HUD | PREMIUM GRID VERSION
--========================================================--

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local UI_NAME = "VeryFunSHOP_UI"

pcall(function()
    if CoreGui:FindFirstChild(UI_NAME) then
        CoreGui[UI_NAME]:Destroy()
    end
end)

--================ THEME =================--
local THEMES = {
    Mint   = {bg="#0F1720", card="#1F2937", accent="#66FFCC"},
    Red    = {bg="#120A0A", card="#241111", accent="#FF5C5C"},
    Blue   = {bg="#071022", card="#0E2438", accent="#7FB3FF"},
    Pink   = {bg="#140A12", card="#2B1022", accent="#FF7AD9"},
    Purple = {bg="#0E0A18", card="#1C1333", accent="#B388FF"},
    Gold   = {bg="#0C0B06", card="#2A260F", accent="#FFC857"}
}

local function C(h) return Color3.fromHex(h) end
local function Corner(o,r)
    local c = Instance.new("UICorner",o)
    c.CornerRadius = UDim.new(0,r or 12)
end

--================ LIB =================--
local Library = {}

function Library:Create(cfg)
    cfg = cfg or {}
    local Theme = THEMES[cfg.Theme or "Mint"]

    local Gui = Instance.new("ScreenGui", CoreGui)
    Gui.Name = UI_NAME
    Gui.ResetOnSpawn = false

    --================ MAIN =================--
    local Main = Instance.new("Frame", Gui)
    Main.Size = UDim2.new(0,720,0,480)
    Main.Position = UDim2.new(0.5,0,0.5,0)
    Main.AnchorPoint = Vector2.new(0.5,0.5)
    Main.BackgroundColor3 = C(Theme.bg)
    Corner(Main,16)

    --================ TITLE =================--
    local Title = Instance.new("TextLabel", Main)
    Title.Size = UDim2.new(1,-100,0,48)
    Title.Position = UDim2.new(0,16,0,0)
    Title.BackgroundTransparency = 1
    Title.Text = cfg.Title or "VeryFunSHOP UI"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.TextColor3 = Color3.new(1,1,1)
    Title.TextXAlignment = Left

    --================ CLOSE =================--
    local Close = Instance.new("TextButton", Main)
    Close.Size = UDim2.new(0,36,0,36)
    Close.Position = UDim2.new(1,-48,0,6)
    Close.Text = "✕"
    Close.Font = Enum.Font.GothamBold
    Close.TextSize = 16
    Close.BackgroundColor3 = C(Theme.card)
    Close.TextColor3 = Color3.new(1,1,1)
    Corner(Close,10)

    Close.MouseButton1Click:Connect(function()
        Gui:Destroy()
    end)

    --================ SIDEBAR =================--
    local Sidebar = Instance.new("Frame", Main)
    Sidebar.Size = UDim2.new(0,160,1,-60)
    Sidebar.Position = UDim2.new(0,0,0,60)
    Sidebar.BackgroundTransparency = 1

    local SideLayout = Instance.new("UIListLayout", Sidebar)
    SideLayout.Padding = UDim.new(0,6)

    --================ PAGES =================--
    local Pages = {}

    local Window = {}

    function Window:Toggle()
        Main.Visible = not Main.Visible
    end

    -- Toggle Key
    if cfg.ToggleKey then
        UIS.InputBegan:Connect(function(i,g)
            if not g and i.KeyCode == cfg.ToggleKey then
                Window:Toggle()
            end
        end)
    end

    -- Toggle Logo
    if cfg.ToggleLogo then
        local Logo = Instance.new("ImageButton", Gui)
        Logo.Size = UDim2.new(0,44,0,44)
        Logo.Position = cfg.TogglePosition or UDim2.new(0,20,0.5,-22)
        Logo.Image = cfg.ToggleLogo
        Logo.BackgroundColor3 = C(Theme.card)
        Corner(Logo,12)

        Logo.MouseButton1Click:Connect(function()
            Window:Toggle()
        end)
    end

    --================ TAB =================--
    function Window:Tab(name)
        local Btn = Instance.new("TextButton", Sidebar)
        Btn.Size = UDim2.new(1,-10,0,36)
        Btn.Text = "  "..name
        Btn.Font = Enum.Font.Gotham
        Btn.TextSize = 14
        Btn.TextXAlignment = Left
        Btn.BackgroundColor3 = C(Theme.card)
        Btn.TextColor3 = Color3.new(1,1,1)
        Corner(Btn,10)

        local Page = Instance.new("ScrollingFrame", Main)
        Page.Position = UDim2.new(0,170,0,60)
        Page.Size = UDim2.new(1,-186,1,-76)
        Page.AutomaticCanvasSize = Y
        Page.ScrollBarThickness = 6
        Page.BackgroundTransparency = 1
        Page.Visible = false

        local Grid = Instance.new("UIGridLayout", Page)
        Grid.CellSize = UDim2.new(0,240,0,80)
        Grid.CellPadding = UDim2.new(0,12,0,12)

        Btn.MouseButton1Click:Connect(function()
            for _,p in pairs(Pages) do
                p.page.Visible = false
                p.btn.BackgroundColor3 = C(Theme.card)
            end
            Page.Visible = true
            Btn.BackgroundColor3 = C(Theme.accent)
        end)

        if #Pages == 0 then
            Page.Visible = true
            Btn.BackgroundColor3 = C(Theme.accent)
        end

        table.insert(Pages,{btn=Btn,page=Page})

        local Tab = {}

        --=========== ELEMENTS ===========--

        function Tab:Section(text)
            local L = Instance.new("TextLabel", Page)
            L.Size = UDim2.new(1,0,0,30)
            L.BackgroundTransparency = 1
            L.Text = text
            L.Font = Enum.Font.GothamBold
            L.TextSize = 14
            L.TextColor3 = C(Theme.accent)
            L.TextXAlignment = Left
        end

        function Tab:Button(text,cb)
            local B = Instance.new("TextButton", Page)
            B.Text = text
            B.Font = Enum.Font.Gotham
            B.TextSize = 14
            B.BackgroundColor3 = C(Theme.card)
            B.TextColor3 = Color3.new(1,1,1)
            Corner(B,12)
            B.MouseButton1Click:Connect(function()
                if cb then cb() end
            end)
        end

        function Tab:Toggle(text,default,cb)
            local state = default
            local B = Instance.new("TextButton", Page)
            B.Font = Enum.Font.Gotham
            B.TextSize = 14
            B.BackgroundColor3 = C(Theme.card)
            B.TextColor3 = Color3.new(1,1,1)
            Corner(B,12)

            local function refresh()
                B.Text = text.." : "..(state and "ON" or "OFF")
            end
            refresh()

            B.MouseButton1Click:Connect(function()
                state = not state
                refresh()
                if cb then cb(state) end
            end)
        end

        function Tab:Slider(text,min,max,default,cb)
            local val = default or min
            local B = Instance.new("TextButton", Page)
            B.Font = Enum.Font.Gotham
            B.TextSize = 14
            B.BackgroundColor3 = C(Theme.card)
            B.TextColor3 = Color3.new(1,1,1)
            Corner(B,12)

            local function refresh()
                B.Text = text.." : "..val
            end
            refresh()

            B.MouseButton1Click:Connect(function()
                val += 1
                if val > max then val = min end
                refresh()
                if cb then cb(val) end
            end)
        end

        function Tab:Dropdown(text,list,cb)
            for _,v in pairs(list) do
                self:Button(text.." : "..v,function()
                    if cb then cb(v) end
                end)
            end
        end

        function Tab:Keybind(key,cb)
            self:Button("Keybind : "..key.Name,function()
                if cb then cb() end
            end)
        end

        return Tab
    end

    return Window
end

return Library
