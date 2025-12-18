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


--=====================================================
-- VERYFUN SHOP | AUTO FARM (BEST + ORIGINAL SKILL)
-- Hover Head | Safe Loop | Use ALL Skills (OLD STYLE)
--=====================================================

--================= LOAD UI =================--
local UI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/amnad2003/veryfun_autofarm/refs/heads/main/VeryFunSHOPUIHUD.lua"
))()
if not UI then return end

UI:SetLogo(82270910588453)
UI:SetTitle("VeryFun SHOP | Premium Hub (BEST)")

--================= SERVICES =================--
local Players = game:GetService("Players")
local RS      = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer

--================= STATE =================--
_G.AutoKill    = false
_G.AutoLoot    = false
_G.AutoQuest   = false
_G.HoverHeight = 6
_G.FPS         = 60
_G.FPS_LOCK    = false

--================= PAGE =================--
local Farm = UI:CreatePage("Auto Farm")

UI:CreateToggle(Farm,"Auto Kill (Hover Head)",false,function(v)
    _G.AutoKill = v
end)

UI:CreateSlider(Farm,"Hover Height",3,15,_G.HoverHeight,function(v)
    _G.HoverHeight = v
end)

UI:CreateToggle(Farm,"Auto Loot",false,function(v)
    _G.AutoLoot = v
end)

UI:CreateToggle(Farm,"Auto Quest",false,function(v)
    _G.AutoQuest = v
end)

UI:CreateLabel(Farm,"⚙ FPS")
UI:CreateSlider(Farm,"FPS",30,240,_G.FPS,function(v)
    _G.FPS = v
    if _G.FPS_LOCK and setfpscap then
        setfpscap(v)
    end
end)

UI:CreateToggle(Farm,"Enable FPS Lock",false,function(v)
    _G.FPS_LOCK = v
    if setfpscap then
        setfpscap(v and _G.FPS or 999)
    end
end)

--================= ANTI AFK =================--
player.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
end)

--=====================================================
-- UTILS
--=====================================================
local function GetCharacter()
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return end
    return char, hrp, hum
end

local function FindMob()
    local mobsFolder = Workspace:FindFirstChild("Mobs")
    if mobsFolder then
        for _,m in ipairs(mobsFolder:GetChildren()) do
            local h = m:FindFirstChildOfClass("Humanoid")
            local hrp = m:FindFirstChild("HumanoidRootPart")
            if h and hrp and h.Health > 0 then
                return m, h, hrp
            end
        end
    end

    for _,m in ipairs(Workspace:GetChildren()) do
        if m:IsA("Model") and m ~= player.Character then
            local h = m:FindFirstChildOfClass("Humanoid")
            local hrp = m:FindFirstChild("HumanoidRootPart")
            if h and hrp and h.Health > 0 then
                return m, h, hrp
            end
        end
    end
end

--=====================================================
-- ORIGINAL SKILL SYSTEM (ใช้สกิลแบบเดิม)
--=====================================================
local function UseAllSkills()
    if not RS:FindFirstChild("Combat") then return end
    if not RS.Combat:FindFirstChild("Skills") then return end
    if not RS.Combat:FindFirstChild("RequestSkillUse") then return end

    for _,skill in ipairs(RS.Combat.Skills:GetChildren()) do
        pcall(function()
            RS.Combat.RequestSkillUse:FireServer(skill.Name)
        end)
    end
end

--=====================================================
-- AUTO KILL (HOVER HEAD / SAFE)
--=====================================================
task.spawn(function()
    while task.wait(0.2) do
        if not _G.AutoKill then continue end

        local char, hrp = GetCharacter()
        if not char then continue end

        local mob, hum, mobHRP = FindMob()
        if not mob then continue end

        while _G.AutoKill
        and mob.Parent
        and hum.Health > 0 do

            local _, p = GetCharacter()
            if not p then break end
            if not mobHRP or not mobHRP.Parent then break end

            p.CFrame = mobHRP.CFrame * CFrame.new(0, _G.HoverHeight, 0)
            UseAllSkills()
            task.wait(0.12)
        end
    end
end)

--=====================================================
-- AUTO LOOT
--=====================================================
local Looted = {}

Workspace.DescendantAdded:Connect(function(obj)
    if _G.AutoLoot and obj.Name:lower():find("loot") then
        if not Looted[obj] and obj:FindFirstChild("CollectLoot") then
            Looted[obj] = true
            pcall(function()
                obj.CollectLoot:FireServer()
            end)
        end
    end
end)

--=====================================================
-- AUTO QUEST
--=====================================================
task.spawn(function()
    while task.wait(1.5) do
        if not _G.AutoQuest then continue end

        pcall(function()
            local board = Workspace:FindFirstChild("Environment")
            and Workspace.Environment.Interactables.Quests:FindFirstChild("QuestBoard")

            if board and board:FindFirstChild("ProximityPrompt") then
                local _,hrp = GetCharacter()
                if hrp then
                    hrp.CFrame = board.CFrame * CFrame.new(0,2,0)
                    fireproximityprompt(board.ProximityPrompt)
                end
            end
        end)
    end
end)

--================= FPS INIT =================--
if setfpscap then
    setfpscap(_G.FPS_LOCK and _G.FPS or 999)
end
