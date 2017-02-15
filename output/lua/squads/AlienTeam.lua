-- Hook to make AlienTeam a SquadTeam

Script.Load("lua/squads/SquadTeamMixin.lua")

local oldAlienTeamInitialize = AlienTeam.Initialize

function AlienTeam:Initialize(teamName, teamNumber)
	oldAlienTeamInitialize(self, teamName, teamNumber)
	if kSquadTeams[kTeam2Index] then
		InitMixin(self, SquadTeamMixin, {teamName = teamName, teamNumber = teamNumber})
	end
end
