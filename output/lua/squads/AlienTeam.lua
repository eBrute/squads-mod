Script.Load("lua/squads/SquadTeamMixin.lua")

local oldAlienTeamInitialize = AlienTeam.Initialize

function AlienTeam:Initialize(teamName, teamNumber)
	oldAlienTeamInitialize(self, teamName, teamNumber)
	InitMixin(self, SquadTeamMixin, {teamName = teamName, teamNumber = teamNumber})
end
