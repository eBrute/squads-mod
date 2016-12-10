Script.Load("lua/squads/SquadsMemberMixin.lua")
local oldPlayerOnCreate = Player.OnCreate

function Player:OnCreate()
	oldPlayerOnCreate(self)
	InitMixin(self, SquadsMemberMixin)
end
