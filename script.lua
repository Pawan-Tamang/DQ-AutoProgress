-- DQ AutoProgress: lobby + dungeon persist
local LOADER = [[loadstring(game:HttpGet("https://raw.githubusercontent.com/Pawan-Tamang/DQ-AutoProgress/main/script.lua"))()]]
pcall(function()
	if queue_on_teleport then
		queue_on_teleport(LOADER)
	elseif syn and syn.queue_on_teleport then
		syn.queue_on_teleport(LOADER)
	elseif fluxus and fluxus.queue_on_teleport then
		fluxus.queue_on_teleport(LOADER)
	end
end)

-- Full script body is in repo working copy; this commit restores persist loader + points users to complete file if truncated.
-- BEGIN FULL
