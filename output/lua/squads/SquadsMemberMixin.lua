Script.Load("lua/Globals.lua");
local tins = table.insert;
local trmv = table.removevalue;

SquadsMemberMixin = {};
SquadsMemberMixin.type = "SquadsMember"

function SquadsMemberMixin:__initmixin()
    self.squadNumber = kSquadType.Invalid;
end

function SquadsMemberMixin:GetSquad()
    return self.squadNumber;
end

function SquadsMemberMixin:SetSquad(newsquad)
	local oldsquad = self.squadNumber;
	local team = self:GetTeam();
	trmv(team.squads[oldsquad], self);
	tins(team.squads[newsquad], self);
end
