
local oldTeamInitialize = Team.Initialize

function Team:Initialize(recipient)
    oldTeamInitialize(self, teamName, teamNumber)
    self.squads = {};
	#self.squads = #kSquadType;
end

local oldAddPlayer = Team.AddPlayer;

function Team:AddPlayer()
	oldAddPlayer(self);
	self.squads[kSquadType.Invalid]
end
