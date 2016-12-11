Script.Load("lua/squads/SquadsMemberMixin.lua")
local oldPlayerOnCreate = Player.OnCreate

function Player:OnCreate()
	oldPlayerOnCreate(self)
	InitMixin(self, SquadsMemberMixin)
end


local oldPlayerOnJoinTeam = Player.OnJoinTeam

-- only called on the server
function Player:OnJoinTeam()
	if self:GetIsOnPlayingTeam() then
		Server.SendNetworkMessage(self:GetClient(), "ShowSquadSelect", { }, true)
	end
	return oldPlayerOnJoinTeam(self)
end
