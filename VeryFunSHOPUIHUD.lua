--==================================================
-- VERYFUN UI CORE (EXTENDED / PURE)
--==================================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local UI = {}
UI.__index = UI

--================ CONFIG =================--
UI.Config = {
    Logo = "rbxassetid://82270910588453",
    Theme = {
        bg = Color3.fromRGB(20,16,28),
        panel = Color3.fromRGB(28,22,38),
        accent = Color3.fromRGB(170,78,255),
        text = Color3.fromRGB(235,210,255)
    }
}

--================ CLEAN OLD =================--
pcall(function()
    if PlayerGui:FindFirstChild("VeryFun_UI_Core") then
        PlayerGui.VeryFun_UI_Core:Destroy()
    end
end)

--================ GUI =================--
local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.Name = "VeryFun_UI_Core"
ScreenGui.ResetOnSpawn = false

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 640, 0, 420)
Main.Position = UDim2.new(0.5, -320, 0.5, -210)
Main.BackgroundColor3 = UI.Config.Theme.bg
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0,16)

-- Title
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1,-24,0,48)
Title.Position = UDim2.new(0,12,0,8)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Text = "VeryFun UI"
Title.TextColor3 = UI.Config.Theme.text
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Sidebar
local Sidebar = Instance.new("ScrollingFrame", Main)
Sidebar.Size = UDim2.new(0,180,1,-72)
Sidebar.Position = UDim2.new(0,12,0,60)
Sidebar.BackgroundColor3 = UI.Config.Theme.panel
Sidebar.ScrollBarThickness = 4
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0,12)

local SideLayout = Instance.new("UIListLayout", Sidebar)
SideLayout.Padding = UDim.new(0,8)

-- Content
local Content = Instance.new("Frame", Main)
Content.Size = UDim2.new(1,-216,1,-72)
Content.Position = UDim2.new(0,204,0,60)
Content.BackgroundTransparency = 1

local Pages = {}
local CurrentPage

--================ API =================--
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

function UI:SetTheme(theme)
    for k,v in pairs(theme) do
        if UI.Config.Theme[k] ~= nil then
            UI.Config.Theme[k] = v
        end
    end
    -- Update all existing elements
    Main.BackgroundColor3 = UI.Config.Theme.bg
    Title.TextColor3 = UI.Config.Theme.text
    Sidebar.BackgroundColor3 = UI.Config.Theme.panel
    if CurrentPage then
        for _,child in pairs(CurrentPage:GetChildren()) do
            if child:IsA("TextButton") or child:IsA("TextLabel") then
                if child.BackgroundColor3 ~= UI.Config.Theme.bg then
                    child.BackgroundColor3 = UI.Config.Theme.panel
                end
            end
        end
    end
end

function UI:Destroy()
    if ScreenGui then
        ScreenGui:Destroy()
    end
end

function UI:CreatePage(name)
    local page = Instance.new("ScrollingFrame", Content)
    page.Size = UDim2.new(1,0,1,0)
    page.ScrollBarThickness = 4
    page.CanvasSize = UDim2.new(0,0,0,0)
    page.Visible = false
    page.BackgroundTransparency = 1

    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0,10)

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 20)
    end)

    Pages[name] = page

    local btn = Instance.new("TextButton", Sidebar)
    btn.Size = UDim2.new(1,0,0,40)
    btn.Text = name
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 15
    btn.TextColor3 = UI.Config.Theme.text
    btn.BackgroundColor3 = UI.Config.Theme.panel
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)

    -- Hover Tween
    local hoverTween = TweenService:Create(btn,TweenInfo.new(0.15),{BackgroundColor3=UI.Config.Theme.accent})
    local leaveTween = TweenService:Create(btn,TweenInfo.new(0.15),{BackgroundColor3=UI.Config.Theme.panel})

    btn.MouseEnter:Connect(function() hoverTween:Play() end)
    btn.MouseLeave:Connect(function() leaveTween:Play() end)

    btn.MouseButton1Click:Connect(function()
        if CurrentPage then CurrentPage.Visible = false end
        CurrentPage = page
        page.Visible = true
    end)

    if not CurrentPage then
        CurrentPage = page
        page.Visible = true
    end

    return page
end

function UI:CreateSection(page, text)
    local lbl = Instance.new("TextLabel", page)
    lbl.Size = UDim2.new(1,0,0,26)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 14
    lbl.TextColor3 = UI.Config.Theme.accent
    lbl.TextXAlignment = Enum.TextXAlignment.Left
end

function UI:CreateButton(page, text, callback)
    local b = Instance.new("TextButton", page)
    b.Size = UDim2.new(1,0,0,34)
    b.BackgroundColor3 = UI.Config.Theme.panel
    b.Text = text
    b.Font = Enum.Font.Gotham
    b.TextSize = 14
    b.TextColor3 = UI.Config.Theme.text
    Instance.new("UICorner", b)

    -- Hover Tween
    local hoverTween = TweenService:Create(b,TweenInfo.new(0.15),{BackgroundColor3=UI.Config.Theme.accent})
    local leaveTween = TweenService:Create(b,TweenInfo.new(0.15),{BackgroundColor3=UI.Config.Theme.panel})

    b.MouseEnter:Connect(function() hoverTween:Play() end)
    b.MouseLeave:Connect(function() leaveTween:Play() end)

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
    b.TextColor3 = UI.Config.Theme.text
    Instance.new("UICorner", b)

    local function refresh()
        b.Text = text .. (state and " : ON" or " : OFF")
        b.BackgroundColor3 = state and UI.Config.Theme.accent or UI.Config.Theme.panel
    end
    refresh()

    local hoverTween = TweenService:Create(b,TweenInfo.new(0.15),{BackgroundColor3=UI.Config.Theme.accent})
    local leaveTween = TweenService:Create(b,TweenInfo.new(0.15),{BackgroundColor3=state and UI.Config.Theme.accent or UI.Config.Theme.panel})

    b.MouseEnter:Connect(function() hoverTween:Play() end)
    b.MouseLeave:Connect(function() leaveTween:Play() end)

    b.MouseButton1Click:Connect(function()
        state = not state
        refresh()
        if callback then callback(state) end
    end)
end

--================ FLOAT TOGGLE =================--
local ToggleBtn = Instance.new("ImageButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0,64,0,64)
ToggleBtn.Position = UDim2.new(0,12,0.45,0)
ToggleBtn.Image = UI.Config.Logo
ToggleBtn.BackgroundColor3 = UI.Config.Theme.panel
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0,16)

ToggleBtn.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

UI.ToggleBtn = ToggleBtn

return UI
