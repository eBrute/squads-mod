Script.Load("lua/squads/SquadsMemberMixin.lua");
local old = Exo.OnInitialized;

function Exo:OnInitialized()
	old(self);
	InitMixin(self, SquadsMemberMixin);
end
