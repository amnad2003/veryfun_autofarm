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


-- โหลด UI
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/amnad2003/veryfun_autofarm/refs/heads/main/VeryFunSHOPUIHUD.lua"))()
if not UI then
    warn("โหลด VeryFunUI ไม่สำเร็จ!")
    return
end

-- ตั้งค่า Logo และ Title
UI:SetLogo(82270910588453)
UI:SetTitle("VeryFun SHOP | Premium Hub")

-- =========================
-- สร้างหน้า Auto Farm
-- =========================
local FarmPage = UI:CreatePage("Auto Farm")

-- =========================
-- ตัวแปรควบคุม
-- =========================
_G.AutoKill = false
_G.AutoQuest = false
_G.AutoLoot = false
_G.FPS = 60
_G.FPS_LOCK = false

local player = game.Players.LocalPlayer

-- =========================
-- UI Toggle / Slider / Label
-- =========================
UI:CreateToggle(FarmPage, "Auto Kill", false, function(state)
    _G.AutoKill = state
end)

UI:CreateToggle(FarmPage, "Auto Quest", false, function(state)
    _G.AutoQuest = state
end)

UI:CreateToggle(FarmPage, "Auto Loot", false, function(state)
    _G.AutoLoot = state
end)

UI:CreateLabel(FarmPage, "⚙ FPS")
UI:CreateSlider(FarmPage, "FPS", 5, 240, _G.FPS, function(v)
    _G.FPS = v
    if _G.FPS_LOCK and setfpscap then
        setfpscap(v)
    end
end)

UI:CreateToggle(FarmPage, "Enable FPS Lock", false, function(v)
    _G.FPS_LOCK = v
    if setfpscap then
        setfpscap(v and _G.FPS or 999)
    end
end)

-- =========================
-- ป้องกัน Skill Spawn / Camera Shake / AFK
-- =========================
workspace.ChildAdded:Connect(function(a)
    if a.Name == "Skill" then
        a:Destroy()
    end
end)

if player:FindFirstChild("PlayerScripts") and player.PlayerScripts:FindFirstChild("CameraShakeClient") then
    player.PlayerScripts.CameraShakeClient.Disabled = true
end

local vu = game:GetService("VirtualUser")
player.Idled:Connect(function()
    vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

-- =========================
-- ฟังก์ชันตรวจสอบ Quest ปัจจุบัน
-- =========================
local function GetCurrentQuestMobName()
    local currentMobName = nil
    for _, questFrame in pairs(player.PlayerGui.Quests.Window.Grid.ScrollingFrame:GetChildren()) do
        if questFrame:IsA("Frame") and questFrame:FindFirstChild("MobName") then
            currentMobName = questFrame.MobName.Text
        end
    end
    return currentMobName
end

local function CanAcceptQuest()
    local Count = 0
    for _, v in pairs(player.PlayerGui.Quests.Window.Grid.ScrollingFrame:GetChildren()) do
        if v:IsA("Frame") and not (v:FindFirstChild("Completed") and v.Completed.Value) then
            Count = Count + 1
        end
    end
    return Count < 5
end

-- =========================
-- Auto Kill + Auto Skill + Auto Loot Logic
-- =========================
spawn(function()
    while task.wait() do
        pcall(function()
            if _G.AutoKill then
                local mobName = GetCurrentQuestMobName()
                if mobName then
                    for _, mob in pairs(workspace.Mobs:GetChildren()) do
                        if mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 
                           and mob:FindFirstChild("HumanoidRootPart") 
                           and mob.Name == mobName then

                            player.Character.HumanoidRootPart.CFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0,20,0)

                            -- ใช้ Skill อัตโนมัติทุกตัว
                            for _, skill in pairs(game:GetService("ReplicatedStorage").Combat.Skills:GetChildren()) do
                                game:GetService("ReplicatedStorage").Combat.RequestSkillUse:FireServer(skill.Name)
                            end

                            -- เก็บ Loot ถ้าเปิด
                            if _G.AutoLoot then
                                for _, loot in pairs(workspace:GetChildren()) do
                                    if loot.Name == "Loot" and loot:FindFirstChild("CollectLoot") then
                                        loot.CollectLoot:FireServer()
                                    end
                                end
                            end
                            break
                        end
                    end
                end
            end
        end)
    end
end)

-- =========================
-- Auto Quest Logic
-- =========================
spawn(function()
    while task.wait() do
        pcall(function()
            if _G.AutoQuest then
                if CanAcceptQuest() then
                    player.Character.HumanoidRootPart.CFrame = workspace.Environment.Interactables.Quests.QuestBoard.CFrame
                    fireproximityprompt(workspace.Environment.Interactables.Quests.QuestBoard.ProximityPrompt)
                    task.wait(1)
                end
            end
        end)
    end
end)

-- =========================
-- ตั้งค่า FPS เริ่มต้น
-- =========================
if setfpscap then
    setfpscap(_G.FPS_LOCK and _G.FPS or 999)
end
