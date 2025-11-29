_G.FPSCAP = not _G.FPSCAP and 30 or _G.FPSCAP

setfpscap(_G.FPSCAP)
local Collection = {} ; Collection.__index = Collection
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ClientMonsters = Workspace:WaitForChild("ClientMonsters")
local fireclickdetector = getfenv().fireclickdetector or fireclickdetector

local MgrMonsterClient = require(ReplicatedStorage.ClientLogic.Monster.MgrMonsterClient)


local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("VeryFun Auto Farm Catch a Monster")


local Tab = Window:NewTab("Menu")
local Section = Tab:NewSection("Automatics")

local Mapinfo = {
    ["Ice Land"] = {
        ["Type"] = "Boss",
        ['Position'] = CFrame.new(  -2304, 42, -1420  ),
        ['MaxHealth'] = "1874304,0",
    },
    ["Volcano Land"] = {
        ["Type"] = "Boss",
        ['Position'] = CFrame.new(  -9, -116, -1539  ),
        ['MaxHealth'] = "3517630,-1",
    },
    ["Root Land"] = {
        ["Type"] = "Boss",
        -- ["Name"] = "Flarecrest",
        ['Position'] = CFrame.new(  814, 3485, -354  ),
        ['MaxHealth'] = "1564499.1,1",
    }
}

function Collection:getRoot(Character)
    return Character:WaitForChild("HumanoidRootPart")
end
function Collection:Teleport(Position)
    local Root = Collection:getRoot(LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait())
    if Root then
        Root.CFrame = typeof(Position) == "CFrame" and Position or CFrame.new(Position)
    end
end

function Collection:getBoss()
    for _,v in pairs(workspace.Monsters:GetChildren()) do
        if v['Health']:GetAttribute("MaxHealth") == Mapinfo[_G.SelectedBoss]['MaxHealth'] then
            Bossname = v
        end
    end
    return Bossname
end
local listMonster = {
    'Leafet',
    'Treemo',
    'Flamix',
    'Puffu',
    'Wattoad',
    'Aquron',
    'Skedeer',
    'Blazelord',
    'Pyrowulf',
    'Frostoise',
    'Woodliz',
    'Flarecub',
    'Frostoise',
    'Fluffairy',
    'Icevolf',
    'Sproutusk',
}
local monsterData = {}
function Collection:RefreshMonsterList()
    table.clear(listMonster)
    table.clear(monsterData)
    
    MgrMonsterClient.IterMonster(function(monsterInfo)
        local monsterName = monsterInfo.Config.Name
        local monsterId = monsterInfo.MonsterId
        
        if not table.find(listMonster, monsterName) then
            table.insert(listMonster, monsterName)
        end
        
        if not monsterData[monsterName] then
            monsterData[monsterName] = {
                Name = monsterName,
                Config = monsterInfo.Config,
                Instances = {}
            }
        end
        
        table.insert(monsterData[monsterName].Instances, {
            MonsterId = monsterId,
            Info = monsterInfo
        })
        
        return true
    end)
    if mobdropdown then
        mobdropdown:Refresh(listMonster)
    end
end
function Collection:getAllAliveMonsterIdsByName(monsterName)
    local data = monsterData[monsterName]
    if not data or #data.Instances == 0 then
        return {}
    end
    
    local aliveIds = {}
    
    for _, instance in ipairs(data.Instances) do
        if instance.Info and instance.Info:IsAlive() then
            table.insert(aliveIds, "Monster_" .. tostring(instance.MonsterId))
        end
    end
    
    return aliveIds
end
label = Section:NewLabel("Position: N/A")
Section:NewSlider("Set Fps", "Spin Delay Position", 120, 5, function(s) -- 500 (MaxValue) | 0 (MinValue)
    _G.FPSCAP = s
end)
game:GetService("RunService").RenderStepped:Connect(function()
	setfpscap(_G.FPSCAP)
    wait(3)
end)
Section:NewButton("Set Position", "ButtonInfo", function()
    _G.SetPosition = Collection:getRoot(LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()).CFrame
    wait()
    label:UpdateLabel("Position: "..math.floor(_G.SetPosition.X)..", "..math.floor(_G.SetPosition.Y)..", "..math.floor(_G.SetPosition.Z))
end)
Section:NewDropdown("SetFarm Mobs", "Selected Mobs to farm",listMonster, function(v)
    _G.SelectedMonster = v
end)
_G.SpinPositionFindBossDelay = 10
Section:NewSlider("Spin Delay", "Spin Delay Position", 10, 1, function(s) -- 500 (MaxValue) | 0 (MinValue)
    _G.SpinPositionFindBossDelay = s
end)
Section:NewToggle("Spin Position Boss", "auto farm boss", function(state)
    _G.SpinPositionFindBoss = state
    while (_G.SpinPositionFindBoss and task.wait() ) do
        local foundboss = false
        if _G.SetPosition == nil then
            game.StarterGui:SetCore("SendNotification", {
                Title = "!! Error !!",
                Text = "Please set spin position first!",
                Duration = 5
            })
            _G.SpinPositionFindBoss = false
            return 
        end
        for _, pos in pairs(Mapinfo) do
            Collection:Teleport(pos.Position)
            task.wait(2)
            Collection:RefreshMonsterList()
            local bossCheck = {}
            for _, name in ipairs({"Flarecrest", "Glazadon", "Flaragon"}) do
                local ids = Collection:getAllAliveMonsterIdsByName(name)
                if ids then
                    for _, id in pairs(ids) do
                        table.insert(bossCheck, id)
                    end
                end
            end
            if #bossCheck > 0 then
                foundBoss = true
                break
            end
        end
        if not foundBoss then
            if _G.SpinPosition then
                Collection:Teleport(_G.SpinPosition)
            end

            task.wait(_G.SpinPositionFindBossDelay or 10)
        else
            break
        end
    end
end)
Section:NewToggle('Auto Farm Mobs', "auto farm mob", function(state)
    _G.AutoFarmMobs = state
    while (_G.AutoFarmMobs and task.wait()) do
        Collection:RefreshMonsterList()
        local success, err = pcall(function()
            local bossExists = {}
            for _, name in ipairs({"Flarecrest", "Glazadon", "Flaragon"}) do
                local ids = Collection:getAllAliveMonsterIdsByName(name)
                if ids then
                    for _, id in pairs(ids) do
                        table.insert(bossExists, id)
                    end
                end
            end
            if #bossExists == 0 then bossExists = nil end
            if not bossExists then
                local ids = Collection:getAllAliveMonsterIdsByName(_G.SelectedMonster)
                if ids and #ids > 0 then
                    for _, v in pairs(ClientMonsters:GetChildren()) do
                        if table.find(ids, v.Name) then
                            local health = v:FindFirstChild("Health")
                            repeat wait()
                                local root = v:FindFirstChild("Root")
                                if root then
                                    local clickDetector = root:FindFirstChild("ClickDetector")
                                    if clickDetector then
                                        if LocalPlayer:DistanceFromCharacter(root.Position) > 20 then
                                            Collection:Teleport(root.Position)
                                            task.wait(0.5)
                                        end
                                        clickDetector.MaxActivationDistance = 1000
                                        fireclickdetector(clickDetector)
                                        task.wait(1)
                                    end
                                end
                            until not (v and v.Parent and v.Root and v.Root:FindFirstChild("ClickDetector") and v.Root.ClickDetector) or not _G.AutoFarmMobs or _G.PathTool.LogicNumber.LessThanOrEqualTo(
                                    _G.PathTool.LogicNumber.FixLogicNumber(health.Value), 0
                                )
                        end
                    end
                end
            end
        end)
        if err then
            print("Error in mob event: ", err)
        end 
    end
end)
Section:NewToggle("Auto Farm Boss", "auto farm boss", function(state)
    _G.AutoFarmBoss = state
    while (_G.AutoFarmBoss and task.wait()) do
        Collection:RefreshMonsterList()
        local success, err = pcall(function()
            local bossExists = {}
            for _, name in ipairs({"Flarecrest", "Glazadon", "Flaragon"}) do
                local ids = Collection:getAllAliveMonsterIdsByName(name)
                if ids then
                    for _, id in pairs(ids) do
                        table.insert(bossExists, id)
                    end
                end
            end
            if #bossExists == 0 then bossExists = nil end
            if bossExists then
                for _, v in pairs(ClientMonsters:GetChildren()) do
                    if table.find(bossExists, v.Name) then
                        local health = v:FindFirstChild("Health")
                        repeat wait()
                            local root = v:FindFirstChild("Root")
                            if root then
                                local clickDetector = root:FindFirstChild("ClickDetector")
                                if clickDetector then
                                    if LocalPlayer:DistanceFromCharacter(root.Position) > 20 then
                                        Collection:Teleport(root.Position)
                                        task.wait(0.5)
                                    end
                                    clickDetector.MaxActivationDistance = 1000
                                    fireclickdetector(clickDetector)
                                    task.wait(1)
                                end
                            end
                        until not (v and v.Parent and v.Root and v.Root:FindFirstChild("ClickDetector") and v.Root.ClickDetector) or not _G.AutoFarmBoss or _G.PathTool.LogicNumber.LessThanOrEqualTo(
                                    _G.PathTool.LogicNumber.FixLogicNumber(health.Value), 0
                                )
                    end
                end
            end
        end)
        if err then
            print("Error in boss event: ", err)
        end 
    end
end)
function Collection:UseEvent(Key)
    local VirtualInputManager = game:GetService("VirtualInputManager")
    VirtualInputManager:SendKeyEvent(true, Key, false, game)
    VirtualInputManager:SendKeyEvent(false, Key, false, game)
end
Section:NewToggle('Auto Collect Drops', "auto collect drops", function(state)
    _G.AutoCollectDrops = state
    while (_G.AutoCollectDrops and task.wait()) do
        if LocalPlayer:FindFirstChild('PlayerGui') and LocalPlayer.PlayerGui:FindFirstChild('CatchDoGui') then
            Collection:UseEvent("E")
        end
    end
end)

local Section2 = Tab:NewSection("Teleoports")
Section2:NewButton("Root Island", "ButtonInfo", function()
    Collection:Teleport(CFrame.new(  150, -95, 390  ))
    wait()
    Collection:RefreshMonsterList()
end)
Section2:NewButton("New Island", "ButtonInfo", function()
    Collection:Teleport(CFrame.new(  814, 3485, -354  ))
    wait()
    Collection:RefreshMonsterList()
end)
Section2:NewButton("Ice Island", "ButtonInfo", function()
    Collection:Teleport(CFrame.new( -2304, 42, -1420  ))
    wait()
    Collection:RefreshMonsterList()
end)
Section2:NewButton("Volcano Island", "ButtonInfo", function()
    Collection:Teleport(CFrame.new( -9, -116, -1539  ))
    wait()
    Collection:RefreshMonsterList()
end)
Section:NewKeybind("KeybindText", "KeybindInfo", Enum.KeyCode.F, function()
	Library:ToggleUI()
end)
local bb=game:service'VirtualUser'
game:service'Players'.LocalPlayer.Idled:connect(function()
    bb:CaptureController()
    bb:ClickButton2(Vector2.new())
end)
