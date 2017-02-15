-- a squad member has a squad number assigned to him
-- the squad number and the team number together identify the squad
-- if the team is not a squadteam, the squad number shall be kSquadType.Invalid

Script.Load("lua/squads/Globals.lua")

SquadMemberMixin = CreateMixin(SquadMemberMixin)
SquadMemberMixin.type = "SquadMember"

SquadMemberMixin.networkVars = {
    squadNumber = "enum kSquadType",
    squadRallyPoint = "vector",
    squadRallyPointLocationId = "integer (-1 to 30)",
}


function SquadMemberMixin:__initmixin()
    if Server then
        self.squadNumber = kSquadType.Invalid
        self.squadRallyPoint = Vector(0,0,0)
        self.squadRallyPointLocationId = -1
    end
end


if Client then
    function SquadMemberMixin:OnSquadNumberChange(newSquadNumber)
        Log(" SquadMemberMixin:OnSquadNumberChange() to squad %s (self: %s) in %s", newSquadNumber, self.squadNumber, self)
    end
end


-- NOTE does not notify squad, use SwitchToSquad() instead, called on the server only
function SquadMemberMixin:SetSquadNumber(squadNumber)
    self.squadNumber = squadNumber
    self:UpdateMinimapBlip()
end


function SquadMemberMixin:GetSquadNumber()
    return self.squadNumber
end


function SquadMemberMixin:GetSquad()
    local team = self:GetTeam()
    if HasMixin(team, "SquadTeam") then
        return team:GetSquad(self.squadNumber)
    end
end


function SquadMemberMixin:SwitchToSquad(squadNumber)
    local team = self:GetTeam()
    if HasMixin(team, "SquadTeam") then
        local oldSquadNumber = self.squadNumber
        local success = team:AddPlayerToSquad(self, squadNumber)
        if success then
            team:RemovePlayerFromSquad(self, oldSquadNumber, false)
        end
        return success
    end
end


function SquadMemberMixin:OnSpawn()
    self.spawnTime = Shared.GetTime()
    self.spawnLocationId = self:GetLocationId()
end


function SquadMemberMixin:SetSquadRallyPoint(rallyPoint, locationId)
    -- Log("SquadMemberMixin:SetSquadRallyPoint %s > %s %s", self, rallyPoint, locationId)
    local location = GetLocationForPoint(rallyPoint)
    if location then
        Log("SquadMemberMixin:SetSquadRallyPoint in %s %s (%s)", locationId, location:GetName(), rallyPoint)
    end
    self.squadRallyPoint = rallyPoint or Vector(0,0,0)
    self.squadRallyPointLocationId = locationId or -1
end


function SquadMemberMixin:GetSquadRallyPoint()
    -- Log("SquadMemberMixin:GetSquadRallyPoint: %s > current squad target: %s %s", self, targetLocation, targetLocationId)
    return self.squadRallyPoint, self.squadRallyPointLocationId
end


function SquadMemberMixin:UpdateMinimapBlip()
    if HasMixin(self, "MapBlip") and self.mapBlipId and Shared.GetEntity(self.mapBlipId) then
        local mapBlip = Shared.GetEntity(self.mapBlipId)
        mapBlip.squadNumber = self.squadNumber
    end
end


if Server then
    function SquadMemberMixin:CopyPlayerDataFrom(oldPlayer)
        if not oldPlayer then return end

        local oldSquad = oldPlayer:GetSquad() -- this is the squad we were in
        if oldSquad then
            oldSquad:RemovePlayer(oldPlayer) -- oldPlayer is about to be destroyed, so remove him
        end

        if oldPlayer:GetTeamNumber() == self:GetTeamNumber() then
            -- change occured in the same team (i.e. marine -> exo), so carry over the squad to the new entity
            local newSquad = self:GetSquad() -- new player already has the default squad because NS2Gamerules:OnEntityCreate joined the team
            if newSquad then
                newSquad:RemovePlayer(self, true)  -- remove the new player from the default squad
            end
            if oldSquad then
                oldSquad:AddPlayer(self)
            end
        else
            local client = self:GetClient()
            if client then
                if client:GetIsVirtual() then
                    self:SwitchToSquad(kSquadBotDefault) -- default squad for bots
                else
                    Server.SendNetworkMessage(client, "SquadMemberJoinedTeam", {newTeam = self:GetTeamNumber()}, true)
                end
            end
        end
    end
end
