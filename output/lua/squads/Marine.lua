local old = Marine.OnInitialized;

function Marine:OnInitialized()
	old();
	InitMixin(self, SquadsMemberMixin);
end
