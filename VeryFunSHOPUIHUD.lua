--==================================================
-- VERYFUN UI LIBRARY (SELL VERSION)
--==================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local UI = {}
UI.__index = UI

--================ CONFIG =================--
UI.Config = {
    Logo = "rbxassetid://82270910588453"
}

function UI:SetLogo(icon)
    if type(icon) == "number" then
        self.Config.Logo = "rbxassetid://"..icon
    elseif type(icon) == "string" and not icon:find("rbxassetid://") then
        self.Config.Logo = "rbxassetid://"..icon
    else
        self.Config.Logo = icon
    end
    if self.ToggleBtn then
        self.ToggleBtn.Image = self.Config.Logo
    end
end

--================ THEME =================--
local THEME = {
    bg = Color3.fromHex("#0F1720"),
    panel = Color3.fromHex("#1F2937"),
    accent = Color3.fromHex("#66FFCC"),
    text = Color3.fromRGB(240,240,240)
}

--================ GUI =================--
pcall(function()
    if PlayerGui:FindFirstChild("VeryFun_UI") then
        PlayerGui.VeryFun_UI:Destroy()
    end
end)

local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.Name = "VeryFun_UI"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.fromOffset(560, 400)
MainFrame.Position = UDim2.fromScale(0.5,0.5)
MainFrame.AnchorPoint = Vector2.new(0.5,0.5)
MainFrame.BackgroundColor3 = THEME.bg
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0,14)

-- Top
local Top = Instance.new("Frame", MainFrame)
Top.Size = UDim2.new(1,0,0,44)
Top.BackgroundColor3 = THEME.panel
Instance.new("UICorner", Top).CornerRadius = UDim.new(0,14)

local Title = Instance.new("TextLabel", Top)
Title.Size = UDim2.new(1,-60,1,0)
Title.Position = UDim2.fromOffset(12,0)
Title.BackgroundTransparency = 1
Title.Text = "VeryFun UI"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextColor3 = THEME.text
Title.TextXAlignment = Left

-- Content
local PageHolder = Instance.new("Frame", MainFrame)
PageHolder.Position = UDim2.fromOffset(12,56)
PageHolder.Size = UDim2.new(1,-24,1,-68)
PageHolder.BackgroundTransparency = 1

local Pages = {}

--================ API =================--

function UI:CreatePage(name)
    local page = Instance.new("ScrollingFrame", PageHolder)
    page.Name = name
    page.Size = UDim2.fromScale(1,1)
    page.ScrollBarImageTransparency = 1
    page.CanvasSize = UDim2.new(0,0,0,0)
    page.Visible = (#Pages == 0)

    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0,10)

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 20)
    end)

    Pages[#Pages+1] = page
    return page
end

function UI:CreateSection(page, text)
    local l = Instance.new("TextLabel", page)
    l.Size = UDim2.new(1,0,0,26)
    l.BackgroundTransparency = 1
    l.Text = text
    l.Font = Enum.Font.GothamBold
    l.TextSize = 14
    l.TextColor3 = THEME.accent
    l.TextXAlignment = Left
end

function UI:CreateButton(page, text, callback)
    local b = Instance.new("TextButton", page)
    b.Size = UDim2.new(1,0,0,34)
    b.BackgroundColor3 = THEME.panel
    b.Text = text
    b.Font = Enum.Font.Gotham
    b.TextSize = 14
    b.TextColor3 = THEME.text
    Instance.new("UICorner", b)

    b.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
end

function UI:CreateToggle(page, text, default, callback)
    local state = default or false

    local b = Instance.new("TextButton", page)
    b.Size = UDim2.new(1,0,0,34)
    b.Font = Enum.Font.Gotham
    b.TextSize = 14
    b.TextColor3 = THEME.text
    Instance.new("UICorner", b)

    local function refresh()
        b.Text = text .. (state and " : ON" or " : OFF")
        b.BackgroundColor3 = state and THEME.accent or THEME.panel
    end
    refresh()

    b.MouseButton1Click:Connect(function()
        state = not state
        refresh()
        if callback then callback(state) end
    end)
end

--================ TOGGLE LOGO =================--
local ToggleBtn = Instance.new("ImageButton", ScreenGui)
ToggleBtn.Size = UDim2.fromOffset(52,52)
ToggleBtn.Position = UDim2.fromOffset(16,200)
ToggleBtn.BackgroundTransparency = 1
ToggleBtn.Image = UI.Config.Logo

ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

UI.ToggleBtn = ToggleBtn

return UI
