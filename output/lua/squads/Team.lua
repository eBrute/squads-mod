Script.Load("lua/Team.lua");
Script.Load("lua/Globals.lua");
Script.Load("lua/Table.lua");

local tins = table.insert;
local trmv = table.removevalue;

local oldTeamInitialize = Team.Initialize

local meta = {
	__mode = "v";
};

function Team:Initialize(recipient)
    oldTeamInitialize(self, teamName, teamNumber);
    self.squads = {};
	for i = 1, #kSquadType do
		tins(self.squads, setmetatable({}, meta));
	end
end

local oldAddPlayer = Team.AddPlayer;

function Team:AddPlayer(player)
	oldAddPlayer(self, player);
	tins(self.squads[kSquadType.Invalid], player);
	player.squadNumber = kSquadType.Invalid;
end

local oldRemovePlayer = Team.RemovePlayer;

function Team:RemovePlayer(player)
	oldRemovePlayer(self, player);
	local squad = player.squadNumber;
	trmv(self.squads[squad], player);
	player.squadNumber = kSquadType.Invalid;
end
