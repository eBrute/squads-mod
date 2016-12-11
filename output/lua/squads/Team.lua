Script.Load("lua/Table.lua")
Script.Load("lua/Globals.lua")

local oldTeamInitialize = Team.Initialize

function Team:Initialize(teamName, teamNumber)
    oldTeamInitialize(self, teamName, teamNumber)
	self.squads = {}
end


local oldTeamAddPlayer = Team.AddPlayer

function Team:AddPlayer(player)
	if (self.teamNumber == kTeam1Index or self.teamNumber == kTeam2Index) and player and player:isa("Player") then
		Log("ADDPLAYER %s to team %s", player:GetId(), self.teamName)
		self.squads[kSquadType.Invalid]:AddPlayer(player)
	end
	return oldTeamAddPlayer(self, player)
end


local oldTeamRemovePlayer = Team.RemovePlayer

function Team:RemovePlayer(player)
	if (self.teamNumber == kTeam1Index or self.teamNumber == kTeam2Index) and player and player:isa("Player") then
		Log("REMOVEPLAYER %s from team %s", player:GetId(), self.teamName)
		local squad = player.squadNumber
		Log("player squad: %s", player.squadNumber)
		self.squads[squad]:RemovePlayer(player)
	end
	return oldTeamRemovePlayer(self, player)
end


local oldTeamReset = Team.Reset

function Team:Reset()
	for i = 1, #self.squads do
		self.squads[i]:Reset()
	end
	return oldTeamReset(self)
end


-- For every player on team, call functor(player)
function Team:ForEachPlayer(functor)

    for i, playerId in ipairs(self.playerIds) do

        local player = Shared.GetEntity(playerId)
        if player and player:isa("Player") then
            if functor(player, self.teamNumber) == false then
                break
            end
        else
            table.remove( self.playerIds, i )
			for s = 1, #self.squads do
				self.squads[s]:RemovePlayerById(playerId)
			end
        end
    end
end
