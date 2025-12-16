--============================--
-- VERYFUN SHOP - HWID LOCK 
--============================--

local HWID_URL = "https://raw.githubusercontent.com/amnad2003/veryfun_autofarm/refs/heads/main/hwidPremium_lock.lua"

local function GetHWID()
    if gethwid then
        return tostring(gethwid())
    elseif syn and syn.get_hwid then
        return tostring(syn.get_hwid())
    elseif crypt and crypt.generate_hash then
        return crypt.generate_hash("HWID")
    else
        return game:GetService("RbxAnalyticsService"):GetClientId()
    end
end

local myHWID = GetHWID()
local whitelistData = {}

-- โหลดไฟล์ HWID จาก GitHub
local ok, rawData = pcall(function()
    return game:HttpGet(HWID_URL)
end)

-- แปลงไฟล์ .lua → table
if ok and rawData then
    local loadFunc = loadstring(rawData)
    if loadFunc then
        local suc, result = pcall(loadFunc)
        if suc and type(result) == "table" then
            whitelistData = result
        end
    end
end

-- เช็คว่า HWID อยู่ใน whitelist?
local function IsHWIDAllowed()
    for _, hw in ipairs(whitelistData) do
        if tostring(hw) == tostring(myHWID) then
            return true
        end
    end
    return false
end

--==============================--
-- UI HWID ถ้าไม่ whitelist
--==============================--

local function ShowHWIDScreen()
    local player = game.Players.LocalPlayer

    local gui = Instance.new("ScreenGui")
    gui.Name = "VERYFUN_HWID_UI"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = player:WaitForChild("PlayerGui")

    local blur = Instance.new("BlurEffect", game.Lighting)
    blur.Size = 15

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0, 450, 0, 260)
    frame.Position = UDim2.new(0.5, -225, 0.5, -130)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BorderSizePixel = 0

    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 16)

    local stroke = Instance.new("UIStroke", frame)
    stroke.Thickness = 2
    stroke.Color = Color3.fromRGB(255, 70, 70)

    -- Animation เด้งขึ้นมา
    frame.Position = UDim2.new(0.5, -225, 0.5, 260)
    game.TweenService:Create(frame, TweenInfo.new(.4, Enum.EasingStyle.Back), {
        Position = UDim2.new(0.5, -225, 0.5, -130)
    }):Play()

    -- Top Bar
    local bar = Instance.new("Frame", frame)
    bar.Size = UDim2.new(1, 0, 0, 45)
    bar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 16)

    local title = Instance.new("TextLabel", bar)
    title.Size = UDim2.new(1, -50, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 21
    title.TextColor3 = Color3.fromRGB(255, 90, 90)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = "VERYFUN SHOP — HWID LOCK"

    local close = Instance.new("TextButton", bar)
    close.Size = UDim2.new(0, 50, 1, 0)
    close.Position = UDim2.new(1, -50, 0, 0)
    close.BackgroundTransparency = 1
    close.Font = Enum.Font.GothamBold
    close.TextSize = 22
    close.TextColor3 = Color3.fromRGB(255, 60, 60)
    close.Text = "✕"

    close.MouseButton1Click:Connect(function()
        frame.Position = UDim2.new(0.5, -225, 0.5, -130)
        game.TweenService:Create(frame, TweenInfo.new(.4, Enum.EasingStyle.Quad), {
            Position = UDim2.new(0.5, -225, 0.5, 300)
        }):Play()
        task.wait(.25)
        gui:Destroy()
        blur:Destroy()
    end)

    -- HWID Display
    local hwidLabel = Instance.new("TextLabel", frame)
    hwidLabel.Size = UDim2.new(1, -20, 0, 80)
    hwidLabel.Position = UDim2.new(0, 10, 0, 60)
    hwidLabel.BackgroundTransparency = 1
    hwidLabel.Font = Enum.Font.Gotham
    hwidLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    hwidLabel.TextSize = 16
    hwidLabel.TextWrapped = true
    hwidLabel.Text = "HWID ของคุณ:\n" .. myHWID

    -- Loading Animation
    local loading = Instance.new("TextLabel", frame)
    loading.Size = UDim2.new(1, 0, 0, 30)
    loading.Position = UDim2.new(0, 0, 1, -85)
    loading.BackgroundTransparency = 1
    loading.Font = Enum.Font.GothamBold
    loading.TextSize = 18
    loading.TextColor3 = Color3.fromRGB(255, 80, 80)
    loading.Text = "กำลังตรวจสอบ HWID..."

    task.spawn(function()
        while gui.Parent do
            loading.Text = "กำลังตรวจสอบ HWID."
            task.wait(0.25)
            loading.Text = "กำลังตรวจสอบ HWID.."
            task.wait(0.25)
            loading.Text = "กำลังตรวจสอบ HWID..."
            task.wait(0.25)
        end
    end)

    -- Copy Button
    local copyBtn = Instance.new("TextButton", frame)
    copyBtn.Size = UDim2.new(0, 200, 0, 40)
    copyBtn.Position = UDim2.new(0.5, -100, 1, -45)
    copyBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    copyBtn.Font = Enum.Font.GothamBold
    copyBtn.TextColor3 = Color3.new(1,1,1)
    copyBtn.TextSize = 16
    copyBtn.Text = "คัดลอก HWID"

    Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 10)

    copyBtn.MouseButton1Click:Connect(function()
        setclipboard(myHWID)
        copyBtn.Text = "คัดลอกแล้ว!"
        copyBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 60)
    end)
end

-- ถ้าไม่ whitelist → แสดง UI และหยุดสคริปต์หลัก
if not IsHWIDAllowed() then
    ShowHWIDScreen()
    return
end

--============================--
-- ผ่าน HWID → รันสคริปต์ VeryFun ต่อ
--============================--


local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Window = WindUI:CreateWindow({
    Title = "VeryFun SHOP | MOUNTRNG",
    Icon = "sparkles",
    Author = "VeryFun SHOP ©",
    Folder = "VeryFunSHOP",
})


local Tab = Window:Tab({
    Title = "Auto Farm",
    Icon = "bird", -- optional
    Locked = false,
})
Tab:Select()


local Toggle = Tab:Toggle({
    Title = "Auto Kill",
    Desc = "Auto Kill",
    Icon = "bird",
    Type = "Checkbox",
    Value = false, -- default value
    Callback = function(state) 
        _G.AutoKill = state
    end
})

local Toggle = Tab:Toggle({
    Title = "Auto Quest",
    Desc = "Auto Quest",
    Icon = "bird",
    Type = "Checkbox",
    Value = false, -- default value
    Callback = function(state) 
        _G.AutoQuest = state
    end
})
local Input = Tab:Input({
    Title = "FPS LOCK",
    Desc = "FPS LOCK",
    Value = "240",
    InputIcon = "bird",
    Type = "Input", -- or "Textarea"
    Placeholder = "Enter Number...",
    Callback = function(input) 
        setfpscap(tonumber(input))
    end
})
--
workspace.ChildAdded:Connect(function(a)
    if a.Name == "Skill" then
        a:Destroy()
    end
end)


game:GetService("Players").LocalPlayer.PlayerScripts.CameraShakeClient.Disabled = true

local vu = game:GetService("VirtualUser")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

player.Idled:Connect(function()
    vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end)

spawn(function()
    while task.wait() do
        pcall(function()
            if _G.AutoKill then
                for i,v in pairs(workspace.Mobs:GetChildren()) do
                    if v:FindFirstChild("Humanoid") and v:FindFirstChild("Humanoid").Health > 0 and v:FindFirstChild("HumanoidRootPart") then
                        v.HumanoidRootPart.CanCollide = true
                        v.HumanoidRootPart.Size = Vector3.new(0, 0, 0)

                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0,20,0)
                        --
                        for i,v in pairs(workspace:GetChildren()) do
                            if v.Name == "Loot" then
                                if v:FindFirstChild("CollectLoot") then
                                    v.CollectLoot:FireServer()
                                end
                            end
                        end
                        for i,v in pairs(game:GetService("ReplicatedStorage").Combat.Skills:GetChildren()) do
                            local args = {
                                v.Name
                            }
                            game:GetService("ReplicatedStorage"):WaitForChild("Combat"):WaitForChild("RequestSkillUse"):FireServer(unpack(args))
                        end
                        -- task.spawn(function()
                        --     for i,vv in pairs(workspace.Mobs:GetChildren()) do
                        --         if vv:FindFirstChild("Humanoid") and vv:FindFirstChild("Humanoid").Health > 0 and vv.Name == v.Name and vv:FindFirstChild("HumanoidRootPart") then
                        --             vv.HumanoidRootPart.CFrame = v.HumanoidRootPart.CFrame
                        --             vv.HumanoidRootPart.CanCollide = true
                        --             vv.HumanoidRootPart.Size = Vector3.new(0, 0, 0)
                        --         end
                        --     end
                        --     if sethiddenproperty then
                        --         sethiddenproperty(game.Players.LocalPlayer, "SimulationRadius", 112412400000)
                        --         sethiddenproperty(game.Players.LocalPlayer, "MaxSimulationRadius", 112412400000)
                        --     end
                        -- end)

                        break
                    end
                end
            end
        end)
    end
end)


-- AUTO QUEST

function CheckQuest()
    Count = 0
    for i,v in pairs(game:GetService("Players").LocalPlayer.PlayerGui.Quests.Window.Grid.ScrollingFrame:GetChildren()) do
        if v:IsA"Frame" then
            Count = Count  +1
        end
    end
    return Count
end


spawn(function()
    while task.wait() do
        pcall(function()
            if _G.AutoQuest then
                if CheckQuest() <= 5 then
                    --
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.Environment.Interactables.Quests.QuestBoard.CFrame
                    fireproximityprompt(workspace.Environment.Interactables.Quests.QuestBoard.ProximityPrompt)
                    --
                end
            end
        end)
    end
end)