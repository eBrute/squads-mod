Script.Load("lua/Globals.lua")

SquadsMemberMixin = {}
SquadsMemberMixin.type = "SquadsMember"

function SquadsMemberMixin:__initmixin()
    self.squadNumber = kSquadType.Invalid
end

function SquadsMemberMixin:GetSquadNumber()
    return self.squadNumber
end

function SquadsMemberMixin:GetSquad()
	local team = self:GetTeam()
	local squad = self.squadNumber
	return team.squads[squad] or nil
end
