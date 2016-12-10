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

local oldReset = Team.Reset;

function Team:Reset()
	oldReset();
	self.squads = {};
	for i = 1, #kSquadType do
		tins(self.squads, setmetatable({}, meta));
	end
end

local function checkPlayers(self)
	local squads = self.squads;
	for i = 1, #squads do
		local squad = squads[i];
		for i = 1, #squad do
			local player = squad[i];
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
