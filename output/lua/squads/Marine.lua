Script.Load("lua/squads/SquadsMemberMixin.lua");
local old = Marine.OnInitialized;

function Marine:OnInitialized()
	old(self);
	InitMixin(self, SquadsMemberMixin);
end
