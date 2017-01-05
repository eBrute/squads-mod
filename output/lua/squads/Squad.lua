class 'Squad'

-- the squad keeps track of the playerids belonging to the squads
-- it is in the responsibility of the squad to keep the players updated about changes in their squadnumber

function Squad:OnCreate()
    Print("SQUAD INIT") -- NOTE never called
end

function Squad:Initialize(teamNumber, squadNumber)
    self.teamNumber = teamNumber
    self.squadNumber = squadNumber
    self.squadName = kSquadNames[squadNumber]
    self.playerIds = {}
end

function Squad:AddPlayer(player)
    table.insertunique(self.playerIds, player:GetId())
    player:SetSquadNumber(self.squadNumber)
    Log("Player %s is now in Squad %s", player:GetId(), self.squadNumber)
end

function Squad:RemovePlayer(player)
    Log("Player %s removed from Squad %s", player:GetId(), self.squadNumber)
    table.removevalue(self.playerIds, player:GetId())
    player:SetSquadNumber(kSquadType.Invalid)
end

function Squad:RemovePlayerById(playerId)
    table.removevalue(self.playerIds, playerId)
end

function Squad:GetSize()
    return #self.playerIds
end

function Squad:GetName()
    return self.squadName
end

function Squad:GetNumber()
    return self.squadNumber
end

function Squad:Reset()
    for _, playerId in ipairs(self.playerIds) do
        local player = Shared.GetEntity(playerId)
        if player and player:isa("Player") and HasMixin(player, "SquadMember") then
            player:SetSquadNumber(kSquadType.Invalid)
        end
    end
    self.playerIds = {}
end

function Squad:Dump()
    Log("Squad #%s.%s: [%s] Players: %s", self.teamNumber, self.squadNumber, self.squadName, self.playerIds)
end
