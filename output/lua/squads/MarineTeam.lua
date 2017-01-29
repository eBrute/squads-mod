-- Hook to make MarineTeam a SquadTeam

Script.Load("lua/squads/SquadTeamMixin.lua")

local oldMarineTeamInitialize = MarineTeam.Initialize

function MarineTeam:Initialize(teamName, teamNumber)
	oldMarineTeamInitialize(self, teamName, teamNumber)
	InitMixin(self, SquadTeamMixin, {teamName = teamName, teamNumber = teamNumber})
end
