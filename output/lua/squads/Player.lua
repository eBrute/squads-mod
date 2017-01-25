Script.Load("lua/squads/SquadMemberMixin.lua")
local oldPlayerOnCreate = Player.OnCreate

function Player:OnCreate()
	oldPlayerOnCreate(self)
	InitMixin(self, SquadMemberMixin)
end
