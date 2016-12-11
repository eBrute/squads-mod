class 'Squad'

function Squad:OnCreate()
    Print("SQUAD INIT")
end

function Squad:Initialize(teamNumber, squadNumber)
    self.teamNumber = teamNumber
    self.squadNumber = squadNumber
    self.squadName = kSquadNames[squadNumber]
    self.playerIds = {}
end

function Squad:AddPlayer(player)
    table.insertunique(self.playerIds, player:GetId())
    player.squadNumber = self.squadNumber
end

function Squad:RemovePlayer(player)
    table.removevalue(self.playerIds, player:GetId())
    player.squadNumber = kSquadType.Invalid
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
    self.playerIds = {}
end
