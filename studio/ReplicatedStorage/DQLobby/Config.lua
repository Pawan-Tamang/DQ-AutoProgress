-- Shared default configuration. Server owns the live copy.

local Config = {
	Enabled = false,
	HostUserId = 0,
	Dungeon = {
		Name = "Desert Temple",
		Difficulty = "Hard",
		Hardcore = true,
		PrivateLobby = false,
		AutoBest = true,
		MinParty = 1,
		MaxParty = 4,
	},
	Members = {},
	Automation = {
		AutoJoin = true,
		AutoRejoin = true,
		AutoAcceptAuthorizedRequests = true,
		AutoStart = true,
		AutoReturnToLobby = true,
		AutoRetry = true,
		MaxRetries = 3,
	},
	Timeouts = {
		MemberJoin = 120,
		LobbyJoin = 30,
		DungeonStart = 30,
		DungeonCompletion = 1800,
		Step = 15,
	},
}

return Config
