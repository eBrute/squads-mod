Script.Load("lua/Globals.lua");

SquadsMemberMixin = {};
SquadsMemberMixin.type = "SquadsMember"
SquadsMemberMixin.networkVars =
{
    squadNumber = string.format("integer (0 to %d)", #kSquadType);
}

function SquadsMemberMixin:__initmixin()
    self.squadNumber = kSquadType.Invalid;
end

function SquadsMemberMixin:GetSquad()
    return self.squadNumber;
end

SquadsMemberMixin.SetSquad = Squad.RegisterPlayer;
