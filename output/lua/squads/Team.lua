-- Hook into team to keep squads informed about changes in the team
-- handle different kinds of resets

Script.Load("lua/Table.lua")
Script.Load("lua/Globals.lua")

local gIsPlayerPreservingReset = false
local oldTeamReset = Team.Reset

function Team:Reset()
	if not gIsPlayerPreservingReset and HasMixin(self, "SquadTeam") then
		self:ResetSquads()
	end
	return oldTeamReset(self)
end


local oldResetPreservePlayers = Team.ResetPreservePlayers

function Team:ResetPreservePlayers(techPoint)
	gIsPlayerPreservingReset = true
	oldResetPreservePlayers(self, techPoint)
	gIsPlayerPreservingReset = false
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
			if HasMixin(self, "SquadTeam") then
				self:RemovePlayerById(playerId)
			end
        end
    end
end
