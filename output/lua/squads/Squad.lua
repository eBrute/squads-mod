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
        self:UpdateRallyPoint()
        self.nextUpdateTime = now + kUpdateIntervalMedium
    end
end


function Squad:UpdateRallyPoint()
    local now = Shared.GetTime()
    local eligibleSquadMembers = {}
    for _, playerId in ipairs(self.playerIds) do
        local player = Shared.GetEntity(playerId)
        if player and player:isa("Player") and HasMixin(player, "SquadMember")
        and not player:isa("Commander")
        and player.spawnLocationId and player.spawnTime
        then
            -- we dont want to unite with players that just spawned
            if player:GetLocationId() ~= player.spawnLocationId
            or now > player.spawnTime + 10 then
                table.insert(eligibleSquadMembers, player)
            end
        end
    end

    -- TODO find better method to identify clusters
    local squadCenterPoint = Vector(0,0,0)
    for i = 1, #eligibleSquadMembers do
        local player = eligibleSquadMembers[i]
        local origin = player:GetOrigin()
        squadCenterPoint = squadCenterPoint + origin
    end
    if #eligibleSquadMembers > 0 then
        squadCenterPoint = squadCenterPoint / #eligibleSquadMembers
    end

    -- find squad member closest to squad center
    local closestPlayer = nil
    local closestDistance = math.huge
    for i = 1, #eligibleSquadMembers do
        local player = eligibleSquadMembers[i]
        local origin = player:GetOrigin()
        local dist = (squadCenterPoint - origin):GetLengthSquared()
        if dist < closestDistance then
            closestPlayer = player
            closestDistance = dist
        end
    end

    local rallyPoint = closestPlayer and closestPlayer:GetOrigin() or Vector(0,0,0)
    local locationId =  closestPlayer and closestPlayer:GetLocationId() or -1
    -- only update when we want the rally point is in a new room or moved too far
    if locationId ~= self.rallyPointLocationId or (rallyPoint - self.rallyPoint):GetLengthSquared() > 5*5 then
        self:SetRallyPoint(rallyPoint, locationId)
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
