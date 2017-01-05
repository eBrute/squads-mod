Script.Load("lua/Globals.lua")

SquadMemberMixin = {}
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
