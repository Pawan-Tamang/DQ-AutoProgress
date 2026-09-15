-- ====================== CONFIG ======================
local HOST_NAME = "kurokazahood"
local CHECK_INTERVAL = 2
local CREATE_DELAY = 3
local PRIVATE = false

local REQUIRED_PLAYERS = {
	"royaldancersss",
	-- Add more alts here later
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
-- ====================================================

if not game:IsLoaded() then
	game.Loaded:Wait()
end
task.wait(2)

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer or Players.PlayerAdded:Wait()

local isHost = (LP.Name:lower() == HOST_NAME:lower())

local function getRemotes()
	local ok, remotes = pcall(function()
		return RS:WaitForChild("remotes", 10)
	end)
	return ok and remotes or nil
end

local function getPlayerLevel()
	local leaderstats = LP:FindFirstChild("leaderstats")
	if leaderstats and leaderstats:FindFirstChild("Level") then
		return leaderstats.Level.Value
	end
	return 1
end

local function getCurrentDungeon()
	local level = getPlayerLevel()
	local current = DUNGEON_PROGRESSION[1]

	for _, dungeon in ipairs(DUNGEON_PROGRESSION) do
		if level >= dungeon.minLevel then
			current = dungeon
		else
			break
		end
	end
	return current
end

local function createLobby()
	local remotes = getRemotes()
	if not remotes then
		warn("[Host] Could not find remotes")
		return false
	end

	local createRemote = remotes:FindFirstChild("createLobby")
	if not createRemote then
		warn("[Host] createLobby remote not found")
		return false
	end

	local dungeon = getCurrentDungeon()
	print(string.format(
		"[Host] Creating: %s | %s | Hardcore: %s | Level: %d",
		dungeon.name,
		dungeon.difficulty,
		tostring(dungeon.hardcore),
		getPlayerLevel()
	))

	local success, err = pcall(function()
		createRemote:InvokeServer(
			dungeon.name,
			dungeon.difficulty,
			0,
			dungeon.hardcore,
			PRIVATE,
			false
		)
	end)

	if not success then
		warn("[Host] Failed to create lobby:", err)
		return false
	end

	return true
end

local function startDungeon()
	local remotes = getRemotes()
	if not remotes then return end

	local startRemote = remotes:FindFirstChild("startDungeon")
	if startRemote then
		pcall(function()
			startRemote:FireServer()
		end)
		print("[Host] Started dungeon")
	end
end

local function allRequiredPlayersJoined()
	for _, requiredName in ipairs(REQUIRED_PLAYERS) do
		local found = false
		local requiredLower = requiredName:lower()

		for _, player in ipairs(Players:GetPlayers()) do
			if player.Name:lower() == requiredLower then
				found = true
				break
			end
		end

		if not found then
			return false
		end
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

	local target = HOST_NAME:lower()

	for _, lobby in ipairs(inLobby:GetChildren()) do
		if lobby.Name:lower() == target then
			local success = pcall(function()
				joinRemote:InvokeServer(lobby.Name)
			end)
			if success then
				print("[Joiner] Joined", HOST_NAME)
				return true
			end
		end
	end
	return false
end

-- ====================== MAIN ======================

if isHost then
	print("[AutoProgress] Running as HOST:", LP.Name)
	print("[Host] Waiting for required players:", table.concat(REQUIRED_PLAYERS, ", "))

	task.spawn(function()
		while true do
			local games = workspace:FindFirstChild("games")
			if games and games:FindFirstChild("inLobby") then
				local created = createLobby()
				if created then
					print("[Host] Lobby created. Waiting for required players...")

					local waited = 0
					while not allRequiredPlayersJoined() and waited < 40 do
						task.wait(1)
						waited += 1
						if waited % 5 == 0 then
							print("[Host] Still waiting... (" .. waited .. "s)")
						end
					end

					if allRequiredPlayersJoined() then
						print("[Host] Required player found! Starting dungeon...")
						task.wait(2)
						startDungeon()
					else
						warn("[Host] Timed out waiting for required players.")
					end
				end
			end
			task.wait(8)
		end
	end)
else
	print("[AutoProgress] Running as JOINER → Looking for:", HOST_NAME)

	task.spawn(function()
		while true do
			tryJoinHost()
			task.wait(CHECK_INTERVAL)
		end
	end)
end

print("Script loaded | Host mode:", isHost)
