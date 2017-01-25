Script.Load("lua/Globals.lua")

local playerInfoNetworkVars =
{
    -- squadNumber = string.format("integer (0 to %d)", #kSquadType)
    squadNumber = "enum kSquadType"
}

local oldPlayerInfoEntity_UpdateScore = PlayerInfoEntity.UpdateScore
function PlayerInfoEntity:UpdateScore()
    if Server then

        local scorePlayer = Shared.GetEntity(self.playerId)

        if scorePlayer then

            self.squadNumber = 0
            if HasMixin(scorePlayer, "SquadMember") then
                self.squadNumber = scorePlayer:GetSquadNumber()
            end
            --Log("PlayerInfoEntity %s", self.squadNumber)
        end

    end
    return oldPlayerInfoEntity_UpdateScore(self)

end


Shared.LinkClassToMap('PlayerInfoEntity', nil, playerInfoNetworkVars)
