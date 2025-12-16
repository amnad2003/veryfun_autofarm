--================================================--
-- VeryFunSHOP UI Engine | Premium Dark
--================================================--

local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

pcall(function()
    if CoreGui:FindFirstChild("VeryFunSHOP_UI") then
        CoreGui.VeryFunSHOP_UI:Destroy()
    end
end)

local Theme = {
    BG = Color3.fromRGB(18,18,22),
    Sidebar = Color3.fromRGB(24,24,30),
    Card = Color3.fromRGB(32,32,40),
    Accent = Color3.fromRGB(0,170,255),
    Text = Color3.fromRGB(235,235,235),
    SubText = Color3.fromRGB(160,160,160)
}

local function corner(o,r)
    local c = Instance.new("UICorner", o)
    c.CornerRadius = UDim.new(0, r or 8)
end

local UI = {}

--================ CREATE WINDOW =================--
function UI:Create(cfg)
    cfg = cfg or {}

    local Gui = Instance.new("ScreenGui", CoreGui)
    Gui.Name = "VeryFunSHOP_UI"
    Gui.ResetOnSpawn = false

    local Main = Instance.new("Frame", Gui)
    Main.Size = UDim2.new(0, 760, 0, 500)
    Main.Position = UDim2.new(0.5,0,0.5,0)
    Main.AnchorPoint = Vector2.new(0.5,0.5)
    Main.BackgroundColor3 = Theme.BG
    corner(Main, 14)

    --================ TOP BAR =================--
    local Top = Instance.new("Frame", Main)
    Top.Size = UDim2.new(1,0,0,48)
    Top.BackgroundColor3 = Theme.Card
    corner(Top,14)

    local Title = Instance.new("TextLabel", Top)
    Title.Size = UDim2.new(1,-80,1,0)
    Title.Position = UDim2.new(0,16,0,0)
    Title.BackgroundTransparency = 1
    Title.Text = cfg.Title or "VeryFunSHOP"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.TextColor3 = Theme.Text
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local Close = Instance.new("TextButton", Top)
    Close.Size = UDim2.new(0,36,0,36)
    Close.Position = UDim2.new(1,-44,0.5,-18)
    Close.Text = "✕"
    Close.Font = Enum.Font.GothamBold
    Close.TextSize = 16
    Close.BackgroundColor3 = Theme.Card
    Close.TextColor3 = Theme.SubText
    corner(Close,8)

    Close.MouseButton1Click:Connect(function()
        Gui:Destroy()
    end)

    --================ SIDEBAR =================--
    local Sidebar = Instance.new("Frame", Main)
    Sidebar.Size = UDim2.new(0,180,1,-58)
    Sidebar.Position = UDim2.new(0,0,0,58)
    Sidebar.BackgroundColor3 = Theme.Sidebar
    corner(Sidebar,12)

    local SideLayout = Instance.new("UIListLayout", Sidebar)
    SideLayout.Padding = UDim.new(0,6)

    --================ CONTENT =================--
    local Pages = {}
    local Tabs = {}

    local Window = {}

    function Window:Toggle()
        Main.Visible = not Main.Visible
    end

    if cfg.ToggleKey then
        UIS.InputBegan:Connect(function(i,gp)
            if not gp and i.KeyCode == cfg.ToggleKey then
                Window:Toggle()
            end
        end)
    end

    --================ TAB =================--
    function Window:Tab(name)
        local Btn = Instance.new("TextButton", Sidebar)
        Btn.Size = UDim2.new(1,-12,0,38)
        Btn.Text = "  "..name
        Btn.Font = Enum.Font.Gotham
        Btn.TextSize = 14
        Btn.TextXAlignment = Enum.TextXAlignment.Left
        Btn.BackgroundColor3 = Theme.Card
        Btn.TextColor3 = Theme.Text
        corner(Btn,8)

        local Page = Instance.new("ScrollingFrame", Main)
        Page.Size = UDim2.new(1,-200,1,-68)
        Page.Position = UDim2.new(0,190,0,58)
        Page.CanvasSize = UDim2.new(0,0,0,0)
        Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Page.ScrollBarImageTransparency = 0.5
        Page.Visible = false
        Page.BackgroundTransparency = 1

        local Layout = Instance.new("UIListLayout", Page)
        Layout.Padding = UDim.new(0,10)

        Btn.MouseButton1Click:Connect(function()
            for _,t in pairs(Tabs) do
                t.Page.Visible = false
                t.Btn.BackgroundColor3 = Theme.Card
            end
            Page.Visible = true
            Btn.BackgroundColor3 = Theme.Accent
        end)

        if #Tabs == 0 then
            Page.Visible = true
            Btn.BackgroundColor3 = Theme.Accent
        end

        table.insert(Tabs, {Btn=Btn, Page=Page})

        local Tab = {}

        function Tab:Section(title)
            local Box = Instance.new("Frame", Page)
            Box.Size = UDim2.new(1,-10,0,40)
            Box.BackgroundColor3 = Theme.Card
            corner(Box,10)

            local L = Instance.new("TextLabel", Box)
            L.Size = UDim2.new(1,-20,0,30)
            L.Position = UDim2.new(0,10,0,5)
            L.BackgroundTransparency = 1
            L.Text = title
            L.Font = Enum.Font.GothamBold
            L.TextSize = 14
            L.TextColor3 = Theme.Accent
            L.TextXAlignment = Enum.TextXAlignment.Left

            local Section = {}

            function Section:Button(text, cb)
                local B = Instance.new("TextButton", Page)
                B.Size = UDim2.new(1,-10,0,36)
                B.Text = text
                B.Font = Enum.Font.Gotham
                B.TextSize = 14
                B.BackgroundColor3 = Theme.Card
                B.TextColor3 = Theme.Text
                corner(B,8)
                B.MouseButton1Click:Connect(function()
                    if cb then cb() end
                end)
            end

            function Section:Toggle(text, default, cb)
                local state = default
                local T = Instance.new("TextButton", Page)
                T.Size = UDim2.new(1,-10,0,36)
                T.Font = Enum.Font.Gotham
                T.TextSize = 14
                T.BackgroundColor3 = Theme.Card
                T.TextColor3 = Theme.Text
                corner(T,8)

                local function refresh()
                    T.Text = text.." : "..(state and "ON" or "OFF")
                end
                refresh()

                T.MouseButton1Click:Connect(function()
                    state = not state
                    refresh()
                    if cb then cb(state) end
                end)
            end

            function Section:Slider(text,min,max,def,cb)
                local val = def or min
                local S = Instance.new("TextButton", Page)
                S.Size = UDim2.new(1,-10,0,36)
                S.Font = Enum.Font.Gotham
                S.TextSize = 14
                S.BackgroundColor3 = Theme.Card
                S.TextColor3 = Theme.Text
                corner(S,8)

                local function refresh()
                    S.Text = text.." : "..val
                end
                refresh()

                S.MouseButton1Click:Connect(function()
                    val = val + 1
                    if val > max then val = min end
                    refresh()
                    if cb then cb(val) end
                end)
            end

            return Section
        end

        return Tab
    end

    return Window
end

return UI
