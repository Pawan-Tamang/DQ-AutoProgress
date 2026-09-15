-- ====================== Dungeon Quest AutoProgress ======================
-- Kuya-style Manager GUI

task.spawn(function()
	if not game:IsLoaded() then
		repeat task.wait() until game:IsLoaded()
	end
	task.wait(2)

	local Players = game:GetService("Players")
	local RS = game:GetService("ReplicatedStorage")
	local TeleportService = game:GetService("TeleportService")
	local LP = Players.LocalPlayer or Players.PlayerAdded:Wait()
	local PlayerGui = LP:FindFirstChild("PlayerGui") or LP:WaitForChild("PlayerGui", 15)
	if not PlayerGui then return end

	local Settings = {
		HostName = "kurokazahood",
		RequiredPlayers = {"royaldancersss"},
		AutoBest = true,
		Hardcore = true,
		Private = false,
		WaitForMembers = true,
		AutoAccept = true,
		WaitTimeout = 45,
		CreateDelay = 2,
		CheckInterval = 2,
	}

	local DUNGEON_PROGRESSION = {
		{name = "Desert Temple",   minLevel = 1,   difficulty = "Easy"},
		{name = "Desert Temple",   minLevel = 6,   difficulty = "Medium"},
		{name = "Desert Temple",   minLevel = 12,  difficulty = "Hard"},
		{name = "Desert Temple",   minLevel = 20,  difficulty = "Insane"},
		{name = "Desert Temple",   minLevel = 27,  difficulty = "Nightmare"},
		{name = "Winter Outpost",  minLevel = 30,  difficulty = "Insane"},
		{name = "Winter Outpost",  minLevel = 55,  difficulty = "Nightmare"},
		{name = "Pirate Island",   minLevel = 60,  difficulty = "Insane"},
		{name = "Pirate Island",   minLevel = 65,  difficulty = "Nightmare"},
		{name = "King's Castle",   minLevel = 70,  difficulty = "Insane"},
		{name = "King's Castle",   minLevel = 75,  difficulty = "Nightmare"},
		{name = "The Underworld",  minLevel = 80,  difficulty = "Insane"},
		{name = "The Underworld",  minLevel = 85,  difficulty = "Nightmare"},
		{name = "Samurai Palace",  minLevel = 90,  difficulty = "Insane"},
		{name = "Samurai Palace",  minLevel = 110, difficulty = "Nightmare"},
		{name = "Northern Lands",  minLevel = 180, difficulty = "Insane"},
		{name = "Northern Lands",  minLevel = 185, difficulty = "Nightmare"},
	}

	local State = "Idle"
	local running = true

	local function getRemotes()
		local ok, remotes = pcall(function()
			return RS:WaitForChild("remotes", 8)
		end)
		return ok and remotes or RS:FindFirstChild("remotes")
	end

	local function getPlayerLevel()
		local ls = LP:FindFirstChild("leaderstats")
		if ls and ls:FindFirstChild("Level") then
			return ls.Level.Value
		end
		return 1
	end

	local function parseMembers(text)
		local list = {}
		for name in string.gmatch(text or "", "[^,%s]+") do
			table.insert(list, name)
		end
		return list
	end

	local function getCurrentDungeon()
		local level = getPlayerLevel()
		local current = DUNGEON_PROGRESSION[1]
		if Settings.AutoBest then
			for _, d in ipairs(DUNGEON_PROGRESSION) do
				if level >= d.minLevel then
					current = d
				else
					break
				end
			end
		end
		return current
	end

	local function fireRemote(names, method, ...)
		local remotes = getRemotes()
		if not remotes then return false end
		for _, name in ipairs(names) do
			local remote = remotes:FindFirstChild(name)
			if remote then
				local ok = pcall(function(...)
					if method == "Invoke" and remote:IsA("RemoteFunction") then
						remote:InvokeServer(...)
					else
						remote:FireServer(...)
					end
				end, ...)
				if ok then return true end
			end
		end
		return false
	end

	local function createLobby()
		local remotes = getRemotes()
		if not remotes then return false end
		local createRemote = remotes:FindFirstChild("createLobby")
		if not createRemote then return false end
		local dungeon = getCurrentDungeon()
		print(string.format("[Host] Creating: %s | %s | HC: %s | Private: %s | Level: %d",
			dungeon.name, dungeon.difficulty, tostring(Settings.Hardcore), tostring(Settings.Private), getPlayerLevel()))
		local ok = pcall(function()
			createRemote:InvokeServer(dungeon.name, dungeon.difficulty, 0, Settings.Hardcore, Settings.Private, false)
		end)
		return ok
	end

	local function startDungeon()
		fireRemote({"startDungeon"}, "Fire")
		print("[Host] Started dungeon")
	end

	local function allRequiredPlayersJoined()
		if not Settings.WaitForMembers then return true end
		if #Settings.RequiredPlayers == 0 then return true end
		for _, name in ipairs(Settings.RequiredPlayers) do
			local found = false
			local lower = name:lower()
			for _, p in ipairs(Players:GetPlayers()) do
				if p.Name:lower() == lower then
					found = true
					break
				end
			end
			if not found then return false end
		end
		return true
	end

	local function tryJoinHost()
		local remotes = getRemotes()
		if not remotes then return false end
		local joinRemote = remotes:FindFirstChild("joinDungeon")
		if not joinRemote then return false end
		local games = workspace:FindFirstChild("games")
		local inLobby = games and games:FindFirstChild("inLobby")
		if not inLobby then return false end
		local target = Settings.HostName:lower()
		for _, lobby in ipairs(inLobby:GetChildren()) do
			if lobby.Name:lower() == target then
				local ok = pcall(function()
					joinRemote:InvokeServer(lobby.Name)
				end)
				if ok then
					print("[Joiner] Joined", Settings.HostName)
					return true
				end
			end
		end
		return false
	end

	local function acceptJoinRequests()
		if not Settings.AutoAccept then return end
		fireRemote({"acceptRequest", "acceptJoin", "acceptJoinRequest", "acceptPlayer"}, "Fire")
		fireRemote({"acceptRequest", "acceptJoin", "acceptJoinRequest", "acceptPlayer"}, "Invoke")
	end

	local function returnToLobby()
		State = "Returning"
		local sent = fireRemote({"leaveDungeon", "returnToLobby", "leaveLobby", "exitDungeon"}, "Fire")
			or fireRemote({"leaveDungeon", "returnToLobby", "leaveLobby", "exitDungeon"}, "Invoke")
		if not sent then
			pcall(function()
				TeleportService:Teleport(game.PlaceId, LP)
			end)
		end
	end

	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "DQAutoProgress"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.Parent = PlayerGui

	local Window = Instance.new("Frame")
	Window.Size = UDim2.new(0, 720, 0, 430)
	Window.Position = UDim2.new(0.5, -360, 0.5, -215)
	Window.BackgroundColor3 = Color3.fromRGB(16, 16, 18)
	Window.BorderSizePixel = 0
	Window.Active = true
	Window.Draggable = true
	Window.Parent = ScreenGui
	Instance.new("UICorner", Window).CornerRadius = UDim.new(0, 8)

	local Top = Instance.new("Frame")
	Top.Size = UDim2.new(1, 0, 0, 42)
	Top.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
	Top.BorderSizePixel = 0
	Top.Parent = Window

	local Title = Instance.new("TextLabel")
	Title.Size = UDim2.new(0, 90, 1, 0)
	Title.BackgroundTransparency = 1
	Title.Text = "kuya"
	Title.TextColor3 = Color3.fromRGB(230, 230, 235)
	Title.Font = Enum.Font.Gotham
	Title.TextSize = 16
	Title.Parent = Top

	local Search = Instance.new("TextBox")
	Search.Size = UDim2.new(1, -180, 0, 26)
	Search.Position = UDim2.new(0, 90, 0.5, -13)
	Search.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
	Search.BorderSizePixel = 0
	Search.PlaceholderText = "Search"
	Search.Text = ""
	Search.TextColor3 = Color3.fromRGB(220, 220, 220)
	Search.PlaceholderColor3 = Color3.fromRGB(130, 130, 140)
	Search.Font = Enum.Font.Gotham
	Search.TextSize = 13
	Search.Parent = Top
	Instance.new("UICorner", Search).CornerRadius = UDim.new(0, 6)

	local Side = Instance.new("Frame")
	Side.Size = UDim2.new(0, 130, 1, -42)
	Side.Position = UDim2.new(0, 0, 0, 42)
	Side.BackgroundColor3 = Color3.fromRGB(14, 14, 16)
	Side.BorderSizePixel = 0
	Side.Parent = Window

	local function sideBtn(text, ypos, active)
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(1, -16, 0, 28)
		b.Position = UDim2.new(0, 8, 0, ypos)
		b.BackgroundTransparency = 1
		b.Text = text
		b.TextXAlignment = Enum.TextXAlignment.Left
		b.Font = Enum.Font.Gotham
		b.TextSize = 14
		b.TextColor3 = active and Color3.fromRGB(235, 235, 240) or Color3.fromRGB(140, 140, 150)
		b.Parent = Side
		return b
	end
	sideBtn("Main", 12, true)
	sideBtn("UI Settings", 42, false)

	local Content = Instance.new("Frame")
	Content.Size = UDim2.new(1, -300, 1, -42)
	Content.Position = UDim2.new(0, 130, 0, 42)
	Content.BackgroundColor3 = Color3.fromRGB(20, 20, 22)
	Content.BorderSizePixel = 0
	Content.Parent = Window

	local StatusPanel = Instance.new("Frame")
	StatusPanel.Size = UDim2.new(0, 170, 1, -42)
	StatusPanel.Position = UDim2.new(1, -170, 0, 42)
	StatusPanel.BackgroundColor3 = Color3.fromRGB(16, 16, 18)
	StatusPanel.BorderSizePixel = 0
	StatusPanel.Parent = Window

	local StatusTitle = Instance.new("TextLabel")
	StatusTitle.Size = UDim2.new(1, -16, 0, 24)
	StatusTitle.Position = UDim2.new(0, 8, 0, 8)
	StatusTitle.BackgroundTransparency = 1
	StatusTitle.Text = "Status"
	StatusTitle.TextXAlignment = Enum.TextXAlignment.Left
	StatusTitle.TextColor3 = Color3.fromRGB(230, 230, 235)
	StatusTitle.Font = Enum.Font.Gotham
	StatusTitle.TextSize = 14
	StatusTitle.Parent = StatusPanel

	local function statusLine(ypos)
		local l = Instance.new("TextLabel")
		l.Size = UDim2.new(1, -16, 0, 18)
		l.Position = UDim2.new(0, 8, 0, ypos)
		l.BackgroundTransparency = 1
		l.TextXAlignment = Enum.TextXAlignment.Left
		l.TextColor3 = Color3.fromRGB(170, 170, 180)
		l.Font = Enum.Font.Gotham
		l.TextSize = 12
		l.Parent = StatusPanel
		return l
	end
	local AccLabel = statusLine(36)
	local StateLabel = statusLine(56)
	local BestLabel = statusLine(76)
	local LevelLabel = statusLine(96)
	local ModeLabel = statusLine(116)

	local Header = Instance.new("TextLabel")
	Header.Size = UDim2.new(1, -20, 0, 24)
	Header.Position = UDim2.new(0, 12, 0, 8)
	Header.BackgroundTransparency = 1
	Header.Text = "Manager"
	Header.TextXAlignment = Enum.TextXAlignment.Left
	Header.TextColor3 = Color3.fromRGB(220, 220, 225)
	Header.Font = Enum.Font.Gotham
	Header.TextSize = 14
	Header.Parent = Content

	local y = 40
	local function addToggle(name, default)
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, -24, 0, 26)
		row.Position = UDim2.new(0, 12, 0, y)
		row.BackgroundTransparency = 1
		row.Parent = Content
		y += 28

		local lab = Instance.new("TextLabel")
		lab.Size = UDim2.new(1, -50, 1, 0)
		lab.BackgroundTransparency = 1
		lab.Text = name
		lab.TextXAlignment = Enum.TextXAlignment.Left
		lab.TextColor3 = Color3.fromRGB(200, 200, 210)
		lab.Font = Enum.Font.Gotham
		lab.TextSize = 13
		lab.Parent = row

		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0, 38, 0, 20)
		btn.Position = UDim2.new(1, -38, 0.5, -10)
		btn.BackgroundColor3 = default and Color3.fromRGB(140, 90, 255) or Color3.fromRGB(70, 70, 78)
		btn.Text = ""
		btn.BorderSizePixel = 0
		btn.Parent = row
		Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

		local knob = Instance.new("Frame")
		knob.Size = UDim2.new(0, 16, 0, 16)
		knob.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
		knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		knob.BorderSizePixel = 0
		knob.Parent = btn
		Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

		local state = default
		btn.MouseButton1Click:Connect(function()
			state = not state
			btn.BackgroundColor3 = state and Color3.fromRGB(140, 90, 255) or Color3.fromRGB(70, 70, 78)
			knob.Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
		end)
		return function() return state end
	end

	local getAutoBest = addToggle("Auto Best Dungeon", Settings.AutoBest)
	local getHardcore = addToggle("Hardcore Lobby", Settings.Hardcore)
	local getPrivate = addToggle("Private Lobby", Settings.Private)
	local getWaitMembers = addToggle("Wait For Members After restart", Settings.WaitForMembers)

	local timeoutLabel = Instance.new("TextLabel")
	timeoutLabel.Size = UDim2.new(1, -24, 0, 18)
	timeoutLabel.Position = UDim2.new(0, 12, 0, y)
	timeoutLabel.BackgroundTransparency = 1
	timeoutLabel.Text = "Member Rejoin Timeout (s)"
	timeoutLabel.TextXAlignment = Enum.TextXAlignment.Left
	timeoutLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
	timeoutLabel.Font = Enum.Font.Gotham
	timeoutLabel.TextSize = 13
	timeoutLabel.Parent = Content
	y += 20

	local sliderBg = Instance.new("Frame")
	sliderBg.Size = UDim2.new(1, -24, 0, 16)
	sliderBg.Position = UDim2.new(0, 12, 0, y)
	sliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 46)
	sliderBg.BorderSizePixel = 0
	sliderBg.Parent = Content
	Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(0, 4)
	y += 24

	local sliderFill = Instance.new("Frame")
	sliderFill.Size = UDim2.new(Settings.WaitTimeout / 120, 0, 1, 0)
	sliderFill.BackgroundColor3 = Color3.fromRGB(140, 90, 255)
	sliderFill.BorderSizePixel = 0
	sliderFill.Parent = sliderBg
	Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(0, 4)

	local sliderText = Instance.new("TextLabel")
	sliderText.Size = UDim2.new(1, 0, 1, 0)
	sliderText.BackgroundTransparency = 1
	sliderText.Text = Settings.WaitTimeout .. "/120"
	sliderText.TextColor3 = Color3.fromRGB(230, 230, 235)
	sliderText.Font = Enum.Font.Gotham
	sliderText.TextSize = 11
	sliderText.Parent = sliderBg

	sliderBg.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local conn
			local function update()
				local mouse = Players.LocalPlayer:GetMouse()
				local rel = math.clamp((mouse.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
				Settings.WaitTimeout = math.max(5, math.floor(rel * 120))
				sliderFill.Size = UDim2.new(Settings.WaitTimeout / 120, 0, 1, 0)
				sliderText.Text = Settings.WaitTimeout .. "/120"
			end
			update()
			conn = game:GetService("UserInputService").InputChanged:Connect(function(inp)
				if inp.UserInputType == Enum.UserInputType.MouseMovement then update() end
			end)
			game:GetService("UserInputService").InputEnded:Connect(function(inp)
				if inp.UserInputType == Enum.UserInputType.MouseButton1 and conn then
					conn:Disconnect()
				end
			end)
		end
	end)

	local hostLab = Instance.new("TextLabel")
	hostLab.Size = UDim2.new(1, -24, 0, 18)
	hostLab.Position = UDim2.new(0, 12, 0, y)
	hostLab.BackgroundTransparency = 1
	hostLab.Text = "Host Username"
	hostLab.TextXAlignment = Enum.TextXAlignment.Left
	hostLab.TextColor3 = Color3.fromRGB(200, 200, 210)
	hostLab.Font = Enum.Font.Gotham
	hostLab.TextSize = 13
	hostLab.Parent = Content
	y += 20

	local HostBox = Instance.new("TextBox")
	HostBox.Size = UDim2.new(1, -24, 0, 24)
	HostBox.Position = UDim2.new(0, 12, 0, y)
	HostBox.BackgroundColor3 = Color3.fromRGB(32, 32, 36)
	HostBox.BorderSizePixel = 0
	HostBox.Text = Settings.HostName
	HostBox.PlaceholderText = "host username"
	HostBox.TextColor3 = Color3.fromRGB(230, 230, 235)
	HostBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 130)
	HostBox.Font = Enum.Font.Gotham
	HostBox.TextSize = 12
	HostBox.ClearTextOnFocus = false
	HostBox.Parent = Content
	Instance.new("UICorner", HostBox).CornerRadius = UDim.new(0, 4)
	y += 30

	local memLab = Instance.new("TextLabel")
	memLab.Size = UDim2.new(1, -24, 0, 18)
	memLab.Position = UDim2.new(0, 12, 0, y)
	memLab.BackgroundTransparency = 1
	memLab.Text = "Member Usernames"
	memLab.TextXAlignment = Enum.TextXAlignment.Left
	memLab.TextColor3 = Color3.fromRGB(200, 200, 210)
	memLab.Font = Enum.Font.Gotham
	memLab.TextSize = 13
	memLab.Parent = Content
	y += 20

	local MembersBox = Instance.new("TextBox")
	MembersBox.Size = UDim2.new(1, -24, 0, 24)
	MembersBox.Position = UDim2.new(0, 12, 0, y)
	MembersBox.BackgroundColor3 = Color3.fromRGB(32, 32, 36)
	MembersBox.BorderSizePixel = 0
	MembersBox.Text = table.concat(Settings.RequiredPlayers, ", ")
	MembersBox.PlaceholderText = "alt1, alt2 (optional)"
	MembersBox.TextColor3 = Color3.fromRGB(230, 230, 235)
	MembersBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 130)
	MembersBox.Font = Enum.Font.Gotham
	MembersBox.TextSize = 12
	MembersBox.ClearTextOnFocus = false
	MembersBox.Parent = Content
	Instance.new("UICorner", MembersBox).CornerRadius = UDim.new(0, 4)
	y += 30

	local getAutoAccept = addToggle("Auto Accept Join Requests", Settings.AutoAccept)

	local function addButton(text)
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(1, -24, 0, 26)
		b.Position = UDim2.new(0, 12, 0, y)
		b.BackgroundColor3 = Color3.fromRGB(36, 36, 42)
		b.BorderSizePixel = 0
		b.Text = text
		b.TextColor3 = Color3.fromRGB(210, 210, 220)
		b.Font = Enum.Font.Gotham
		b.TextSize = 12
		b.Parent = Content
		Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
		y += 30
		return b
	end

	local RefreshBtn = addButton("Refresh Server Requirements")
	local ReturnBtn = addButton("Return To Lobby Now")

	local Footer = Instance.new("TextLabel")
	Footer.Size = UDim2.new(1, 0, 0, 18)
	Footer.Position = UDim2.new(0, 0, 1, -20)
	Footer.BackgroundTransparency = 1
	Footer.Text = "created by the one and only. Kuya"
	Footer.TextColor3 = Color3.fromRGB(120, 120, 130)
	Footer.Font = Enum.Font.Gotham
	Footer.TextSize = 11
	Footer.Parent = Window

	local function syncSettings()
		Settings.HostName = HostBox.Text:gsub("%s+", "")
		Settings.RequiredPlayers = parseMembers(MembersBox.Text)
		Settings.AutoBest = getAutoBest()
		Settings.Hardcore = getHardcore()
		Settings.Private = getPrivate()
		Settings.WaitForMembers = getWaitMembers()
		Settings.AutoAccept = getAutoAccept()
	end

	local function refreshStatus()
		local dungeon = getCurrentDungeon()
		local isHost = LP.Name:lower() == Settings.HostName:lower()
		AccLabel.Text = "Account: " .. LP.Name
		StateLabel.Text = "State: " .. State
		BestLabel.Text = "Best for: " .. dungeon.name .. " " .. dungeon.difficulty
		LevelLabel.Text = "Your Lvl: " .. tostring(getPlayerLevel())
		ModeLabel.Text = isHost and "Role: HOST" or ("Role: JOIN " .. Settings.HostName)
	end

	RefreshBtn.MouseButton1Click:Connect(function()
		syncSettings()
		refreshStatus()
		print("[Manager] Refreshed. Best dungeon:", getCurrentDungeon().name, getCurrentDungeon().difficulty)
	end)

	ReturnBtn.MouseButton1Click:Connect(function()
		returnToLobby()
	end)

	task.spawn(function()
		while ScreenGui.Parent do
			syncSettings()
			refreshStatus()
			task.wait(1)
		end
	end)

	task.spawn(function()
		while ScreenGui.Parent do
			if Settings.AutoAccept then
				acceptJoinRequests()
			end
			task.wait(2)
		end
	end)

	task.spawn(function()
		task.wait(4)
		while ScreenGui.Parent and running do
			syncSettings()
			local isHost = LP.Name:lower() == Settings.HostName:lower()
			if isHost then
				local games = workspace:FindFirstChild("games")
				if games and games:FindFirstChild("inLobby") then
					State = "Creating"
					local created = createLobby()
					if created then
						if Settings.WaitForMembers and #Settings.RequiredPlayers > 0 then
							State = "Waiting"
							local waited = 0
							while not allRequiredPlayersJoined() and waited < Settings.WaitTimeout and running do
								task.wait(1)
								waited += 1
							end
						end
						if (not Settings.WaitForMembers) or allRequiredPlayersJoined() then
							State = "Starting"
							task.wait(Settings.CreateDelay)
							startDungeon()
							State = "InDungeon"
						else
							State = "Timeout"
						end
					end
				end
			else
				State = "Joining"
				tryJoinHost()
			end
			task.wait(8)
		end
	end)

	print("[DQ AutoProgress] Manager GUI loaded")
end)
