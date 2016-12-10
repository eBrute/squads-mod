function Team:Initialize(teamName, teamNumber)
end

local oldTeamInitialize = Team.Initialize

function Team:Initialize(recipient)
    oldTeamInitialize(self, teamName, teamNumber)
    self.squads = table.array(kMaxSquads)
    for i = 1, kMaxSquads do
        self.squads[i] = Squad:Initialize(kSquadType[i], i)
    end
end
