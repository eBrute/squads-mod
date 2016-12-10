Script.Load("lua/Globals.lua");
Script.Load("lua/Table.lua");
local tins = table.insert;
local trmv = table.removevalue;
local function warn(b, msg)
	if not b then
		Log("WARN: %s", msg);
		Log(debug.traceback());
	end
	return b;
end

Squad = {};

local squads = {
	[kMarineTeamType] = {[0] = {}}
};

for i = 1, #kSquadType do
	tins(squads[kMarineTeamType], {});
end

function Squad.RegisterPlayer(player, squad)
	local tid = player:GetTeamNumber();
	local old_squad = player:GetSquadNumber();
	warn(trmv(squads[tid][old_squad], player), "Player was not in a valid squad!");
	tins(squads[tid][squad], player);
end
