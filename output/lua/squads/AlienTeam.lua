Script.Load("lua/squads/Squad.lua")

local oldAlienTeamInitialize = AlienTeam.Initialize

function AlienTeam:Initialize(teamName, teamNumber)
	oldAlienTeamInitialize(self, teamName, teamNumber)
	for squadNumber = 1, #kSquadType do
		self.squads[squadNumber] = Squad()
		self.squads[squadNumber]:Initialize(teamNumber, squadNumber)
	end
end
