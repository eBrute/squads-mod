Script.Load("lua/Globals.lua");
Script.Load("lua/Table.lua");

local tins = table.insert;
local trmv = table.removevalue;

local meta = {
	__mode = "v";
};

local oldTeamInitialize = Team.Initialize

function Team:Initialize(teamName, teamNumber)
    oldTeamInitialize(self, teamName, teamNumber);
    self.squads = {};
	for i = 0, #kSquadType do
		tins(self.squads, setmetatable({}, meta));
	end
end

local oldAddPlayer = Team.AddPlayer;

function Team:AddPlayer(player)
	if player and player:isa("Player") then
		tins(self.squads[kSquadType.Invalid], player);
		player.squadNumber = kSquadType.Invalid;
	end
	return oldAddPlayer(self, player);
end

local oldRemovePlayer = Team.RemovePlayer;

function Team:RemovePlayer(player)
	local squad = player.squadNumber;
	trmv(self.squads[squad], player);
	player.squadNumber = kSquadType.Invalid;
	return oldRemovePlayer(self, player);
end

local oldReset = Team.Reset;
function Team:Reset()
	oldReset(self);
	self.squads = {};
	for i = 0, #kSquadType do
		tins(self.squads, setmetatable({}, meta));
	end
end

local function checkPlayers(self)
	local squads = self.squads;
	for i = 0, #squads do
		local squad = squads[i];
		for j = 1, #squad do
			local player = squad[j];
			local id = player:GetId();
			local replayer = Shared.GetEntity(id);
			Log("Player: %s, Id: %s, Replayer: %s", player, id, replayer);
		end
	end
end

-- For every player on team, call functor(player)
function Team:ForEachPlayer(functor)

	local checkPlayers = false;

    for i, playerId in ipairs(self.playerIds) do

        local player = Shared.GetEntity(playerId)
        if player and player:isa("Player") then
            if functor(player, self.teamNumber) == false then
                break
            end
        else
            table.remove( self.playerIds, i )
			checkPlayers = true;
        end

    end

	if checkPlayers then
		checkPlayers(self);
	end

end
