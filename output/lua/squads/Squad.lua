Script.Load("lua/squads/Globals.lua")

class 'Squad'

-- the squad keeps track of the playerids belonging to the squads
-- it is in the responsibility of the squad to keep the players updated about changes in their squadnumber

function Squad:Initialize(teamNumber, squadNumber)
    self.teamNumber = teamNumber
    self.squadNumber = squadNumber
    self.squadName = kSquadNames[squadNumber]
    self.nextUpdateTime = 0
    self.playerIds = {}
    self.rallyPoint = Vector(0,0,0)
    self.rallyPointLocationId = -1
end


function Squad:AddPlayer(player)
    if #self.playerIds < kMaxSquadsMembersPerSquad or self.squadNumber == kSquadType.Unassigned then
        table.insertunique(self.playerIds, player:GetId())
        player:SetSquadNumber(self.squadNumber)
        player:SetSquadRallyPoint(self.rallyPoint, self.rallyPointLocationId)
        return true
    end
    return false
end


function Squad:RemovePlayer(player, notifyPlayer)
    table.removevalue(self.playerIds, player:GetId())
    if notifyPlayer then
        player:SetSquadNumber(kSquadType.Invalid)
    end
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


function Squad:OnUpdate(deltaTime)
    local now = Shared.GetTime()
    if now > self.nextUpdateTime then
        local rallyPoint = Vector(0,0,0)
        local locationId = -1
        for _, playerId in ipairs(self.playerIds) do
            local player = Shared.GetEntity(playerId)
            if player and player:isa("Player") and HasMixin(player, "SquadMember") then
                -- Log("Squad %s: player %s in %s", self.squadName, player, player.locationId)
                -- if player.locationId then Log("player is in %s", Shared.GetString(player.locationId)) end

                local techPoints = EntityListToTable(Shared.GetEntitiesWithClassname("TechPoint"))
                Shared.SortEntitiesByDistance(Vector(1,1,1), techPoints)
                rallyPoint = techPoints[1]:GetOrigin()
                locationId = techPoints[1].locationId
            end
        end

        if locationId ~= self.rallyPointLocationId then
            self:SetRallyPoint(rallyPoint, locationId)
        end
        self.nextUpdateTime = now + kUpdateIntervalMedium
    end
end


function Squad:SetRallyPoint(rallyPoint, locationId)
    self.rallyPoint = rallyPoint
    self.rallyPointLocationId = locationId
    for _, playerId in ipairs(self.playerIds) do
        local player = Shared.GetEntity(playerId)
        if player and player:isa("Player") and HasMixin(player, "SquadMember") then
            player:SetSquadRallyPoint(rallyPoint, locationId)
        end
    end
end


function Squad:Dump()
    Log("Squad #%s.%s: [%s] Players: %s", self.teamNumber, self.squadNumber, self.squadName, self.playerIds)
end
