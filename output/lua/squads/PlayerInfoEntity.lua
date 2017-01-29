-- Hook to add the squadnumber to the PlayerInfoEntity
-- PlayerInfoEntity is created together with the player, player knows about his PlayerInfoEntity
-- PlayerInfoEntity is relevant even when player is not, and is used to sync properties of the player

Script.Load("lua/Globals.lua")

local playerInfoNetworkVars =
{
    squadNumber = "enum kSquadType"
}

local oldPlayerInfoEntity_UpdateScore = PlayerInfoEntity.UpdateScore
function PlayerInfoEntity:UpdateScore()
    if Server then

        local scorePlayer = Shared.GetEntity(self.playerId)

        if scorePlayer then

            self.squadNumber = kSquadType.Invalid
            if HasMixin(scorePlayer, "SquadMember") then
                self.squadNumber = scorePlayer:GetSquadNumber()
            end
        end

    end
    return oldPlayerInfoEntity_UpdateScore(self)

end


Shared.LinkClassToMap('PlayerInfoEntity', nil, playerInfoNetworkVars)
