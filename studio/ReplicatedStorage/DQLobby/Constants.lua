local Constants = {}

Constants.STATES = {
	IDLE = "IDLE",
	CHECK_CONFIGURATION = "CHECK_CONFIGURATION",
	CHECK_LOBBY = "CHECK_LOBBY",
	CREATE_OR_JOIN_LOBBY = "CREATE_OR_JOIN_LOBBY",
	WAIT_FOR_MEMBERS = "WAIT_FOR_MEMBERS",
	VERIFY_MEMBERS = "VERIFY_MEMBERS",
	WAIT_FOR_READY = "WAIT_FOR_READY",
	START_DUNGEON = "START_DUNGEON",
	MONITOR_DUNGEON = "MONITOR_DUNGEON",
	DUNGEON_COMPLETE = "DUNGEON_COMPLETE",
	RETURN_TO_LOBBY = "RETURN_TO_LOBBY",
	ERROR = "ERROR",
	STOPPED = "STOPPED",
}

Constants.MEMBER_STATES = {
	Offline = "Offline",
	Joining = "Joining",
	InLobby = "InLobby",
	Ready = "Ready",
	RunningDungeon = "RunningDungeon",
	Completed = "Completed",
	Rejoining = "Rejoining",
	Failed = "Failed",
}

Constants.DUNGEONS = {
	{ name = "Desert Temple", minLevel = 1, difficulty = "Easy" },
	{ name = "Desert Temple", minLevel = 6, difficulty = "Medium" },
	{ name = "Desert Temple", minLevel = 12, difficulty = "Hard" },
	{ name = "Desert Temple", minLevel = 20, difficulty = "Insane" },
	{ name = "Desert Temple", minLevel = 27, difficulty = "Nightmare" },
	{ name = "Winter Outpost", minLevel = 30, difficulty = "Insane" },
	{ name = "Winter Outpost", minLevel = 55, difficulty = "Nightmare" },
	{ name = "Pirate Island", minLevel = 60, difficulty = "Insane" },
	{ name = "Pirate Island", minLevel = 65, difficulty = "Nightmare" },
	{ name = "King's Castle", minLevel = 70, difficulty = "Insane" },
	{ name = "King's Castle", minLevel = 75, difficulty = "Nightmare" },
	{ name = "The Underworld", minLevel = 80, difficulty = "Insane" },
	{ name = "The Underworld", minLevel = 85, difficulty = "Nightmare" },
	{ name = "Samurai Palace", minLevel = 90, difficulty = "Insane" },
	{ name = "Samurai Palace", minLevel = 110, difficulty = "Nightmare" },
	{ name = "Northern Lands", minLevel = 180, difficulty = "Insane" },
	{ name = "Northern Lands", minLevel = 185, difficulty = "Nightmare" },
}

Constants.REMOTE_NAMES = {
	CreateLobby = "createLobby",
	JoinDungeon = "joinDungeon",
	StartDungeon = "startDungeon",
	LeaveDungeon = "leaveDungeon",
	AcceptJoin = "acceptJoinRequest",
}

return Constants
