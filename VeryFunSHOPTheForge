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

local ok, rawData = pcall(function()
    return game:HttpGet(HWID_URL)
end)

if ok and rawData then
    local loadFunc = loadstring(rawData)
    if loadFunc then
        local suc, result = pcall(loadFunc)
        if suc and type(result) == "table" then
            whitelistData = result
        end
    end
end

local function IsHWIDAllowed()
    for _, hw in ipairs(whitelistData) do
        if tostring(hw) == tostring(myHWID) then
            return true
        end
    end
    return false
end

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

    frame.Position = UDim2.new(0.5, -225, 0.5, 260)
    game.TweenService:Create(frame, TweenInfo.new(.4, Enum.EasingStyle.Back), {
        Position = UDim2.new(0.5, -225, 0.5, -130)
    }):Play()

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

    local hwidLabel = Instance.new("TextLabel", frame)
    hwidLabel.Size = UDim2.new(1, -20, 0, 80)
    hwidLabel.Position = UDim2.new(0, 10, 0, 60)
    hwidLabel.BackgroundTransparency = 1
    hwidLabel.Font = Enum.Font.Gotham
    hwidLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    hwidLabel.TextSize = 16
    hwidLabel.TextWrapped = true
    hwidLabel.Text = "HWID ของคุณ:\n" .. myHWID

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

if not IsHWIDAllowed() then
    ShowHWIDScreen()
    return
end



-- VeryFun | The Forge

if not game:IsLoaded() then
	repeat
		task.wait()
	until game:IsLoaded()
end

local cloneref = function(...)
	return ...
end

local Missing = function(t, f, fallback)
	return type(f) == t and f or fallback
end

local cloneref = Missing("function",cloneref,function(...)
	return ...
end)

local Service = setmetatable({},{__index = function(self, name)
	return cloneref(game:GetService(name))
end})

do 
	ReplicatedStorage = Service.ReplicatedStorage
	Players = Service.Players
	StarterGui = Service.StarterGui


	Client = Players.LocalPlayer
	Character = Client.Character or Client.CharacterAdded:Wait()
	Humanoid = Character:WaitForChild("Humanoid")
	RootPart = Character:WaitForChild("HumanoidRootPart")
	UserId = Client.UserId
	PlayerGui = Client:WaitForChild("PlayerGui")
	Backpack = Client:WaitForChild("Backpack")

	DataRock = require(ReplicatedStorage.Shared.Data.Rock)
	Inventory = require(ReplicatedStorage.Controllers.UIController.Inventory)
	Notification = require(ReplicatedStorage.Controllers.UIController.Notifications)
	ForgeController = require(ReplicatedStorage.Controllers.ForgeController)
	Knit = require(ReplicatedStorage.Shared.Packages.Knit)

	Rocks = workspace.Rocks
	Proximity = workspace.Proximity

	func = {}
	RockName = {}
end

local game = game
if typeof(game) ~= "Instance" then
	game = workspace.Parent
end

local function c() return _G end

do 
	do 
		for i in pairs(DataRock) do 
			table.insert(RockName, i)
		end
	end

	do
		for _, conn in pairs(getconnections(Client.Idled)) do
			if conn.Disable then
				conn:Disable()
			elseif conn.Disconnect then
				conn:Disconnect()
			end
		end
	end
end

Client.CharacterAdded:Connect(function(newCharacter)
	Character = newCharacter
	Humanoid = Character:WaitForChild("Humanoid")
	RootPart = Character:WaitForChild("HumanoidRootPart")
	Backpack = Client:WaitForChild("Backpack")

	if c().NSF then 
		pcall(function()
			setfflag("NextGenReplicatorEnabledWrite4", "false")
			task.wait(1)
			setfflag("NextGenReplicatorEnabledWrite4", "true")
		end)
		c().NSF = false
	end
end)

local RockName = {} for _,v in pairs(DataRock) do table.insert(RockName, _) end table.sort(RockName)

local function GetDistanceRoot(Objective)
	if typeof(Objective) == "Instance" then
		if Objective:IsA("BasePart") then
			return (Objective.Position - RootPart.Position).Magnitude
		else
			return 0
		end
	elseif typeof(Objective) == "Vector3" then
		return (Objective - RootPart.Position).Magnitude
	elseif typeof(Objective) == "CFrame" then 
		return (Objective.Position - RootPart.Position).Magnitude
	end
	return 0
end

local function GetAllRocks()
	local rocks = {}
	for i,v in pairs(Rocks:GetChildren()) do
		for _,x in pairs(v:GetChildren()) do
			if x:IsA("BasePart") and x.Name == "SpawnLocation" then
				if x:FindFirstChildOfClass('Model') then 
					table.insert(rocks, x:FindFirstChildOfClass('Model'))
				end
			end
		end
	end
	return rocks
end

local function InRaya(Path, contion)
	local ClosestTarget = nil
	local ShortestDistance = math.huge

	for _, Object in pairs(Path) do
		if contion(Object) then
			local Distance = (Object:GetPivot().Position - RootPart.Position).Magnitude
			if Distance < ShortestDistance then
				ShortestDistance = Distance
				ClosestTarget = Object
			end
		end
	end

	return ClosestTarget
end

local function GetAllInventoryItems()
	local items = {}
	for i,v in pairs(PlayerGui.Menu.Frame.Frame.Menus.Stash.Background:GetChildren()) do
		if v.Name ~= 'UIGridLayout' then 
			local Name = v.Name
			local Quantity = tostring(v.Main.Quantity.Text):gsub('x','') or 1
			table.insert(items, {Name = Name, Quantity = tonumber(Quantity)})
		end
	end
	return items
end

local function Teleport(targetCF)
	local startCF = RootPart:GetPivot()
	local startPos = startCF.Position
	local targetPos = targetCF.Position
	local dir = (targetPos - startPos)
	local dist = dir.Magnitude
	if dist == 0 then RootPart:PivotTo(targetCF) return end
	dir = dir.Unit
	local movedDist = 0
	local speed = 90
	local startTime = tick()
	while movedDist < dist and not _G['StopTween'] do
		local elapsed = tick() - startTime
		movedDist = math.min(elapsed * speed, dist)
		local pos = startPos + dir * movedDist
		RootPart:PivotTo(CFrame.new(pos) * (targetCF - targetCF.Position))
		for _, v in ipairs(Character:GetDescendants()) do
			if v:IsA("BasePart") then
				v.AssemblyLinearVelocity = Vector3.zero
				v.AssemblyAngularVelocity = Vector3.zero
				v.Velocity = Vector3.zero
			end
		end
		task.wait()
	end
	RootPart:PivotTo(targetCF)
end

local function ForceStopTween()
	_G['StopTween'] = true
	task.wait()
	_G['StopTween'] = false
end

local function EquipTool(s)
	if Backpack:FindFirstChild(s) then Humanoid:EquipTool(Backpack:FindFirstChild(s)) end
end

local function GetData()
	local hrp = {}
	function hrp:Ore()
		local all = {}
		for i,v in pairs(ReplicatedStorage.Assets.Ores:GetChildren()) do
			table.insert(all, v.Name)
		end	
		return all
	end
	return hrp
end

local function RunCommand(...)
    local args = {...}
    return ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("DialogueService"):WaitForChild("RF"):WaitForChild("RunCommand"):InvokeServer(unpack(args))
end

local function AutoKudAndAttack()
	ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("ToolService"):WaitForChild("RF"):WaitForChild("ToolActivated"):InvokeServer('Pickaxe')
	if Backpack:FindFirstChild('Weapon') then 
		for i,v in pairs(workspace.Living:GetChildren()) do
			if v:FindFirstChild('Humanoid') and v:FindFirstChild('HumanoidRootPart') and not Players:FindFirstChild(v.Name) then
				if GetDistanceRoot(v:FindFirstChild('HumanoidRootPart')) <= 6 then
					ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("ToolService"):WaitForChild("RF"):WaitForChild("ToolActivated"):InvokeServer('Weapon')
				end
			end
		end
	end
end

local function Lookat_Pos(yoon,mong) return CFrame.lookAt(yoon, mong) end

func['Auto_Mine'] = function()
	while task.wait() do
		pcall(function()
			if c().Auto_Mine then 
				if Inventory:CalculateTotal("Stash") < Inventory:GetBagCapacity() then 
					local rock = InRaya(GetAllRocks(), function(rock)
						return table.find(c().Rock_List,rock.Name) and rock:GetAttribute('Health') > 0
					end)

					if rock then
						repeat task.wait()
							if GetDistanceRoot(rock.Hitbox) > 4 then
								RootPart.Anchored = false
								Teleport(rock.Hitbox.CFrame * CFrame.new(0, -3.250, 0) * CFrame.Angles(math.rad(90), 0, 0))
							else 
								RootPart.Anchored = true
								AutoKudAndAttack()
							end
						until rock:GetAttribute('Health') <= 0 or not c().Auto_Mine
						RootPart.Anchored = false
					end
				else 
					if c().Auto_Sell then 
						repeat task.wait()
							local seller = Proximity:FindFirstChild("Greedy Cey")
							if seller and GetDistanceRoot(seller.HumanoidRootPart) > 9 then
								Teleport(seller.HumanoidRootPart.CFrame)
							else 
								local basket = {}
								for i,v in pairs(GetAllInventoryItems()) do
									for _,oreName in pairs(GetData():Ore()) do
										if string.find(v.Name, oreName) then
											basket[v.Name] = v.Quantity
										end
									end
								end

								fireproximityprompt(seller:FindFirstChild('ProximityPrompt'))
								RunCommand("SellConfirm", {Basket = basket})
								ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("DialogueService"):WaitForChild("RE"):WaitForChild("DialogueEvent"):FireServer("Closed")
							end
						until Inventory:CalculateTotal("Stash") < Inventory:GetBagCapacity() or not c().Auto_Sell or not c().Auto_Mine
					else 
						Notification:Notify({
							Title = "VeryFun | The Forge",
							Text = "Your stash is full!",
							Duration = 5,
							Sound = "Item Notification",
						})
						task.wait(1)
					end
				end
			else
				RootPart.Anchored = false
				ForceStopTween()
			end
		end)
	end
end

func['Auto_Forge'] = function()
	pcall(function()
		while task.wait() do
			if c().Auto_Forge then 
				if PlayerGui.Forge and PlayerGui.Forge.Enabled then
					if PlayerGui.Forge.MeltMinigame.Visible then 
						ForgeController:ChangeSequence("Pour", {
							ClientTime = workspace:GetServerTimeNow(),
							InContact = true
						})
						PlayerGui.Forge.MeltMinigame.Visible = false
					elseif PlayerGui.Forge.PourMinigame.Visible then 
						ForgeController:ChangeSequence("Hammer", {
							ClientTime = workspace:GetServerTimeNow(),
							InContact = true
						})
						PlayerGui.Forge.PourMinigame.Visible = false
					elseif workspace:FindFirstChild('Debris'):FindFirstChild('Mold') and workspace:FindFirstChild('Debris'):FindFirstChild('Mold'):FindFirstChild('ClickDetector') then 
						fireclickdetector(workspace:FindFirstChild('Debris'):FindFirstChild('Mold'):FindFirstChild('ClickDetector'))	
					elseif PlayerGui.Forge.HammerMinigame:FindFirstChild('Frame') and PlayerGui.Forge.HammerMinigame:FindFirstChild('Frame').Frame.ImageColor3 == Color3.fromRGB(72, 108, 72) then
						firesignal(PlayerGui.Forge.HammerMinigame.Frame.MouseButton1Click)
					elseif Knit.GetController("ForgeController").Sequence == "Showcase" then 
						ForgeController:ChangeSequence("Close", {
							ClientTime = workspace:GetServerTimeNow(),
							InContact = true
						})
						PlayerGui.Forge.Enabled = false
						Knit.GetController("ForgeController"):ChangeSequence('Close')
						ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("ForgeService"):WaitForChild("RF"):WaitForChild("EndForge"):InvokeServer()
						Knit.GetController("ForgeController"):EndForge()
					end
				else 
					workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
					workspace.CurrentCamera.FieldOfView = 70
				end
			end
		end
	end)
end

local Library_Tool = loadstring(game:HttpGet("https://raw.githubusercontent.com/Yenixs/VeryFun/refs/heads/main/Library_Tool.luau"))() Library_Tool.SC()
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Window = WindUI:CreateWindow({
	Title = "VeryFun | The Forge",
	Icon = "github",
	Author = "By #pow",
	Folder = "VeryFun",
	Size = UDim2.fromOffset(400, 400),
	Theme = "Dark",
	Transparent = true,
	Resizable = true,
	OpenButton = {
		Title = "VeryFun",
		CornerRadius = UDim.new(1,0),
		StrokeThickness = 3,
		Enabled = true,
		Draggable = true,
		OnlyMobile = false,

		Color = ColorSequence.new(Color3.fromRGB(50, 168, 131),Color3.fromRGB(50, 168, 131))
	},
})

local Tabs = {
	General = Window:Tab({Title = "General", Icon = "library"}),
}

Tabs.General:Select()

local function Section(Tab,Text)
	local Section = Tab:Section({ 
		Title = Text,
		Box = false,
		TextSize = 17,
		Opened = true,
	})
	return Section
end

local function Tg(def,Tab,Description,Title,Keys,Callback)
	local taskThread
	local toggle = Tab:Toggle({
		Title = Title,
		Desc = Description,
		Value = c()[Keys] or def,
		Callback = function(state)
			Library_Tool.S()[Keys] = state
			c()[Keys] = state
			if Callback and typeof(Callback) == "function" then
				Callback(state)
			end
			if not state then 
				if taskThread then
					cancel(taskThread)
					taskThread = nil
				end
			end

			if state then 
				if func[Keys] then
					taskThread = task.spawn(function() func[Keys]() end)
				end
			end
			Library_Tool.SG()
		end
	})
	if toggle then toggle.Callback(c()[Keys]) end
	return toggle 
end

local function Slider(Tab,Title,Steps,Mins,Maxs,Def,Keys)
	local slider = Tab:Slider({
		Flag = Title,
		Title = Title,
		Step = Steps,
		Value = {
			Min = Mins,
			Max = Maxs,
			Default = c()[Keys] or Def,
		},
		Callback = function(value)
			Library_Tool.S()[Keys] = value 
			c()[Keys] = value 
			Library_Tool.SG()
		end
	})
	if slider then slider.Callback(c()[Keys] or Def) end
	return slider
end

local function Input(Tab, Title, Keys)
	local input = Tab:Input({
		Title = Title,
		Type = "Input",
		Placeholder = "Enter here...",
		Callback = function(value)
			Library_Tool.S()[Keys] = value
			c()[Keys] = value
			Library_Tool.SG()
		end
	})
	return input
end

local function Dropdown(Tab, Title, Keys, Values, Multi)
	local dropdown = Tab:Dropdown({
		Title = Title,
		Values = Values or {"nigger","Back"},
		Multi = Multi or false,
		AllowNone = false, 
		Value = c()[Keys] or Values[1], 
		Callback = function(option)
			Library_Tool.S()[Keys] = option
			c()[Keys] = option
			Library_Tool.SG()
		end
	})
	if dropdown and dropdown.Callback then
		dropdown.Callback(c()[Keys] or (Multi and {} or Values[1]))
	end
	return dropdown
end

local function Button(Tab, Title, Desc, Callback)
	local button = Tab:Button({
		Title = Title,
		Desc = Desc,
		Locked = false,
		Callback = function()
			if Callback then Callback() end
		end
	})

	return button
end

do 
	local Mining = Section(Tabs.General, "Mining")
	Dropdown(Mining, "Rock Target List", "Rock_List", RockName, true)
	Tg(false, Mining, "Automatically to mine for you.", "Auto Mine", "Auto_Mine", function(v) 
		c().NeedVelocity = v
	end)
	Tg(false, Mining, "Automatic Selling of mined rocks when your stash is full.", "Auto Sell", "Auto_Sell")
	local AutoForge = Section(Tabs.General, "Auto Forge")
	Tg(false, AutoForge, "Automatically to forge for you.", "Auto Forge", "Auto_Forge")

	local Miscellaneous = Section(Tabs.General, "Miscellaneous")
	Button(Miscellaneous, "Desync", "Your Character will not update in other player.", function() 
		pcall(function()
			setfflag("NextGenReplicatorEnabledWrite4", "false")
			task.wait(1)
			setfflag("NextGenReplicatorEnabledWrite4", "true")
		end)
		task.wait()
		replicatesignal(Client.Kill)
		c().NSF = true
	end)
end

task.spawn(function()
	while task.wait(1) do 
		for _, track in pairs(Humanoid:GetPlayingAnimationTracks()) do
			if c().Auto_Mine then
				track:Stop()
			end
		end
		if c().NeedVelocity then
			for i,v in pairs(Character:GetChildren()) do
				if v:IsA("BasePart") then 
					v.Velocity = Vector3.zero
					v.AssemblyLinearVelocity = Vector3.zero
					v.RotVelocity = Vector3.zero
					v.AssemblyAngularVelocity = Vector3.zero
					v.CanCollide = false
				end
			end
			if not RootPart:FindFirstChild('BodyVelocity') then 
				local bv = Instance.new('BodyVelocity')
				bv.Velocity = Vector3.zero
				bv.MaxForce = Vector3.new(9999999999999999,9999999999999999,9999999999999999)
				bv.Parent = RootPart
			end
		else
			for i,v in pairs(Character:GetChildren()) do
				if v:IsA("BasePart") then 
					v.CanCollide = true
				end
			end
			if RootPart:FindFirstChild('BodyVelocity') then 
				RootPart:FindFirstChild('BodyVelocity'):Destroy()
			end
		end
	end
end)
