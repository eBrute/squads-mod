-- a squad member has a squad number assigned to him
-- the squad number and the team number together identify the squad
-- if the team is not a squadteam, the squad number shall be kSquadType.Invalid

Script.Load("lua/Globals.lua")

SquadMemberMixin = CreateMixin(SquadMemberMixin)
SquadMemberMixin.type = "SquadMember"

function SquadMemberMixin:__initmixin()
    self.squadNumber = kSquadType.Invalid
end


function SquadMemberMixin:SetSquadNumber(squadNumber)
    self.squadNumber = squadNumber
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
        team:RemovePlayerFromSquad(self, self.squadNumber)
        team:AddPlayerToSquad(self, squadNumber)
    end
end


function SquadMemberMixin:OnEntityChange(oldEntityId, newEntityId)
    if not Server then return end
    if not oldEntityId or not newEntityId then return end -- only interested in changes, not in creation/destruction (handled by team)

    local oldPlayer = Shared.GetEntity(oldEntityId)
    if not oldPlayer or not oldPlayer:isa("Player") then return end

    local oldSquad = oldPlayer:GetSquad() -- this is the squad we were in
    if oldSquad then
        oldSquad:RemovePlayer(oldPlayer) -- oldPlayer is about to be destroyed, so remove him
    end

    local newPlayer = Shared.GetEntity(newEntityId)
    if not newPlayer or not newPlayer:isa("Player") then return end
    if oldPlayer:GetTeamNumber() == newPlayer:GetTeamNumber() then
        -- change occured in the same team (i.e. marine -> exo), so carry over the squad to the new entity
        local newSquad = newPlayer:GetSquad() -- new player already has the default squad because NS2Gamerules:OnEntityCreate joined the team
        if newSquad then
            newSquad:RemovePlayer(newPlayer)  -- remove the new player from the default squad
        end
        oldSquad:AddPlayer(newPlayer)
    end
end
