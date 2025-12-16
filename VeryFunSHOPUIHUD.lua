--========================================================--
-- VeryFunSHOP UI HUD
--========================================================--

--================ SERVICES ================--
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local UI_NAME = "VeryFunSHOP_UI_FINAL"

local THEMES = {
    Mint   = { bg = Color3.fromHex("#0F1720"), accent = Color3.fromHex("#1F2937"), highlight = Color3.fromHex("#66FFCC") },
    Red    = { bg = Color3.fromHex("#0F0A0A"), accent = Color3.fromHex("#241111"), highlight = Color3.fromHex("#FF5C5C") },
    Blue   = { bg = Color3.fromHex("#071022"), accent = Color3.fromHex("#0E2438"), highlight = Color3.fromHex("#7FB3FF") },
    Pink   = { bg = Color3.fromHex("#120812"), accent = Color3.fromHex("#261429"), highlight = Color3.fromHex("#FF8FD8") },
    Purple = { bg = Color3.fromHex("#0B0612"), accent = Color3.fromHex("#221633"), highlight = Color3.fromHex("#B47DFF") },
    Gold   = { bg = Color3.fromHex("#0B0B06"), accent = Color3.fromHex("#2A260F"), highlight = Color3.fromHex("#FFC857") },
}

pcall(function()
    if CoreGui:FindFirstChild(UI_NAME) then
        CoreGui[UI_NAME]:Destroy()
    end
end)

local function safe(cb, ...)
    if cb then
        local ok, err = pcall(cb, ...)
        if not ok then warn("[VeryFunSHOP UI Error]:", err) end
    end
end

local function corner(obj, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = obj
end

local Library = {}

function Library:Create(cfg)
    cfg = cfg or {}
    local Theme = THEMES[cfg.Theme] or THEMES.Mint
    local SaveFolder = cfg.SaveFolder or "VeryFunSHOP"

    local GUI = Instance.new("ScreenGui")
    GUI.Name = UI_NAME
    GUI.ResetOnSpawn = false
    GUI.Parent = CoreGui

    local Main = Instance.new("Frame", GUI)
    Main.Size = UDim2.new(0.5, 0, 0.7, 0)
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BackgroundColor3 = Theme.bg
    corner(Main, 12)

    local TitleBar = Instance.new("Frame", Main)
    TitleBar.Size = UDim2.new(1, 0, 0, 42)
    TitleBar.BackgroundColor3 = Theme.accent
    corner(TitleBar, 12)

    local Title = Instance.new("TextLabel", TitleBar)
    Title.Position = UDim2.new(0, 14, 0, 0)
    Title.Size = UDim2.new(1, -20, 1, 0)
    Title.BackgroundTransparency = 1
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Text = cfg.Title or "VeryFunSHOP UI"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.TextColor3 = Color3.new(1,1,1)

    do
        local dragging, startPos, startFrame
        TitleBar.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                startPos = i.Position
                startFrame = Main.Position
            end
        end)

        UIS.InputChanged:Connect(function(i)
            if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = i.Position - startPos
                Main.Position = startFrame + UDim2.new(0, delta.X, 0, delta.Y)
            end
        end)

        UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
    end

    --========== SIDEBAR ==========--
    local Sidebar = Instance.new("Frame", Main)
    Sidebar.Size = UDim2.new(0.25, 0, 1, -52)
    Sidebar.Position = UDim2.new(0, 0, 0, 52)
    Sidebar.BackgroundTransparency = 1

    local SideLayout = Instance.new("UIListLayout", Sidebar)
    SideLayout.Padding = UDim.new(0, 8)

    --========== PAGES ==========--
    local Pages = {}
    local Values = {}
    local Window = {}

    function Window:Toggle()
        Main.Visible = not Main.Visible
    end

    function Window:Destroy()
        GUI:Destroy()
    end

    function Window:SaveConfig(name)
        if writefile then
            writefile(SaveFolder.."_"..name..".json", HttpService:JSONEncode(Values))
        end
    end

    function Window:LoadConfig(name)
        if readfile and isfile and isfile(SaveFolder.."_"..name..".json") then
            local data = HttpService:JSONDecode(readfile(SaveFolder.."_"..name..".json"))
            for k,v in pairs(data) do
                if Values[k] ~= nil then
                    Values[k] = v
                end
            end
        end
    end

    --========== TAB ==========--
    function Window:Tab(name)
        local Btn = Instance.new("TextButton", Sidebar)
        Btn.Size = UDim2.new(1, -12, 0, 36)
        Btn.Text = "  "..name
        Btn.Font = Enum.Font.Gotham
        Btn.TextSize = 14
        Btn.TextXAlignment = Enum.TextXAlignment.Left
        Btn.BackgroundColor3 = Theme.accent
        Btn.TextColor3 = Color3.new(1,1,1)
        corner(Btn, 8)

        local Page = Instance.new("ScrollingFrame", Main)
        Page.Size = UDim2.new(0.75, -16, 1, -60)
        Page.Position = UDim2.new(0.25, 8, 0, 56)
        Page.CanvasSize = UDim2.new(0,0,0,0)
        Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Page.ScrollBarThickness = 5
        Page.BackgroundTransparency = 1
        Page.Visible = false

        local PageLayout = Instance.new("UIListLayout", Page)
        PageLayout.Padding = UDim.new(0, 8)

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

        table.insert(Pages, {btn = Btn, page = Page})

        --========== CONTROLS ==========--
        local Tab = {}

        function Tab:Section(text)
            local L = Instance.new("TextLabel", Page)
            L.Size = UDim2.new(1, -12, 0, 26)
            L.BackgroundTransparency = 1
            L.TextXAlignment = Enum.TextXAlignment.Left
            L.Text = text
            L.Font = Enum.Font.GothamBold
            L.TextSize = 15
            L.TextColor3 = Theme.highlight
        end

        function Tab:Button(text, cb)
            local B = Instance.new("TextButton", Page)
            B.Size = UDim2.new(1, -12, 0, 36)
            B.Text = text
            B.Font = Enum.Font.Gotham
            B.TextSize = 14
            B.BackgroundColor3 = Theme.accent
            B.TextColor3 = Color3.new(1,1,1)
            corner(B, 8)
            B.MouseButton1Click:Connect(function()
                safe(cb)
            end)
        end

        function Tab:Toggle(text, default, cb)
            Values[text] = default
            local B = Instance.new("TextButton", Page)
            B.Size = UDim2.new(1, -12, 0, 36)
            B.Font = Enum.Font.Gotham
            B.TextSize = 14
            B.BackgroundColor3 = Theme.accent
            B.TextColor3 = Color3.new(1,1,1)
            corner(B, 8)

            local function refresh()
                B.Text = text.." : "..(Values[text] and "ON" or "OFF")
            end
            refresh()

            B.MouseButton1Click:Connect(function()
                Values[text] = not Values[text]
                refresh()
                safe(cb, Values[text])
            end)
        end

        function Tab:Slider(text, min, max, default, cb)
            Values[text] = default
            local B = Instance.new("TextButton", Page)
            B.Size = UDim2.new(1, -12, 0, 36)
            B.Font = Enum.Font.Gotham
            B.TextSize = 14
            B.BackgroundColor3 = Theme.accent
            B.TextColor3 = Color3.new(1,1,1)
            corner(B, 8)

            local function refresh()
                B.Text = text..": "..Values[text]
            end
            refresh()

            B.MouseButton1Click:Connect(function()
                Values[text] += 1
                if Values[text] > max then Values[text] = min end
                refresh()
                safe(cb, Values[text])
            end)
        end

        function Tab:Dropdown(text, list, cb)
            if not list or #list == 0 then return end
            Values[text] = list[1]
            local idx = 1

            local B = Instance.new("TextButton", Page)
            B.Size = UDim2.new(1, -12, 0, 36)
            B.Font = Enum.Font.Gotham
            B.TextSize = 14
            B.BackgroundColor3 = Theme.accent
            B.TextColor3 = Color3.new(1,1,1)
            corner(B, 8)

            local function refresh()
                B.Text = text..": "..Values[text]
            end
            refresh()

            B.MouseButton1Click:Connect(function()
                idx = idx % #list + 1
                Values[text] = list[idx]
                refresh()
                safe(cb, Values[text])
            end)
        end

        function Tab:Keybind(key, cb)
            UIS.InputBegan:Connect(function(i,gp)
                if not gp and i.KeyCode == key then
                    safe(cb)
                end
            end)
        end

        return Tab
    end

    if cfg.ToggleKey then
        UIS.InputBegan:Connect(function(i,gp)
            if not gp and i.KeyCode == cfg.ToggleKey then
                Window:Toggle()
            end
        end)
    end

    return Window
end

return Library
