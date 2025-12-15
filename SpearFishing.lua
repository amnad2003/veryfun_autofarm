--=====================================================
-- VERYFUN SHOP | PREMIUM HUB (FULL)
--=====================================================

-- ===== Load UI =====
local WindUI = loadstring(game:HttpGet(
    "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"
))()

-- ===== Window =====
local Window = WindUI:CreateWindow({
    Title = "VeryFun SHOP | Premium Hub",
    Icon = "sparkles",
    Author = "VeryFun SHOP ©",
    Folder = "VeryFunSHOP",
})

-- ===== Tabs =====
local FarmTab = Window:Tab({
    Title = "Auto Farm",
    Icon = "bird"
})

local PerfTab = Window:Tab({
    Title = "SetFPS",
    Icon = "activity"
})

local AFKTab = Window:Tab({
    Title = "Anti AFK",
    Icon = "clock"
})

FarmTab:Select()

--=====================================================
-- GLOBAL VALUES
--=====================================================
_G.Sea = "1"
_G.AutoKill = false
_G.AutoKillBuff = false
_G.AutoSell = false
_G.FPS_LOCK = false
_G.FPS = 60
_G.AFK = false
_G.AFK_TIME = 300

--=====================================================
-- AUTO FARM UI
--=====================================================
FarmTab:Dropdown({
    Title = "Select Sea",
    Values = {"1","2","3","4"},
    Value = "1",
    Callback = function(v)
        _G.Sea = v
    end
})

FarmTab:Toggle({
    Title = "Auto Kill",
    Value = false,
    Callback = function(v)
        _G.AutoKill = v
    end
})

FarmTab:Toggle({
    Title = "Auto Kill [ Buff Fish ]",
    Value = false,
    Callback = function(v)
        _G.AutoKillBuff = v
    end
})

FarmTab:Toggle({
    Title = "Auto Sell",
    Value = false,
    Callback = function(v)
        _G.AutoSell = v
    end
})

--=====================================================
-- AUTO FARM LOGIC
--=====================================================
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer

local SeaPos = {
    ["1"] = CFrame.new(1264,85,90),
    ["2"] = CFrame.new(1277,85,-77),
    ["3"] = CFrame.new(1259,85,-276),
    ["4"] = CFrame.new(1257,85,-527),
}

local function EquipTool()
    for _,v in pairs(LP.Backpack:GetChildren()) do
        if v.Name:find("Harpoon") then
            LP.Character.Humanoid:EquipTool(v)
        end
    end
end

--=====================================================
-- AUTO KILL
--=====================================================
task.spawn(function()
    while task.wait() do
        if _G.AutoKill then
            pcall(function()
                if workspace.WorldSea:FindFirstChild("Sea".._G.Sea) then
                    EquipTool()

                    for _,sea in pairs(workspace.WorldSea:GetChildren()) do
                        if sea.Name == "Sea".._G.Sea then
                            for _,fish in pairs(sea:GetChildren()) do
                                if fish:IsA("Part") then
                                    RS.Remotes.FireRE:FireServer("Fire",{
                                        cameraOrigin = workspace.Camera.CFrame.Position,
                                        player = LP,
                                        toolInstance = LP.Character:FindFirstChildOfClass("Tool"),
                                        destination = fish.Position,
                                        isCharge = true
                                    })

                                    RS.Remotes.FireRE:FireServer("Hit",{
                                        fishInstance = fish,
                                        HitPos = fish.Position,
                                        toolInstance = LP.Character:FindFirstChildOfClass("Tool")
                                    })

                                    LP.Character.HumanoidRootPart.CFrame =
                                        fish.Model.Root.CFrame * CFrame.new(0,5,0)
                                    break
                                end
                            end
                        end
                    end
                else
                    LP.Character.HumanoidRootPart.CFrame = SeaPos[_G.Sea]
                end
            end)
        end
    end
end)

--=====================================================
-- AUTO BUFF FISH
--=====================================================
task.spawn(function()
    while task.wait() do
        if _G.AutoKillBuff then
            pcall(function()
                if workspace.WorldSea:FindFirstChild("Sea".._G.Sea) then
                    EquipTool()

                    for _,sea in pairs(workspace.WorldSea:GetChildren()) do
                        if sea.Name == "Sea".._G.Sea then
                            for _,fish in pairs(sea:GetChildren()) do
                                if fish:IsA("Part") and fish:GetAttribute("Mutation") then
                                    RS.Remotes.FireRE:FireServer("Fire",{
                                        cameraOrigin = workspace.Camera.CFrame.Position,
                                        player = LP,
                                        toolInstance = LP.Character:FindFirstChildOfClass("Tool"),
                                        destination = fish.Position,
                                        isCharge = true
                                    })

                                    RS.Remotes.FireRE:FireServer("Hit",{
                                        fishInstance = fish,
                                        HitPos = fish.Position,
                                        toolInstance = LP.Character:FindFirstChildOfClass("Tool")
                                    })

                                    LP.Character.HumanoidRootPart.CFrame =
                                        fish.Model.Root.CFrame * CFrame.new(0,5,0)
                                    break
                                end
                            end
                        end
                    end
                else
                    LP.Character.HumanoidRootPart.CFrame = SeaPos[_G.Sea]
                end
            end)
        end
    end
end)

--=====================================================
-- AUTO SELL
--=====================================================
task.spawn(function()
    while task.wait(0.2) do
        if _G.AutoSell then
            pcall(function()
                local list = {}
                for _,v in pairs(LP.PlayerGui.Data.Fish:GetChildren()) do
                    table.insert(list, v.Name)
                end

                if #list > 0 then
                    RS.Remotes.FishRE:FireServer("SellAll",{UIDs = list})
                end
            end)
        end
    end
end)

--=====================================================
-- FPS LOCK UI
--=====================================================
PerfTab:Input({
    Title = "Set FPS (5 - 120)",
    Placeholder = "เช่น 30 / 60 / 120",
    Callback = function(v)
        local n = tonumber(v)
        if n and n >= 5 and n <= 120 then
            _G.FPS = n
            if _G.FPS_LOCK and setfpscap then
                setfpscap(_G.FPS)
            end
        end
    end
})

PerfTab:Toggle({
    Title = "Enable FPS Lock",
    Value = false,
    Callback = function(v)
        _G.FPS_LOCK = v
        if setfpscap then
            if v then
                setfpscap(_G.FPS)
            else
                setfpscap(999)
            end
        end
    end
})

--=====================================================
-- ANTI AFK
--=====================================================
AFKTab:Input({
    Title = "AFK Interval (seconds)",
    Placeholder = "300 = 5 นาที",
    Callback = function(v)
        local n = tonumber(v)
        if n and n >= 30 then
            _G.AFK_TIME = n
        end
    end
})

AFKTab:Toggle({
    Title = "Enable Anti AFK",
    Value = false,
    Callback = function(v)
        _G.AFK = v
    end
})

task.spawn(function()
    while task.wait(1) do
        if _G.AFK then
            task.wait(_G.AFK_TIME)
            pcall(function()
                local hum = LP.Character.Humanoid
                hum:Move(Vector3.new(0,0,-1), false)
                task.wait(1)
                hum:Move(Vector3.zero, false)
            end)
        end
    end
end)



--=====================================================
-- VERYFUN SHOP | FLY SYSTEM (NO DRIFT)
--=====================================================

local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

_G.FLY = false
_G.FLY_SPEED = 30

local BV, BG
local Control = {F=0,B=0,L=0,R=0,U=0,D=0}

--================ UI =================
FarmTab:Toggle({
    Title = "Fly Mode (Manual)",
    Value = false,
    Callback = function(v)
        _G.FLY = v
        if not v then
            if BV then BV:Destroy() BV=nil end
            if BG then BG:Destroy() BG=nil end
        end
    end
})

FarmTab:Input({
    Title = "Fly Speed",
    Placeholder = "20 - 60",
    Callback = function(v)
        local n = tonumber(v)
        if n and n >= 10 and n <= 100 then
            _G.FLY_SPEED = n
        end
    end
})

--================ INPUT =================
UIS.InputBegan:Connect(function(i,gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.W then Control.F = 1 end
    if i.KeyCode == Enum.KeyCode.S then Control.B = 1 end
    if i.KeyCode == Enum.KeyCode.A then Control.L = 1 end
    if i.KeyCode == Enum.KeyCode.D then Control.R = 1 end
    if i.KeyCode == Enum.KeyCode.Space then Control.U = 1 end
    if i.KeyCode == Enum.KeyCode.LeftControl then Control.D = 1 end
end)

UIS.InputEnded:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.W then Control.F = 0 end
    if i.KeyCode == Enum.KeyCode.S then Control.B = 0 end
    if i.KeyCode == Enum.KeyCode.A then Control.L = 0 end
    if i.KeyCode == Enum.KeyCode.D then Control.R = 0 end
    if i.KeyCode == Enum.KeyCode.Space then Control.U = 0 end
    if i.KeyCode == Enum.KeyCode.LeftControl then Control.D = 0 end
end)

--================ LOOP =================
RunService.RenderStepped:Connect(function()
    if not _G.FLY then return end

    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not (hum and hrp) then return end
    hum:ChangeState(Enum.HumanoidStateType.Physics)
    hum.AutoRotate = false

    if not BG then
        BG = Instance.new("BodyGyro")
        BG.P = 1e5
        BG.D = 500
        BG.MaxTorque = Vector3.new(9e9,9e9,9e9)
        BG.Parent = hrp
    end

    if not BV then
        BV = Instance.new("BodyVelocity")
        BV.MaxForce = Vector3.new(9e9,9e9,9e9)
        BV.P = 1e4
        BV.Parent = hrp
    end

    BG.CFrame = workspace.CurrentCamera.CFrame

    local cam = workspace.CurrentCamera
    local move =
        (cam.CFrame.LookVector * (Control.F - Control.B)) +
        (cam.CFrame.RightVector * (Control.R - Control.L)) +
        (Vector3.new(0,1,0) * (Control.U - Control.D))

    if move.Magnitude == 0 then
        BV.Velocity = Vector3.zero
    else
        BV.Velocity = move.Unit * _G.FLY_SPEED
    end
end)
