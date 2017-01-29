-- a squadteam is a team that has several squads
-- the squadteam informs the squads about joining/leaving players
-- squadteam assigns the default squad

Script.Load("lua/Globals.lua")
Script.Load("lua/squads/Squad.lua")

SquadTeamMixin = CreateMixin(SquadTeamMixin)
SquadTeamMixin.type = "SquadTeam"

function SquadTeamMixin:__initmixin()
    self.squads = {}
	for squadNumber = 1, #kSquadType do
		self.squads[squadNumber] = Squad()
		self.squads[squadNumber]:Initialize(self.__mixindata.teamNumber, squadNumber)
	end
end


function SquadTeamMixin:GetSquad(squadNumber)
    if squadNumber ~= kSquadType.Invalid then
        return self.squads[squadNumber]
    end
end


-- NOTE on teamswitch, AddPlayer happens before RemovePlayer
function SquadTeamMixin:AddPlayer(player)
    if player and player:isa("Player") then
        self:AddPlayerToSquad(player, kSquadType.Unassigned)
    end
end


function SquadTeamMixin:RemovePlayer(player)
    if HasMixin(player, "SquadMember") then
        local squadNumber = player:GetSquadNumber()
        self:RemovePlayerFromSquad(player, squadNumber, true)
    end
end


function SquadTeamMixin:RemovePlayerById(playerId)
    for squadNumber = 1, #kSquadType do
        self.squads[squadNumber]:RemovePlayerById(playerId)
    end
end


function SquadTeamMixin:AddPlayerToSquad(player, squadNumber)
    if squadNumber ~= kSquadType.Invalid then
        return self.squads[squadNumber]:AddPlayer(player)
    end
    return false
end


function SquadTeamMixin:RemovePlayerFromSquad(player, squadNumber, notifyPlayer)
    if squadNumber ~= kSquadType.Invalid then
        self.squads[squadNumber]:RemovePlayer(player, notifyPlayer)
    end
end


function SquadTeamMixin:ResetSquads()
    for squadNumber = 1, #kSquadType do
		self.squads[squadNumber]:Reset()
	end
end


function SquadTeamMixin:DumpSquads()
    for squadNumber = 1, #kSquadType do
		self.squads[squadNumber]:Dump()
	end
end
