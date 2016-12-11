Script.Load("lua/squads/Squad.lua")

local oldMarineTeamInitialize = MarineTeam.Initialize

function MarineTeam:Initialize(teamName, teamNumber)
	oldMarineTeamInitialize(self, teamName, teamNumber)
	for squadNumber = 1, #kSquadType do
		self.squads[squadNumber] = Squad()
		self.squads[squadNumber]:Initialize(teamNumber, squadNumber)
	end
end
