Script.Load("lua/squads/SquadsMemberMixin.lua");
local old = Marine.OnInitialized;

function Marine:OnInitialized()
	old();
	InitMixin(self, SquadsMemberMixin);
	error("fak");
	Log("ADJWIXU");
end
