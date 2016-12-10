SquadsMemberMixin = CreateMixin(SquadsMemberMixin)
SquadsMemberMixin.type = "SquadsMember"
SquadsMemberMixin.networkVars =
{
    squadNumber = string.format("integer (-1 to %d)", kMaxSquadsMembersPerSquad)
}

function SquadsMemberMixin:__initmixin()
    self.squadNumber = kSquadInvalid
end


if Client then
    function SquadsMemberMixin:OnGetIsVisible(visibleTable, viewerTeamNumber)
        local player = Client.GetLocalPlayer()
        if player and player:isa("Commander") and viewerTeamNumber == GetEnemyTeamNumber(self:GetTeamNumber()) and HasMixin(self, "LOS") and not self:GetIsSighted() then
            visibleTable.Visible = false
        end
    end
end

local kTeamIndexToType = { }
kTeamIndexToType[kTeamInvalid] = kNeutralTeamType
kTeamIndexToType[kTeamReadyRoom] = kNeutralTeamType
kTeamIndexToType[kTeam1Index] = kTeam1Type
kTeamIndexToType[kTeam2Index] = kTeam2Type
kTeamIndexToType[kSpectatorIndex] = kNeutralTeamType

function SquadsMemberMixin:GetTeamType()
    return kTeamIndexToType[self.teamNumber]
end


function SquadsMemberMixin:GetTeamNumber()
    return self.teamNumber
end


function SquadsMemberMixin:SetTeamNumber(teamNumber)
    self.teamNumber = teamNumber
    if self.OnTeamChange then
        self:OnTeamChange()
    end
end


function SquadsMemberMixin:OnInitialized()
    local teamNumber = GetAndCheckValue(self.teamNumber, 0, 3, "teamNumber", 0, true)
    self:SetTeamNumber(teamNumber)
end


function SquadsMemberMixin:GetTeam()
    assert(Server)
    if not GetHasGameRules() then
        return nil
    end
    return GetGamerules():GetTeam(self:GetTeamNumber())
end



function SquadsMemberMixin:OnOwnerChanged(oldOwner, newOwner)
    if newOwner and HasMixin(newOwner, "SquadsMember") then
        self:SetOwner(nil)
    end
end
