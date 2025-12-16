--========================================================--
-- VeryFunSHOP UI HUD 
--========================================================--

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local UI_NAME = "VeryFunSHOP_UI_ULTIMATE"

pcall(function()
    if CoreGui:FindFirstChild(UI_NAME) then
        CoreGui[UI_NAME]:Destroy()
    end
end)

--================ THEME =================--
local THEMES = {
    Mint   = {bg=Color3.fromHex("#0F1720"), accent=Color3.fromHex("#1F2937"), highlight=Color3.fromHex("#66FFCC")},
    Red    = {bg=Color3.fromHex("#0F0A0A"), accent=Color3.fromHex("#241111"), highlight=Color3.fromHex("#FF5C5C")},
    Blue   = {bg=Color3.fromHex("#071022"), accent=Color3.fromHex("#0E2438"), highlight=Color3.fromHex("#7FB3FF")},
    Gold   = {bg=Color3.fromHex("#0B0B06"), accent=Color3.fromHex("#2A260F"), highlight=Color3.fromHex("#FFC857")},
    Pink   = {bg=Color3.fromHex("#140A12"), accent=Color3.fromHex("#2B1022"), highlight=Color3.fromHex("#FF7AD9")},
    Purple = {bg=Color3.fromHex("#0E0A18"), accent=Color3.fromHex("#1C1333"), highlight=Color3.fromHex("#B388FF")}
}

local function corner(o,r)
    local c = Instance.new("UICorner",o)
    c.CornerRadius = UDim.new(0,r or 8)
end

--================ LIBRARY =================--
local Library = {}

function Library:Create(cfg)
    cfg = cfg or {}
    local Theme = THEMES[cfg.Theme] or THEMES.Mint
    local SaveFolder = cfg.SaveFolder or "VeryFunSHOP_Config"

    local GUI = Instance.new("ScreenGui", CoreGui)
    GUI.Name = UI_NAME
    GUI.ResetOnSpawn = false

    --================ MAIN =================--
    local Main = Instance.new("Frame", GUI)
    Main.Size = UDim2.new(0,640,0,460)
    Main.Position = UDim2.new(0.5,0,0.5,0)
    Main.AnchorPoint = Vector2.new(0.5,0.5)
    Main.BackgroundColor3 = Theme.bg
    corner(Main,14)

    --================ TITLE =================--
    local TitleBar = Instance.new("Frame", Main)
    TitleBar.Size = UDim2.new(1,0,0,46)
    TitleBar.BackgroundColor3 = Theme.accent
    corner(TitleBar,14)

    local Title = Instance.new("TextLabel", TitleBar)
    Title.Size = UDim2.new(1,-20,1,0)
    Title.Position = UDim2.new(0,14,0,0)
    Title.BackgroundTransparency = 1
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.TextColor3 = Color3.new(1,1,1)
    Title.Text = cfg.Title or "VeryFunSHOP UI"

    --================ DRAG =================--
    do
        local drag, startPos, startFrame
        TitleBar.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                drag = true
                startPos = i.Position
                startFrame = Main.Position
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
                local d = i.Position - startPos
                Main.Position = startFrame + UDim2.new(0,d.X,0,d.Y)
            end
        end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                drag = false
            end
        end)
    end

    --================ SIDEBAR =================--
    local Sidebar = Instance.new("Frame", Main)
    Sidebar.Size = UDim2.new(0,160,1,-56)
    Sidebar.Position = UDim2.new(0,0,0,56)
    Sidebar.BackgroundTransparency = 1

    local SideLayout = Instance.new("UIListLayout", Sidebar)
    SideLayout.Padding = UDim.new(0,6)

    --================ CONTENT =================--
    local Pages = {}
    local Window = {}

    function Window:Toggle()
        Main.Visible = not Main.Visible
    end

    --================ TOGGLE KEY =================--
    if cfg.ToggleKey then
        UIS.InputBegan:Connect(function(i,gp)
            if not gp and i.KeyCode == cfg.ToggleKey then
                Window:Toggle()
            end
        end)
    end

    --================ TOGGLE LOGO =================--
    if cfg.ToggleLogo then
        local Logo = Instance.new("ImageButton", GUI)
        Logo.Size = UDim2.new(0,44,0,44)
        Logo.Position = cfg.TogglePosition or UDim2.new(0,20,0.5,-22)
        Logo.Image = cfg.ToggleLogo
        Logo.BackgroundColor3 = Theme.accent
        corner(Logo,12)

        Logo.MouseButton1Click:Connect(function()
            Window:Toggle()
        end)
    end

    --================ TAB =================--
    function Window:Tab(name)
        local Btn = Instance.new("TextButton", Sidebar)
        Btn.Size = UDim2.new(1,-10,0,36)
        Btn.Text = "  "..name
        Btn.TextXAlignment = Enum.TextXAlignment.Left
        Btn.Font = Enum.Font.Gotham
        Btn.TextSize = 14
        Btn.BackgroundColor3 = Theme.accent
        Btn.TextColor3 = Color3.new(1,1,1)
        corner(Btn,8)

        local Page = Instance.new("ScrollingFrame", Main)
        Page.Size = UDim2.new(1,-180,1,-66)
        Page.Position = UDim2.new(0,170,0,56)
        Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Page.ScrollBarThickness = 5
        Page.BackgroundTransparency = 1
        Page.Visible = false

        local Layout = Instance.new("UIListLayout", Page)
        Layout.Padding = UDim.new(0,8)

        Btn.MouseButton1Click:Connect(function()
            for _,p in pairs(Pages) do
                p.page.Visible = false
                p.btn.BackgroundColor3 = Theme.accent
            end
            Page.Visible = true
            Btn.BackgroundColor3 = Theme.highlight
        end)

        if #Pages == 0 then
            Page.Visible = true
            Btn.BackgroundColor3 = Theme.highlight
        end

        table.insert(Pages,{btn=Btn,page=Page})

        local Tab = {}

        function Tab:Section(text)
            local L = Instance.new("TextLabel", Page)
            L.Size = UDim2.new(1,-10,0,26)
            L.BackgroundTransparency = 1
            L.Text = text
            L.Font = Enum.Font.GothamBold
            L.TextSize = 14
            L.TextColor3 = Theme.highlight
            L.TextXAlignment = Enum.TextXAlignment.Left
        end

        function Tab:Button(text,cb)
            local B = Instance.new("TextButton", Page)
            B.Size = UDim2.new(1,-10,0,36)
            B.Text = text
            B.Font = Enum.Font.Gotham
            B.TextSize = 14
            B.BackgroundColor3 = Theme.accent
            B.TextColor3 = Color3.new(1,1,1)
            corner(B,8)
            B.MouseButton1Click:Connect(function()
                if cb then cb() end
            end)
        end

        function Tab:Toggle(text,default,cb)
            local state = default
            local B = Instance.new("TextButton", Page)
            B.Size = UDim2.new(1,-10,0,36)
            B.Font = Enum.Font.Gotham
            B.TextSize = 14
            B.BackgroundColor3 = Theme.accent
            B.TextColor3 = Color3.new(1,1,1)
            corner(B,8)

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
            local value = default or min
            local B = Instance.new("TextButton", Page)
            B.Size = UDim2.new(1,-10,0,36)
            B.Font = Enum.Font.Gotham
            B.TextSize = 14
            B.BackgroundColor3 = Theme.accent
            B.TextColor3 = Color3.new(1,1,1)
            corner(B,8)

            local function refresh()
                B.Text = text.." : "..value
            end
            refresh()

            B.MouseButton1Click:Connect(function()
                value = value + 1
                if value > max then value = min end
                refresh()
                if cb then cb(value) end
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
                cb()
            end)
        end

        return Tab
    end

    return Window
end

return Library
