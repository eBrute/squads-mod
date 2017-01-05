Script.Load("lua/Globals.lua")
Script.Load("lua/squads/Squad.lua")

SquadTeamMixin = {}
SquadTeamMixin.type = "SquadTeam"

function SquadTeamMixin:__initmixin()
    self.squads = {}
    Log("Initialize SquadTeam")
    Log("__mixindata: %s", self.__mixindata)
	for squadNumber = 1, #kSquadType do
		self.squads[squadNumber] = Squad()
		self.squads[squadNumber]:Initialize(self.__mixindata.teamNumber, squadNumber)
	end
end


function SquadTeamMixin:GetSquad(squadNumber)
    return self.squads[squadNumber]
end


function SquadTeamMixin:AddPlayerToSquadTeam(player)
    self:AddPlayerToSquad(player, kSquadType.Unassigned)
end


function SquadTeamMixin:RemovePlayerFromSquadTeamById(playerId)
    local player = Shared.GetEntity(playerId)
    if player and player:isa("Player") then
        self:RemovePlayerFromSquadTeam(player)
    end
end


function SquadTeamMixin:RemovePlayerFromSquadTeam(player)
    if player and HasMixin(player, "SquadMember") then
        local squadNumber = player:GetSquadNumber()
        self:RemovePlayerFromSquad(player, squadNumber)
    end
end


function SquadTeamMixin:AddPlayerToSquad(player, squadNumber)
    self.squads[squadNumber]:AddPlayer(player)
end


function SquadTeamMixin:RemovePlayerFromSquad(player, squadNumber)
    self.squads[squadNumber]:RemovePlayer(player)
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
