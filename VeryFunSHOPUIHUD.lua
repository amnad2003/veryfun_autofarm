--========================================================--
-- VeryFunSHOP UI HUD | Premium Dark Version
--========================================================--

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local UI_NAME = "VeryFunSHOP_UI"

-- Destroy existing UI
pcall(function()
	if CoreGui:FindFirstChild(UI_NAME) then
		CoreGui[UI_NAME]:Destroy()
	end
end)

--================ THEME =================--
local THEMES = {
	Dark   = {bg=Color3.fromRGB(18,18,22), sidebar=Color3.fromRGB(24,24,30), card=Color3.fromRGB(32,32,40), accent=Color3.fromRGB(0,170,255), text=Color3.fromRGB(235,235,235), subtext=Color3.fromRGB(160,160,160)},
	Mint   = {bg=Color3.fromHex("#0F1720"), accent=Color3.fromHex("#1F2937"), highlight=Color3.fromHex("#66FFCC")},
	Red    = {bg=Color3.fromHex("#0F0A0A"), accent=Color3.fromHex("#241111"), highlight=Color3.fromHex("#FF5C5C")},
	Blue   = {bg=Color3.fromHex("#071022"), accent=Color3.fromHex("#0E2438"), highlight=Color3.fromHex("#7FB3FF")},
	Gold   = {bg=Color3.fromHex("#0B0B06"), accent=Color3.fromHex("#2A260F"), highlight=Color3.fromHex("#FFC857")},
	Pink   = {bg=Color3.fromHex("#140A12"), accent=Color3.fromHex("#2B1022"), highlight=Color3.fromHex("#FF7AD9")},
	Purple = {bg=Color3.fromHex("#0E0A18"), accent=Color3.fromHex("#1C1333"), highlight=Color3.fromHex("#B388FF")}
}

local function corner(o,r)
	local c = Instance.new("UICorner",o)
	c.CornerRadius = UDim.new(0,r or 8)
end

local Library = {}

function Library:Create(cfg)
	cfg = cfg or {}
	local Theme = THEMES[cfg.Theme] or THEMES.Dark
	local ToggleKey = cfg.ToggleKey or Enum.KeyCode.RightControl
	local ToggleLogo = cfg.ToggleLogo
	local TogglePosition = cfg.TogglePosition or UDim2.new(0,20,0.5,-22)

	local GUI = Instance.new("ScreenGui", CoreGui)
	GUI.Name = UI_NAME
	GUI.ResetOnSpawn = false

	--================ MAIN FRAME =================--
	local Main = Instance.new("Frame", GUI)
	Main.Size = UDim2.new(0,760,0,500)
	Main.Position = UDim2.new(0.5,0,0.5,0)
	Main.AnchorPoint = Vector2.new(0.5,0.5)
	Main.BackgroundColor3 = Theme.bg
	corner(Main,14)

	--================ TOP BAR =================--
	local Top = Instance.new("Frame", Main)
	Top.Size = UDim2.new(1,0,0,48)
	Top.BackgroundColor3 = Theme.card or Theme.accent
	corner(Top,14)

	local Title = Instance.new("TextLabel", Top)
	Title.Size = UDim2.new(1,-80,1,0)
	Title.Position = UDim2.new(0,16,0,0)
	Title.BackgroundTransparency = 1
	Title.Text = cfg.Title or "VeryFunSHOP UI"
	Title.Font = Enum.Font.GothamBold
	Title.TextSize = 16
	Title.TextColor3 = Theme.text
	Title.TextXAlignment = Enum.TextXAlignment.Left

	local Close = Instance.new("TextButton", Top)
	Close.Size = UDim2.new(0,36,0,36)
	Close.Position = UDim2.new(1,-44,0.5,-18)
	Close.Text = "✕"
	Close.Font = Enum.Font.GothamBold
	Close.TextSize = 16
	Close.BackgroundColor3 = Theme.card
	Close.TextColor3 = Theme.subtext
	corner(Close,8)

	Close.MouseButton1Click:Connect(function()
		GUI:Destroy()
	end)

	--================ SIDEBAR =================--
	local Sidebar = Instance.new("Frame", Main)
	Sidebar.Size = UDim2.new(0,180,1,-58)
	Sidebar.Position = UDim2.new(0,0,0,58)
	Sidebar.BackgroundColor3 = Theme.sidebar
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

	-- ToggleKey support
	UIS.InputBegan:Connect(function(i,gp)
		if not gp and i.KeyCode == ToggleKey then
			Window:Toggle()
		end
	end)

	-- ToggleLogo support
	if ToggleLogo then
		local Logo = Instance.new("ImageButton", GUI)
		Logo.Size = UDim2.new(0,44,0,44)
		Logo.Position = TogglePosition
		Logo.Image = ToggleLogo
		Logo.BackgroundColor3 = Theme.accent
		corner(Logo,12)

		Logo.MouseButton1Click:Connect(function()
			Window:Toggle()
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
		Btn.BackgroundColor3 = Theme.card
		Btn.TextColor3 = Theme.text
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
				t.Btn.BackgroundColor3 = Theme.card
			end
			Page.Visible = true
			Btn.BackgroundColor3 = Theme.accent
		end)

		if #Tabs == 0 then
			Page.Visible = true
			Btn.BackgroundColor3 = Theme.accent
		end

		table.insert(Tabs,{Btn=Btn,Page=Page})

		local Tab = {}

		function Tab:Section(title)
			local Box = Instance.new("Frame", Page)
			Box.Size = UDim2.new(1,-10,0,40)
			Box.BackgroundColor3 = Theme.card
			corner(Box,10)

			local L = Instance.new("TextLabel", Box)
			L.Size = UDim2.new(1,-20,0,30)
			L.Position = UDim2.new(0,10,0,5)
			L.BackgroundTransparency = 1
			L.Text = title
			L.Font = Enum.Font.GothamBold
			L.TextSize = 14
			L.TextColor3 = Theme.accent
			L.TextXAlignment = Enum.TextXAlignment.Left

			local Section = {}

			function Section:Button(text, cb)
				local B = Instance.new("TextButton", Page)
				B.Size = UDim2.new(1,-10,0,36)
				B.Text = text
				B.Font = Enum.Font.Gotham
				B.TextSize = 14
				B.BackgroundColor3 = Theme.card
				B.TextColor3 = Theme.text
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
				T.BackgroundColor3 = Theme.card
				T.TextColor3 = Theme.text
				corner(T,8)

				local OptionFrame = Instance.new("Frame", Page)
				OptionFrame.Size = UDim2.new(1,-20,0,0)
				OptionFrame.Position = UDim2.new(0,10,0,0)
				OptionFrame.BackgroundTransparency = 1
				OptionFrame.Visible = false

				local function refresh()
					T.Text = text.." : "..(state and "ON" or "OFF")
					OptionFrame.Visible = state
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
				S.BackgroundColor3 = Theme.card
				S.TextColor3 = Theme.text
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

return Library
