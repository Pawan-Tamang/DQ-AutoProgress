-- ====================== Dungeon Quest AutoProgress ======================
-- GUI Version + Auto Start

if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(1.5)

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- ====================== SETTINGS ======================
local Settings = {
	HostName = "kurokazahood",
	RequiredPlayers = {"royaldancersss"},
	Hardcore = true,
	Private = false,
	WaitTimeout = 40,
	CreateDelay = 2,
	CheckInterval = 2,
}

local DUNGEON_PROGRESSION = {
	{name = "Desert Temple",   minLevel = 1,   difficulty = "Easy",      hardcore = true},
	{name = "Desert Temple",   minLevel = 6,   difficulty = "Medium",    hardcore = true},
	{name = "Desert Temple",   minLevel = 12,  difficulty = "Hard",      hardcore = true},
	{name = "Desert Temple",   minLevel = 20,  difficulty = "Insane",    hardcore = true},
	{name = "Desert Temple",   minLevel = 27,  difficulty = "Nightmare", hardcore = true},
	{name = "Winter Outpost",  minLevel = 30,  difficulty = "Insane",    hardcore = true},
	{name = "Winter Outpost",  minLevel = 55,  difficulty = "Nightmare", hardcore = true},
	{name = "Pirate Island",   minLevel = 60,  difficulty = "Insane",    hardcore = true},
	{name = "Pirate Island",   minLevel = 65,  difficulty = "Nightmare", hardcore = true},
	{name = "King's Castle",   minLevel = 70,  difficulty = "Insane",    hardcore = true},
	{name = "King's Castle",   minLevel = 75,  difficulty = "Nightmare", hardcore = true},
	{name = "The Underworld",  minLevel = 80,  difficulty = "Insane",    hardcore = true},
	{name = "The Underworld",  minLevel = 85,  difficulty = "Nightmare", hardcore = true},
	{name = "Samurai Palace",  minLevel = 90,  difficulty = "Insane",    hardcore = true},
	{name = "Samurai Palace",  minLevel = 110, difficulty = "Nightmare", hardcore = true},
	{name = "Northern Lands",  minLevel = 180, difficulty = "Insane",    hardcore = true},
	{name = "Northern Lands",  minLevel = 185, difficulty = "Nightmare", hardcore = true},
}

-- ====================== HELPERS ======================
local function getRemotes()
	local ok, remotes = pcall(function() return RS:WaitForChild("remotes", 8) end)
	return ok and remotes or nil
end

local function getPlayerLevel()
	local ls = LP:FindFirstChild("leaderstats")
	if ls and ls:FindFirstChild("Level") then return ls.Level.Value end
	return 1
end

local function getCurrentDungeon()
	local level = getPlayerLevel()
	local current = DUNGEON_PROGRESSION[1]
	for _, d in ipairs(DUNGEON_PROGRESSION) do
		if level >= d.minLevel then current = d else break end
	end
	return current
end

local function createLobby()
	local remotes = getRemotes()
	if not remotes then return false end
	local createRemote = remotes:FindFirstChild("createLobby")
	if not createRemote then return false end

	local dungeon = getCurrentDungeon()
	print(string.format("[Host] Creating: %s | %s | Hardcore: %s | Level: %d",
		dungeon.name, dungeon.difficulty, tostring(Settings.Hardcore), getPlayerLevel()))

	local success = pcall(function()
		createRemote:InvokeServer(dungeon.name, dungeon.difficulty, 0, Settings.Hardcore, Settings.Private, false)
	end)
	return success
end

local function startDungeon()
	local remotes = getRemotes()
	if not remotes then return end
	local startRemote = remotes:FindFirstChild("startDungeon")
	if startRemote then
		pcall(function() startRemote:FireServer() end)
		print("[Host] Started dungeon")
	end
end

local function allRequiredPlayersJoined()
	for _, name in ipairs(Settings.RequiredPlayers) do
		local found = false
		local lower = name:lower()
		for _, p in ipairs(Players:GetPlayers()) do
			if p.Name:lower() == lower then found = true break end
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
			local ok = pcall(function() joinRemote:InvokeServer(lobby.Name) end)
			if ok then
				print("[Joiner] Joined", Settings.HostName)
				return true
			end
		end
	end
	return false
end

-- ====================== GUI ======================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DQAutoProgress"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LP:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 320, 0, 400)
Main.Position = UDim2.new(0.5, -160, 0.5, -200)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 36)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
Title.BorderSizePixel = 0
Title.Text = "DQ AutoProgress"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = Main

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

local function createLabel(text, y)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -30, 0, 20)
	label.Position = UDim2.new(0, 15, 0, y)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(200, 200, 210)
	label.Font = Enum.Font.Gotham
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = Main
	return label
end

local function createTextBox(placeholder, y, default)
	local box = Instance.new("TextBox")
	box.Size = UDim2.new(1, -30, 0, 28)
	box.Position = UDim2.new(0, 15, 0, y)
	box.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
	box.BorderSizePixel = 0
	box.Text = default or ""
	box.PlaceholderText = placeholder
	box.TextColor3 = Color3.fromRGB(255, 255, 255)
	box.PlaceholderColor3 = Color3.fromRGB(120, 120, 130)
	box.Font = Enum.Font.Gotham
	box.TextSize = 13
	box.ClearTextOnFocus = false
	box.Parent = Main

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = box
	return box
end

local function createToggle(text, y, default)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -30, 0, 28)
	frame.Position = UDim2.new(0, 15, 0, y)
	frame.BackgroundTransparency = 1
	frame.Parent = Main

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -50, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(200, 200, 210)
	label.Font = Enum.Font.Gotham
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	local toggle = Instance.new("TextButton")
	toggle.Size = UDim2.new(0, 40, 0, 22)
	toggle.Position = UDim2.new(1, -40, 0.5, -11)
	toggle.BackgroundColor3 = default and Color3.fromRGB(100, 70, 200) or Color3.fromRGB(60, 60, 70)
	toggle.BorderSizePixel = 0
	toggle.Text = ""
	toggle.Parent = frame

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = toggle

	local circle = Instance.new("Frame")
	circle.Size = UDim2.new(0, 16, 0, 16)
	circle.Position = default and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
	circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	circle.BorderSizePixel = 0
	circle.Parent = toggle

	local circleCorner = Instance.new("UICorner")
	circleCorner.CornerRadius = UDim.new(1, 0)
	circleCorner.Parent = circle

	local state = default
	toggle.MouseButton1Click:Connect(function()
		state = not state
		toggle.BackgroundColor3 = state and Color3.fromRGB(100, 70, 200) or Color3.fromRGB(60, 60, 70)
		circle.Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
	end)

	return function() return state end
end

createLabel("Host Username", 50)
local HostBox = createTextBox("Host username...", 72, Settings.HostName)

createLabel("Member Usernames (comma separated)", 110)
local MembersBox = createTextBox("alt1, alt2, alt3", 132, table.concat(Settings.RequiredPlayers, ", "))

local getHardcore = createToggle("Hardcore Lobby", 175, Settings.Hardcore)
local getPrivate = createToggle("Private Lobby", 210, Settings.Private)

local StartBtn = Instance.new("TextButton")
StartBtn.Size = UDim2.new(1, -30, 0, 36)
StartBtn.Position = UDim2.new(0, 15, 0, 255)
StartBtn.BackgroundColor3 = Color3.fromRGB(100, 70, 200)
StartBtn.BorderSizePixel = 0
StartBtn.Text = "Start Script"
StartBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StartBtn.Font = Enum.Font.GothamBold
StartBtn.TextSize = 14
StartBtn.Parent = Main

local StartCorner = Instance.new("UICorner")
StartCorner.CornerRadius = UDim.new(0, 8)
StartCorner.Parent = StartBtn

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -30, 0, 50)
StatusLabel.Position = UDim2.new(0, 15, 0, 300)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Auto-starting in 5 seconds...\n(You can still change settings)"
StatusLabel.TextColor3 = Color3.fromRGB(160, 160, 170)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 12
StatusLabel.TextWrapped = true
StatusLabel.Parent = Main

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -34, 0, 4)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 20
CloseBtn.Parent = Main

CloseBtn.MouseButton1Click:Connect(function()
	ScreenGui:Destroy()
end)

-- ====================== MAIN LOGIC ======================
local running = false

local function startScript()
	if running then return end
	running = true
	StartBtn.Text = "Running..."
	StartBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)

	-- Apply settings from GUI
	Settings.HostName = HostBox.Text:gsub("%s+", "")
	Settings.Hardcore = getHardcore()
	Settings.Private = getPrivate()

	local members = {}
	for name in string.gmatch(MembersBox.Text, "[^,%s]+") do
		table.insert(members, name)
	end
	Settings.RequiredPlayers = members

	local isHost = (LP.Name:lower() == Settings.HostName:lower())

	if isHost then
		StatusLabel.Text = "Running as HOST: " .. LP.Name
		print("[AutoProgress] Running as HOST:", LP.Name)

		task.spawn(function()
			while running do
				local games = workspace:FindFirstChild("games")
				if games and games:FindFirstChild("inLobby") then
					local created = createLobby()
					if created then
						StatusLabel.Text = "Lobby created. Waiting for members..."
						local waited = 0
						while not allRequiredPlayersJoined() and waited < Settings.WaitTimeout and running do
							task.wait(1)
							waited += 1
							if waited % 5 == 0 then
								StatusLabel.Text = "Waiting for members... (" .. waited .. "s)"
							end
						end

						if allRequiredPlayersJoined() then
							StatusLabel.Text = "Members found! Starting dungeon..."
							task.wait(Settings.CreateDelay)
							startDungeon()
						else
							StatusLabel.Text = "Timed out waiting for members."
						end
					end
				end
				task.wait(8)
			end
		end)
	else
		StatusLabel.Text = "Running as JOINER → " .. Settings.HostName
		print("[AutoProgress] Running as JOINER →", Settings.HostName)

		task.spawn(function()
			while running do
				tryJoinHost()
				task.wait(Settings.CheckInterval)
			end
		end)
	end
end

StartBtn.MouseButton1Click:Connect(startScript)

-- Auto-start after 5 seconds (for auto-execute)
task.spawn(function()
	for i = 5, 1, -1 do
		if running then return end
		StatusLabel.Text = "Auto-starting in " .. i .. " seconds...\n(You can still change settings)"
		task.wait(1)
	end
	if not running then
		startScript()
	end
end)

print("[DQ AutoProgress] GUI loaded. Auto-starts in 5 seconds.")
